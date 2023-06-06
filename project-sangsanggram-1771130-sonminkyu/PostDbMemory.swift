//
//  PostDbMemory.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/03.
//

import Foundation
class PostDbMemory: PostDatabase {
    private var storage: [Post]
    
    var parentNotification: ((Post?, PostDbAction?) -> Void)?
    
    required init(parentNotification: ((Post?, PostDbAction?) -> Void)?) {
        self.parentNotification = parentNotification
        
        storage = []
        
        let amount = 0
        for _ in 0..<amount {
            let delta = Int(arc4random_uniform(UInt32(amount))) - amount/2
            let date = Date(timeInterval: TimeInterval(delta*24*60*60), since: Date())
            storage.append(Post(date: date))
        }
    }
}

extension PostDbMemory {
    func queryPosts(fromDate: Date, toDate: Date) {
        for i in 0..<storage.count {
            if storage[i].date >= fromDate && storage[i].date <= toDate {
                if let parentNotification = parentNotification {
                    // 한 개씩 여러번 전달한다.
                    parentNotification(storage[i], .Add)
                }
            }
        }
    }
    
    func saveChange(post: Post, action: PostDbAction) {
        if action == .Add {
            storage.append(post)
        } else {
            for i in 0...storage.count {
                if post.key == storage[i].key {
                    if action == .Delete{
                        storage.remove(at: i)
                    }
                    if action == .Modify{
                        storage[i] = post
                    }
                    break
                }
            }
        }
        if let parentNotification = parentNotification {
            // 변경된 내역을 알려준다.
            parentNotification(post, action)
        }
    }
}
