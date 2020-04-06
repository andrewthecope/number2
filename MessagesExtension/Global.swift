//
//  Global.swift
//  Number 2
//
//  Created by Andrew Cope on 8/13/16.
//  Copyright © 2016 Andrew Cope. All rights reserved.
//

import UIKit


//var currentAwards = [Award]()

//var names = [UUID:String]()

//var accessories = [UIImage]()

//var poops = [Poop]()

//var poopCollections = [PoopCollection]()



//prizes you have won
var prizePoops = PoopCollection(title: "Awards", poops: [Poop]())
var prizeAccessories = [UIImage]()
var prizeBackgrounds = [UIImage]()


var awards = [
    Award(title: "The Newbie", subTitle: "Sent your first message in Number 2.", prize:  Prize(accessory: #imageLiteral(resourceName: "sunglasses")), image: #imageLiteral(resourceName: "newbie"),determineIfWon: {sentPoops in
        if sentPoops.count > 0 {
            return true
        }
        return false
        }),
    Award(title: "The Regular: Bronze", subTitle: "Sent 8 poops.", prize: Prize(background: #imageLiteral(resourceName: "tile")), image: #imageLiteral(resourceName: "bronzeRegular"), determineIfWon: {sentPoops in
        var counter = 0
        for p in sentPoops {
            if p.picOrPoop == .poop {
                counter += 1
                if counter >= 8 {
                    return true
                }
            }
        }
        return false
    }),
    Award(title: "The Regular: Silver", subTitle: "Sent 15 poops.", prize: Prize(accessory: #imageLiteral(resourceName: "santa")), image: #imageLiteral(resourceName: "silverRegular"), determineIfWon: {sentPoops in
        var counter = 0
        for p in sentPoops {
            if p.picOrPoop == .poop {
                counter += 1
                if counter >= 15 {
                    return true
                }
            }
        }
        return false
    }),
    Award(title: "The Regular: Gold", subTitle: "Sent 25 poops.", prize: Prize(accessory: #imageLiteral(resourceName: "poopMask")), image: #imageLiteral(resourceName: "goldRegular"), determineIfWon: {sentPoops in
        var counter = 0
        for p in sentPoops {
            if p.picOrPoop == .poop {
                counter += 1
                if counter >= 25 {
                    return true
                }
            }
        }
        return false
    }),
    
    
    
    //Poop-o-grapher
    Award(title: "The Poop-ographer: Bronze", subTitle: "Sent 8 selfies.", prize: Prize(accessory: #imageLiteral(resourceName: "kitty")), image: #imageLiteral(resourceName: "cameraBronze"), determineIfWon: {sentPoops in
        var counter = 0
        for p in sentPoops {
            if p.picOrPoop == .pic {
                counter += 1
                if counter >= 8 {
                    return true
                }
            }
        }
        return false
    }),
    Award(title: "The Poop-ographer: Silver", subTitle: "Sent 15 selfies.", prize: Prize(accessory: #imageLiteral(resourceName: "goldGlasses")), image: #imageLiteral(resourceName: "cameraSilver"), determineIfWon: {sentPoops in
        var counter = 0
        for p in sentPoops {
            if p.picOrPoop == .pic {
                counter += 1
                if counter >= 15 {
                    return true
                }
            }
        }
        return false
    }),
    Award(title: "The Poop-ographer: Gold", subTitle: "Sent 25 selfies.", prize: Prize(background: #imageLiteral(resourceName: "toiletback")), image: #imageLiteral(resourceName: "cameraAward"), determineIfWon: {sentPoops in
        var counter = 0
        for p in sentPoops {
            if p.picOrPoop == .pic {
                counter += 1
                if counter >= 25 {
                    return true
                }
            }
        }
        return false
    }),
    
    //The Traveler
    Award(title: "The Traveler: Bronze", subTitle: "Two check-ins at least 10 miles apart.", prize: Prize(background: #imageLiteral(resourceName: "starry")), image: #imageLiteral(resourceName: "travelBronze"), determineIfWon: {sentPoops in
        let distance = LeaderboardsViewController.calculateFurthestDistance(sentPoops: sentPoops)
        if distance >= 10 {
            return true
        } else {
            return false
        }
    }),
    Award(title: "The Traveler: Silver", subTitle: "Two check-ins at least 100 miles apart.", prize: Prize(accessory: #imageLiteral(resourceName: "bow")), image: #imageLiteral(resourceName: "travelSilver"), determineIfWon: {sentPoops in
        let distance = LeaderboardsViewController.calculateFurthestDistance(sentPoops: sentPoops)
        if distance >= 100 {
            return true
        } else {
            return false
        }
        
    }),
    Award(title: "The Traveler: Gold", subTitle: "Two check-ins at least 300 miles apart.", prize: Prize(accessory: #imageLiteral(resourceName: "googlies")), image: #imageLiteral(resourceName: "travelGold"), determineIfWon: {sentPoops in
        let distance = LeaderboardsViewController.calculateFurthestDistance(sentPoops: sentPoops)
        if distance >= 300 {
            return true
        } else {
            return false
        }
    }),
    
    
    
    //The Streaker
    Award(title: "The Streaker: Bronze", subTitle: "Longest streak of at least 3 days.", prize: Prize(accessory: #imageLiteral(resourceName: "toiletpaper")), image: #imageLiteral(resourceName: "streakBronze"), determineIfWon: {sentPoops in
        let streak = LeaderboardsViewController.calculateLongestStreak(sentPoops: sentPoops)
        if streak >= 3 {
            return true
        } else {
            return false
        }
    }),
    Award(title: "The Streaker: Silver", subTitle: "Longest streak of at least 7 days.", prize: Prize(accessory: #imageLiteral(resourceName: "crink")), image: #imageLiteral(resourceName: "streakSilver"), determineIfWon: {sentPoops in
        let streak = LeaderboardsViewController.calculateLongestStreak(sentPoops: sentPoops)
        if streak >= 7 {
            return true
        } else {
            return false
        }
        
    }),
    Award(title: "The Streaker: Gold", subTitle: "Longest streak of at least 15 days.", prize: Prize(poop: Poop(title: "Scream", image: #imageLiteral(resourceName: "scream"))), image: #imageLiteral(resourceName: "streakGold"), determineIfWon: {sentPoops in
        let streak = LeaderboardsViewController.calculateLongestStreak(sentPoops: sentPoops)
        if streak >= 15 {
            return true
        } else {
            return false
        }
    }),
    
    ]

//var backgrounds = [UIImage]()


var captions = ["Oops I Did It Again.",
                "It came in like a wreckingball",
                "Started from the bottom now we're here.",
                "Can't hold it back anymore",
                "$5 footlong",
                "Hello from the other side.",
                "Who let the dogs out?",
                "I'm Free, Free Fallin'",
                "It's going down. I'm yelling timber.",
                "I can't fight this feeling anymore.",
                "Drop it like it's hot.",
                "Easy, breezy, beautiful.",
                "Good things come to those who wait.",
                "Elvis has left the building.",
                "The eagle has landed.",
                ]

var newCaption: String {
    return captions[Int(arc4random_uniform(UInt32(captions.count)))]
}

