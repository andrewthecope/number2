//
//  NavigationManager.swift
//  Number 2
//
//  Created by Andrew Cope on 9/27/16.
//  Copyright © 2016 Andrew Cope. All rights reserved.
//

import UIKit

class NavigationManager: UIViewController {

    var currentScreen = CurrentScreen.MainMenu
    var direction = AnimationDirection.None
    
    //screens
    var mainMenuVC = MainMenuViewController()
    var picVC = CaptureViewController()
    var editVC = EditCaptureViewController()
    var poopVC = PoopViewController()
    var aboutVC = AboutViewController()
    var leaderVC = LeaderboardsViewController()
    var readVC = ReadPoopViewController()
    
    var story: UIStoryboard? = nil
    
    var poopToEdit: Poop? = nil
    var imageToEdit: UIImage? = nil

    func presentViewController() {
        
        var controller = UIViewController()
        
        switch currentScreen {
        case .MainMenu:
            controller = mainMenuVC
        case .Poop:
            controller = poopVC
        case .EditPoop:
            editVC.screenType = .Poop
            editVC.poopToEdit = poopToEdit
            controller = editVC
            
        case .Pic:
            controller = picVC
        case .EditPic:
            editVC.screenType = .Image
            editVC.picToEdit = imageToEdit
            controller = editVC
        case .About:
            controller = aboutVC
        case .Leaderboards:
            controller = leaderVC
        case .ReadPoop:
            controller = readVC
        }
        
        let frameWidth = view.frame.width
        
        if direction == .None {
            for vc in childViewControllers {
                 removeViewController(controller: vc)
            }
            addViewController(controller: controller)
        } else if direction == .SlideLeft {
            if let prevVC = childViewControllers.first {
                // prev:  0 -> -view
                // new:   view -> 0
                presentWithAnimation(prevVC: prevVC, newVC: controller, newInit: frameWidth, newTo: 0, prevInit: 0, prevTo: -frameWidth)
            }
        } else if direction == .SlideRight {
            if let prevVC = childViewControllers.first {
                //prev: 0 -> view
                //new: -view -> 0
                presentWithAnimation(prevVC: prevVC, newVC: controller, newInit: -frameWidth, newTo: 0, prevInit: 0, prevTo: frameWidth)
                
                
            }
        }
        
        
        
    }
    
    var prevLeft: NSLayoutConstraint?
    var prevRight: NSLayoutConstraint?
    
    func presentWithAnimation(prevVC: UIViewController, newVC: UIViewController, newInit: CGFloat, newTo:CGFloat, prevInit: CGFloat, prevTo: CGFloat) {

        
        var newLeft: NSLayoutConstraint?
        var newRight: NSLayoutConstraint?
        

        addVCWithoutConstraints(controller: newVC)
        
        view.layoutIfNeeded()
        
        //Set Initial Positions
        newVC.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        newVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        prevVC.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        prevVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        prevLeft?.isActive = false
        prevLeft = prevVC.view.leftAnchor.constraint(equalTo: view.leftAnchor, constant: prevInit)
        prevLeft?.isActive = true
        prevRight?.isActive = false
        prevRight = prevVC.view.rightAnchor.constraint(equalTo: view.rightAnchor, constant: prevInit)
        prevRight?.isActive = true
        
        newLeft = newVC.view.leftAnchor.constraint(equalTo: view.leftAnchor, constant: newInit)
        newLeft?.isActive = true
        newRight = newVC.view.rightAnchor.constraint(equalTo: view.rightAnchor, constant: newInit)
        newRight?.isActive = true
        
        view.layoutIfNeeded()
        
        //Set New Positions
        newLeft?.isActive = false
        newLeft = newVC.view.leftAnchor.constraint(equalTo: view.leftAnchor, constant: newTo)
        newLeft?.isActive = true

        
        newRight?.isActive = false
        newRight = newVC.view.rightAnchor.constraint(equalTo: view.rightAnchor, constant: newTo)
        newRight?.isActive = true

        prevLeft?.isActive = false
        prevLeft = prevVC.view.leftAnchor.constraint(equalTo: view.leftAnchor, constant: prevTo)
        prevLeft?.isActive = true
        
        prevRight?.isActive = false
        prevRight = prevVC.view.rightAnchor.constraint(equalTo: view.rightAnchor, constant: prevTo)
        prevRight?.isActive = true
        
        
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: {_ in
                self.prevLeft?.isActive = false
                self.prevRight?.isActive = false
                
                self.prevLeft = newLeft
                self.prevRight = newRight
                
                self.removeViewController(controller: prevVC)
        })
        
        
    }
    
    func presentWithRightAnimation(prevVC: UIViewController, newVC: UIViewController) {
        
    }
    
    

    
    func addViewController(controller: UIViewController) {
        
        self.addChildViewController(controller)
        
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        
        controller.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        prevLeft?.isActive = false
        prevRight?.isActive = false
        
        prevLeft = controller.view.leftAnchor.constraint(equalTo: view.leftAnchor)
        prevLeft?.isActive = true
        prevRight = controller.view.rightAnchor.constraint(equalTo: view.rightAnchor)
        prevRight?.isActive = true
        
        controller.didMove(toParentViewController: self)
        
    }
    
    func addVCWithoutConstraints(controller: UIViewController) {
        self.addChildViewController(controller)
        
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        
        controller.didMove(toParentViewController: self)

    }
    
    func removeViewController(controller: UIViewController) {
        controller.willMove(toParentViewController: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParentViewController()
    }
    
    func setUpNavigation(messagesVC: ScreenToMessages) {
        mainMenuVC = story?.instantiateViewController(withIdentifier: "MainMenuViewController") as! MainMenuViewController
        picVC = story?.instantiateViewController(withIdentifier: "CaptureViewController") as! CaptureViewController
        editVC = story?.instantiateViewController(withIdentifier: "EditCaptureViewController") as! EditCaptureViewController
        poopVC = story?.instantiateViewController(withIdentifier: "PoopViewController") as! PoopViewController
        aboutVC = story?.instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
        leaderVC = story?.instantiateViewController(withIdentifier: "LeaderboardsViewController") as! LeaderboardsViewController
        readVC = story?.instantiateViewController(withIdentifier: "ReadPoopViewController") as! ReadPoopViewController
        
        mainMenuVC.view.translatesAutoresizingMaskIntoConstraints = false
        picVC.view.translatesAutoresizingMaskIntoConstraints = false
        editVC.view.translatesAutoresizingMaskIntoConstraints = false
        poopVC.view.translatesAutoresizingMaskIntoConstraints = false
        aboutVC.view.translatesAutoresizingMaskIntoConstraints = false
        leaderVC.view.translatesAutoresizingMaskIntoConstraints = false
        readVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        mainMenuVC.messagesDelegate = messagesVC
        picVC.messagesDelegate = messagesVC
        editVC.messagesDelegate = messagesVC
        poopVC.messagesDelegate = messagesVC
        aboutVC.messagesDelegate = messagesVC
        leaderVC.messagesDelegate = messagesVC
        readVC.messagesDelegate = messagesVC
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        

    }
    
}
