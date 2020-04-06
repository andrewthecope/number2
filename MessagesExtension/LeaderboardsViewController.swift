//
//  LeaderboardsViewController.swift
//  Number 2
//
//  Created by Andrew Cope on 8/31/16.
//  Copyright © 2016 Andrew Cope. All rights reserved.
//

import UIKit
import CloudKit
import MapKit

class LeaderboardsViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    var currentAwards = [Award]()
    var sentPoops = [SentPoop]()
    
    //outlets
    @IBOutlet weak var poopsSentLabel: UILabel!
    @IBOutlet weak var picsSentLabel: UILabel!
    @IBOutlet weak var currentStreakLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var furthestDistanceLabel: UILabel!
    @IBOutlet weak var longestStreakLabel: UILabel!
    var annotations = [MKAnnotation]()
    var messagesDelegate: ScreenToMessages? = nil
    
    override func viewDidLoad() {
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        mapView.showAnnotations(annotations, animated: false)
    }
    
    func updateUI() {
        
        var numPoopsSent = 0
        var numPicsSent = 0
        annotations = [MKAnnotation]()
        
        for poop in sentPoops {
            if poop.picOrPoop == .pic {
                numPicsSent += 1
            } else {
                numPoopsSent += 1
            }
            
            annotations.append(poop.location)
            mapView.addAnnotation(poop.location)
        }
        
        mapView.showAnnotations(annotations, animated: false)
        
        picsSentLabel.text = "\(numPicsSent)"
        poopsSentLabel.text = "\(numPoopsSent)"
        furthestDistanceLabel.text = "\(String(format: "%.2f mi.", LeaderboardsViewController.calculateFurthestDistance(sentPoops: sentPoops)))"
        
        let currentStreak = LeaderboardsViewController.caluclateCurrentStreak(array: sentPoops)
        if currentStreak == 1 {
            currentStreakLabel.text = "\(currentStreak) Day"
        } else {
            currentStreakLabel.text = "\(currentStreak) Days"
        }
        
        let longestStreak = LeaderboardsViewController.calculateLongestStreak(sentPoops: sentPoops)
        if longestStreak == 1 {
            longestStreakLabel.text = "\(longestStreak) Day"
        } else {
            longestStreakLabel.text = "\(longestStreak) Days"
        }
        
    }
    

    
    static func calculateFurthestDistance(sentPoops:[SentPoop]) -> Double {
        var ret = CLLocationDistance(0.0)
        for poop1 in sentPoops {
            let loc1 = poop1.location.location
            for poop2 in sentPoops {
                let loc2 = poop2.location.location
                let distance = loc1.distance(from: loc2)
                if distance > ret {
                    ret = distance
                }
            }
        }
        //convert from meters to miles
        ret = ret * 0.000621371
        return ret
    }
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? PoopLocation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                
            }
            return view
        }
        return nil
    }
    
    
    // Mark - CollectionView stuff
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("self.currentAwards.count = \(self.currentAwards.count)")
        return self.currentAwards.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! AwardCell
        cell.award = self.currentAwards[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! AwardCell
        messagesDelegate?.showAwardViewController(award: cell.award!)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    ///Streak Calculator
    
    static func calculateLongestStreak(sentPoops:[SentPoop]) -> Int {
        
        var longestStreak = 0
        
        for poop in sentPoops {
            var streak = 0
            var date = poop.timeStamp
            while (find(date: date, in: sentPoops)) {
                streak += 1
                date = getNextDay(date: date)
            }
            
            if longestStreak < streak {
                longestStreak = streak
            }
            
            streak = 0
        }
        
        print("longestStreak is \(longestStreak)")
        return longestStreak
    }
    
    static func getNextDay(date:Date) -> Date {
        var dayComponent = DateComponents()
        dayComponent.day = 1
        
        let theCalendar = NSCalendar.current
        let nextDate = theCalendar.date(byAdding: dayComponent, to: date)
        return nextDate!
    }
    
    static func getPreviousDay(date:Date) -> Date {
        var dayComponent = DateComponents()
        dayComponent.day = -1
        
        let theCalendar = NSCalendar.current
        let prevDate = theCalendar.date(byAdding: dayComponent, to: date)
        return prevDate!
    }
    
    static func find(date:Date, in array:[SentPoop]) -> Bool {
        for poop in array {
            if NSCalendar.current.isDate(poop.timeStamp, inSameDayAs: date) {
                return true
            }
        }
        
        return false
    }
    
    static func caluclateCurrentStreak(array: [SentPoop]) -> Int {
        
        let sentPoops = array.sorted(by: {(a,b) -> Bool in //backwards order
            return a.timeStamp > b.timeStamp
        })
        
        var currentStreak = 0
        
        if sentPoops.count > 0 {
            var date = sentPoops[0].timeStamp
            let now = Date()
            
            if NSCalendar.current.isDate(date, inSameDayAs: now) {
                while (find(date: date, in: sentPoops)) {
                    currentStreak += 1
                    date = getPreviousDay(date: date)
                }
            }
            
            
            
            
        }
        
        print("currentStreak is \(currentStreak)")
        return currentStreak
        
    }
    
}
