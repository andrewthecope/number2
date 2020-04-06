//
//  MainMenuViewController.swift
//  Number 2
//
//  Created by Andrew Cope on 7/31/16.
//  Copyright © 2016 Andrew Cope. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {

    
    override func viewWillAppear(_ animated: Bool) {
        //set views to transparent and small
        mainMenuHeader.alpha = 0
        poopRC.alpha = 0
        picRC.alpha = 0
        leaderRC.alpha = 0
        aboutButton.alpha = 0
        
        mainMenuHeader.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        poopRC.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        picRC.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        leaderRC.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        aboutButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("view did appear")

//        
        
        introAnimation()
        
        
        
    }
    
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var mainMenuHeader: UILabel!
    
    func introAnimation() {
        
        self.view.layoutIfNeeded()
        self.view.setNeedsUpdateConstraints()
        
        springAnimation(animationDelay: 0, object: mainMenuHeader)
        springAnimation(animationDelay: 0.2, object: poopRC)
        springAnimation(animationDelay: 0.4, object: picRC)
        springAnimation(animationDelay: 0.6, object: leaderRC)
        springAnimation(animationDelay: 0, object: aboutButton)
        
        
    }
    
    func outroAnimation() {
        springAwayAnimation(animationDelay: 0, object: mainMenuHeader)
        springAwayAnimation(animationDelay: 0, object: poopRC)
        springAwayAnimation(animationDelay: 0, object: picRC)
        springAwayAnimation(animationDelay: 0, object: leaderRC)
        springAwayAnimation(animationDelay: 0, object: aboutButton)
    }
    
    func springAnimation(animationDelay: Double, object: UIView) {
        UIView.animate(withDuration: 2.0, delay: animationDelay,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 6.0,
                       options: UIViewAnimationOptions.allowUserInteraction,
                       animations: {
                        object.alpha = 1
                        
                        object.transform = CGAffineTransform(scaleX: 1, y: 1)
        }) { _ in
            self.view.layoutIfNeeded()
        }
    }
    
    func springAwayAnimation(animationDelay:Double, object: UIView) {

        UIView.animate(withDuration: 0.25, delay: animationDelay,
                       options: .allowUserInteraction,
                       animations: {
                            object.alpha = 0
                            object.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                        },
                       completion: nil)
    }
    

    
    @IBOutlet weak var backgroundView: UIView!

    

    var messagesDelegate: ScreenToMessages?

    @IBOutlet weak var poopRC: RoundedCorners!
    @IBAction func poop_touchDown(_ sender: AnyObject) { poopRC.bounceDown() }
    
    
    @IBOutlet weak var picRC: RoundedCorners!
    @IBAction func pic_TouchDown(_ sender: AnyObject) {
        picRC.bounceDown()
    }
    
    @IBOutlet weak var leaderRC: RoundedCorners!
    
    @IBAction func leader_TouchDown(_ sender: AnyObject) {
        leaderRC.bounceDown()
    }
    @IBAction func viaPoopPressed(_ sender: UIButton) {

        poopRC.bounceUp()
        self.messagesDelegate?.changeScreen(screen: .Poop, direction: .None)
        //outroAnimation() //called in viewWillTransition
        
    }
    
    @IBAction func viaPicPressed(_ sender: UIButton) {

        
        picRC.bounceUp()
        messagesDelegate?.changeScreen(screen: .Pic, direction: .None)
        //outroAnimation()  //called in viewWillTransition
    }
    
    @IBAction func leaderPressed(_ sender: AnyObject) {

        
        leaderRC.bounceUp()
        messagesDelegate?.changeScreen(screen: .Leaderboards, direction: .None)
        // outroAnimation() //called in viewWillTransition
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func aboutPressed(_ sender:UIButton) {
        messagesDelegate?.changeScreen(screen: .About, direction: .None)
        //messagesDelegate?.showAwardViewController(award: awards[0])
    }
    
    
    //touch_cancelled stuff (to fix issue where press gets cancelled, and buttons disapear
    
    @IBAction func viaPoop_Cancelled(_ sender: UIButton) {
        print("touch cancelled")
    }
    

}
