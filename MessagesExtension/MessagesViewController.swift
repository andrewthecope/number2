//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by Andrew Cope on 7/10/16.
//  Copyright © 2016 Andrew Cope. All rights reserved.
//

import UIKit
import Messages
import CloudKit
import CoreLocation
import MessageUI

enum CurrentScreen {
    case MainMenu
    case Pic
    case EditPic
    case Poop
    case EditPoop
    case Leaderboards
    case About
    case ReadPoop
}

enum AnimationDirection {
    case None
    case SlideLeft
    case SlideRight
}

protocol ScreenToMessages {
    func changeScreen(screen: CurrentScreen, direction: AnimationDirection)
    func sendPhoto(image: UIImage)
    func editPoop(poop: Poop)
    func editPic(pic: UIImage)
    func goBackFromEditPoop()
    func goBackFromEditPic()
    func showAwardViewController(award:Award)
    func hideAwardViewController(award:Award)
    func reloadSentPoopsAndCurrentAwards()
    func showMail()
}




class MessagesViewController: MSMessagesAppViewController, ScreenToMessages, CLLocationManagerDelegate, MFMailComposeViewControllerDelegate, DownloadToUI {
    
    
    var downloadManager = DownloadManager()
    var navigationManager: NavigationManager? = nil
    
    var sentPoops = [SentPoop]()
    

    override func viewDidLoad() {
        navigationManager?.setUpNavigation(messagesVC: self)
        downloadManager.downloadDelegate = self
    }
    
    func newAwardsCalculated(newAwards: [Award]) {
        awardsToShow += newAwards
        if awardsToShow.count > 0 {
            showAwardViewController(award: awardsToShow.first!)
            //currentAwards.append(awardsToShow.first!)
            navigationManager?.leaderVC.collectionView.reloadData()
        }
    }
    
    
    func poopCollectionsDownloaded() {
        navigationManager?.poopVC.poopCollections = downloadManager.poopCollections
        if navigationManager?.currentScreen == .Poop {
            if let tableView =  navigationManager?.poopVC.tableViewObj {
                tableView.reloadData()
                print("tableView reloaded")
            }
        }
    }
    
