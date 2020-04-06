//
//  ReadPoopViewController.swift
//  Number 2
//
//  Created by Andrew Cope on 9/5/16.
//  Copyright © 2016 Andrew Cope. All rights reserved.
//

import UIKit

class ReadPoopViewController: UIViewController {
    
    var messagesDelegate: ScreenToMessages? = nil
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var flipView: UIView!
    var orientationIsLandscape: Bool {
        return UIDevice.current.orientation.isLandscape
    }
    
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var menuRC: RoundedCorners!
    @IBOutlet weak var shareRC: RoundedCorners!
    
    
    override func viewDidAppear(_ animated: Bool) {
        let heightTresh = 400.0
        if view.frame.size.height < CGFloat(heightTresh) {
            flipView.isHidden = false
        } else {
            flipView.isHidden = true
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        imageView.image = nil
        activityLabel.text = "Fetching Poop..."
    }
    

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let heightTresh = 400.0
        if size.height < CGFloat(heightTresh) {
            flipView.isHidden = false
        } else {
            flipView.isHidden = true
        }
    }

    
    func displayShareSheet(shareContent:UIImage) {
        let activityViewController = UIActivityViewController(activityItems: [shareContent], applicationActivities: nil)
        
        present(activityViewController, animated: true) {
            self.shareRC.bounceUp()
        }
    }
    
    
    @IBAction func menu_touchDown(_ sender: UIButton) {
        menuRC.bounceDown()
    }
    
    @IBAction func menuPressed(_ sender: UIButton) {
        menuRC.bounceUp()
        messagesDelegate?.changeScreen(screen: .MainMenu, direction: .None)
    }
    
    @IBAction func share_touchDown(_ sender: UIButton) {
        shareRC.bounceDown()
        if let img = imageView.image {
            displayShareSheet(shareContent: img)
        }
        
    }
    
    @IBAction func sharePressed(_ sender: UIButton) {
        shareRC.bounceUp()
    }
}
