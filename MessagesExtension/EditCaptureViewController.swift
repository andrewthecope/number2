//
//  EditCaptureViewController.swift
//  Number 2
//
//  Created by Andrew Cope on 7/31/16.
//  Copyright © 2016 Andrew Cope. All rights reserved.
//

import UIKit
import CloudKit


class EditCaptureViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var leftButton: UIButton!
    
    
    var accessories = [UIImage]()
    var backgrounds = [UIImage]()
    var poops = [Poop]()
    
    override func viewDidDisappear(_ animated: Bool) {
        print("viewdiddisappear")
        reset()
    }
    
    func reset() {
        //remove accessories
        for view in canvas.subviews {
            if view != backgroundImageView &&
               view != imageView &&
                view != canvasEffectView &&
                view != textView &&
                view != trashCan &&
                view != trashCanReference {
                view.removeFromSuperview()
            }
        }
        
        //revert background
        backgroundImageView.image = #imageLiteral(resourceName: "default")
        
        
    }
    
    
    
    enum ScreenType {
        case Poop
        case Image
    }
    
    var screenType = ScreenType.Poop
    var messagesDelegate: ScreenToMessages?

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var captionButton: UIButton!
    @IBOutlet weak var canvasEffectView: UIVisualEffectView!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var canvas: UIView!
    @IBOutlet weak var textView: UITextField!
    
    var doCareAboutKeyboard = true
    
    //Panel Pan Objects
    @IBOutlet weak var panelHandle: UIView!
    @IBOutlet weak var panelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var panel: UIView!
    
    var poopToEdit: Poop? = nil
    var picToEdit: UIImage? = nil
    @IBOutlet weak var thirdButton: UIButton!
    
    
    
    
    @IBAction func handlePanelPan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: canvas)
        
        if panelHeightConstraint.constant + translation.y > canvas.frame.height + 50 {
            panelHeightConstraint.constant = canvas.frame.height + 50
            awayButton.isHidden = true
        } else if panelHeightConstraint.constant + translation.y < 50 {
            panelHeightConstraint.constant = 50
            awayButton.isHidden = false
        } else {
            panelHeightConstraint.constant += translation.y
            awayButton.isHidden = false
        }
        
        if recognizer.state == .ended {
            handlePanelPanEnded(recognizer: recognizer)
        }
        
        
        recognizer.setTranslation(CGPoint(), in: canvas)
    }
    
    func handlePanelPanEnded(recognizer: UIPanGestureRecognizer) {
        
        let velocity = recognizer.velocity(in: canvas)
        let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
        let slideMultiplier = magnitude / 200
        
        let slideFactor = 0.1 * slideMultiplier     //Increase for more of a slide
        var y = panelHeightConstraint.constant + (velocity.y * slideFactor)
        
        y = min(max(y,50), canvas.frame.height + 50)
        
        self.panelHeightConstraint.constant = y
        
        UIView.animate(withDuration: Double(slideFactor / 2),
            delay: 0,
            options: UIViewAnimationOptions.curveEaseOut,
            animations: {self.view.layoutIfNeeded()},
            completion: nil)
    }
    
    func setPanelHeight(show:Bool) {
        view.layoutIfNeeded()
        
        if show {
            panelHeightConstraint.constant = canvas.frame.height > 300 ? 300 : canvas.frame.height
            awayButton.isHidden = false
        } else {
            panelHeightConstraint.constant = 50
            awayButton.isHidden = true
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
        })
    }
    

    
    @IBOutlet weak var awayButton: UIButton!
    @IBAction func awayButtonPressed(_ sender: UIButton) {
        //isPanelShowing = false
        setPanelHeight(show: false)
    }
    
    @IBAction func captionButtonPressed(_ sender: UIButton) {
        //isPanelShowing = false
        sender.isHidden = true
        textView.isHidden = false
        textView.becomeFirstResponder()
    }
    
    @IBAction func accessoriesPressed(_ sender: UIButton) {
        currentCollection = .Accessories
        panelCollectionView.reloadData()
        setPanelHeight(show: true)
        
    }
    
    @IBAction func poopPressed(_ sender: UIButton) {
        
        if screenType == .Image {
            currentCollection = .Poops
        } else {
            currentCollection = .Background
        }
        
        panelCollectionView.reloadData()
        setPanelHeight(show: true)
    }
    
    @IBOutlet weak var trashCanTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var trashCan: UIView!
    @IBOutlet weak var trashCanReference: UIView!
    @IBOutlet weak var trash_closed: UIImageView!
    @IBOutlet weak var trash_open: UIImageView!
    
    func openCloseTrash(open: Bool) {
        if open {
            trash_open.isHidden = false
            trash_closed.isHidden = true
        } else  {
            trash_open.isHidden = true
            trash_closed.isHidden = false
        }
    }
    
    func toggleTrash(show: Bool) {
        if show {
            trashCanTopConstraint.constant = 10
        } else {
            trashCanTopConstraint.constant = -60
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
            }, completion: { _ in
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func send_TouchDown(_ sender: UIButton) {
        rightArrowRight.constant = 18
        rightRC.bounceDown()
        UIView.animate(withDuration: 2, delay: 0,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 6.0,
                       options: UIViewAnimationOptions.allowUserInteraction,
                       animations: {
                        self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        leftRC.bounceUp()
        leftArrowLeft.constant = 8
        
        UIView.animate(withDuration: 2, delay: 0,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 6.0,
                       options: UIViewAnimationOptions.allowUserInteraction,
                       animations: {
                        self.view.layoutIfNeeded()
            }, completion: nil)
        
        if screenType == .Image {
            messagesDelegate?.goBackFromEditPic()
        } else {
            messagesDelegate?.goBackFromEditPoop()
        }
    }

    @IBAction func sendPressed(_ sender: UIButton) {
        rightRC.bounceUp()
        rightArrowRight.constant = 10
        
        UIView.animate(withDuration: 2, delay: 0,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 6.0,
                       options: UIViewAnimationOptions.allowUserInteraction,
                       animations: {
                        self.view.layoutIfNeeded()
            }, completion: nil)
        
        let image = canvas.saveViewAsImage()
        doCareAboutKeyboard = false
        messagesDelegate?.sendPhoto(image: image)
    }
    
    @IBOutlet weak var rightArrowRight: NSLayoutConstraint!
    @IBOutlet weak var rightRC: RoundedCorners!
    
    func reload() {
        
        textView.text = newCaption
        
        if screenType == .Poop {
            thirdButton.setTitle("Background", for: .normal)
            leftButton.setTitle("Poops", for: .normal)
            if let poop = poopToEdit {
                imageView.image = poop.image
                imageView.isHidden = false
            }
        } else {
            thirdButton.setTitle("Poops", for: .normal)
            leftButton.setTitle("Retake", for: .normal)
            
            if let pic = picToEdit {
                backgroundImageView.image = pic
                imageView.isHidden = true
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reload()
        
        activatePoopArray()
        flipOrNot(size: view.frame.size)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        flipOrNot(size: size)
    }
    
    @IBOutlet weak var flipView: UIView!
    
    func flipOrNot(size:CGSize) {
        let heightTresh = 400.0
        if size.height < CGFloat(heightTresh) {
            flipView.isHidden = false
        } else {
            flipView.isHidden = true
        }
    }
    
    func activatePoopArray() {
//        poops = [Poop]()
//        
//        for collection in poopCollections {
//            poops += collection.poops
//        }
    }
    
    
    func fetchBackgrounds() {
        
//        backgrounds = [UIImage]()
//        
//        let ckContainer = CKContainer.default()
//        let publicDatabase = ckContainer.publicCloudDatabase
//        
//        let ckQuery = CKQuery(recordType: "Background", predicate: NSPredicate(value: true))
//        publicDatabase.perform(ckQuery, inZoneWith: nil) {
//            records, error in
//            
//            if error != nil {
//                print(error!.localizedDescription)
//            } else if let safeRecords = records {
//                
//                for record in safeRecords {
//                    let asset = record.object(forKey: "image") as! CKAsset
//                    let data = NSData(contentsOf: asset.fileURL)
//                    let image = UIImage(data: data as! Data)
//                    
//                    let isEnabled = record.object(forKey: "enabled") as! Int
//                    if isEnabled == 1 {
//                        backgrounds.append(image!)
//                    }
//                }
//                
//            }
//        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        canvasEffectView.effect = nil

        
        //panelHeight.constant = 0
        textView.delegate = self
        textView.addTarget(self, action: #selector(EditCaptureViewController.textFieldDidEdit), for: .editingChanged)
        
        textFieldDidEdit()
        awayButton.isHidden = true
        
        //reload()
        
        textView.textColor = UIColor.white
        
        //backgroundImageView.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin | UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleWidth
        backgroundImageView.contentMode = UIViewContentMode.scaleAspectFill
     
        let gestureRec = UILongPressGestureRecognizer(target: self, action: #selector(EditCaptureViewController.handlePanelDrag))
        gestureRec.minimumPressDuration = 0.2
        //gestureRec.delaysTouchesBegan = true
        gestureRec.delegate = self
        panelCollectionView.addGestureRecognizer(gestureRec)
        
        NotificationCenter.default.addObserver(self, selector: #selector(EditCaptureViewController.keyboardWillShow(notification:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditCaptureViewController.keyboardWillHide(notification:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //fetchAccessories()
        fetchBackgrounds()
    }
    
    //var panelGestureRecognizer = UILongPressGestureRecognizer()
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    } //Ours was a short time...

    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: canvas)

        if textViewBottomConstraint.constant - translation.y > 0
            && textViewBottomConstraint.constant - translation.y < canvas.frame.height - textView.frame.height {
            textViewBottomConstraint.constant -= translation.y;
        } else if textViewBottomConstraint.constant - translation.y < 0 {
            textViewBottomConstraint.constant = 0
        } else if textViewBottomConstraint.constant - translation.y > canvas.frame.height - textView.frame.height {
            textViewBottomConstraint.constant = canvas.frame.height - textView.frame.height
        }

        recognizer.setTranslation(CGPoint(), in: canvas)
    }
    
    var tempTextViewConstraint = CGFloat(0)
    
    func keyboardWillShow(notification: NSNotification) {
        
        if doCareAboutKeyboard {
            tempTextViewConstraint = textViewBottomConstraint.constant
            textViewBottomConstraint.constant = canvas.frame.height - textView.frame.height - 15
            
            
            UIView.animate(withDuration: 0.5, animations: {
                self.canvasEffectView.isHidden = false
                self.canvas.bringSubview(toFront: self.canvasEffectView)
                self.canvas.bringSubview(toFront: self.textView)
                self.canvasEffectView.effect = UIBlurEffect(style: .dark)
                self.view.layoutIfNeeded()
            })
        }

  
    }
    
    func keyboardWillHide(notification: NSNotification) {
        textViewBottomConstraint.constant = tempTextViewConstraint
        
        if textView.text!.isEmpty {
            captionButton.isHidden = false
            textView.isHidden = true
        } else {
            captionButton.isHidden = true
            textView.isHidden = false
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.canvasEffectView.effect = nil
            self.view.layoutIfNeeded()
            }, completion: { _ in
            self.canvasEffectView.isHidden = true
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textView.endEditing(true)
        
        return false
    }
    
    enum CurrentCollection {
        case Accessories
        case Poops
        case Background
    }
    
    var currentCollection = CurrentCollection.Accessories
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {

        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch currentCollection {
        case .Accessories:
            return prizeAccessories.count + accessories.count
        case .Background:
            return prizeBackgrounds.count + backgrounds.count
        case .Poops:
            return poops.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageCell

        switch currentCollection {
        case .Accessories:
            
            if indexPath.row < prizeAccessories.count {
                cell.image.image = prizeAccessories[indexPath.row]
            } else {
                cell.image.image = accessories[indexPath.row - prizeAccessories.count]
            }
            
            
        case .Background:
            
            if indexPath.row < prizeBackgrounds.count {
                cell.image.image = prizeBackgrounds[indexPath.row]
            } else {
                cell.image.image = backgrounds[indexPath.row - prizeBackgrounds.count]
            }
        
        case .Poops:
            cell.image.image = poops[indexPath.row].image
        }
        
        
        return cell
    }
    
    @IBOutlet weak var panelCollectionView: UICollectionView!
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        
        
        currentCell = indexPath
        
        if currentCollection == .Background {
            if indexPath.row < prizeBackgrounds.count {
                backgroundImageView.image = prizeBackgrounds[indexPath.row]
            } else {
                backgroundImageView.image = backgrounds[indexPath.row - prizeBackgrounds.count]
            }
            
        }
        
        
        
        //cell.image.alpha = 0
    }

    
    var currentCell = IndexPath()
    var currentDragObj = UIView()
    
    
    func handleObjDrag(recognizer:UIPanGestureRecognizer) {
        
        let offset = recognizer.translation(in: canvas)
        
        if let view = recognizer.view {
            view.center = CGPoint(x: view.center.x + offset.x, y: view.center.y + offset.y)
        }
        
        if recognizer.state == .began {
            toggleTrash(show: true)
        } else if recognizer.state == .ended {
            toggleTrash(show: false)
        }
        
        recognizer.setTranslation(CGPoint(), in: canvas)
        
    }
    
    func highlightDragObj(recognizer: UILongPressGestureRecognizer)
    {
        if let view = recognizer.view {
            
            if recognizer.state == .began {
                canvas.bringSubview(toFront: view)
                view.alpha = 0.5
                view.transform = view.transform.scaledBy(x: 1.1, y: 1.1)
            }
            else if recognizer.state == .ended {
                canvas.bringSubview(toFront: textView)
                view.alpha = 1
                view.transform = view.transform.scaledBy(x: (0.909), y: (0.909))
                
                
                print("trashcan:  \(trashCan.center)  view:  \(view.center)")
                if trashCanReference.frame.contains(view.center) {
                    view.removeFromSuperview()
                }
            }
            
            if trashCanReference.frame.contains(view.center) {
                openCloseTrash(open: true)
            } else {
                openCloseTrash(open: false)
            }

            
        }
    }
    
    
    @IBOutlet weak var pseudoCanvas: UIView!
    
    func handlePanelDrag(recognizer:UILongPressGestureRecognizer) {
        
        
        if (currentCollection != .Background)
        {
            setPanelHeight(show: false)
            
            if recognizer.state == .began {
                let cell = panelCollectionView.cellForItem(at: currentCell) as! ImageCell
                
                
                let dragObj = UIView(frame: CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: cell.frame.width + 40, height: cell.frame.height + 40))
                let image = UIImageView(image: cell.image.image)
                image.frame.size = dragObj.frame.size
                dragObj.addSubview(image)
                
                let lpGestureRec = UILongPressGestureRecognizer(target: self, action: #selector(EditCaptureViewController.highlightDragObj))
                lpGestureRec.minimumPressDuration = 0
                let panGestureRec = UIPanGestureRecognizer(target: self, action: #selector(EditCaptureViewController.handleObjDrag))
                //panGestureRec.minimumPressDuration = 0.0
                let pinchGestureRec = UIPinchGestureRecognizer(target: self, action: #selector(EditCaptureViewController.handlePinch))
                let rotateGestureRec = UIRotationGestureRecognizer(target: self, action: #selector(EditCaptureViewController.handleRotate))
                lpGestureRec.delegate = self
                panGestureRec.delegate = self
                pinchGestureRec.delegate = self
                rotateGestureRec.delegate = self
                dragObj.addGestureRecognizer(lpGestureRec)
                dragObj.addGestureRecognizer(panGestureRec)
                dragObj.addGestureRecognizer(pinchGestureRec)
                dragObj.addGestureRecognizer(rotateGestureRec)
                
                pseudoCanvas.isHidden = false
                
                
                dragObj.alpha = 0.5
                dragObj.transform = view.transform.scaledBy(x: 1.2, y: 1.2)
                
                
                pseudoCanvas.addSubview(dragObj)
                currentDragObj = dragObj
                
                //isPanelShowing = false
            }
                
            else if recognizer.state == .changed {
                
                currentDragObj.center = recognizer.location(in: canvas)
            }
                
            else if recognizer.state == .ended  {
                
                currentDragObj.alpha = 1
                currentDragObj.transform = view.transform.scaledBy(x: (0.833333), y: (0.833333))
                
                currentDragObj.removeFromSuperview()
                canvas.addSubview(currentDragObj)
                canvas.bringSubview(toFront: textView)
                pseudoCanvas.isHidden = true
            }

        }
        
    }
    
    func handlePinch(recognizer : UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1
        }
    }
    
    func handleRotate(recognizer : UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func textFieldDidEdit() {
        
    }
    
    
    
    //bounce buttons
    
    override func viewWillAppear(_ animated: Bool) {
        leftArrowLeft.constant = 8
        textViewBottomConstraint.constant = 8
    }
    
    @IBOutlet weak var leftRC: RoundedCorners!
    
    @IBOutlet weak var leftArrowLeft: NSLayoutConstraint!
    @IBOutlet weak var leftArrow: Chrevron!
    @IBAction func left_TouchDown(_ sender: AnyObject) {
        leftArrowLeft.constant = 18
        
        UIView.animate(withDuration: 2, delay: 0,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 6.0,
                       options: UIViewAnimationOptions.allowUserInteraction,
                       animations: {
                        self.view.layoutIfNeeded()
            }, completion: nil)

        leftRC.bounceDown()
    }

}

extension UIView {
    func saveViewAsImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}






