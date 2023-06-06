//
//  Post.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/03.
//

import Foundation
import UIKit
import FirebaseFirestore

class Post {
    var image: UIImage
    var writer: String
    var date: Date
    var likes: Int
    var content: String
    var key: String
    
    init(image: UIImage, writer: String, date: Date, content: String, likes: Int) {
        self.key = UUID().uuidString
        self.image = image
        self.writer = writer
        self.date = date
        self.content = content
        self.likes = likes
    }

    init(date: Date) {
        self.key = UUID().uuidString
        self.image = UIImage(named: "helloworld")!
        self.writer = "writer"
        self.date = date
        self.content = "content"
        self.likes = 0
    }

}

extension Post {
    func toDict() -> [String: Any?] {
        var dict: [String: Any?] = [:]
        dict["key"] = key
        dict["date"] = Timestamp(date: date)
        dict["owner"] = writer
        dict["content"] = content
        
        return dict
    }
    
    func toPost(dict: [String: Any?]) {
        key = dict["key"] as! String
        date = Date()
        if let timestamp = dict["date"] as? Timestamp{
            date = timestamp.dateValue()
        }
        writer = dict["writer"] as! String
        content = dict["content"] as! String
    }
}
