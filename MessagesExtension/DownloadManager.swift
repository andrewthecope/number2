//
//  DownloadManager.swift
//  Number 2
//
//  Created by Andrew Cope on 9/24/16.
//  Copyright © 2016 Andrew Cope. All rights reserved.
//

import UIKit
import CloudKit

protocol DownloadToUI {
    func poopCollectionsDownloaded()
    func poopDownloaded(row:Int)
    func allPoopsDownloaded()
    func accessoriesDownloaded()
    func backgroundsDownloaded()
    func awardsDownloaded()
    func sentPoopsDownloaded()
    func newAwardsCalculated(newAwards: [Award])
    func showErrorMessage()
}


class DownloadManager: NSObject {

    
    var downloadDelegate: DownloadToUI? = nil
    
    var poopCollections = [PoopCollection]()
    var accessories = [UIImage]()
    var backgrounds = [UIImage]()
    
    var currentAwards = [Award]()
    var sentPoops = [SentPoop]()
    
    var hasShownErrorMessage = false //just so you only show one and aren't a total asshole about it
    func showErrorMessage() {
        if hasShownErrorMessage == false {
            downloadDelegate?.showErrorMessage()
            hasShownErrorMessage = true
        }
    }
    
    func beginDownloads() {
        fetchPoopCollections()
        fetchAccessories()
        fetchBackgrounds()
        fetchCurrentAwards()
        fetchSentPoops()
    }
    
    
    func deleteCurrentSentPoop(sentPoop: CKRecord) {
        let id = sentPoop.recordID
        
        CKContainer.default().privateCloudDatabase.delete(withRecordID: id, completionHandler: {
            _, error in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("successfully deleted sentPoop")
                self.downloadDelegate?.sentPoopsDownloaded()
                self.sentPoops = [SentPoop]()
                self.fetchSentPoops()
            }
        })
    }
    
    
    func reloadSentPoopsAndCurrentAwards() {
        currentAwards = [Award]()
        sentPoops = [SentPoop]()
        
        fetchCurrentAwards()
        fetchSentPoops()
    }
    
    
    func getRecordFrom(award: Award) -> CKRecord {
        
        let record = CKRecord(recordType: "Award")
        record.setObject(award.title as CKRecordValue, forKey: "title")
        record.setObject(award.subTitle as CKRecordValue, forKey: "subTitle")
        record.setObject(award.prize.prizeType as CKRecordValue, forKey: "prizeType")
        
        if award.prize.prizeType == 0 {
            record.setObject(award.prize.poop!.title as CKRecordValue, forKey: "prizePoopTitle")
        }
        
        let asset = CKAsset(fileURL: writeImage(image: award.prize.image))
        record.setObject(asset, forKey: "prize")
        
        let image = CKAsset(fileURL: writeImage(image: award.image))
        record.setObject(image, forKey: "image")
        
        return record
        
    }
    
    
    //calculate Awards
    func calculateNewCurrentAwards()  {
        
        var ret = [Award]()
        
        for award in awards {
            if award.determineIfWon(sentPoops) == true && !awardIsInCurrentAwards(award: award) {
                ret.append(award)
            }
        }
        
        
        //send new awards to the CLOUUUDD
        let privateDatabase = CKContainer.default().privateCloudDatabase
        
        for a in ret {
            privateDatabase.save(getRecordFrom(award: a)) {
                (_, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    self.showErrorMessage()
                } else {
                    self.currentAwards.append(a)
                    self.downloadDelegate?.awardsDownloaded() //update UI in leaderVC
                }
            }    
        }
        
        distributePrizes(awards: ret)
        
        //show in ui or whatever
        downloadDelegate?.newAwardsCalculated(newAwards: ret)
        //downloadDelegate?.awardsDownloaded()
        
    }
    
    private func awardIsInCurrentAwards(award:Award) -> Bool {
        for a in currentAwards {
            if a.title == award.title {
                return true
            }
        }
        return false
    }
    
    
    private func distributePrizes(awards: [Award]) {
        
        prizePoops = PoopCollection(title: "Awards", poops: [Poop]())
        prizeAccessories = [UIImage]()
        prizeBackgrounds = [UIImage]()
        
        for award in awards {
            if award.prize.prizeType == 0 { //poop
                prizePoops.poops.append(award.prize.poop!)
            } else if award.prize.prizeType == 1 {
                prizeAccessories.append(award.prize.accessory!)
            } else if award.prize.prizeType == 2 {
                prizeBackgrounds.append(award.prize.background!)
            }
        }
    }
    
    private func fetchSentPoops() {
        let privateDatabase = CKContainer.default().privateCloudDatabase
        let ckQuery = CKQuery(recordType: "SentPoop", predicate: NSPredicate(value: true))
        privateDatabase.perform(ckQuery, inZoneWith: nil) {
            records, error in
            
            if error != nil {
                print(error!.localizedDescription)
                self.showErrorMessage()
            } else if let safeRecords = records {
                for record in safeRecords {
                    self.sentPoops.append(SentPoop(record: record))
                }
                OperationQueue.main.addOperation {
                    self.downloadDelegate?.sentPoopsDownloaded()
                }
                
            }
        }
        
        
    }
    
    private func fetchCurrentAwards() {
    
        currentAwards = [Award]()
        
        let privateDatabase = CKContainer.default().privateCloudDatabase
        
        let ckQuery = CKQuery(recordType: "Award", predicate: NSPredicate(value: true))
        privateDatabase.perform(ckQuery, inZoneWith: nil) {
            awardRecords, error in
            
            if error != nil {
                self.showErrorMessage()
                print(error!.localizedDescription)
            } else if let safeRecords = awardRecords {
                for r in safeRecords {
                    self.currentAwards.append(Award(record: r))
                }
                OperationQueue.main.addOperation {
                    self.downloadDelegate?.awardsDownloaded()
                    self.distributePrizes(awards: self.currentAwards)
                }
            }
        }
    }
    
    private func fetchBackgrounds() {
        
        let ckContainer = CKContainer.default()
        let publicDatabase = ckContainer.publicCloudDatabase
        
        let ckQuery = CKQuery(recordType: "Background", predicate: NSPredicate(value: true))
        publicDatabase.perform(ckQuery, inZoneWith: nil) {
            records, error in
            
            if error != nil {
                self.showErrorMessage()
                print(error!.localizedDescription)
            } else if let safeRecords = records {
                
                for record in safeRecords {
                    let asset = record.object(forKey: "image") as! CKAsset
                    let data = NSData(contentsOf: asset.fileURL)
                    let image = UIImage(data: data as! Data)
                    
                    let isEnabled = record.object(forKey: "enabled") as! Int
                    if isEnabled == 1 {
                        self.backgrounds.append(image!)
                    }
                    OperationQueue.main.addOperation {
                        self.downloadDelegate?.backgroundsDownloaded()
                    }
                }
                
            }
        }
    }
    
    private func fetchAccessories() {
        let ckContainer = CKContainer.default()
        let publicDatabase = ckContainer.publicCloudDatabase
        
        let ckQuery = CKQuery(recordType: "Accessory", predicate: NSPredicate(value: true))
        publicDatabase.perform(ckQuery, inZoneWith: nil) {
            records, error in
            
            if error != nil {
                self.showErrorMessage()
                print(error!.localizedDescription)
            } else if let safeRecords = records {
                
                for record in safeRecords {
                    let asset = record.object(forKey: "image") as! CKAsset
                    let data = NSData(contentsOf: asset.fileURL)
                    let image = UIImage(data: data as! Data)
                    
                    let isEnabled = record.object(forKey: "enabled") as! Int
                    if isEnabled == 1 {
                        self.accessories.append(image!)
                    }
                }
                
                OperationQueue.main.addOperation {
                    //UPDATE UI: accessories.
                    self.downloadDelegate?.accessoriesDownloaded()
                }
                
            }
        }

    }
    
    private func fetchPoopCollections() {
        print("fetching poop collections")
        let ckContainer = CKContainer.default()
        let publicDatabase = ckContainer.publicCloudDatabase
        let ckQuery = CKQuery(recordType: "PoopCollection", predicate: NSPredicate(value: true))
        
        let tempPoop = Poop(title: "...", image: #imageLiteral(resourceName: "poopTrans"))
        
        publicDatabase.perform(ckQuery, inZoneWith: nil) {
            records, error in
            if error != nil {
                self.showErrorMessage()
                print(error!.localizedDescription)
            } else if let safeRecords = records {
                print("poop collections found")
                for collectionRecord in safeRecords {
                    let collection = PoopCollection(title: collectionRecord["title"] as! String)
                    collection.order = collectionRecord["order"] as! Int
                    var tempPoops = [Poop]()
                    for _ in 0..<(collectionRecord["poops"] as! [CKReference]).count {
                        tempPoops.append(tempPoop)
                    }
                    print("\(tempPoops.count) items in poopCollection")
                    collection.poops = tempPoops
                    self.poopCollections.append(collection)
                }
                
                OperationQueue.main.addOperation {
                    //UPDATE UI: Poop Collections Downloaded
                    
//                    self.poopCollections.sort(by: {a,b in
//                        a.order < b.order
//                    })
                    
                    self.downloadDelegate?.poopCollectionsDownloaded()
                }
                
                //fetch poops from from collectionRecord
                for (index, collectionRecord) in safeRecords.enumerated() {
                    self.fetchPoops(record: collectionRecord, database: publicDatabase, poopCollection: self.poopCollections[index], rowIndex: index) //this will update UI
                }
                
                
            }

        }

    }
    
    private func fetchPoops(record:CKRecord, database: CKDatabase, poopCollection: PoopCollection, rowIndex: Int) {
        
        let poopRecords:[CKReference] = record["poops"] as! [CKReference] //poopRecords is made of `Poop`s
        
        for (poopIndex,r) in poopRecords.enumerated() {
            
            database.fetch(withRecordID: r.recordID) {
                record, error in
                if error != nil {
                    self.showErrorMessage()
                    print(error?.localizedDescription)
                } else if let safeRecord = record {
                    let poopTitle = safeRecord["title"] as! String
                    let poopData = safeRecord["image"] as! CKAsset
                    
                    let imageData = NSData(contentsOf: poopData.fileURL)
                    
                    if let data = imageData {
                        if let image = UIImage(data: data as Data) {
                            if poopIndex >= 0 && poopIndex < poopCollection.poops.count {
                                poopCollection.poops[poopIndex] = Poop(title: poopTitle, image: image)
                                
                                OperationQueue.main.addOperation {
                                    //UPDATE UI: update collection view Cell somehow
                                    self.downloadDelegate?.poopDownloaded(row: rowIndex)
                                    self.downloadDelegate?.allPoopsDownloaded()
                                }
                            }
                            
                            
                        }
                    }
                }
            }
        }
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
    
    
}
