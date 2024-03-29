//
//  ProfileViewController2.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/06.
//

import UIKit
import FirebaseAuth

class ProfileViewController2: UIViewController {
    var collectionView: UICollectionView!
    var postGroup: PostGroup!
    var userGroup: UserGroup!
    var uid: String!
    private var userPosts = [Post]()
    private var users = [User]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        uid = Auth.auth().currentUser?.uid
        print("get my uid \(uid)")
        
        postGroup = PostGroup(parentNotification: receivingNotification)
        postGroup.queryDataWithWriter(writer: uid)
        
        userGroup = UserGroup(parentNotification: receivingUsersInfo)
        userGroup.database.queryUser()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.sectionInset = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
        let size = (view.width - 4)/3
        layout.itemSize = CGSize(width: size, height: size)
        
        
        
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        // cell
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        
        // headers
        collectionView.register(ProfileInfoHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileInfoHeaderCollectionReusableView.identifier)
        
        collectionView.register(ProfileTabsCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileTabsCollectionReusableView.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        guard let collectionView = collectionView else {
            return
        }
        view.addSubview(collectionView)
    }
    
    func receivingUsersInfo(user: User?, action: UserDbAction?) {
        
    }
    
    func receivingNotification(post: Post?, action: PostDbAction?){
        self.collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
}

extension ProfileViewController2: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }
        return postGroup.getPosts().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as! PhotoCollectionViewCell
        
        // cell의 이미지를 포스트의 이미지로 설정한다, 일종의 썸네일
        // cell.configure(withImage: model.image)
        let post = postGroup.getPosts()[indexPath.row]
        cell.configure(withImage: post.imageUrl)
        
        return cell
    }
    
    // cell을 터치했을 경우 호출되는 함수
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        users = userGroup.getUsers()
        print("users \(users.count)"))
    }
    
    
    // 여기부터 헤더
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader else {
            // footer
            return UICollectionReusableView()
        }
        
        if indexPath.section == 1 {
            let tabControlHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileTabsCollectionReusableView.identifier, for: indexPath) as! ProfileTabsCollectionReusableView
            
            tabControlHeader.delegate = self
            return tabControlHeader
        }
        
        let profileHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileInfoHeaderCollectionReusableView.identifier, for: indexPath) as! ProfileInfoHeaderCollectionReusableView
        
        profileHeader.delegate = self
        
        MyUserFirebaseDatabase.shared.findUsernameAndProfileImageWithUid(with: uid) { userName, profileImage in
            DispatchQueue.main.async {
                profileHeader.nameLabelText(name: userName!)
                profileHeader.postsCountLabel.text = String(self.postGroup.getPosts().count)
                self.downloadImage(imageView: profileHeader.profilePhotoImageView, url: URL(string: profileImage!)!)
            }
        }
        
        return profileHeader
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: collectionView.width, height: collectionView.height/3)
        }
        
        // size of section tabs
        return CGSize(width: collectionView.width, height: 50)
    }
}

extension ProfileViewController2: ProfileInfoHeaderCollectionReusableViewDelegate {
    func didTapFollowingButton() {
        print("hello world6")
        let vc = FollowingViewController()
        present(vc, animated: true)
    }
}

extension ProfileViewController2: ProfileTabsCollectionReusableViewDelegate {
    func didTapGridButtonTab() {
        // reload collection view with data
    }
    
    func didTapTaggedButtonTab() {
        //
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

