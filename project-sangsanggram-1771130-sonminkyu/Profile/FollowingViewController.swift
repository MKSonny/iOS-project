//
//  FollowingViewController.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/09.
//

import UIKit
import FirebaseAuth

class FollowingViewController: UIViewController {

    var followersListTableView: UITableView!
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
                self.followersListTableView.reloadData()
            }
            // Additional code that relies on the retrieved data can be placed here
        }

//        MyUserFirebaseDatabase.shared.getFollowingList(uid: uid) { usersname in
//            self.usersname = usersname
//            print("hello world 10 \(usersname)")
////            DispatchQueue.main.async {
////                self.followersListTableView.reloadData()
////            }
//        }
        
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

extension FollowingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("hello world 12 45 \(myFollowingList.count)")
        return myFollowingList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FollowersTableViewCell", for: indexPath) as? FollowersTableViewCell else { return UITableViewCell() }
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "")
//        cell.textLabel?.text = usersname[indexPath.row]
        cell.textLabel?.text = myFollowingList[indexPath.row].username
        return cell
    }
}
