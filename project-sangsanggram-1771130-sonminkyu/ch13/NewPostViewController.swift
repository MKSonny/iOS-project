//
//  NewPostViewController.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/14.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import Vision
import AVKit

class NewPostViewController: UIViewController {

    // 객체 딥러닝
    var vnCoreMLRequest: VNCoreMLRequest!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var textView: UITextView!
    var postGroup: PostGroup!
    var imageUrl: String!
    var username: String!
    var writerImage: String!
    var uid: String!
    // 오토레이아웃을 프로그램으로 조정할 수 있다.
    @IBOutlet weak var bottomViewContraint: NSLayoutConstraint!
    @IBAction func addPostButton(_ sender: UIBarButtonItem) {
        let content = textView.text
        let comments: [String: String] = [uid: content ?? ""]
        let post = Post(imageUrl: imageUrl!,username: username, uid: uid,writerImage: writerImage, date: Date().setCurrentTime(), content: content ?? "", likes: 0, comments: [comments])
        
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
            guard let ciImage = CIImage(image: image!) else {
                return
            }
            let handler = VNImageRequestHandler(ciImage: ciImage)
            DispatchQueue.main.async {
                do {
                    try handler.perform([self.vnCoreMLRequest])
                } catch {
                    print("Error: \(error)")
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 여기까지 와도 이미지가 설정이 안되어있을 수 있다.
        imageView.image = image ?? nil
        
        vnCoreMLRequest = createCoreML(modelName: "SqueezeNet", modelExt: "mlmodelc", completionHandler: handleImageClassifier)
        
        
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
        textView.resignFirstResponder()
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

extension NewPostViewController {
    /*
     "createCoreML(modelName:modelExt:completionHandler:)" 함수는 Core ML 모델을 사용하여 "VNCoreMLRequest"를 생성하는 함수다. 이 함수는 앱 번들에서 모델을 로드하고 모델을 사용하여 요청을 생성한다. 제공된 completionHandler는 요청이 완료될 때 호출한다.
     */
    func createCoreML(modelName: String, modelExt: String, completionHandler: @escaping (VNRequest, Error?) -> Void) -> VNCoreMLRequest?{
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: modelExt) else {
            return nil
        }
        guard let vnCoreMLModel = try? VNCoreMLModel(for: MLModel(contentsOf: modelURL)) else{
            return nil
        }
        return VNCoreMLRequest(model: vnCoreMLModel, completionHandler: completionHandler)
    }
}

extension NewPostViewController{
    /*
     handleImageClassifier(request:error:)" 메서드는 분류 결과를 처리한다. 이 메서드는 요청 결과에서 분류 관측값을 가져와 가장 높은 결과의 확률과 식별자를 "textView"에 업데이트한다.
     */
    func handleImageClassifier(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation] else { return }
        if let topResult = results.first {
            DispatchQueue.main.async {
                self.textView.text = "#\(topResult.identifier)"
            }
        }
    }
}

extension NewPostViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        // 여기서 이미지가 담겨져 온 sampleBuffer에 대한 처리를 하면된다.
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let handler = VNImageRequestHandler(ciImage: ciImage)
        try! handler.perform([vnCoreMLRequest])
    }
}
