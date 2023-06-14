//
//  AlbumMemoViewController.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/14.
//

import UIKit
import Photos
import AVFoundation

class AlbumMemoViewController: UIViewController {
    // live 이미지 처리를 위한 변수
    @IBOutlet weak var takePictureButton: UIButton!
    var captureSession: AVCaptureSession?
    @IBOutlet weak var liveImageView: UIImageView!

    // collection view를 위한 변수
    @IBOutlet weak var collectionView: UICollectionView!
    var fetchResult: PHFetchResult<PHAsset>! // 사진에 대한 데이터 저장
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "게시물 작성"
        
        takePictureButton.addTarget(self, action: #selector(takeLivePicture), for: .touchUpInside)

        if captureSession == nil {
                captureSession = AVCaptureSession()
                if let videoInput = createVideoInput(), let videoOutput = createVideoOutput() {
                    if captureSession!.canAddInput(videoInput) && captureSession!.canAddOutput(videoOutput) {
                        captureSession!.addInput(videoInput)
                        captureSession!.addOutput(videoOutput)
                        attachPreviewer(captureSession: captureSession!)
                    }
                }
            }
            
            if let captureSession = captureSession {
                if !captureSession.isRunning {
                    captureSession.startRunning()
                }
            }
        
        liveImageView.image = UIImage(named: "helloworld")
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(takePicture2))
        liveImageView.addGestureRecognizer(tap2)
        liveImageView.isUserInteractionEnabled = true
        
        // 모든 사진을 가져온다
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @objc func takeLivePicture() {
        
    }
}

// 이미지 뷰에 실시간으로 계속 받아오는 영상 데이터를 버퍼에 담아서 이미지 뷰 화면에 뿌려준다.
extension AlbumMemoViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func createVideoInput() -> AVCaptureDeviceInput? {
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return try? AVCaptureDeviceInput(device: device)
        }
        return nil
    }
    func createVideoOutput() -> AVCaptureVideoDataOutput? {
        let videoOutput = AVCaptureVideoDataOutput()
        let settings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)]
        videoOutput.videoSettings = settings
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global())
        return videoOutput
    }
    
    func attachPreviewer(captureSession: AVCaptureSession) {
        let avCaptureImagePreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        avCaptureImagePreviewLayer.frame = liveImageView.layer.bounds
        avCaptureImagePreviewLayer.videoGravity = .resize
        liveImageView.layer.addSublayer(avCaptureImagePreviewLayer)
    }
    
    @objc func takePicture2(sender: UITapGestureRecognizer) {
        if let captureSession = captureSession {
            if captureSession.isRunning {
                captureSession.stopRunning()
            } else {
                captureSession.startRunning()
            }
            return
        }
        
        captureSession.ou
        
        performSegue(withIdentifier: "ShowDetail", sender: sender)
    }
}

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
        
        // 이미지에 대한 정보를 가져온다
        let indexPath = sender as! IndexPath    // sender이 indexPath이다.
        let asset = fetchResult.object(at: indexPath.row)
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat // 고해상도를 가져오기 우l함임
        PHCachingImageManager.default().requestImage(for: asset, targetSize: CGSize(), contentMode: .aspectFill, options: options, resultHandler: { image, _ in
            // 한참있다가 실행된다. 즉, albumDetailViewController가 로딩되고 appear한 후에 나타난다.
            newPostViewController.image = image  // 앞에서 didSet을 사용한 이유이다.
        })
    }
}
