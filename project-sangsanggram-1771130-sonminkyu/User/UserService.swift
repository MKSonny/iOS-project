//
//  UserService.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/10.
//

import Foundation

class UserService {
    static let shared = UserService()
    let userRepository = MyUserFirebaseDatabase.shared
    
    public func getPostCountByUid(uid: String, completion: @escaping (Int) -> Void) {
        
    }
}
