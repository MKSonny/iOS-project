//
//  NewPostViewController.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/14.
//

import UIKit
import FirebaseStorage
import FirebaseAuth

class NewPostViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var textField: UITextField!
    var postGroup: PostGroup!
    var imageUrl: String!
    var username: String!
    var writerImage: String!
    var uid: String!
    // 오토레이아웃을 프로그램으로 조정할 수 있다.
    @IBOutlet weak var bottomViewContraint: NSLayoutConstraint!
    @IBAction func addPostButton(_ sender: UIBarButtonItem) {
        print("hello world 11")
        
        let post = Post(imageUrl: imageUrl!,username: username, uid: uid,writerImage: writerImage, date: Date().setCurrentTime(), content: "hello world", likes: 0)
        
        postGroup.saveChange(post: post, action: .Add)
        navigationController?.popViewController(animated: true)
    }
    
    var image: UIImage? {
        // image 값이 변경되면 항상 didSet가 호출된다.
        // viewDidLoad에서 이미지가 nil로 설정되어도
        // 이후 이미지가 설정되면 아래 didSet 함수가 호출되어
        // 이미지가 나타난다.
        didSet {
            if let imageView = imageView {
                imageView.image = image
                uploadImage(image: image!, pathRoot: "post_image") { url in
                    if let url = url {
                        self.imageUrl = url.absoluteString
                        print("업로드 성공 \(url)")
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 여기까지 와도 이미지가 설정이 안되어있을 수 있다.
        imageView.image = image ?? nil
        
        // 키보드가 나타나면 keyboardWillShow 함수를 호출한다
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillShow),
                  name: UIResponder.keyboardWillShowNotification, object: nil
                )
                // 키보드가 사라지면 keyboardWillHide 함수를 호출한다
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillHide),
                  name: UIResponder.keyboardWillHideNotification,object: nil
                )
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(removeKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        uid = Auth.auth().currentUser?.uid
        MyUserFirebaseDatabase.shared.findUsernameAndProfileImageWithUid(with: uid) { writer, writerImage in
            self.username = writer
            self.writerImage = writerImage
        }
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height  // 키보드의 높이를 구한다
            bottomViewContraint.constant = keyboardHeight   // 스택뷰의 하단 여백을 높인다
        }
    }
    @objc private func keyboardWillHide(_ notification: Notification) {
        bottomViewContraint.constant = 8     // 스택뷰의 하단 여백을 원래대로 설정한다
    }
    @objc func removeKeyboard(sender: UITapGestureRecognizer){
        textField.resignFirstResponder()
    }
}

extension NewPostViewController {
    func uploadImage(image: UIImage, pathRoot: String, completion: @escaping (URL?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.4) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        let imageName = UUID().uuidString + String(Date().timeIntervalSince1970)
        
        let firebaseReference = Storage.storage().reference().child("\(imageName)")
        firebaseReference.putData(imageData, metadata: metaData) { metaData, error in
            firebaseReference.downloadURL { url, _ in
                completion(url)
            }
        }
    }
}
