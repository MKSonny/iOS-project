//
//  Database.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/03.
//

import Foundation
enum DbAction {
    case Add, Delete, Modify
}

protocol Database {
    // 데이터베이스에 변경이 생기면 parentNotificatioin을 호출하여 부모에게 알린다.
    init(parentNotification: ((Plan?, DbAction?) -> Void)?)
    
    func queryPlan(fromDate: Date, toDate: Date)
    
    func saveChange(plan: Plan, action: DbAction)
}
