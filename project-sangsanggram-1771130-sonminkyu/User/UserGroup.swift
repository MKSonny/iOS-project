//
//  UserGroup.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/09.
//

import Foundation
class UserGroup {
    var users = [User]()
    var database: UserDatabase!
    var parentNotification: ((User?, UserDbAction?) -> Void)?
    
    init(parentNotification: ((User?, UserDbAction?) -> Void)?) {
        self.parentNotification = parentNotification
//        database = PostDbMemory(parentNotification: receivingNotification)
        database = UserFirebaseDatabase(parentNotification: receivingNotification)
    }
    
    func receivingNotification(user: User?, action: UserDbAction?){
        // 데이터베이스로부터 메시지를 받고 이를 부모에게 전달한다
        if let user = user {
            switch(action){    // 액션에 따라 적절히     plans에 적용한다
            case .Add: addUser(user: user)
            case .Modify: modifyUser(modifiedUser: user)
//            case .Delete: removeUser(removedUser: user)
            default: break
            }
        }
        if let parentNotification = parentNotification{
            parentNotification(user, action) // 역시 부모에게 알림내용을 전달한다.
        }
    }
}

extension UserGroup {
    func queryData(){
        users.removeAll()      // 이달 마지막일이 속한 토요일을 마감시간
        database.queryUser()
    }
    
    func queryFollowing() {
        users.removeAll()
        database
    }
    
    func saveChange(user: User, action: UserDbAction){
        // 단순히 데이터베이스에 변경요청을 하고 plans에 대해서는
        // 데이터베이스가 변경알림을 호출하는 receivingNotification에서 적용한다
        database.saveChange(user: user, action: action)
    }
}

extension UserGroup {
    func getUsers() -> [User] {
        return users
    }

}

extension UserGroup {
    private func count() -> Int {
        return users.count
    }
    
    private func find(_ key: String) -> Int? {
        for i in 0..<users.count {
            if key == users[i].key {
                return i
            }
        }
        return nil
    }
}

extension UserGroup {
    public func addUser(user: User) {
        users.append(user)
    }
    private func modifyUser(modifiedUser: User) {
        if let index = find(modifiedUser.key) {
            users[index] = modifiedUser
        }
    }
    private func removePost(removedUser: User) {
        if let index = find(removedUser.key) {
            users.remove(at: index)
        }
    }
}