    func poopDownloaded(row:Int) {
        if navigationManager?.currentScreen == .Poop {
            if let tableView = navigationManager?.poopVC.tableViewObj {
                let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0))
                if let poopCell = cell as? PoopCollectionCell {
                    if let collectionView = poopCell.collectionView {
                        collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    func accessoriesDownloaded() {
        navigationManager?.editVC.accessories = downloadManager.accessories
    }
    
    func backgroundsDownloaded() {
        navigationManager?.editVC.backgrounds = downloadManager.backgrounds
    }
    
    func allPoopsDownloaded() {
        var poops = [Poop]()
        for collection in downloadManager.poopCollections {
            for poop in collection.poops {
                poops.append(poop)
            }
        }
        
        navigationManager?.editVC.poops = poops
    }
    
    func awardsDownloaded() {
        navigationManager?.leaderVC.currentAwards = downloadManager.currentAwards
        
        if navigationManager?.currentScreen == .Leaderboards {
            if let collectionView = navigationManager?.leaderVC.collectionView {
                collectionView.reloadData()
            }
        }
    }
    
    func sentPoopsDownloaded() {
        navigationManager?.leaderVC.sentPoops = downloadManager.sentPoops
        if navigationManager?.currentScreen == .Leaderboards {
            navigationManager?.leaderVC.updateUI()
        }
    }
    
    override func didReceiveMemoryWarning() {
        print("DID RECEIVE MEMORY WARNING")
    }

    
    func editPoop(poop: Poop) {
        navigationManager?.poopToEdit = poop
        changeScreen(screen: .EditPoop, direction: .SlideLeft)
    }
    
    func editPic(pic: UIImage) {
        navigationManager?.imageToEdit = pic
        changeScreen(screen: .EditPic, direction: .SlideLeft)
    }
    
    func goBackFromEditPoop() {
        changeScreen(screen: .Poop, direction: .SlideRight)
    }
    
    func goBackFromEditPic() {
        changeScreen(screen: .Pic, direction: .SlideRight)
    }
    
    var currentPublicPoop: CKRecord? = nil
    var currentSentPoop: CKRecord? = nil
    
    func sendPhoto(image: UIImage) {
        requestPresentationStyle(.compact)
        
        guard let conversation = activeConversation else { fatalError("Expected a conversation") }
        
        
        currentPublicPoop = CKRecord(recordType: "PublicPoop")
        let asset = CKAsset(fileURL: writeImage(image: image))
        currentPublicPoop?.setObject(asset, forKey: "image")
        let publicID = currentPublicPoop!.recordID.recordName

        
        let message = composeMessage(with: image)
        let _ = setCurrentPoop(from: image)
        
        var components = URLComponents()
        let queryItem = URLQueryItem(name: "~*~" + publicID, value: nil)
        components.queryItems = [queryItem]
        
        message.url = components.url!
        print("message url is \(message.url)")
        conversation.insert(message) { error in
            if let error = error {
                print(error)
            } else {
                print("successfully added message to conversation")
            }
        }
        
        
        
        let publicDB = CKContainer.default().publicCloudDatabase
        
        if let safePublicPoop = currentPublicPoop {
            publicDB.save(safePublicPoop) {
                _, error in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    print("successfully saved currentPublicPoop to database")
                }
            }
        } else {
            fatalError("currentPublicPoop is nil")
        }
        
        
        
        
        
        //add SentPoop to private database
        let sentPoopRecord = CKRecord(recordType: "SentPoop")
        
        if (expandedScreen == .EditPic) {
            sentPoopRecord.setObject(1 as CKRecordValue, forKey: "picOrPoop")
        } else {
            sentPoopRecord.setObject(0 as CKRecordValue, forKey: "picOrPoop")
        }
        
        sentPoopRecord.setObject(lastLocation, forKey: "location")
        
        let privateDB = CKContainer.default().privateCloudDatabase
        privateDB.save(sentPoopRecord) {
            record, error in
            if error != nil {
                print(error?.localizedDescription)
            }
        }
        
        
        //put SentPoop into local sentPoops to avoid having to upload then download again
        downloadManager.sentPoops.append(SentPoop(record: sentPoopRecord))
        navigationManager?.leaderVC.sentPoops = downloadManager.sentPoops
        
        
        
        

        
        
    }
    
    private func composeMessage(with image: UIImage) -> MSMessage {
        
        let layout = MSMessageTemplateLayout()
        layout.image = image
        layout.caption = "You've got Poop"
        
        if let convo = activeConversation {
            layout.subcaption = "$\(convo.localParticipantIdentifier) is Pooping"
        }
        
        let message = MSMessage(session: MSSession())
        message.layout = layout
    
        
        return message
    }
    
    var currentController:UIViewController? = nil
    
    func changeScreen(screen: CurrentScreen, direction: AnimationDirection ) {
        hasCalledChangedScreen = true
        
        navigationManager?.currentScreen = screen
        navigationManager?.direction = direction
        
        if screen == .MainMenu {
            if presentationStyle != .compact {
                requestPresentationStyle(.compact)
            } else {
                navigationManager?.presentViewController()
            }
            
        } else {
            if presentationStyle != .expanded {
                requestPresentationStyle(.expanded)
            } else {
                navigationManager?.presentViewController()
            }
            
        }
    }
    

    var expandedScreen = CurrentScreen.Pic
 
    
    
    func setCurrentPoop(from image:UIImage) -> String {
        //put currentSentPoop in the clouuuud
        
        let record = CKRecord(recordType: "SentPoop")
        let asset = CKAsset(fileURL: writeImage(image: image))
        record.setObject(asset, forKey: "image")
        record.setObject(lastLocation, forKey: "location")
        let uuid = UUID()
        record["id"] = uuid.uuidString as CKRecordValue
        
        currentSentPoop = record
        
        return uuid.uuidString
    }
    

    func writeImage(image: UIImage) -> URL {
        var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        documentsURL.appendPathComponent(UUID().uuidString + ".png")
        if let imageData = UIImagePNGRepresentation(image) {
            do {
                try imageData.write(to: documentsURL)
            }
            catch {fatalError("Couldn't write Image to URL")}
        }
        
        return documentsURL
    }
    
    
    // MARK: - Conversation Handling
    
    var hasCalledChangedScreen = false
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        super.willBecomeActive(with: conversation)
        
        let container = CKContainer.default()
        container.accountStatus() {
            status, error in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                if status != .available {
                    //present error of some kind
                    
                    let continueAction = UIAlertAction(title: "Continue", style: .cancel) { _ in }
                    let editWarning = UIAlertController(title: "Number 2 Requires iCloud.", message: "To enable iCloud for this app: \n Settings > iCloud > iCloud Drive > Number 2", preferredStyle: .alert)
                    editWarning.addAction(continueAction)
                    self.present(editWarning, animated: true)

                }
            }
        }
 
        print("downloadsBegun")
        downloadManager.beginDownloads()
        

        
        
        manager.delegate = self
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        } else {
            if CLLocationManager.authorizationStatus() == .notDetermined {
                manager.requestWhenInUseAuthorization()
            }
        }
        

