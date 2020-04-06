//
//  PoopStickersController.swift
//  Number 2
//
//  Created by Andrew Cope on 7/19/16.
//  Copyright © 2016 Andrew Cope. All rights reserved.
//

import UIKit


private let reuseIdentifier = "Cell"

class PoopStickersController: UICollectionViewController {
    // MARK: Types
    
    /// An enumeration that represents an item in the collection view.
    enum CollectionViewItem {
        case iceCream
        case create
    }
    
    // MARK: Properties
    
    static let storyboardIdentifier = "IceCreamsViewController"
    
    private let items: [PoopSticker]
    
    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        // Map the previously completed ice creams to an array of `CollectionViewItem`s.
        for _ in 0..<8 {
            items.append(PoopSticker())
        }
        
        super.init(coder: aDecoder)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.row]
        
        return dequeueIceCreamCell(for: iceCream, at: indexPath)
        
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        
        switch item {
        case .create:
            delegate?.iceCreamsViewControllerDidSelectAdd(self)
            
        default:
            break
        }
    }
    
    // MARK: Convenience
    
    private func dequeueIceCreamCell(for iceCream: IceCream, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView?.dequeueReusableCell(withReuseIdentifier: IceCreamCell.reuseIdentifier, for: indexPath) as? IceCreamCell else { fatalError("Unable to dequeue am IceCreamCell") }
        
        cell.representedIceCream = iceCream
        
        // Use a placeholder sticker while we fetch the real one from the cache.
        let cache = IceCreamStickerCache.cache
        cell.stickerView.sticker = cache.placeholderSticker
        
        // Fetch the sticker for the ice cream from the cache.
        cache.sticker(for: iceCream) { sticker in
            OperationQueue.main.addOperation {
                // If the cell is still showing the same ice cream, update its sticker view.
                guard cell.representedIceCream == iceCream else { return }
                cell.stickerView.sticker = sticker
            }
        }
        
        return cell
    }
    
    private func dequeueIceCreamOutlineCell(at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView?.dequeueReusableCell(withReuseIdentifier: IceCreamOutlineCell.reuseIdentifier, for: indexPath) as? IceCreamOutlineCell else { fatalError("Unable to dequeue a IceCreamOutlineCell") }
        
        return cell
    }
}
