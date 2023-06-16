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
    var uid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser?.uid

        // Do any additional setup after loading the view.
        searchTableView.dataSource = self
        userGroup = UserGroup(parentNotification: notification1)
        userGroup.queryData()
    }
    
    private func notification1(user: User?, action: UserDbAction?) {
        print("users count \(userGroup.getUsers().count)")
        self.searchTableView.reloadData()
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("users count2 \(userGroup.getUsers().count)")
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
        
        (cell.contentView.subviews[1] as! UILabel).text = userName
        let button = cell.contentView.subviews[2] as! UIButton
        button.titleLabel?.text = "팔로우"
        button.tag = indexPath.row
        button.addTarget(self, action: #selector(onTapFollowingButton), for: .touchUpInside)
        return cell
    }
    
    // 팔로잉 버튼을 눌렀을 경우
    @objc func onTapFollowingButton(_ sender: UIButton) {
        let rowIndex = sender.tag
        MyUserFirebaseDatabase.shared.addToFollowing(with: uid, followingUid: userGroup.getUsers()[rowIndex].uid)
        
        // 버튼의 텍스트 컬러와 배경색 반전
        let button = sender
        button.layer.cornerRadius = 8.0
        button.setTitle("팔로잉", for: .normal)
        button.setTitleColor(.black, for: .normal) // 텍스트 컬러를 반전시킴
        button.backgroundColor = .systemGray5 // 배경색을 반전시킴
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
