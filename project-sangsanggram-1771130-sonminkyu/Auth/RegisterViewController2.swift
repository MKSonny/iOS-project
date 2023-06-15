//
//  RegisterViewController2.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/15.
//

import UIKit

class RegisterViewController2: UIViewController {
    
    var usernameTextField: UITextField!
    
    var emailTextField: UITextField!
    
    var passwordTextField: UITextField!
    
    var cancelButton: UIButton!
    
    var registerButton: UIButton!
    
    var privacyPolicy: UIButton!
    
    private func createTextField(placeHolder: String, frame: CGRect) -> UITextField {
        let textField = UITextField(frame: frame)
        textField.textAlignment = .center
        textField.placeholder = placeHolder
        textField.font = UIFont.systemFont(ofSize: 20) // Adjust the font size as needed
        textField.keyboardType = .default
        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = true
        textField.layer.cornerRadius = 8.0
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        return textField
    }
    
    private func createButton(title: String, frame: CGRect, color: UIColor) -> UIButton {
        let button = UIButton(frame: frame)
        button.setTitle(title, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8.0
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        view.addSubview(button)
        return button
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        usernameTextField = createTextField(placeHolder: "이름 입력...", frame: CGRect(x: 20, y: view.safeAreaInsets.top + 100, width: view.bounds.width - 49, height: 52))
        emailTextField = createTextField(placeHolder: "이메일 입력...", frame: CGRect(x: 20, y: usernameTextField.frame.maxY + 20, width: view.bounds.width - 49, height: 52))
        passwordTextField = createTextField(placeHolder: "비밀번호 입력...", frame: CGRect(x: 20, y: emailTextField.frame.maxY + 20, width: view.bounds.width - 49, height: 52))
        
        registerButton = createButton(title: "회원가입", frame: CGRect(x: 20, y: passwordTextField.frame.maxY + 20, width: view.bounds.width - 49, height: 52), color: .systemGreen)
        
        cancelButton = createButton(title: "취소", frame: CGRect(x: 20, y: registerButton.frame.maxY + 20, width: view.bounds.width - 49, height: 52), color: .systemGray2)
        
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        
        registerButton.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
    }
    
    
}

extension RegisterViewController2 {
    @objc func didTapRegisterButton() {
        usernameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty, password.count >= 1,
              let username = usernameTextField.text, !username.isEmpty else {
            return
        }
        
        AuthDatabase.shared.makeNewUser(username: username, email: email, password: password) { registered in
            // 결과에 따라서 ui를 업데이트 한다.
            DispatchQueue.main.async {
                if registered {
                    self.dismiss(animated: true)
                } else {
                    let vc = AlertViewController()
                    self.present(vc, animated: true)
                }
            }
        }
    }
    
    @objc func didTapCancelButton() {
        dismiss(animated: true)
    }
}

extension RegisterViewController2 {
    func connectVertically(views: UIView..., spacing: CGFloat){
        for i in 0..<views.count - 1{
            views[i].bottomAnchor.constraint(equalTo: views[i+1].topAnchor, constant: spacing).isActive = true
        }
    }
    func connectHorizontally(views: UIView...){
        for view in views{
            view.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        }
    }
}

