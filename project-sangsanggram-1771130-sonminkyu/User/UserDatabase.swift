//
//  UserDatabase.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/06.
//

import Foundation
enum UserDbAction {
    case Add, Delete, Modify
}

protocol UserDatabase {
    init(parentNotification: ((User?, UserDbAction?) -> Void)?)
    
    func queryUser()
    
    func saveChange(user: User, action: UserDbAction)
}
