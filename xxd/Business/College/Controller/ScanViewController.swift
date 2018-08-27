//
//  ScanViewController.swift
//  xxd
//
//  Created by remy on 2018/5/9.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import UIKit

private let scannerX: CGFloat = 58.0 * XDSize.scaleRatio
private let scannerY: CGFloat = 101.0 * XDSize.scaleRatio
private let scannerWidth: CGFloat = XDSize.screenWidth - 2.0 * scannerX

class ScanViewController: SSViewController {
    
    private var session: AVCaptureSession?
    private lazy var filterLayer: CAShapeLayer = {
        let maskLayer: CAShapeLayer = CAShapeLayer()
        let path: UIBezierPath = UIBezierPath(rect: CGRect(x: 0.0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.screenHeight - XDSize.topHeight))
        let scannerPath: UIBezierPath = UIBezierPath(rect: self.scannerView.frame)
        path.append(scannerPath)
        maskLayer.path = path.cgPath
        maskLayer.fillRule = kCAFillRuleEvenOdd
        maskLayer.fillColor = UIColor(white: 0.0, alpha: 0.5).cgColor
        maskLayer.strokeColor = UIColor.clear.cgColor
        return maskLayer
    }()
    private lazy var scannerView: ScannerView = ScannerView(frame: CGRect(x: scannerX, y: scannerY + XDSize.topHeight, width: scannerWidth, height: scannerWidth))
    private lazy var tipLabel: UILabel = UILabel(frame: CGRect(x: 0.0, y: self.scannerView.bottom + 24.0, width: XDSize.screenWidth, height: 20.0), text: "扫描网页版登录界面的二维码进行登录", textColor: UIColor(white: 1.0, alpha: 0.6), fontSize: 14.0)
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let session = session {
            session.startRunning()
            scannerView.animateScannerLines()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let session = session {
            session.stopRunning()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.backgroundColor = XDColor.itemTitle
        navigationBar.leftItem.image = UIImage(named: "top_left_arrow_white")
        navigationBar.centerTitle = "登录选校帝网页版"
        navigationBar.centerItem.textColor = .white
        navigationBar.bottomLine.isHidden = true
        view.addSubview(scannerView)
        view.layer.addSublayer(filterLayer)
        tipLabel.textAlignment = .center
        view.addSubview(tipLabel)
        configureCameraSession()
    }
    
    private func configureCameraSession() {
        guard let device: AVCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        do {
            let input = try AVCaptureDeviceInput(device: device)
            let output = AVCaptureMetadataOutput()
            output.setMetadataObjectsDelegate(self, queue: .main)
            output.rectOfInterest = CGRect(x: scannerY/(XDSize.screenHeight-XDSize.topHeight), y: scannerX/XDSize.screenWidth, width: scannerWidth/(XDSize.screenHeight-XDSize.topHeight), height: scannerWidth/XDSize.screenWidth)
            session = AVCaptureSession()
            session?.sessionPreset = .high
            session?.addInput(input)
            session?.addOutput(output)
            output.metadataObjectTypes = [.qr]
            let previewLayer = AVCaptureVideoPreviewLayer(session: session!)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = CGRect(x: 0.0, y: XDSize.topHeight, width: XDSize.screenWidth, height: XDSize.screenHeight-XDSize.topHeight)
            view.layer.insertSublayer(previewLayer, at: 0)
            session?.startRunning()
        } catch {
            XDPopView.toast(error.localizedDescription)
        }
    }
    
    private func codeVerify(_ str: String) {
        XDPopView.loading()
        SSNetworkManager.shared().post(XD_API_QRCODE_VERIFY, parameters: ["token": str], success: {
            [weak self] (_, response) in
            guard let sSelf = self else { return }
            let res = ((response as! [String : Any])["data"] as? Bool) ?? false
            if res {
                let vc = ScanWebLoginViewController()
                vc.token = str
                XDRoute.pushToVC(vc)
                XDPopView.hide()
            } else {
                sSelf.session?.startRunning()
                XDPopView.toast("请刷新二维码重试")
            }
            }, failure: {
                [weak self] (_, error) in
                guard let sSelf = self else { return }
                sSelf.session?.startRunning()
                XDPopView.toast(error.localizedDescription)
        })
    }
}

extension ScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count > 0 {
            session?.stopRunning()
            let first = metadataObjects.first as? AVMetadataMachineReadableCodeObject
            guard let scannerValue = first?.stringValue else {
                return
            }
            if XDUser.shared.hasLogin() {
                codeVerify(scannerValue)
            } else {
                let vc = SignInViewController()
                presentModalViewController(vc, animated: true, completion: nil)
            }
        }
    }
    
}
