//
//  PostGroup.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/03.
//

import Foundation
class PostGroup {
    var posts = [Post]()
    var fromDate, toDate: Date?
    var database: PostDatabase!
    var parentNotification: ((Post?, PostDbAction?) -> Void)?
    
    init(parentNotification: ((Post?, PostDbAction?) -> Void)?) {
        self.parentNotification = parentNotification
        database = DbFirebasePost(parentNotification: receivingNotification)
    }
    
    func receivingNotification(post: Post?, action: PostDbAction?){
        // 데이터베이스로부터 메시지를 받고 이를 부모에게 전달한다
        if let post = post{
            switch(action){    // 액션에 따라 적절히     plans에 적용한다
            case .Add: addPost(post: post)
            case .Modify: modifyPost(modifiedPost: post)
            case .Delete: removePost(removedPost: post)
            default: break
            }
        }
        if let parentNotification = parentNotification{
            parentNotification(post, action) // 역시 부모에게 알림내용을 전달한다.
        }
    }
}

extension PostGroup {
    func queryData(date: Date){
        posts.removeAll()    // 새로운 쿼리에 맞는 데이터를 채우기 위해 기존 데이터를 전부 지운다
        
        // date가 속한 1개월 +-알파만큼 가져온다
        fromDate = date.firstOfMonth().firstOfWeek()// 1일이 속한 일요일을 시작시간
        toDate = date.lastOfMonth().lastOfWeek()    // 이달 마지막일이 속한 토요일을 마감시간
        database.queryPosts(fromDate: fromDate!, toDate: toDate!)
    }
    
    func queryDataWithFollowingList(followingList: [String]) {
        posts.removeAll()
        database.queryPostsByFollowing(followingList: followingList)
    }
    
    func queryDataWithWriter(writer: String) {
        posts.removeAll()
        
        database.queryPostsByWriter(writer: writer)
    }
    
    func saveChange(post: Post, action: PostDbAction){
        // 단순히 데이터베이스에 변경요청을 하고 plans에 대해서는
        // 데이터베이스가 변경알림을 호출하는 receivingNotification에서 적용한다
        database.saveChange(post: post, action: action)
    }

}

extension PostGroup {
    func getPosts(date: Date? = nil) -> [Post] {
        // plans 중에서 date 날짜에 있는 것만 리턴한다.
        if let date = date {
            var postForDate: [Post] = []
            let start = date.firstOfDay()
            let end = date.lastOfDay()
            for post in posts {
                if post.date >= start && post.date <= end {
                    postForDate.append(post)
                }
            }
            return postForDate.sorted(by: { $0.date > $1.date }) // Sort in reverse order by date
        }
        return posts.sorted(by: { $0.date > $1.date }) // Sort all posts in reverse order by date
    }
}

extension PostGroup {
    private func count() -> Int {
        return posts.count
    }
    
    func isIn(date: Date) -> Bool {
        if let from = fromDate, let to = toDate {
            return (date >= from && date <= to) ? true: false
        }
        return false
    }
    
    private func find(_ key: String) -> Int? {
        for i in 0..<posts.count {
            if key == posts[i].key {
                return i
            }
        }
        return nil
    }
}

extension PostGroup {
    public func addPost(post: Post) {
        posts.append(post)
    }
    private func modifyPost(modifiedPost: Post) {
        if let index = find(modifiedPost.key) {
            posts[index] = modifiedPost
        }
    }
    private func removePost(removedPost: Post) {
        if let index = find(removedPost.key) {
            posts.remove(at: index)
        }
    }
    func changePlan(from: Post, to: Post) {
        if let fromIndex = find(from.key), let toIndex = find(to.key) {
            posts[fromIndex] = to
            posts[toIndex] = from
        }
    }
}
