//
//  LoginViewController2.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/15.
//

import UIKit

class LoginViewController2: UIViewController {
    var emailTextField: UITextField!
    var passwordTextField: UITextField!
    var loginButton: UIButton!
    var registerButton: UIButton!
    var privacyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 다크모드 사용 가능하게 해준다.
        view.backgroundColor = .systemBackground
        
        emailTextField = createTextField(placeHolder: "이메일 입력...", frame: CGRect(x: 20, y: view.safeAreaInsets.top + 100, width: view.bounds.width - 49, height: 52))
        
        passwordTextField = createTextField(placeHolder: "비밀번호 입력...", frame: CGRect(x: 20, y: emailTextField.frame.maxY + 20, width: view.bounds.width - 49, height: 52))
        
        loginButton = createButton(title: "로그인", frame: CGRect(x: 20, y: passwordTextField.frame.maxY + 20, width: view.bounds.width - 49, height: 52), color: .systemGreen)
        
        registerButton = createButton(title: "회원가입", frame: CGRect(x: 20, y: passwordTextField.frame.maxY + 400, width: view.bounds.width - 49, height: 52), color: .systemBlue)
        
        privacyButton = createButton(title: "개인정보 처리 방침", frame: CGRect(x: 20, y: registerButton.frame.maxY + 20, width: view.bounds.width - 49, height: 52), color: .systemBlue)
        
        loginButton.addTarget(self, action: #selector(tappedLoginButton), for: .touchUpInside)
        
        registerButton.addTarget(self, action: #selector(tappedRegisterButton), for: .touchUpInside)
        
        privacyButton.addTarget(self, action: #selector(tappedPrivacyButton), for: .touchUpInside)
    }
}

extension LoginViewController2 {
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
    
    @objc func tappedLoginButton() {
        let email = emailTextField.text
        let password = passwordTextField.text
        AuthDatabase.shared.loginCheck(email: email, password: password!) { good in
            DispatchQueue.main.async {
                if good {
                    self.dismiss(animated: true)
                } else {
                    let alertController = UIAlertController(title: "오류", message: "이메일 혹은 비밀번호를 잘못 입력하셨습니다", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "확인", style: .cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func tappedRegisterButton() {
        let registerVC = RegisterViewController2()
        registerVC.modalPresentationStyle = .fullScreen
        present(registerVC, animated: true)
    }
    
    @objc func tappedPrivacyButton() {
        let webVC = PrivacyInfoViewController()
        present(webVC, animated: true)
    }
}
