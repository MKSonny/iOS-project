//
//  ProfileViewController3.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/15.
//

import UIKit
import FirebaseAuth

class ProfileViewController3: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var postLabel: UILabel!
    
    @IBOutlet weak var followersLabel: UILabel!
    
    @IBOutlet weak var followingLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var profileEditButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func logOutButtonPressed(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "로그아웃", message: "정말 로그아웃 하시겠습니까?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let logOutAction = UIAlertAction(title: "확인", style: .default) { _ in
            do {
                try Auth.auth().signOut()
                // 로그아웃 성공한 후
                if let tabBarController = self.tabBarController {
                    // 홈 탭으로 이동하도록 설정 -> 홈 탭(게시물 리스트 페이지)에는
                    // 현재 currentUser가 nil이면 로그인 페이지가 나오도록 설정되어 있다.
                    tabBarController.selectedIndex = 0
                }
            } catch let signOutError as NSError {
                // 로그아웃 실패한 경우
                print("로그아웃 실패: \(signOutError.localizedDescription)")
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(logOutAction)
        present(alertController, animated: true, completion: nil)
    }
    var postGroup: PostGroup!
//    var userGroup: UserGroup!
    var uid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileEditButton.layer.cornerRadius = 8.0
        
        // 프로필이미지를 원형으로 만들기 위해 설정한다.
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(didtapFollowersLabel))
        followersLabel.addGestureRecognizer(tap1)
        followersLabel.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didtapFollowingLabel))
        followingLabel.addGestureRecognizer(tap)
        followingLabel.isUserInteractionEnabled = true
    }
    
    @objc func didtapFollowersLabel() {
        let vc = FollowersViewController()
        present(vc, animated: true)
    }
    
    @objc func didtapFollowingLabel() {
        let vc = FollowingViewController()
        present(vc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        uid = Auth.auth().currentUser?.uid
        print("final \(uid)")
        
        postGroup = PostGroup(parentNotification: receivingNotification)
        postGroup.queryDataWithWriter(writer: uid)
        
        MyUserFirebaseDatabase.shared.getFollowersListWithUid(with: uid) { followers in
            DispatchQueue.main.async {
                self.followersLabel.text = String(followers.count - 1)
            }
        }
        
        MyUserFirebaseDatabase.shared.findUserProfileInfoWithUid(with: uid) { userName, profileImage, followingCount in
            DispatchQueue.main.async {
                self.nameLabel.text = userName
                self.postLabel.text = String(self.postGroup.getPosts().count)
                self.followingLabel.text = String(followingCount!)
                self.downloadImage(imageView: self.profileImageView, url: URL(string: profileImage!)!)
            }
        }
    }
    
    /*
     파이어스토어에 저장된 이미지를 이미지뷰에 표시한다.
     
     */
    func downloadImage(imageView: UIImageView, url: URL) {
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

extension ProfileViewController3: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // 위의 postGroup.queryDataWithWriter(writer: uid)에서 writer는
    // 본인의 uid이다. 즉, 본인이 작성한 게시물들만 postGroup에 추가된다.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postGroup.getPosts().count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 한 행에 3개씩 이미지뷰가 나오도록 크기를 조절했다.
        return CGSize(width: 119, height: 119)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // MyPostsCollectionViewCell에는 이미지 뷰하나가 있다.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyPostsCollectionViewCell", for: indexPath) as! MyPostsCollectionViewCell
        
        // 해당 이미지 뷰는 게시물의 사진이며
        let post = postGroup.getPosts()[indexPath.row]
        // configure(withImage:) 메서드를 사용하여 이미지를 설정한다.
        cell.configure(withImage: post.imageUrl)
        // 구성된 셀을 반환한다.
        return cell
    }
}
extension ProfileViewController3 {
    func receivingUsersInfo(user: User?, action: UserDbAction?) {
    }
    
    // postGroup.queryDataWithWriter 데이터가 받아와지면 collectionView를 다시 로드한다.
    func receivingNotification(post: Post?, action: PostDbAction?) {
        self.collectionView.reloadData()
    }
}
