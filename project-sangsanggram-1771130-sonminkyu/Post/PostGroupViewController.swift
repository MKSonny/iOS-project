//
//  PostGroupViewController.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/03.
//

import UIKit
import FirebaseAuth

class PostGroupViewController: UIViewController {
    // 게시물들을 조회할 수 있도록 테이블뷰를 변수
    @IBOutlet weak var postTableView: UITableView!
    // 게시물들이 저장되어 있는 포스트 그룹 변수
    var postGroup: PostGroup!
    // 현재 유저의 정보를 얻기 위한 uid 변수
    var uid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.delegate = self
        
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        postTableView.register(nib, forCellReuseIdentifier: "PostTableViewCell")
        // 테이블뷰의 데이터 소스로 등록
        postTableView.dataSource = self

        // 단순히 planGroup객체만 생성한다
        // 시간 순 정렬
        postGroup = PostGroup(parentNotification: receivingNotification)
    }

    func receivingNotification(post: Post?, action: PostDbAction?){
        // 데이터가 올때마다 이 함수가 호출되는데 맨 처음에는 기본적으로 add라는 액션으로 데이터가 온다.
        self.postTableView.reloadData()
    }
}

extension PostGroupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // 게시물의 갯수만큼 테이블뷰 행을 생성한다.
        if let postGroup = postGroup {
            return postGroup.getPosts().count
        }
        // planGroup가 생성되기전에 호출될 수도 있어 일단 0을 리턴하도록 설정하였다.
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 따로 만든 TableViewCell을 호출합니다.
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as? PostTableViewCell else { return UITableViewCell() }
        
        cell.delegate = self
        // 해당하는 TableViewCell에 게시물 내용을 적용시킨다.
        let post = postGroup.getPosts()[indexPath.row]
        cell.setData(post: post)
        return cell
    }
}

extension PostGroupViewController {
    override func viewDidAppear(_ animated: Bool) {
        // 만약 현재 유저가 없다면
        if Auth.auth().currentUser == nil {
            // 로그인 화면을 띄운다
            let loginVC = LoginViewController2()
            // present하되 전체화면으로 나오도록 설정한다
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true)
        } else {
            // 로그인한 유저가 있을 경우
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 인스타그램에서는 팔로우한 유저의 게시물만 표시된다.
        // 따라서 getFollowingList 메서드를 통해 팔로잉 유저들의 uid를 문자열 배열로 가져온다.
        if let uid = Auth.auth().currentUser?.uid {
            MyUserFirebaseDatabase.shared.getFollowingList(uid: uid) { following in
                if following.count > 0 {
                    // 그리고 해당 post에서 writer가 해당 uid인 것들만 postGroup에 .Add 한다.
                    self.postGroup.queryDataWithFollowingList(followingList: following)
                }
            }
        }
        postTableView.reloadData()
    }
}

extension PostGroupViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if let viewController = viewController as? UINavigationController{
//            if let profileVC3 = viewController.viewControllers[0] as? ProfileViewController3 {
//                profileVC3.postGroup = postGroup
//            }

            if let albumMemoVC = viewController.viewControllers[0] as? AlbumMemoViewController {
                albumMemoVC.postGroup = postGroup
            }
        }
        if let cameraViewController = viewController as? CameraViewController {
            cameraViewController.postGroup = postGroup
        }
        if let profileViewController2 = viewController as? ProfileViewController2 {
//            profileViewController2.uid = uid
//            profileViewController2.tableView = postTableView
//            profileViewController2.postGroup = postGroup
        }
    }
}

extension PostGroupViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let likesVC = segue.destination as? LikesViewController {
            let likesUid = sender as! [String]
            likesVC.likesUsers = likesUid
        }
    }
}

extension PostGroupViewController: PostTableViewCellDelegate {
    func didTapCommentButton(post: Post) {
        let commentVC = CommentViewController()
        commentVC.post = post
        commentVC.postGroup = postGroup
        navigationController?.pushViewController(commentVC, animated: true)
    }
    
    func didTapLikeLabel(post: Post) {
        performSegue(withIdentifier: "ShowLikes", sender: post.likes)
    }
    
    // 좋아요 버튼을 누르면 파이어베이스에 업데이트
    func didTapLikeButton(post: Post) {
        postGroup.saveChange(post: post, action: .Modify)
    }
}
