//
//  RegisterViewController.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/06.
//

import UIKit

class RegisterViewController: UIViewController {
    
    struct Contants {
        static let cornerRadius: CGFloat = 8.0
    }
    
    private let usernameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Username..."
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
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Contants.cornerRadius
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        
        usernameField.delegate = self
        emailField.delegate = self
        passwordTextField.delegate = self

        
        view.addSubview(usernameField)
        view.addSubview(emailField)
        view.addSubview(passwordTextField)
        view.addSubview(registerButton)
        view.backgroundColor = .systemBackground
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        usernameField.frame = CGRect(x: 20, y: view.safeAreaInsets.top+100, width: view.width-49, height: 52)
        emailField.frame = CGRect(x: 20, y: usernameField.bottom+10, width: view.width-49, height: 52)
        passwordTextField.frame = CGRect(x: 20, y: emailField.bottom+10, width: view.width-49, height: 52)
        registerButton.frame = CGRect(x: 20, y: passwordTextField.bottom+10, width: view.width-49, height: 52)
    }
    
    @objc private func didTapRegister() {
        usernameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty, password.count >= 1,
              let username = usernameField.text, !username.isEmpty else {
            return
        }
        
        AuthDatabase.shared.makeNewUser(username: username, email: email, password: password) { registered in
            // 결과에 따라서 ui를 업데이트 한다.
            DispatchQueue.main.async {
                if registered {
                    self.dismiss(animated: true)
                } else {
                    
                }
            }
        }
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            emailField.becomeFirstResponder()
        }
        else if textField == emailField {
            passwordTextField.becomeFirstResponder()
        }
        else {
            didTapRegister()
        }
        return true
    }
}

