//
//  FollowersViewController.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/17.
//

import UIKit
import FirebaseAuth

class FollowersViewController: UIViewController {

    var followersListTableView: UITableView!
    var userGroup: UserGroup!
    var usersname: [String]!
    var myFollowersList: [(username: String?, profileImage: String?)] = []
    var uid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser?.uid
        
        MyUserFirebaseDatabase.shared.getFollowersListImageWithUid(uid: uid) { followersList in
            self.myFollowersList = followersList
            DispatchQueue.main.async {
                self.followersListTableView.reloadData()
            }
        }
        userGroup = UserGroup(parentNotification: notification1)
        
        followersListTableView = UITableView(frame: CGRect())
        
        let nib = UINib(nibName: "FollowersTableViewCell", bundle: nil)
        followersListTableView.register(nib, forCellReuseIdentifier: "FollowersTableViewCell")
        
        view.addSubview(followersListTableView)
        
        followersListTableView.translatesAutoresizingMaskIntoConstraints = false
        followersListTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        
        followersListTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        followersListTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        followersListTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        
        followersListTableView.dataSource = self
    }
    
    private func notification1(user: User?, action: UserDbAction?) {
        self.followersListTableView.reloadData()
    }
}

extension FollowersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("hello world 12 45 \(myFollowersList.count)")
        return myFollowersList.count - 1 ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowersTableViewCell", for: indexPath) as! FollowersTableViewCell
        let follower = myFollowersList[indexPath.row]
        cell.setData(profileUrl: follower.profileImage, username: follower.username)
        return cell
    }
}
