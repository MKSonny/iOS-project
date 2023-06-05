//
//  Plan.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/03.
//

import Foundation
import FirebaseFirestore

class Plan {
    enum Kind: Int {
        case Todo = 0, Metting, Study, Etc
        func toString() -> String {
            switch self {
            case .Todo: return "할 일"
            case .Metting: return "회의"
            case .Study: return "공부"
            case .Etc: return "기타"
            }
        }
        static var count: Int { return Kind.Etc.rawValue + 1}
    }
    var key: String
    var owner: String?
    var content: String
    var date: Date
    var kind: Kind
    
    init(date: Date, owner: String?, kind: Kind, content: String) {
        self.key = UUID().uuidString
        self.date = Date(timeInterval: 0, since: date)
        self.owner = owner
        self.kind = kind
        self.content = content
    }
}

extension Plan {
    func toDict() -> [String: Any?] {
        var dict: [String: Any?] = [:]
        dict["key"] = key
        dict["date"] = Timestamp(date: date)
        dict["owner"] = owner
        dict["kind"] = kind.rawValue
        dict["content"] = content
        
        return dict
    }
    
    func toPlan(dict: [String: Any?]) {
        key = dict["key"] as! String
        date = Date()
        if let timestamp = dict["date"] as? Timestamp{
            date = timestamp.dateValue()
        }
        owner = dict["owner"] as? String
        let rawValue = dict["kind"] as! Int
        kind = Plan.Kind(rawValue: rawValue)!
        content = dict["content"] as! String
    }
}

extension Plan{
    convenience init(date: Date? = nil, withData: Bool = false){
        if withData == true{
            var index = Int(arc4random_uniform(UInt32(Kind.count)))
            let kind = Kind(rawValue: index)! // 이것의 타입은 옵셔널이다. Option+click해보라

            let contents = ["iOS 숙제", "졸업 프로젝트", "아르바이트","데이트","엄마 도와드리기"]
            index = Int(arc4random_uniform(UInt32(contents.count)))
            let content = contents[index]
            
            self.init(date: date ?? Date(), owner: "me", kind: kind, content: content)
            
        }else{
            self.init(date: date ?? Date(), owner: "me", kind: .Etc, content: "")

        }
    }
}
