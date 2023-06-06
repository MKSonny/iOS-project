//
//  PlanGroupViewController.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/03.
//

import UIKit

class PlanGroupViewController: UIViewController {
    
    @IBAction func editingPlans(_ sender: UIButton) {
        if planGroupTableView.isEditing == true {
            planGroupTableView.isEditing = false
            sender.setTitle("Edit", for: .normal)
        } else {
            planGroupTableView.isEditing = true
            sender.setTitle("Done", for: .normal)
        }
    }
    
    @IBAction func addingPlan(_ sender: UIButton) {
        let plan = Plan(date: nil, withData: true)        // 가짜 데이터 생성
        planGroup.saveChange(plan: plan, action: .Add)    // 단지 데이터베이스에 저장만한다. 그러면 receivingNotification 함수가 호출되고 tableView.reloadData()를 호출하여 생성된 데이터가 테이블뷰에 보이게 된다.
    }
    
    @IBOutlet weak var planGroupTableView: UITableView!
    var planGroup: PlanGroup!

    override func viewDidLoad() {
        super.viewDidLoad()
        planGroupTableView.dataSource = self        // 테이블뷰의 데이터 소스로 등록

        // 단순히 planGroup객체만 생성한다
        planGroup = PlanGroup(parentNotification: receivingNotification)
        planGroup.queryData(date: Date())       // 이달의 데이터를 가져온다. 데이터가 오면 planGroupListener가 호출된다.
    }

    func receivingNotification(plan: Plan?, action: DbAction?){
        // 데이터가 올때마다 이 함수가 호출되는데 맨 처음에는 기본적으로 add라는 액션으로 데이터가 온다.
        self.planGroupTableView.reloadData()  // 속도를 증가시키기 위해 action에 따라 개별적 코딩도 가능하다.
    }
}

extension PlanGroupViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let planGroup = planGroup{
            return planGroup.getPlans().count
        }
        return 0    // planGroup가 생성되기전에 호출될 수도 있다
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .value1, reuseIdentifier: "PlanTableViewCell") // TableViewCell을 생성한다
  
        // planGroup는 대략 1개월의 플랜을 가지고 있다.
        let plan = planGroup.getPlans()[indexPath.row] // Date를 주지않으면 전체 plan을 가지고 온다

        // 적절히 cell에 데이터를 채움
        cell.textLabel!.text = plan.date.toStringDateTime()
        cell.detailTextLabel?.text = plan.content
        
        return cell
    }
}

extension PlanGroupViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let plan = self.planGroup.getPlans()[indexPath.row]
            
            self.planGroup.saveChange(plan: plan, action: .Delete)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let from = planGroup.getPlans()[sourceIndexPath.row]
        let to = planGroup.getPlans()[destinationIndexPath.row]
        planGroup.changePlan(from: from, to: to)
        tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
    }
}
