//
//  PrivacyInfoViewController.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/15.
//

import UIKit
import WebKit

class PrivacyInfoViewController: UIViewController {

    var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView()
        
        view.addSubview(webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        var urlString = "https://www.hansung.ac.kr/sites/hansung/index.do"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        let session = URLSession(configuration: .default)
        DispatchQueue.main.async {
            self.webView.load(request)
        }
    }
}
