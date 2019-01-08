//
//  videoVC.swift
//  VideoProject
//
//  Created by Esmeralda Angeles on 1/4/19.
//  Copyright © 2019 SmeAngeles. All rights reserved.
//

import UIKit
import AVFoundation

class videoVC: UIViewController {
    
    var session: AVCaptureSession!
    var layer: AVCaptureVideoPreviewLayer!
    var faceView: UIView?
    
    var backInput: AVCaptureDeviceInput!
    var frontInput: AVCaptureDeviceInput!
    
    var frontDeviceIndicator:  Bool = false

    @IBOutlet weak var rotate: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session =  AVCaptureSession()
        
        let backDevice = obtainDevice(position: AVCaptureDevice.Position.back)
        let frontDevice = obtainDevice(position: AVCaptureDevice.Position.front)
        
        do{backInput = try AVCaptureDeviceInput(device: backDevice!);session.addInput(backInput) }catch{ return}
        do{frontInput = try AVCaptureDeviceInput(device: frontDevice!)}catch{return}
        
        let output = AVCaptureMetadataOutput()
        
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.face]
        
        
        layer =  AVCaptureVideoPreviewLayer(session: session)
        layer.frame = view.layer.bounds
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(layer)
        
        session.startRunning()
        view.bringSubviewToFront(rotate)
        
        rotate.addTarget(self, action: #selector(rotateCamera), for: UIControl.Event.touchUpInside)
        
        faceView = UIView()
        
        faceView!.layer.borderColor = UIColor.blue.cgColor
        faceView!.layer.borderWidth = 2
        view.addSubview(faceView!)
        
        view.bringSubviewToFront(faceView!)
        

    }
    
    func obtainDevice(position: AVCaptureDevice.Position)-> AVCaptureDevice?{
        
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera],mediaType: .video, position: position)
        
        guard let device = discoverySession.devices.first else {
            print("Failed to get the camera device")
            return nil
        }
        return device
    }

    @objc func rotateCamera(){
        
        if frontDeviceIndicator{
            frontDeviceIndicator = false
            faceView?.frame = CGRect.zero
            session.removeInput(frontInput!)
            self.session.addInput(backInput)
        }else{
            frontDeviceIndicator = true
            faceView?.frame = CGRect.zero
            session.removeInput(backInput!)
            self.session.addInput(frontInput)
        }

    }
    
}

extension videoVC: AVCaptureMetadataOutputObjectsDelegate{
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        print(metadataObjects)
        if let metadataObject = metadataObjects.first {
            
            if metadataObject.type == AVMetadataObject.ObjectType.face{
                
                let barCodeObject = layer?.transformedMetadataObject(for: metadataObject)
                faceView?.frame = barCodeObject!.bounds
            }
        }
        else{
            faceView?.frame = CGRect.zero
        }
    }
}
