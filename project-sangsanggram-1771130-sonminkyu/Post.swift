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
    var imageUrl: String
    var username: String
    var uid: String
    var writerImage: String
    var date: Date
    var likes: Int
    var content: String
    var key: String
    // uid, comment 내용
    var comments: [String: String]
    
    init(imageUrl: String, username: String, uid: String,writerImage: String, date: Date, content: String, likes: Int, comments: [String: String]) {
        self.key = UUID().uuidString
        self.imageUrl = imageUrl
        self.uid = uid
        self.username = username
        self.date = date
        self.content = content
        self.likes = likes
        self.writerImage = writerImage
        self.comments = comments
    }

    init(date: Date) {
        self.key = UUID().uuidString
        self.imageUrl =  "https://firebasestorage.googleapis.com/v0/b/sangsanggram.appspot.com/o/1C768A5D-E42E-4C78-AEDC-AC241026BFDB1686022565.9349241?alt=media&token=bc33a00e-d755-4c29-bfea-5abf9f01da9a&_gl=1*1bb2xin*_ga*MTE3NTg0NzAzNi4xNjczMjQzOTM3*_ga_CW55HF8NVT*MTY4NjAxOTc5Mi40Ni4xLjE2ODYwMjI5NjkuMC4wLjA."
        self.username = "writer"
        self.date = date
        self.content = "content"
        self.likes = 0
        self.writerImage = "dafsdfadf"
        self.uid = "uid"
        self.comments = ["comments": "comments test"]
    }

}

extension Post {
    func toDict() -> [String: Any?] {
        var dict: [String: Any?] = [:]
        dict["key"] = key
        dict["date"] = Timestamp(date: date)
        dict["username"] = username
        dict["uid"] = uid
        dict["content"] = content
        dict["image_url"] = imageUrl
        dict["writerImage"] = writerImage
        dict["likes"] = likes
        dict["comments"] = comments
        
        return dict
    }
    
    func toPost(dict: [String: Any?]) {
        key = dict["key"] as! String
        date = Date()
        if let timestamp = dict["date"] as? Timestamp{
            date = timestamp.dateValue()
        }
        username = dict["username"] as! String
        uid = dict["uid"] as! String
        content = dict["content"] as! String
        imageUrl = dict["image_url"] as! String
        writerImage = dict["writerImage"] as! String
        likes = dict["likes"] as! Int
        comments = dict["comments"] as! [String: String]
    }
}
