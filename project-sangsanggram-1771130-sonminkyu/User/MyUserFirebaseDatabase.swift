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
   
    public func getFollowingList(uid: String, completion: @escaping ([String]) -> Void) {
        let documentRef = reference.document(uid)
        
        documentRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let following = document.data()?["following"] as? [String] {
                    completion(following)
                }
            }
        }
    }
    
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

    
    // check if username and email is available
    public func canCreateNewUser(withEmail: String, usernmae: String, completion: (Bool) -> Void) {
        completion(true)
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

    
    // insert new user data to database
    public func insertNewUser(email: String, username: String, uid: String, completion: @escaping (Bool) -> Void) {
        var following = [String]()
        following.append(uid)
        reference.document(uid).setData(
            ["username" : username, "profileImage" : "https://firebasestorage.googleapis.com/v0/b/sangsanggram.appspot.com/o/images.png?alt=media&token=10c7d64c-0aa6-40bc-8199-16f5b0d94a67&_gl=1*tc4kn7*_ga*MTE3NTg0NzAzNi4xNjczMjQzOTM3*_ga_CW55HF8NVT*MTY4NjA0MTYyMS40OC4xLjE2ODYwNDQ5ODMuMC4wLjA.", "following": following]) { error in
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
