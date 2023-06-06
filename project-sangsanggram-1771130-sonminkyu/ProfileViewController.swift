//
//  ProfileViewController.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/06.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    var uid: String!
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        AuthDatabase.shared.logOut { sucess in
            DispatchQueue.main.async {
                if sucess {
                    // present login
                    let loginVC = RegisterViewController()
                    loginVC.modalPresentationStyle = .fullScreen
                    self.present(loginVC, animated: true) {
                        self.navigationController?.popToRootViewController(animated: false)
                        self.tabBarController?.selectedIndex = 0
                    }
                } else {
                    
                }
            }
        }
    }
    
    @IBOutlet weak var userPostCount: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func downloadImage(imageView: UIImageView, url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
        }.resume()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        MyDatabase.shared.findUsernameAndProfileImage(with: Auth.auth().currentUser!.uid) { username, profileUrl in
            print("username 로딩 성공 \(username)")
            self.userName.text = username
            self.downloadImage(imageView: self.profileImage, url: URL(string: profileUrl!)!)
        }
    }
}

