//
//  PostDatabase.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/03.
//

import Foundation
enum PostDbAction {
    case Add, Delete, Modify
}

protocol PostDatabase {
    init(parentNotification: ((Post?, PostDbAction?) -> Void)?)
    
    func queryPosts(fromDate: Date, toDate: Date)
    
    func saveChange(post: Post, action: PostDbAction)
    
    func queryPostsByWriter(writer: String)
}
