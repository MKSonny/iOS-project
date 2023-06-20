//
//  FollowingViewController.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/09.
//

import UIKit
import FirebaseAuth

class FollowingViewController: UIViewController {

    var followingListTableView: UITableView!
    var userGroup: UserGroup!
    var usersname: [String]!
    var myFollowingList: [(username: String?, profileImage: String?)] = []
    var uid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser?.uid
        
        MyUserFirebaseDatabase.shared.getFollowingList(uid: uid) { followingList in
            self.myFollowingList = followingList
            DispatchQueue.main.async {
                self.followingListTableView.reloadData()
            }
        }
        
        userGroup = UserGroup(parentNotification: notification1)
        
        followingListTableView = UITableView(frame: CGRect())
        
        let nib = UINib(nibName: "FollowingTableViewCell", bundle: nil)
        followingListTableView.register(nib, forCellReuseIdentifier: "FollowingTableViewCell")
        
        view.addSubview(followingListTableView)
        
        followingListTableView.translatesAutoresizingMaskIntoConstraints = false
        followingListTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        
        followingListTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        followingListTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        followingListTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        
        followingListTableView.dataSource = self
    }
    
    private func notification1(user: User?, action: UserDbAction?) {
        self.followingListTableView.reloadData()
    }
}

extension FollowingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("hello world 12 45 \(myFollowingList.count)")
        return myFollowingList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowingTableViewCell", for: indexPath) as! FollowingTableViewCell
        let following = myFollowingList[indexPath.row]
        cell.setData(profileUrl: following.profileImage, username: following.username)
        return cell
    }
}
