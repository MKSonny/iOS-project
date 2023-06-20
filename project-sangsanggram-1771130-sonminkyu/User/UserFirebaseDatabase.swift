//
//  UserFirebaseDatabase.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/09.
//

import Foundation
import FirebaseFirestore

class UserFirebaseDatabase: UserDatabase {
    var reference: CollectionReference                    // firestore에서 데이터베이스 위치
    var parentNotification: ((User?, UserDbAction?) -> Void)? // PlanGroupViewController에서 설정
    var existQuery: ListenerRegistration?                 // 이미 설정한 Query의 존재여부
    
    required init(parentNotification: ((User?, UserDbAction?) -> Void)?) {
        self.parentNotification = parentNotification
        reference = Firestore.firestore().collection("users") // 첫번째 "plans"라는 Collection
    }
    
}

extension UserFirebaseDatabase{
    
    func saveChange(user: User, action: UserDbAction){
        if action == .Delete{
            reference.document(user.uid).delete()    // key로된 plan을 지운다
            return
        }
        
        let data = user.toDict()
        // 저장 형태로 만든다
        let storeData: [String : Any] = ["username": data["username"], "image_url": data["image_url"], "uid": data["uid"]]
        print("hello world 8 \(data["uid"])")
        reference.document(user.uid).setData(storeData)
    }
}
extension UserFirebaseDatabase{
    
    func queryUser() {
        print("queryUser")
        if let existQuery = existQuery{    // 이미 적용 쿼리가 있으면 제거, 중복 방지
            existQuery.remove()
        }
        let queryReference = reference
        
        existQuery = queryReference.addSnapshotListener(onChangingData)
    }
    
    func findUserByUid(uid: String) {
        if let existQuery = existQuery{    // 이미 적용 쿼리가 있으면 제거, 중복 방지
            existQuery.remove()
        }
        let queryReference = reference.whereField("uid", isEqualTo: uid)
        existQuery = queryReference.addSnapshotListener(onChangingData)
    }
    
    func queryPlan(fromDate: Date, toDate: Date) {
        
        if let existQuery = existQuery{    // 이미 적용 쿼리가 있으면 제거, 중복 방지
            existQuery.remove()
        }
        let queryReference = reference.whereField("date", isGreaterThanOrEqualTo: fromDate).whereField("date", isLessThanOrEqualTo: toDate)
        
        // onChangingData는 쿼리를 만족하는 데이터가 있거나 firestore내에서 다른 앱에 의하여
        // 데이터가 변경되어 쿼리를 만족하는 데이터가 발생하면 호출해 달라는 것이다.
        existQuery = queryReference.addSnapshotListener(onChangingData)
    }
}
extension UserFirebaseDatabase{
    func onChangingData(querySnapshot: QuerySnapshot?, error: Error?) {
        //        print("hello world4")
        guard let querySnapshot = querySnapshot else{ return }
        // 초기 데이터가 하나도 없는 경우에 count가 0이다
        if(querySnapshot.documentChanges.count <= 0){
            //            print("hello world4")
            if let parentNotification = parentNotification { parentNotification(nil, nil)} // 부모에게 알림
        }
        // 쿼리를 만족하는 데이터가 많은 경우 한꺼번에 여러 데이터가 온다
        for documentChange in querySnapshot.documentChanges {
            print("hello world4")
            let data = documentChange.document.data() //["date": date, "data": data!]로 구성되어 있다
            
            let user = User()
            if data["username"] != nil {
                print("hello world42 \(data["username"])")
                user.toUser(dict: data)
            }
            
            var action: UserDbAction?
            switch(documentChange.type){    // 단순히 DbAction으로 설정
            case    .added: action = .Add; print("add user")
            case    .modified: action = .Modify
            case    .removed: action = .Delete
            }
            if let parentNotification = parentNotification {parentNotification(user, action)} // 부모에게 알림
        }
    }
}
