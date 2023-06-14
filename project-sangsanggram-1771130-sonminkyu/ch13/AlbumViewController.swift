//
//  AlbumViewController.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/14.
//

import UIKit
import Photos
import AVFoundation

class AlbumViewController: UIViewController {

    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    
    var captureSession: AVCaptureSession?
    var count: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap1 = UITapGestureRecognizer(target: self, action: #selector(takePicture1))
        imageView1.addGestureRecognizer(tap1)
        // 이미지뷰가 유저와 인터렉션 할 수 있도록 해준다.
        imageView1.isUserInteractionEnabled = true
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(takePicture2))
        imageView2.addGestureRecognizer(tap2)
        imageView2.isUserInteractionEnabled = true
    }
    
    @objc func takePicture1(sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            imagePickerController.sourceType = .camera
//        } else {
            imagePickerController.sourceType = .photoLibrary
//        }
        present(imagePickerController, animated: true, completion: nil)
    }
}

// 이미지 뷰에 실시간으로 계속 받아오는 영상 데이터를 버퍼에 담아서 이미지 뷰 화면에 뿌려준다.
extension AlbumViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
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
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        count += 1
        print("여기서 이미지가 담겨져 온 sample buffer에 대한 처리를 하면된다. \(count)")
    }
    func attachPreviewer(captureSession: AVCaptureSession) {
        let avCaptureImagePreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        avCaptureImagePreviewLayer.frame = imageView2.layer.bounds
        avCaptureImagePreviewLayer.videoGravity = .resize
        imageView2.layer.addSublayer(avCaptureImagePreviewLayer)
    }
    
    @objc func takePicture2(sender: UITapGestureRecognizer) {
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
            if captureSession.isRunning {
                captureSession.stopRunning()
            } else {
                captureSession.startRunning()
            }
            return
        }
    }
}
/*
 사진에 대한 메타 정보하고 이미지 정보를 앨범에서는 따로따로 구분한다.
 그래서 앨범에서 어떤 이미지를 얻어오려면 이 메타 정보를 알아야 된다.
 */

extension AlbumViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    // 사진을 찍은 경우 호출되는 함수
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        // 여기서 이미지에 대한 추가적인 작업을 한다.
        // imageView1에 선택된 이미지를 출력해라
        imageView1.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 사진 캡쳐를 취소하는 경우 호출 함수
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
