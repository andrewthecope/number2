//
//  AwardViewController.swift
//  Number 2
//
//  Created by Andrew Cope on 9/13/16.
//  Copyright © 2016 Andrew Cope. All rights reserved.
//

import UIKit

class AwardViewController: UIViewController {

    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var awardTitle: UILabel!
    @IBOutlet weak var awardSubTitle: UILabel!
    @IBOutlet weak var awardImage: UIImageView!
    @IBOutlet weak var prizeImage: UIImageView!
    @IBOutlet weak var prizeLabel: UILabel!
    
    @IBOutlet weak var container: RoundedCorners!
    
    var award = Award(title: "Full Moon: Bronze", subTitle: "", prize: Prize(), image: UIImage(), determineIfWon: {_ in true})
    
    var messagesDelegate: ScreenToMessages? = nil

    override func viewDidLoad() {
        view.alpha = 0
        container.setUpForBounce()
    }
    
    @IBAction func xPressed(_ sender: UIButton) {
        container.bounceDown()
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 0
        }) { _ in
            self.messagesDelegate?.hideAwardViewController(award: self.award)
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.5, animations: { self.view.alpha = 1}) { _ in
            self.container.bounceUp()
        }
    }
    
    
    func updateUI(award:Award) {
        self.award = award
        
        awardTitle.text = award.title
        awardSubTitle.text = award.subTitle
        awardImage.image = award.image
        prizeImage.image = award.prize.image
        prizeLabel.text = award.prize.prizeLabel
    }
    
 
    
    
}
