//
//  User.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/06.
//

import Foundation
class User {
    var imageUrl: String
    var userName: String
    var postCount: Int
    var key: String
    
    init(imageUrl: String, userName: String, postCount: Int) {
        self.key = UUID().uuidString
        self.imageUrl = imageUrl
        self.userName = userName
        self.postCount = postCount
    }

    init() {
        self.key = UUID().uuidString
        self.imageUrl =  "https://firebasestorage.googleapis.com/v0/b/sangsanggram.appspot.com/o/1C768A5D-E42E-4C78-AEDC-AC241026BFDB1686022565.9349241?alt=media&token=bc33a00e-d755-4c29-bfea-5abf9f01da9a&_gl=1*1bb2xin*_ga*MTE3NTg0NzAzNi4xNjczMjQzOTM3*_ga_CW55HF8NVT*MTY4NjAxOTc5Mi40Ni4xLjE2ODYwMjI5NjkuMC4wLjA."
        self.userName = "userName"
        self.postCount = 0
    }

}

extension User {
    func toDict() -> [String: Any?] {
        var dict: [String: Any?] = [:]
        dict["key"] = key
        dict["userName"] = userName
        dict["postCount"] = postCount
        dict["image_url"] = imageUrl
        
        return dict
    }
    
    func toPost(dict: [String: Any?]) {
        key = dict["key"] as! String
        userName = dict["userName"] as! String
        postCount = dict["postCount"] as! Int
        imageUrl = dict["image_url"] as! String
    }
}
