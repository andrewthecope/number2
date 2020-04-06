//
//  PoopViewController.swift
//  Number 2
//
//  Created by Andrew Cope on 8/14/16.
//  Copyright © 2016 Andrew Cope. All rights reserved.
//

import UIKit
import CloudKit

class PoopViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    
    var messagesDelegate: ScreenToMessages?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        poopCollections = [PoopCollection]()
//        
//        //fetch Poops
//        let ckContainer = CKContainer.default()
//        let publicDatabase = ckContainer.publicCloudDatabase
//        
//        let ckQuery = CKQuery(recordType: "PoopCollection", predicate: NSPredicate(value: true))
//        publicDatabase.perform(ckQuery, inZoneWith: nil) {
//            records, error in
//            
//            if error != nil {
//                print(error!.localizedDescription)
//            } else if let safeRecords = records {
//                for (index, collectionRecord) in safeRecords.enumerated() {
//                    let collection = PoopCollection(record: collectionRecord, database: publicDatabase)
//                    poopCollections.append(collection)
//                    collection.fetchPoops()
//                    
//                }
//                OperationQueue.main.addOperation {
//                    poopCollections.sort(by: {(a,b) -> Bool in
//                        return a.order < b.order
//                    })
//                    
//                    self.tableView.reloadData()
//                }
//                
//            }
//        }
        
    }
    
    var poopCollections = [PoopCollection]()
    
    @IBOutlet weak var tableViewObj: UITableView!


    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if prizePoops.poops.count > 0 {
            return self.poopCollections.count + 1
        } else {
            return self.poopCollections.count
        }
        
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        print("viaPoop: viewDidApear")
        //tableView.alpha = 1
        //tableView.reloadData()
    }
    
    
    
    func outroAnimation() {
        UIView.animate(withDuration: 0.5, animations: {
            self.tableView.alpha = 0
        })
    }
    

    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PoopCollectionCell
        
        cell.poopIndex = indexPath.row
        
        if indexPath.row < poopCollections.count {
            
            
            
//            if poopCollections[indexPath.row].hasLoadedData == false {
//                poopCollections[indexPath.row].fetchPoops(/*collectionView: cell, indexPath: indexPath*/)
//            } else {
//
//            }
            
            //
            cell.spinner.isHidden = true
            poopCollections[indexPath.row].collectionView = cell.collectionView
            cell.title.text = poopCollections[indexPath.row].title
            cell.poopCollection = poopCollections[indexPath.row]
        } else { 
            cell.title.text = prizePoops.title
            cell.poopCollection = prizePoops
        }
        
        
        
        cell.messagesDelegate = messagesDelegate
        cell.cellRC.alpha = 0
        cell.cellRC.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let poopCell = cell as! PoopCollectionCell
        poopCell.collectionView.reloadData()
        UIView.animate(withDuration: 1.5, delay: 0,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 6.0,
                       options: UIViewAnimationOptions.allowUserInteraction,
                       animations: {
                            poopCell.cellRC.alpha = 1
                            poopCell.cellRC.transform = CGAffineTransform(scaleX: 1, y: 1)
                       }, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let poopCell = cell as! PoopCollectionCell
        
        UIView.animate(withDuration: 2.0, delay: 0,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 6.0,
                       options: UIViewAnimationOptions.allowUserInteraction,
                       animations: {
                        poopCell.cellRC.alpha = 0
                        poopCell.cellRC.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }, completion: nil)
    }
    
    
    

}
