//
//  PostGroupViewController.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/03.
//

import UIKit
import FirebaseAuth

class PostGroupViewController: UIViewController {
    @IBOutlet weak var postTableView: UITableView!
    var postGroup: PostGroup!
    var uid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser?.uid
        
        tabBarController?.delegate = self
        
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        postTableView.register(nib, forCellReuseIdentifier: "PostTableViewCell")
        postTableView.dataSource = self        // 테이블뷰의 데이터 소스로 등록

        // 단순히 planGroup객체만 생성한다
        postGroup = PostGroup(parentNotification: receivingNotification)
        
        MyUserFirebaseDatabase.shared.getFollowingList(uid: uid) { following in
            print("hello world 11 \(following)")
            self.postGroup.queryDataWithFollowingList(followingList: following)
        }
//        postGroup.queryData(date: Date())       // 이달의 데이터를 가져온다. 데이터가 오면 planGroupListener가 호출된다.
        
    }

    func receivingNotification(post: Post?, action: PostDbAction?){
        print("hello world 12 \(post?.username)")
        // 데이터가 올때마다 이 함수가 호출되는데 맨 처음에는 기본적으로 add라는 액션으로 데이터가 온다.
        self.postTableView.reloadData()  // 속도를 증가시키기 위해 action에 따라 개별적 코딩도 가능하다.
    }
}

extension PostGroupViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let postGroup = postGroup {
            print("hello world 14 \(postGroup.getPosts().count)")
            return postGroup.getPosts().count
        }
        return 0    // planGroup가 생성되기전에 호출될 수도 있다
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as? PostTableViewCell else { return UITableViewCell() }
        
        cell.delegate = self
        
        cell.setData(post: postGroup.getPosts()[indexPath.row])
        
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
        if Auth.auth().currentUser == nil {
            // show log in
            print("로그인 한 유저 없음")
            let loginVC = RegisterViewController()
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true)
        } else {
            print("로그인 한 유저 uid \(Auth.auth().currentUser?.uid)")
            print("로그인 한 유저 있음 \(Auth.auth().currentUser?.email)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        postTableView.reloadData()
    }
}

extension PostGroupViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let cameraViewController = viewController as? CameraViewController {
            print("hello world2 cameraViewController")
            cameraViewController.postGroup = postGroup
        }
        if let profileViewController2 = viewController as? ProfileViewController2 {
            print("hello world2 good")
//            profileViewController2.uid = uid
//            profileViewController2.tableView = postTableView
//            profileViewController2.postGroup = postGroup
        }
    }
}

extension PostGroupViewController: PostTableViewCellDelegate {
    // 좋아요 버튼을 누르면 파이어베이스에 업데이트
    func didTapLikeButton(post: Post) {
        // postId를 활용하여 해당 게시글에 대한 처리 로직을 구현
        // 예: Firebase API를 사용하여 해당 게시글의 데이터를 업데이트
        
        // 예시: 게시글의 좋아요 버튼을 눌렀을 때 로직
//        print("Like button tapped for postId: \(postId)")
        
        // 해당 게시글에 대한 업데이트 등의 로직을 구현
        postGroup.saveChange(post: post, action: .Modify)
    }
}
