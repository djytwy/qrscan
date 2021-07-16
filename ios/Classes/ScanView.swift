//
//  ScanViewController.swift
//  qrscan
//
//  Created by 斌王 on 2020/11/20.
//

import UIKit
import AVFoundation

class ScanView: UIView, AVCaptureMetadataOutputObjectsDelegate, FlutterPlatformView {

    var delegate: ScanType?
    var session: AVCaptureSession?
    var previewLay: AVCaptureVideoPreviewLayer?

    func view() -> UIView {
        self
    }

    init(frame: CGRect, delegate: ScanType?) {
        super.init(frame: UIScreen.main.bounds)
        self.delegate = delegate
        NotificationCenter.default.addObserver(forName: Notification.Name.stopRunning, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            self?.dispose()
        }
        NotificationCenter.default.addObserver(forName: Notification.Name.startRunning, object: nil, queue: OperationQueue.main) { [weak self] notification in
            self?.startCapture()
        }
        NotificationCenter.default.addObserver(forName: Notification.Name.scanImagePath, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            self?.scanImagePath(notification: notification)
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func startCapture() {
        let block: () -> Void = {
            guard let device = AVCaptureDevice.default(for: .video) else {
                NotificationCenter.default.post(name: Notification.Name.permissionDenied, object: ScanErrorCode.notSupport)
                return
            }
            guard let input = try? AVCaptureDeviceInput.init(device: device) else {
                NotificationCenter.default.post(name: Notification.Name.permissionDenied, object: ScanErrorCode.notSupport)
                return
            }

            let output: AVCaptureMetadataOutput = {
                let outPut = AVCaptureMetadataOutput.init()
                outPut.connection(with: .metadata)
                return outPut
            }()

            let session: AVCaptureSession = {
                let session = AVCaptureSession.init()
                if session.canSetSessionPreset(.high) {
                    session.sessionPreset = .high
                }
                return session
            }()

            let preLayer = AVCaptureVideoPreviewLayer.init()

            output.setMetadataObjectsDelegate(self as AVCaptureMetadataOutputObjectsDelegate, queue: DispatchQueue.main)
            preLayer.session = session;

            if session.canAddInput(input) && session.canAddOutput(output) {
                session.addInput(input)
                session.addOutput(output)
                output.metadataObjectTypes = [.qr]
            }
            preLayer.videoGravity = .resizeAspectFill
            preLayer.frame = self.bounds
            self.layer.insertSublayer(preLayer, at: 0)
            session.startRunning()
        }
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined, .restricted:
            AVCaptureDevice.requestAccess(for: .video) { flag in
                DispatchQueue.main.async {
                    if flag {
                        block()
                    } else {
                        NotificationCenter.default.post(name: Notification.Name.permissionDenied, object: ScanErrorCode.notSupport)
                    }
                }
            }
        case .denied:
            NotificationCenter.default.post(name: Notification.Name.permissionDenied, object: ScanErrorCode.permissionDenied)
        case .authorized:
            block()
        @unknown default:
            print("")
        }
    }


    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for obj in metadataObjects {
            guard let codeObj = obj as? AVMetadataMachineReadableCodeObject else {
                return
            }
            delegate?.didScanResult(codeObj.stringValue ?? "")
        }
    }

    func scanImagePath(notification: Notification) {
        guard let args = notification.userInfo?["arguments"]  as? Dictionary<String, Any>, let path = args["path"] as? String else {
            return
        }
        
        let fh = FileHandle.init(forReadingAtPath: path)
        if let data = fh?.readDataToEndOfFile(), let ciImage = CIImage.init(data: data) {
            var options: [String: Any]
            let context = CIContext()
                    options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
                    let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
                    if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)){
                        options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
                    } else {
                        options = [CIDetectorImageOrientation: 1]
                    }
                    let features = qrDetector?.features(in: ciImage, options: options)
            
            _ = features?.compactMap { feature in
                if let res = (feature as? CIQRCodeFeature)?.messageString {
                    delegate?.didScanResult(res)
                }
            }
        }
    }    

    func dispose() {
        session?.stopRunning()
    }

}
