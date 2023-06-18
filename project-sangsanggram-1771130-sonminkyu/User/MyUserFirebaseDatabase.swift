//
//  MyUserFirebaseDatabase.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/10.
//

import Foundation
import FirebaseFirestore

public class MyUserFirebaseDatabase {
    static let shared = MyUserFirebaseDatabase()
    var reference: CollectionReference = Firestore.firestore().collection("users")
    /*
     아래 getFollowingList는 이름은 같지만 기능은 다르다(반환값이 다르다)
     첫번째 것은 following 하는 유저들의 uid 문자열 배열을 가져 오는 것이다.
     */
    public func getFollowingList(uid: String, completion: @escaping ([String]) -> Void) {
        let documentRef = reference.document(uid)
        print("why? \(uid)")
        documentRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let following = document.data()?["following"] as? [String] {
                    // 본인은 제외
//                    let filteredFollowing = following.filter { $0 != uid }
//                    print("why? \(filteredFollowing)")
                    completion(following)
                }
            }
        }
    }
    
    // 이 함수는 팔로잉 리스트를 볼때 유저 이름과 유저 프로필 이미지를 조회할 수 있도록 하는 함수다
    public func getFollowingList(uid: String, completion: @escaping ([(username: String?, profileImage: String?)]) -> Void) {
        MyUserFirebaseDatabase.shared.getFollowingList(uid: uid) { followingUIDs in
            var userProfiles: [(username: String?, profileImage: String?)] = []
            let dispatchGroup = DispatchGroup()
            
            for followingUid in followingUIDs {
                dispatchGroup.enter()
                MyUserFirebaseDatabase.shared.findUsernameAndProfileImageWithUid(with: followingUid) { username, image in
                    let userProfile = (username: username, profileImage: image)
                    userProfiles.append(userProfile)
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(userProfiles)
            }
        }
    }
    
    // 해당 유저의 팔로잉 리스트에 유저를 추가하는 함수
    /*
     1. 주어진 uid를 사용하여 Firestore 데이터베이스의 해당 사용자 문서에 대한 참조인 documentRef를 만듭니다.
     documentRef를 사용하여 해당 문서를 가져온다.
     2. 가져온 문서가 존재하면, 이미 사용자 문서가 있는 것이므로 following 필드를 업데이트 한다.
     3. 문서에서 following 필드를 가져와서 배열로 변환한다. 만약 following 필드가 이미 배열로 존재한다면, 중복되지 않는지 확인한 후 followingUid를 배열에 추가한다.
     4. following 필드가 존재하지 않는다면, 새로운 배열을 생성하고 followingUid를 추가한다.
     5. 업데이트된 following 배열을 documentRef에 다시 저장한다. merge: true 옵션을 사용하여 문서의 다른 필드는 변경되지 않도록 보존한다.
     6. 문서가 존재하지 않는 경우(해당 사용자의 문서가 아직 생성되지 않은 경우), following 필드와 followingUid를 포함한 새로운 문서를 생성한다.
     */
    public func addToFollowing(with uid: String, followingUid: String) {
        let documentRef = reference.document(uid)
        
        documentRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if var following = document.data()?["following"] as? [String] {
                    if !following.contains(followingUid) {
                        following.append(followingUid)
                        documentRef.setData(["following": following], merge: true)
                    }
                } else {
                    documentRef.setData(["following": [followingUid]], merge: true)
                }
            } else {
                documentRef.setData(["following": [followingUid]], merge: true)
            }
        }
    }
    
    // 팔로잉 버튼을 누르면 팔로잉 취소된다.
    public func removeFromFollowing(with uid: String, followingUid: String) {
        let documentRef = reference.document(uid)
        
        documentRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if var following = document.data()?["following"] as? [String] {
                    following.removeAll { $0 == followingUid }
                    documentRef.setData(["following": following], merge: true)
                }
            }
        }
    }


    // 프로필 탭에서 본인이 올린 게시물들을 찾기 위한 함수
    public func findPostByUsername(with username: String, completion: @escaping ([String]) -> Void) {
        Firestore.firestore().collection("posts").whereField("writer", isEqualTo: username)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    completion([])
                } else {
                    var postIDs: [String] = []
                    for document in querySnapshot!.documents {
                        postIDs.append(document.documentID)
                        print("did \(document.documentID) => \(document.data())")
                    }
                    completion(postIDs)
                }
        }
    }

    // 회원 가입을 위한 함수
    public func canCreateNewUser(withEmail: String, usernmae: String, completion: (Bool) -> Void) {
        completion(true)
    }
    
    // 프로필 이미지, 이름 수정
    public func editProfileImageAndUsernameWithUid(with uid: String, imageUrl: String, username: String, completion: @escaping (Bool) -> Void) {
        let documentRef = reference.document(uid)
        let data: [String: Any] = [
            "profileImage": imageUrl,
            "username": username
        ]
        
        documentRef.updateData(data) { error in
            if let error = error {
                // Error occurred while updating the data
                print("Failed to update profile image and username: \(error.localizedDescription)")
                completion(false)
            } else {
                // Data updated successfully
                completion(true)
            }
        }
    }

    public func findUsernameAndProfileImageWithUid(with uid: [String], completion: @escaping ([String], [String]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var usernames: [String] = []
        var profileImages: [String] = []
        
        for id in uid {
            dispatchGroup.enter()
            let docRef = reference.document(id)

            docRef.getDocument { (document, error) in
                defer {
                    dispatchGroup.leave()
                }
                
                if let document = document, document.exists {
                    // Document exists and field values can be retrieved
                    let data = document.data()
                    let username = data?["username"] as? String
                    let profileImage = data?["profileImage"] as? String
                    
                    if let username = username, let profileImage = profileImage {
                        usernames.append(username)
                        profileImages.append(profileImage)
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(usernames, profileImages)
        }
    }

    
    public func findUsernameAndProfileImageWithUid(with uid: String, completion: @escaping (String?, String?) -> Void) {
        let docRef = reference.document(uid)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // 문서가 존재하고 필드 값을 가져올 수 있는 경우
                let data = document.data()
                let fieldValue = data?["username"] as? String
                let imageValue = data?["profileImage"] as? String
                completion(fieldValue, imageValue)
            } else {
                // 문서가 존재하지 않거나 가져오는 동안 오류가 발생한 경우
                print("문서가 존재하지 않거나 오류 발생: \(error?.localizedDescription ?? "")")
                completion(nil, nil)
            }
        }
    }
    
    public func getFollowersListWithUid(with uid: String, completion: @escaping ([String]) -> Void) {
        reference.whereField("following", arrayContains: uid).getDocuments { snapshot, error in
            var followers: [String] = []
            
            if let documents = snapshot?.documents {
                for document in documents {
                    let followerUid = document.documentID
                    followers.append(followerUid)
                }
            }
            
            completion(followers)
        }
    }
    
    public func getFollowersListImageWithUid(uid: String, completion: @escaping ([(username: String?, profileImage: String?)]) -> Void) {
        MyUserFirebaseDatabase.shared.getFollowersListWithUid(with: uid) { followingUIDs in
            var userProfiles: [(username: String?, profileImage: String?)] = []
            let dispatchGroup = DispatchGroup()
            
            for followingUid in followingUIDs {
                dispatchGroup.enter()
                MyUserFirebaseDatabase.shared.findUsernameAndProfileImageWithUid(with: followingUid) { username, image in
                    let userProfile = (username: username, profileImage: image)
                    userProfiles.append(userProfile)
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(userProfiles)
            }
        }
    }

    
    
    public func findUserProfileInfoWithUid(with uid: String, completion: @escaping (String?, String?, Int?) -> Void) {
        let docRef = reference.document(uid)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // 문서가 존재하고 필드 값을 가져올 수 있는 경우
                let data = document.data()
                let fieldValue = data?["username"] as? String
                let imageValue = data?["profileImage"] as? String
                let followingValue = data?["following"] as? [String]
                // 본인은 제외
                let count = (followingValue?.count ?? 0) - 1
                completion(fieldValue, imageValue, count)
            } else {
                // 문서가 존재하지 않거나 가져오는 동안 오류가 발생한 경우
                print("문서가 존재하지 않거나 오류 발생: \(error?.localizedDescription ?? "")")
                completion(nil, nil, nil)
            }
        }
    }

    
    // 회원가입시 새로운 유저를 데이터베이스에 추가한다
    public func insertNewUser(email: String, username: String, uid: String, completion: @escaping (Bool) -> Void) {
        var following = [String]()
        following.append(uid)
        reference.document(uid).setData(
            ["username" : username, "profileImage" : "https://firebasestorage.googleapis.com/v0/b/sangsanggram.appspot.com/o/images.png?alt=media&token=10c7d64c-0aa6-40bc-8199-16f5b0d94a67&_gl=1*tc4kn7*_ga*MTE3NTg0NzAzNi4xNjczMjQzOTM3*_ga_CW55HF8NVT*MTY4NjA0MTYyMS40OC4xLjE2ODYwNDQ5ODMuMC4wLjA.", "following": following, "uid": uid]) { error in
                if error == nil {
                    // 성공
                    completion(true)
                    return
                }
                else {
                    completion(false)
                    return
                }
            }
    }
}
