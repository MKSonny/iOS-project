//
//  LikesViewController.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/18.
//

import UIKit
import FirebaseAuth

class LikesViewController: UIViewController {
    // 만약 팔로우 버튼을 누르면 나의 팔로잉 목록에 추가되어야 한다.
    @IBOutlet weak var searchTableView: UITableView!
//    var userGroup: UserGroup!
//    var users: [User]!
    var myFollowingList: [String]!
    var likesUsers: [String]!
    var uid: String!
    var userName: String!
    
    // 프로필 이미지 설정
    var profileImageUrl: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        uid = Auth.auth().currentUser?.uid

        // Do any additional setup after loading the view.
        searchTableView.dataSource = self
//        userGroup = UserGroup(parentNotification: notification1)
//        userGroup.queryData()
        
        
        MyUserFirebaseDatabase.shared.getFollowingList(uid: uid) { followingList in
            self.myFollowingList = followingList
            self.searchTableView.reloadData()
        }
    }
    
    private func notification1(user: User?, action: UserDbAction?) {
//        print("users count \(userGroup.getUsers().count)")
        self.searchTableView.reloadData()
    }
}

extension LikesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("users count2 \(userGroup.getUsers().count)")
        return likesUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SerachTableViewCell")!
        
       
        
//        let userName = users[indexPath.row].userName
//        
//        // 프로필 이미지 설정
//        let profileImageUrl = users[indexPath.row].imageUrl
        let profileImageView = cell.contentView.subviews[0] as! UIImageView
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
//        (cell.contentView.subviews[1] as! UILabel).text = userName
        let button = cell.contentView.subviews[2] as! UIButton
        button.tag = indexPath.row
        button.addTarget(self, action: #selector(onTapFollowingButton), for: .touchUpInside)
        
        MyUserFirebaseDatabase.shared.findUsernameAndProfileImageWithUid(with: likesUsers[indexPath.row]) { username, imageUrl in
            DispatchQueue.main.async {
                    if let username = username {
                        self.userName = username
                        (cell.contentView.subviews[1] as! UILabel).text = username
                    }
                    self.downloadImage(imageView: profileImageView, urlStr: imageUrl!)
                }
                self.searchTableView.reloadData()
        }

        // Check if the UID is in myFollowingList
        let user = likesUsers[indexPath.row]
//        print("hello world 13 \(user.uid)")
        if let myFollowingList = myFollowingList, myFollowingList.contains(user) {
            // UID exists in myFollowingList, update button attributes
            button.layer.cornerRadius = 8.0
            button.setTitle("팔로잉", for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = .systemGray5
        } else {
            // UID does not exist in myFollowingList, reset button attributes
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
        let user = likesUsers[rowIndex]
        let isFollowing = myFollowingList?.contains(user) ?? false

        if isFollowing {
            // User is already being followed, remove from the following list
            MyUserFirebaseDatabase.shared.removeFromFollowing(with: uid, followingUid: user)
        } else {
            // User is not being followed, add to the following list
            MyUserFirebaseDatabase.shared.addToFollowing(with: uid, followingUid: user)
        }
        
        // Update following status and button attributes
        if var myFollowingList = myFollowingList {
            if isFollowing {
                myFollowingList.removeAll(where: { $0 == user })
                sender.setTitle("팔로우", for: .normal)
                sender.setTitleColor(.white, for: .normal)
                sender.backgroundColor = .systemBlue
            } else {
                myFollowingList.append(user)
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
