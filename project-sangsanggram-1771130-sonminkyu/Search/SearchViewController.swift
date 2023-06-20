//
//  SearchViewController.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/10.
//

import UIKit
import FirebaseAuth

class SearchViewController: UIViewController {
    // 만약 팔로우 버튼을 누르면 나의 팔로잉 목록에 추가되어야 한다.
    @IBOutlet weak var searchTableView: UITableView!
    var userGroup: UserGroup!
    var users: [User]!
    var myFollowingList: [String]!
    var uid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        uid = Auth.auth().currentUser?.uid

        searchTableView.dataSource = self
        userGroup = UserGroup(parentNotification: notification1)
        userGroup.queryData()
        
        MyUserFirebaseDatabase.shared.getFollowingList(uid: uid) { followingList in
            self.myFollowingList = followingList
            self.searchTableView.reloadData()
        }
    }
    
    private func notification1(user: User?, action: UserDbAction?) {
        self.searchTableView.reloadData()
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userGroup.getUsers().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SerachTableViewCell")!
        let users = userGroup.getUsers()
        let userName = users[indexPath.row].userName
        
        // 프로필 이미지 설정
        let profileImageUrl = users[indexPath.row].imageUrl
        let profileImageView = cell.contentView.subviews[0] as! UIImageView
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        downloadImage(imageView: profileImageView, urlStr: profileImageUrl)
        
        if let myFollowingList = myFollowingList {
            
        }
        (cell.contentView.subviews[1] as! UILabel).text = userName
        let button = cell.contentView.subviews[2] as! UIButton
        button.tag = indexPath.row
        button.addTarget(self, action: #selector(onTapFollowingButton), for: .touchUpInside)

        // uid가 내 myFollowingList에 존재하는지 확인
        let user = users[indexPath.row]
        if let myFollowingList = myFollowingList, myFollowingList.contains(user.uid) {
            // uid가 myFollowingList에 존재하면 버튼 속성을 업데이트한다
            button.layer.cornerRadius = 8.0
            button.setTitle("팔로잉", for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = .systemGray5
        } else {
            // uid가 myFollowingList 존재하지 않는다면 버튼을 속성을 원래대로 되돌린다
            button.layer.cornerRadius = 8.0
            button.setTitle("팔로우", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .systemBlue
        }

        return cell
    }
    
    // 팔로잉 버튼을 눌렀을 경우
    @objc func onTapFollowingButton(_ sender: UIButton) {
        let rowIndex = sender.tag
        let user = userGroup.getUsers()[rowIndex]
        let isFollowing = myFollowingList?.contains(user.uid) ?? false

        if isFollowing {
            // 이미 팔로잉 목록에 있을 경우 데이터베이스에서 해당 uid 팔로잉을 삭제한다
            MyUserFirebaseDatabase.shared.removeFromFollowing(with: uid, followingUid: user.uid)
        } else {
            // 만약 팔로잉하고 있지 않는다면 해당 uid를 팔로잉에 추가한다
            MyUserFirebaseDatabase.shared.addToFollowing(with: uid, followingUid: user.uid)
        }
        
        if var myFollowingList = myFollowingList {
            if isFollowing {
                myFollowingList.removeAll(where: { $0 == user.uid })
                sender.setTitle("팔로우", for: .normal)
                sender.setTitleColor(.white, for: .normal)
                sender.backgroundColor = .systemBlue
            } else {
                myFollowingList.append(user.uid)
                sender.setTitle("팔로잉", for: .normal)
                sender.setTitleColor(.black, for: .normal)
                sender.backgroundColor = .systemGray5
            }
            self.myFollowingList = myFollowingList
        }
    }


    
    func downloadImage(imageView: UIImageView, urlStr: String) {
        let url = URL(string: urlStr)!
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
        }.resume()
    }
}
