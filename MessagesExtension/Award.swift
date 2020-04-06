//
//  Award.swift
//  Number 2
//
//  Created by Andrew Cope on 8/29/16.
//  Copyright © 2016 Andrew Cope. All rights reserved.
//

import UIKit
import CloudKit

class Award: NSObject {

    
    var title = "Pooping Royalty"
    var subTitle = "Most Poops Sent"
    var image = UIImage()
    var prize = Prize()
    
    var determineIfWon = {
        (_: [SentPoop]) -> Bool in
            return true
    }
    
    
    init(title: String, subTitle: String, prize: Prize, image: UIImage, determineIfWon: @escaping ([SentPoop]) -> Bool) {
        self.title = title
        self.subTitle = subTitle
        self.prize = prize
        self.image = image
        self.determineIfWon = determineIfWon
    }
    
    init(record:CKRecord) {
        title = record.object(forKey: "title") as! String
        subTitle = record.object(forKey: "subTitle") as! String
        
        let awardImageAsset = record.object(forKey: "image") as! CKAsset
        let awardData = NSData(contentsOf: awardImageAsset.fileURL)
        if let d = awardData {
            if let image = UIImage(data: d as Data) {
                self.image = image
            }
        }
        
        
        
        
        let prizeType = record.object(forKey: "prizeType") as! Int
        
        let prizeData = record.object(forKey: "prize") as! CKAsset
        let imageData = NSData(contentsOf: prizeData.fileURL)
        
        if let data = imageData {
            if let image = UIImage(data: data as Data) {
                
                switch prizeType {
                case 0: //poop
                    let poopTitle = record.object(forKey: "prizePoopTitle") as? String
                    if let t = poopTitle {
                        prize = Prize(poop: Poop(title: t, image: image))
                    }
                    
                    
                case 1: //accessory
                    prize = Prize(accessory:image)
                case 2: //background
                    prize = Prize(background:image)
                default: //fatalError
                    fatalError("PrizeType not recognized integer")
                }
                
                
                
            }
        }
    }
    
}