        if let message = conversation.selectedMessage {
            if let url = message.url {
                let urlString = "\(url)".replacingOccurrences(of: "?~*~", with: "")
                print("url is \(urlString)")
                if hasCalledChangedScreen == false {
                    getPublicPoopFrom(url: urlString)
                    self.navigationManager?.currentScreen = .ReadPoop
                    self.expandedScreen = .ReadPoop
                } else {
                    expandedScreen = .Poop
                }
            }
        }
        
        navigationManager?.presentViewController()

        hasCalledChangedScreen = false
    }
    
    

    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    

    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
        print("calculateNewCurrentAwards")
        //save image in public database

//        let sentPoop = SentPoop(/*record: sentPoopRecord*/)
//        sentPoops.append(sentPoop)
//        leaderVC.updateUI(sentPoops: sentPoops)
        downloadManager.calculateNewCurrentAwards()
        
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        if let csp = currentSentPoop {
            downloadManager.deleteCurrentSentPoop(sentPoop: csp)
        }
        
        // Use this to clean up state related to the deleted message.
        currentSentPoop = nil
        currentPublicPoop = nil
    }
    

    
    func getPublicPoopFrom(url: String) {
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        let recordID = CKRecordID(recordName: url)
        
        publicDatabase.fetch(withRecordID: recordID) {
            records, error in
            if error != nil {
                OperationQueue.main.addOperation {
                    self.navigationManager?.readVC.activityLabel.text = "Something Went Wrong. My Bad."
                    self.navigationManager?.readVC.activityIndicator.stopAnimating()
                }
                print(error!.localizedDescription)
            } else if let record = records {
                let asset = record["image"] as? CKAsset
                if asset != nil {
                    let nsData = NSData(contentsOf: asset!.fileURL)
                    if let data = nsData {
                        let image = UIImage(data: data as Data)
                        OperationQueue.main.addOperation {
                            
                            self.navigationManager?.readVC.imageView.image = image
                        }
                        
                    }
                }

            }
        }
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
        
//        OperationQueue.main.addOperation {
//            print("supposedly happened")
//            //self.mainMenuVC.outroAnimation()
//        }
        
        if self.presentationStyle != presentationStyle {
            navigationManager?.direction = .None
        }
        
        if navigationManager?.currentScreen != .MainMenu {
            print("outro")
            navigationManager?.mainMenuVC.outroAnimation()
        }
        
    }
    


    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
 
        guard let conversation = activeConversation else { fatalError("Expected an active converstation") }

        if !hasCalledChangedScreen {
            if let message = conversation.selectedMessage {
                if let url = message.url {
                    let urlString = "\(url)".replacingOccurrences(of: "?~*~", with: "")
                    getPublicPoopFrom(url: urlString)
                    self.navigationManager?.currentScreen = .ReadPoop
                    self.expandedScreen = .ReadPoop
                }
            }
        }
        
        if presentationStyle == .compact {
            navigationManager?.currentScreen = .MainMenu
        }
        
        navigationManager?.presentViewController()
        
        hasCalledChangedScreen = false
    }
    
    func showErrorMessage() {
        let continueAction = UIAlertAction(title: "Continue", style: .cancel) { _ in }
        let editWarning = UIAlertController(title: "No Poop For You.", message: "Check your internet connection.", preferredStyle: .alert)
        editWarning.addAction(continueAction)
        self.present(editWarning, animated: true)
    }
    

    
    var awardsToShow = [Award]()
    
    

    
    func showAwardViewController(award: Award) {
        let awardVC = storyboard?.instantiateViewController(withIdentifier: "AwardViewController") as! AwardViewController
        awardVC.messagesDelegate = self
        self.addChildViewController(awardVC)
        view.addSubview(awardVC.view)
        awardVC.view.frame = view.bounds
        awardVC.view.translatesAutoresizingMaskIntoConstraints = false
        awardVC.view.leftAnchor.constraint(equalTo:  view.leftAnchor).isActive = true
        awardVC.view.rightAnchor.constraint(equalTo:  view.rightAnchor).isActive = true
        awardVC.view.topAnchor.constraint(equalTo:  view.topAnchor).isActive = true
        awardVC.view.bottomAnchor.constraint(equalTo:  view.bottomAnchor).isActive = true
        awardVC.didMove(toParentViewController: self)
        self.view.bringSubview(toFront: awardVC.view)
        
        awardVC.updateUI(award: award)
    }
    
    func hideAwardViewController(award: Award) {
        
        if let index = awardsToShow.index(of: award) {
            awardsToShow.remove(at: index)
        }
        
        
        for child in self.childViewControllers {
            if let c = child as? AwardViewController {
                c.willMove(toParentViewController: nil)
                c.view.removeFromSuperview()
                c.removeFromParentViewController()
            }
        }
        
        if awardsToShow.count > 0 {
            showAwardViewController(award: awardsToShow.first!)
        }
    }
    
    func reloadSentPoopsAndCurrentAwards() {
        downloadManager.reloadSentPoopsAndCurrentAwards()
    }

    
    //location data
    
    let manager = CLLocationManager()
    var lastLocation = CLLocation()
    private func locationManager(manager: CLLocationManager,
                         didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
            // ...
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last!
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["number2@thecope.net"])
        mailComposerVC.setSubject("Number 2 Feedback")
        mailComposerVC.setMessageBody("Hey Andrew, I've been using Number 2 and I have some thoughts...", isHTML: false)
        
        return mailComposerVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        mailComposeVC.removeFromParentViewController()
        mailComposeVC.view.removeFromSuperview()
    }
    
    var mailComposeVC = MFMailComposeViewController()
    
    func showMail() {
        let mailComposeViewController = configuredMailComposeViewController()
        //mailComposeViewController.navigationBar.backgroundColor = blueColor
        if MFMailComposeViewController.canSendMail() {
            //self.present(mailComposeViewController, animated: true)
            
            addChildViewController(mailComposeViewController)
            mailComposeViewController.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(mailComposeViewController.view)
            
            mailComposeViewController.view.leftAnchor.constraint(equalTo:  view.leftAnchor).isActive = true
            mailComposeViewController.view.rightAnchor.constraint(equalTo:  view.rightAnchor).isActive = true
            mailComposeViewController.view.topAnchor.constraint(equalTo:  view.topAnchor, constant: 85).isActive = true
            mailComposeViewController.view.bottomAnchor.constraint(equalTo:  view.bottomAnchor, constant: -43).isActive = true
            mailComposeViewController.didMove(toParentViewController: self)
            mailComposeVC = mailComposeViewController
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "navController" {
            navigationManager = segue.destination as? NavigationManager
            navigationManager?.story = self.storyboard
        }
    }
    
}
