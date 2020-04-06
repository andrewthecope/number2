//
//  PoopCollectionCell.swift
//  Number 2
//
//  Created by Andrew Cope on 8/27/16.
//  Copyright © 2016 Andrew Cope. All rights reserved.
//

import UIKit

class PoopCollectionCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var messagesDelegate: ScreenToMessages? = nil

    @IBOutlet weak var title: UILabel!
    var poopIndex = 0
    
    var poopCollection = PoopCollection(title: "Collection", poops: [Poop]())
    
    @IBOutlet weak var spinner: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    @IBOutlet weak var cellRC: RoundedCorners!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return poopCollection.poops.count
        
    }
    
    func onTap(_ recognizer: UILongPressGestureRecognizer) {
        
        if recognizer.state == .began {
            if let cell = recognizer.view as? PoopCell {
                cell.cellRC.bounceDown()
            }
        } else if recognizer.state == .ended {
            if let cell = recognizer.view as? PoopCell {
                cell.cellRC.bounceUp()
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PoopCell
        
        cell.title.text = poopCollection.poops[indexPath.row].title
        cell.image.image = poopCollection.poops[indexPath.row].image
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(PoopCollectionCell.onTap(_:)))
        recognizer.minimumPressDuration = 0.1
        recognizer.cancelsTouchesInView = false
        cell.addGestureRecognizer(recognizer)
        
        return cell
    }
    
    
    
//    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath) as! PoopCell
//        cell.cellRC.bounceDown()
//        
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath) as! PoopCell
//        cell.cellRC.bounceUp()
//    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath) as! PoopCell
//        cell.cellRC.bounceDown()
        messagesDelegate?.editPoop(poop: poopCollection.poops[indexPath.row])
    }
    
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath) as! PoopCell
//        cell.cellRC.bounceUp()
//    }

}
