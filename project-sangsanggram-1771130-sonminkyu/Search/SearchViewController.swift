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
        let userName = userGroup.getUsers()[indexPath.row].userName
        (cell.contentView.subviews[1] as! UILabel).text = userName
        let button = cell.contentView.subviews[2] as! UIButton
        button.titleLabel?.text = "팔로우"
        button.tag = indexPath.row
        button.addTarget(self, action: #selector(onTapFollowingButton), for: .touchUpInside)
        return cell
    }
    
    @objc func onTapFollowingButton(_ sender: UIButton) {
        let rowIndex = sender.tag
        print("hello world 7 \(userGroup.getUsers()[rowIndex].uid)")
        MyUserFirebaseDatabase.shared.addToFollowing(with: uid, followingUid: userGroup.getUsers()[rowIndex].uid)
    }
}
