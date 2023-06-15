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
    
    @IBOutlet weak var profileInfoTextView: UITextView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var postGroup: PostGroup!
    var userGroup: UserGroup!
    
    
    var uid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didtapFollowingLabel))
        followingLabel.addGestureRecognizer(tap)
        followingLabel.isUserInteractionEnabled = true
    }
    
    @objc func didtapFollowingLabel() {
        let vc = FollowingViewController()
        present(vc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        uid = Auth.auth().currentUser?.uid
        
        postGroup = PostGroup(parentNotification: receivingNotification)
        postGroup.queryDataWithWriter(writer: uid)
        
        userGroup = UserGroup(parentNotification: receivingUsersInfo)
        userGroup.database.queryUser()
        
        
        
        MyUserFirebaseDatabase.shared.findUsernameAndProfileImageWithUid(with: uid) { userName, profileImage in
            DispatchQueue.main.async {
                self.nameLabel.text = userName
//                profileHeader.nameLabelText(name: userName!)
                self.postLabel.text = String(self.postGroup.getPosts().count)
                
                self.downloadImage(imageView: self.profileImageView, url: URL(string: profileImage!)!)
            }
        }
    }
    
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if section == 0 {
//            return 0
//        }
        return postGroup.getPosts().count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 119, height: 119)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyPostsCollectionViewCell", for: indexPath) as! MyPostsCollectionViewCell
        
        let post = postGroup.getPosts()[indexPath.row]
        print("hello world 200 \(post)")
        cell.configure(withImage: post.imageUrl)
        
        return cell
    }
}

//extension ProfileViewController3: UICollectionViewDelegate, UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        // 만약 fetchResult nil이면 아직 다 못 읽어왔다는 거니까 일단 0을 리턴한다.
//        return postGroup.getPosts().count
//    }
//
//    // 사진의 크기를 조정
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 119, height: 119)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyPostsCollectionViewCell", for: indexPath) as! MyPostsCollectionViewCell
//
//        let post = postGroup.getPosts()[indexPath.row]
//        print("hello world 199 \(post)")
//        cell.configure(withImage: post.imageUrl)
//
//        return cell
//    }
//}

extension ProfileViewController3 {
    func receivingUsersInfo(user: User?, action: UserDbAction?) {
    }
    
    func receivingNotification(post: Post?, action: PostDbAction?){
        print("hello world 199 23")
        self.collectionView.reloadData()
    }
}
