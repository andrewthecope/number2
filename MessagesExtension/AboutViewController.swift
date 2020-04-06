//
//  AboutViewController.swift
//  Number 2
//
//  Created by Andrew Cope on 8/31/16.
//  Copyright © 2016 Andrew Cope. All rights reserved.
//

import UIKit
import CloudKit
import GameplayKit
import MessageUI

class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate, UIAlertViewDelegate {

    
    var messagesDelegate: ScreenToMessages? = nil
    
    
    @IBOutlet weak var artistTextView: UITextView!
    
    @IBOutlet weak var reviewRC: RoundedCorners!
    @IBOutlet weak var feedbackRC: RoundedCorners!
    
    @IBAction func rate_touchDown(_ sender: AnyObject) {
        reviewRC.bounceDown()
    }
    
    @IBAction func feedback_touchDown(_ sender: UIButton) {
        feedbackRC.bounceDown()
    }
    
    @IBAction func ratePressed(_ sender: UIButton) {
        reviewRC.bounceUp()
        //let targetURL = NSURL(string: "https://itunes.apple.com/us/app/learn-your-lines-memorization/id1049082615?ls=1&mt=8")
        
        
       // let application = UIApplication.shared
        
       // application.openURL(targetURL! as URL);
        //UIApplication.shared.open(URL(string: "https://itunes.apple.com/us/app/learn-your-lines-memorization///id1049082615?ls=1&mt=8")!, options: [String:Any](), completionHandler: nil)
        
        extensionContext!.open(URL(string: "https://itunes.apple.com/us/app/learn-your-lines-memorization/id1049082615?ls=1&mt=8")!) {
            success in
            print("success was \(success)")
        }
        
    }
    
    @IBAction func feedbackPressed(_ sender: UIButton) {
        feedbackRC.bounceUp()
        
        messagesDelegate?.showMail()
    }
    


    
    
    var artists = [String]()
    
    
    func reloadArtists() {
        
        //shuffle order of artists, I love all my children equally.
        artists.shuffle()
        
        if artists.count == 0 {
            artistTextView.text = "Unable to get get you a list of Poop Artists. But as you can imagine, they are all lovely. "
        } else {
            for artist in artists {
                artistTextView.text.append(artist + "\n")
            }
        }
        
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        artistTextView.text = ""

        let container = CKContainer.default()
        let database = container.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Artist", predicate: predicate)
        
        database.perform(query, inZoneWith: nil) {
            records, error in
            
            if error != nil {
                print(error?.localizedDescription)
            } else if let safeRecords = records {
                for record in safeRecords {
                    let artistRecord = record as CKRecord
                    let name = artistRecord.object(forKey: "Name") as! String
                    self.artists.append(name)
                }
            }
            
            let queue = OperationQueue.main
            queue.addOperation {
                self.reloadArtists()
            }
            
        }
    }
    


    
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated:true)
    }
    
    
    
    @IBAction func clearDataPressed(_ sender: UIButton) {
        
        let continueAction = UIAlertAction(title: "Continue", style: .destructive) { _ in
            self.clearData(recordType: "Award")
            self.clearData(recordType: "SentPoop")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {_ in }
        let editWarning = UIAlertController(title: "Are You Sure?", message: "You will lose all your poop data and your awards. It will be very sad for you.", preferredStyle: .alert)
        editWarning.addAction(continueAction)
        editWarning.addAction(cancelAction)
        self.present(editWarning, animated: true)
        
        
    }
    
    func clearData(recordType: String) {

        let privateDatabase: CKDatabase = CKContainer.default().privateCloudDatabase
        
        // fetch records from iCloud, get their recordID and then delete them
        var recordIDsArray =  [CKRecordID]()
        
        let ckQuery = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        privateDatabase.perform(ckQuery, inZoneWith: nil) {
            records, error in
            if error != nil {
                print(error!.localizedDescription)
            } else if let safeRecords = records {
                for r in safeRecords {
                    recordIDsArray.append(r.recordID)
                }
                OperationQueue.main.addOperation {
                    let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDsArray)
                    operation.modifyRecordsCompletionBlock = {
                        (savedRecords: [CKRecord]?, deletedRecordIDs: [CKRecordID]?, error: Error?) in
                        print("deleted all \(recordType)s")
                        self.messagesDelegate?.reloadSentPoopsAndCurrentAwards()
                    }
                    
                    privateDatabase.add(operation)
                }
            }
        }
        
        
        
        
        
    }
    
    
    
}


extension Array
{
    /** Randomizes the order of an array's elements. */
    mutating func shuffle()
    {
        for _ in 0..<10
        {
            sort { (_,_) in arc4random() < arc4random() }
        }
    }
}
