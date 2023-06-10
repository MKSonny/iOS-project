//
//  LoginViewController.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/10.
//

import UIKit

class LoginViewController: UIViewController {
    struct Contants {
        static let cornerRadius: CGFloat = 8.0
    }
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email Address..."
        field.returnKeyType = .next
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.masksToBounds = true
        field.layer.cornerRadius = Contants.cornerRadius
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.secondaryLabel.cgColor
        return field
    }()
    
    private let passwordTextField: UITextField = {
        let field = UITextField()
        field.isSecureTextEntry = true
        field.placeholder = "Password..."
        field.returnKeyType = .continue
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.masksToBounds = true
        field.layer.cornerRadius = Contants.cornerRadius
        // for dark mode
        field.backgroundColor = .secondarySystemBackground
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.secondaryLabel.cgColor
        return field
    }()
    
    private let logInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign In", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Contants.cornerRadius
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logInButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)

        view.addSubview(emailField)
        view.addSubview(passwordTextField)
        view.addSubview(logInButton)
        view.backgroundColor = .systemBackground
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        emailField.frame = CGRect(x: 20, y: view.top+100, width: view.width-49, height: 52)
        passwordTextField.frame = CGRect(x: 20, y: emailField.bottom+10, width: view.width-49, height: 52)
        logInButton.frame = CGRect(x: 20, y: passwordTextField.bottom+10, width: view.width-49, height: 52)
    }
    
    @objc func didTapLogin() {
        let email = emailField.text
        let password = passwordTextField.text
        AuthDatabase.shared.loginCheck(email: email, password: password!) { good in
            DispatchQueue.main.async {
                if good {
                    self.dismiss(animated: true)
                } else {
                    print("not good")
                }
            }
        }
    }
}
