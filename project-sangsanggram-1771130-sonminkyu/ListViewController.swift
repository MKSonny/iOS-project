//
//  ListViewController.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/08.
//

import UIKit

class ListViewController: UIViewController {
    private let data: [String]
    
    init(data: [String]) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
    }
}
