//
//  CameraViewController.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/05.
//

import UIKit
import FirebaseStorage
import FirebaseAuth

class CameraViewController: UIViewController {
    @IBOutlet weak var previewImageView: UIImageView!
    var postGroup: PostGroup!
    var imageUrl: String!
    var username: String!
    var writerImage: String!
    var uid: String!
    
    @IBAction func addButton(_ sender: UIButton) {
        print("imageUrl 성공 \(imageUrl)")
        
        let post = Post(imageUrl: imageUrl!,username: username, uid: uid,writerImage: writerImage, date: Date().setCurrentTime(), content: "hello world", likes: 0)
        
        postGroup.saveChange(post: post, action: .Add)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser?.uid
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self // 이 딜리게이터를 설정하면 사진을 찍은 후 호출된다

        // 이미지 피커 컨트롤러 소스 타입 설정
        // if UIImagePickerController.isSourceTypeAvailable(.camera) {
        //     imagePickerController.sourceType = .camera
        // } else {
        //     imagePickerController.sourceType = .photoLibrary
        // }

        imagePickerController.sourceType = .photoLibrary

        // UIImagePickerController 활성화
        present(imagePickerController, animated: true, completion: nil)
    }
    
//    func receivingNotification(post: Post?, action: PostDbAction?){
//        // 데이터가 올때마다 이 함수가 호출되는데 맨 처음에는 기본적으로 add라는 액션으로 데이터가 온다.
//        self.tableView.reloadData()  // 속도를 증가시키기 위해 action에 따라 개별적 코딩도 가능하다.
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("please work: \(uid)")
        MyUserFirebaseDatabase.shared.findUsernameAndProfileImageWithUid(with: uid) { writer, writerImage in
            self.username = writer
            print("done \(writer)")
            self.writerImage = writerImage
        }
//        MyDatabase.shared.findUsernameAndProfileImage(with: Auth.auth().currentUser!.uid) { userName, imageUrl in
//            self.writer = userName
//            self.writerImage = imageUrl
//        }
    }
}

extension CameraViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // 사진을 찍은 경우 호출되는 함수
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
 
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            uploadImage(image: image, pathRoot: "post_image") { url in
                if let url = url {
                    self.imageUrl = url.absoluteString
                    print("업로드 성공 \(url)")
                }
            }
            previewImageView.image = image
        }
        
        picker.dismiss(animated: true, completion: nil)
    }

    // 사진 캡쳐를 취소하는 경우 호출 함수
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

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
