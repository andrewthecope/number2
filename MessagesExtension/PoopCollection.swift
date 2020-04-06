//
//  PoopCollection.swift
//  Number 2
//
//  Created by Andrew Cope on 8/27/16.
//  Copyright © 2016 Andrew Cope. All rights reserved.
//

import UIKit
import CloudKit

class PoopCollection: NSObject {

    var title = "Emotions"
    
    var poops = [Poop]()
    
    var order = 0
    
    init(title:String, poops:[Poop]) {
        self.title = title
        self.poops = poops
    }
    
    init(title: String) {
        self.title = title
    }
    
    var record: CKRecord? = nil
    var database: CKDatabase? = nil
    var hasLoadedData = false
    
    var collectionView: UICollectionView? = nil
    
    func fetchPoops(/*collectionView: PoopCollectionCell, indexPath: IndexPath*/) {
        if record == nil || database == nil {
            fatalError("must initialize PoopCollection with database before calling fetchPoops()")
        }
        
        
        
        
        
        let poopRecords:[CKReference] = record?.object(forKey: "poops") as! [CKReference] //poopRecords is made of 'Poop's
        
        for r in poopRecords {
            
            database?.fetch(withRecordID: r.recordID) {
                record, error in
                if error != nil {
                    print(error?.localizedDescription)
                } else if let safeRecord = record {
                    let poopTitle = safeRecord.object(forKey: "title") as! String
                    let poopData = safeRecord.object(forKey: "image") as! CKAsset
                    
                    let imageData = NSData(contentsOf: poopData.fileURL)
                    
                    if let data = imageData {
                        if let image = UIImage(data: data as Data) {
                            self.poops.append(Poop(title: poopTitle, image: image))
                            OperationQueue.main.addOperation {
                                self.collectionView?.reloadData()
                            }
                        }
                    }
                    
                }
            }
        }
        
        
        self.hasLoadedData = true
        
    }

    
    init(record: CKRecord, database: CKDatabase) { //assumes a PoopCollection Record
        super.init()
        
        self.record = record
        self.database = database
        
        title = record.object(forKey: "title") as! String
        order = record.object(forKey: "order") as! Int

    }
    
    
}
