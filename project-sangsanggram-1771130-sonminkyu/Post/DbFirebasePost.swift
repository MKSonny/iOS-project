//
//  DbFirebasePost.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/05.
//

import Foundation
import FirebaseFirestore

class DbFirebasePost: PostDatabase {
    // FirebaseFirestore에서 데이터베이스 위치
    var reference: CollectionReference
    // PostGroupViewController에서 설정
    var parentNotification: ((Post?, PostDbAction?) -> Void)?
    // 이미 설정한 Query의 존재여부
    var existQuery: ListenerRegistration?
    
    required init(parentNotification: ((Post?, PostDbAction?) -> Void)?) {
        self.parentNotification = parentNotification
        // collection "posts" 레퍼런스
        reference = Firestore.firestore().collection("posts")
    }
}

extension DbFirebasePost{
    func saveChange(post: Post, action: PostDbAction){
        if action == .Delete{
            reference.document(post.key).delete()    // key로된 plan을 지운다
            return
        }
        
        let data = post.toDict()
        
        // 게시물 추가 시 수정하면 여기도 수정!
        // 저장 형태로 만든다
        /* 게시글 추가시 다음과 같은 내용이 적힌다.
         date: 게시글 작성 날짜
         content: 게시글 내용
         username: 게시글 작성자 이름
         image_url: 게시글에 사용할 이미지 주소 -> firestore와 연결되어 있다
         likes: 좋아요 수
         uid" 게시글 작성자 uid -> Firebase Auth에서 생성된 uid
         comments: 게시글 댓글
         */
        let storeData: [String : Any] = ["date": post.date, "content": data["content"]!, "username": data["username"]!, "key": data["key"]!, "image_url": data["image_url"], "writerImage": data["writerImage"], "likes": data["likes"], "uid": data["uid"], "comments": data["comments"]]
        reference.document(post.key).setData(storeData)
    }
}

extension DbFirebasePost {
    func queryPostsByFollowing(followingList: [String]) {
        if let existQuery = existQuery{    // 이미 적용 쿼리가 있으면 제거, 중복 방지
            existQuery.remove()
        }
        /*
         followingList는 팔로잉하는 사람들의 uid들이 들어있다. post 컬렉션에서 uid 필드가
         이와 같은 post들을 찾아 postGroup에 추가한다.
         */
        let queryReference = reference.whereField("uid", in: followingList)
        
        existQuery = queryReference.addSnapshotListener(onChangingData)
    }
}

extension DbFirebasePost {
    // 본인이 작성한 게시물을 위한 쿼리문이다.
    func queryPostsByWriter(writer: String) {
        if let existQuery = existQuery{    // 이미 적용 쿼리가 있으면 제거, 중복 방지
            existQuery.remove()
        }
        // collection이 "post"인 곳에서 문서안의 "uid" 필드가 writer 같은 것들을
        // postGtoup의 posts에 추가한다.
        let queryReference = reference.whereField("uid", isEqualTo: writer)
        
        existQuery = queryReference.addSnapshotListener(onChangingData)
    }
    
    
    
    func queryPosts(fromDate: Date, toDate: Date) {
        
        if let existQuery = existQuery{    // 이미 적용 쿼리가 있으면 제거, 중복 방지
            existQuery.remove()
        }
        let queryReference = reference.whereField("date", isGreaterThanOrEqualTo: fromDate).whereField("date", isLessThanOrEqualTo: toDate)
        
        // onChangingData는 쿼리를 만족하는 데이터가 있거나 firestore내에서 다른 앱에 의하여
        // 데이터가 변경되어 쿼리를 만족하는 데이터가 발생하면 호출해 달라는 것이다.
        existQuery = queryReference.addSnapshotListener(onChangingData)
    }
}
extension DbFirebasePost{
    func onChangingData(querySnapshot: QuerySnapshot?, error: Error?){
        guard let querySnapshot = querySnapshot else{ return }
        // 초기 데이터가 하나도 없는 경우에 count가 0이다
        if(querySnapshot.documentChanges.count <= 0){
            if let parentNotification = parentNotification { parentNotification(nil, nil)} // 부모에게 알림
        }
        // 쿼리를 만족하는 데이터가 많은 경우 한꺼번에 여러 데이터가 온다
        for documentChange in querySnapshot.documentChanges {
            let data = documentChange.document.data() //["date": date, "data": data!]로 구성되어 있다
            
            let post = Post(date: Date().setCurrentTime())
            if data["comments"] != nil {
                post.toPost(dict: data)
            }
            
            var action: PostDbAction?
            switch(documentChange.type){    // 단순히 DbAction으로 설정
            case    .added: action = .Add;
            case    .modified: action = .Modify
            case    .removed: action = .Delete
            }
            if let parentNotification = parentNotification {parentNotification(post, action)} // 부모에게 알림
        }
    }
}
