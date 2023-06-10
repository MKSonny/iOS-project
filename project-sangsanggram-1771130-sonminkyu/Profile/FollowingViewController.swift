//
//  FollowingViewController.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/09.
//

import UIKit

class FollowingViewController: UIViewController {

    var followersListTableView: UITableView!
    var userGroup: UserGroup!
    var usersname: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MyUserFirebaseDatabase.shared.getFollowersList(uid: "kAekCXIZ0MhThXmJMWb9dR5vwKo1") { usersname in
            self.usersname = usersname
            print("hello world 10 \(usersname)")
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

extension FollowingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersname?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FollowersTableViewCell", for: indexPath) as? FollowersTableViewCell else { return UITableViewCell() }
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "")
        cell.textLabel?.text = usersname[indexPath.row]
        return cell
    }
    
    
}
