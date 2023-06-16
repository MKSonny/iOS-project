//
//  AlbumMemoViewController.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/14.
//

import UIKit
import Photos
import AVFoundation
import Vision

class AlbumMemoViewController: UIViewController {
    // 카메라를 사용하여 촬영할 경우
    @IBOutlet weak var takePictureButton: UIButton!
    // 실시간으로 UIImageView를 보려고 시도했으나 실패했다
    var captureSession: AVCaptureSession?
    // 카메라로 촬영한 이미지를 확인할 liveImageView 변수
    @IBOutlet weak var liveImageView: UIImageView!
    // 내가 올린 게시물들을 담기 위한 postGroup 변수
    var postGroup: PostGroup!
    
    
    @IBAction func tapTakePicture(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self // 이 딜리게이터를 설정하면 사진을 찍은후 호출된다

        imagePickerController.sourceType = .camera

        // UIImagePickerController이 활성화 된다, 11장을 보라
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // collection view를 위한 변수
    @IBOutlet weak var collectionView: UICollectionView!
    var fetchResult: PHFetchResult<PHAsset>! // 사진에 대한 데이터 저장
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "게시물 작성"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didtapLiveImageView))
        liveImageView.addGestureRecognizer(tap)
        liveImageView.isUserInteractionEnabled = true

//        if captureSession == nil {
//                captureSession = AVCaptureSession()
//                if let videoInput = createVideoInput(), let videoOutput = createVideoOutput() {
//                    if captureSession!.canAddInput(videoInput) && captureSession!.canAddOutput(videoOutput) {
//                        captureSession!.addInput(videoInput)
//                        captureSession!.addOutput(videoOutput)
//                        attachPreviewer(captureSession: captureSession!)
//                    }
//                }
//            }
//
//            if let captureSession = captureSession {
//                if !captureSession.isRunning {
//                    captureSession.startRunning()
//                }
//            }
        
        liveImageView.image = UIImage(named: "helloworld")
//        let tap2 = UITapGestureRecognizer(target: self, action: #selector(takePicture2))
//        liveImageView.addGestureRecognizer(tap2)
//        liveImageView.isUserInteractionEnabled = true
        
        // 모든 사진을 가져온다
        let allPhotosOptions = PHFetchOptions()
        // 생성된 날짜 순으로 정렬한다
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @objc func didtapLiveImageView() {
        performSegue(withIdentifier: "ShowDetail", sender: liveImageView.image)
    }
}

// 이미지 뷰에 실시간으로 계속 받아오는 영상 데이터를 버퍼에 담아서 이미지 뷰 화면에 뿌려준다.
//extension AlbumMemoViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
//    func createVideoInput() -> AVCaptureDeviceInput? {
//        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
//            return try? AVCaptureDeviceInput(device: device)
//        }
//        return nil
//    }
//    func createVideoOutput() -> AVCaptureVideoDataOutput? {
//        let videoOutput = AVCaptureVideoDataOutput()
//        let settings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)]
//        videoOutput.videoSettings = settings
//        videoOutput.alwaysDiscardsLateVideoFrames = true
//        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global())
//        return videoOutput
//    }
//
//    func attachPreviewer(captureSession: AVCaptureSession) {
//        let avCaptureImagePreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        avCaptureImagePreviewLayer.frame = liveImageView.layer.bounds
//        avCaptureImagePreviewLayer.videoGravity = .resize
//        liveImageView.layer.addSublayer(avCaptureImagePreviewLayer)
//    }
//
//    @objc func takePicture2(sender: UITapGestureRecognizer) {
//        if let captureSession = captureSession {
//            if captureSession.isRunning {
//                captureSession.stopRunning()
//            } else {
//                captureSession.startRunning()
//            }
//            return
//        }
//
//        performSegue(withIdentifier: "ShowDetail", sender: sender)
//    }
//}

extension AlbumMemoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 만약 fetchResult nil이면 아직 다 못 읽어왔다는 거니까 일단 0을 리턴한다.
        return fetchResult == nil ? 0: fetchResult.count
    }
    
    // 사진의 크기를 조정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 119, height: 119)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        
        // 해당 인덱스에 맞는 앨범 이미지 메타 데이터를 가져온다.
        let asset = fetchResult.object(at: indexPath.row)
        PHCachingImageManager.default().requestImage(for: asset, targetSize: CGSize(), contentMode: .aspectFill, options: nil) {
            (image, _) in // 요청한 이미지를 디스크로부터 읽으면 이 함수가 호출 된다.
            cell.imageView.image = image
        }
        return cell
    }
}

extension AlbumMemoViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 이 이미지를 클릭하면 자세히 보기로 전이한다. Send가 self가 아니고 클릭된 Cell의 indexPath이다.
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }
}
extension AlbumMemoViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let newPostViewController = segue.destination as! NewPostViewController
        newPostViewController.postGroup = postGroup
        
        // 이미지에 대한 정보를 가져온다
        if sender is IndexPath {
            let indexPath = sender as! IndexPath    // sender이 indexPath이다.
            let asset = fetchResult.object(at: indexPath.row)
            
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat // 고해상도를 가져오기 우l함임
            PHCachingImageManager.default().requestImage(for: asset, targetSize: CGSize(), contentMode: .aspectFill, options: options, resultHandler: { image, _ in
                // 한참있다가 실행된다. 즉, albumDetailViewController가 로딩되고 appear한 후에 나타난다.
                newPostViewController.image = image  // 앞에서 didSet을 사용한 이유이다.
            })
        } else {
            // 카메라를 사용하여 촬영할 경우
            let senderImage = sender as! UIImage
            newPostViewController.image = senderImage
        }
    }
}

// 카메라를 사용해 촬영할 경우 처리
extension AlbumMemoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // 사진을 찍은 경우 호출되는 함수
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
 
       let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        // 여기서 이미지에 대한 추가적인 작업을 한다
        liveImageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }

    // 사진 캡쳐를 취소하는 경우 호출 함수
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // imagePickerController을 죽인다
        picker.dismiss(animated: true, completion: nil)
    }
}
