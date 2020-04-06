//
//  CaptureViewController.swift
//  Number 2
//
//  Created by Andrew Cope on 7/19/16.
//  Copyright © 2016 Andrew Cope. All rights reserved.
//

import UIKit
import AVFoundation

class CaptureViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    
    //uiOutlets
    
    
    @IBOutlet weak var flipRC: RoundedCorners!
    @IBOutlet weak var flashRC: RoundedCorners!
    @IBOutlet weak var flashImage: UIImageView!
    
    @IBOutlet weak var flashView: UIView!
    
    
    //
    @IBOutlet weak var flipView: UIView!
    

    var messagesDelegate: ScreenToMessages? = nil
    
    @IBOutlet weak var previewImage: RoundedCorners!
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCapturePhotoOutput()
    var error: NSError?
    //var deviceInput = AVCaptureDeviceInput(device: <#T##AVCaptureDevice!#>)
    
    var previewLayer = AVCaptureVideoPreviewLayer()
    
    var cameraPosition = AVCaptureDevicePosition.front
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AVCaptureDevice.devices().count > 0 {
            if let layer = AVCaptureVideoPreviewLayer(session: captureSession) {
                previewLayer = layer
                previewLayer.bounds = previewImage.bounds
                previewLayer.position = CGPoint(x: previewImage.bounds.midX, y: previewImage.bounds.midY)
                previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                
                previewImage.layer.addSublayer(previewLayer)
                
            }
        }
        
        
        setUpCamera()
        
        previewImage.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

    
    }
    
    func flipOrNot(size:CGSize) {
        let heightTresh = 400.0
        if size.height < CGFloat(heightTresh) {
            flipView.isHidden = false
        } else {
            flipView.isHidden = true
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        flipOrNot(size: size)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        previewImage.bounceUp()
        previewLayer.bounds = previewImage.bounds
        previewLayer.position = CGPoint(x: previewImage.bounds.midX, y: previewImage.bounds.midY)
        flipOrNot(size: view.frame.size)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        previewImage.bounceDown()
    }
    
    override func viewDidLayoutSubviews() {
        previewLayer.bounds = previewImage.bounds
        previewLayer.position = CGPoint(x: previewImage.bounds.midX, y: previewImage.bounds.midY)
    }
    
    
    func setUpCamera() {
        captureSession.removeInput(deviceInput)
        captureSession.removeOutput(stillImageOutput)
        
        
        let devices = AVCaptureDevice.devices().filter{ ($0 as! AVCaptureDevice).hasMediaType(AVMediaTypeVideo) && ($0 as! AVCaptureDevice).position == cameraPosition }
        if let captureDevice = devices.first as? AVCaptureDevice  {
            
            if isFlash {
                if captureDevice.hasFlash && cameraPosition == .back {
                    do {
                        try captureDevice.lockForConfiguration()
                        captureDevice.flashMode = .on
                        captureDevice.unlockForConfiguration()
                    } catch { print("couldn't change flash mode")}
                }
            } else {
                if captureDevice.hasFlash && cameraPosition == .back {
                    do {
                        try captureDevice.lockForConfiguration()
                        captureDevice.flashMode = .off
                        captureDevice.unlockForConfiguration()
                    } catch { print("couldn't change flash mode")}
                }
            }
            
            
            
            do {
                deviceInput = try AVCaptureDeviceInput(device: captureDevice)
                captureSession.addInput(deviceInput)
            } catch { }
            captureSession.sessionPreset = AVCaptureSessionPresetPhoto
            captureSession.startRunning()
            stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
            if captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
            }

            
        }
    }
    
    
   
    
    @IBAction func capturePressed(_ sender: UIButton) {
        if self.cameraPosition == .front && self.isFlash {
            self.showFrontFlash(show: true)
        }
        
        
        stillImageOutput.captureStillImageAsynchronously(from: self.stillImageOutput.connection(withMediaType: AVMediaTypeVideo),
            completionHandler: {(imageSampleBuffer, error) in
                
            if self.cameraPosition == .front && self.isFlash {
                self.showFrontFlash(show: false)
            }
                
            if (imageSampleBuffer != nil) {
                let imageData =      AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer! as CMSampleBuffer)
                var image: UIImage = UIImage(data: imageData!)!
                
                if self.cameraPosition == .front {
                    image = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: UIImageOrientation.leftMirrored)
                }
                
                
                self.messagesDelegate?.editPic(pic: image)
            }
        })
    }
    
    
    @IBAction func flash_TouchDown(_ sender: UIButton) {
        flashRC.bounceDown()
    }
    
    
    var isFlash = false
    @IBAction func flashPressed(_ sender: UIButton) {
        flashRC.bounceUp()
        
        //then actually do something
        isFlash = !isFlash
        
        if isFlash {
            flashImage.image = #imageLiteral(resourceName: "flashOn")
        } else {
            flashImage.image = #imageLiteral(resourceName: "flashOff")
        }
        
        setUpCamera()
    }
    
    
    @IBAction func flip_TouchDown(_ sender: UIButton) {
        flipRC.bounceDown()
        
    }
    
    @IBAction func flipPressed(_ sender: UIButton) {
        flipRC.bounceUp()
        
        cameraPosition = cameraPosition == .back ? .front : .back
        setUpCamera()
    }
    
    
    func showFrontFlash(show: Bool) {
        if show {
            self.flashView.alpha = 1
            flashView.isHidden = false
        } else  {
            UIView.animate(withDuration: 0.2, animations: {
                self.flashView.alpha = 0
                }, completion: {_ in
                    self.flashView.isHidden = true
            })
        }
    }
    

    
    //bounce buttons
    
    
    
    
}
