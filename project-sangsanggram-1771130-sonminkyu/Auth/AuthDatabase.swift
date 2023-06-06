//
//  AuthDatabase.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/06.
//

import Foundation
import FirebaseAuth

public class AuthDatabase {
    static let shared = AuthDatabase()
    
    public func makeNewUser(username: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        MyDatabase.shared.canCreateNewUser(withEmail: email, usernmae: username) { canCreate in
            if canCreate {
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    guard error == nil, result != nil else {
                        // firebase auth could not create account
                        
                        completion(false)
                        return
                    }
                    // insert into database
                    MyDatabase.shared.insertNewUser(with: email, username: username, uid: (result?.user.uid)!) { inserted in
                        if inserted {
                            completion(true)
                            return
                        } else {
                            // failed to insert to database
                            completion(false)
                            return
                        }
                    }
                }
            }
            else {
                // either username or email does not exist
                completion(false)
            }
        }
    }
    
    // completion: 로그인이 성공 혹은 실패했음을 알린다.
    public func loginCheck(username: String?, email: String?, password: String, completion: @escaping ((Bool) -> Void)) {
        if let email = email {
            Auth.auth().signIn(withEmail: email, password: password) {
                result, error in
                guard result != nil, error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            }
        }
        else if let username = username {
            print("username \(username)")
        }
    }
    
    public func logOut(completion: (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true)
            return
        }
        catch {
            completion(false)
            print(error)
            return
        }
    }
}
