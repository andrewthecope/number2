//
//  StreakCalculator.swift
//  Number 2
//
//  Created by Andrew Cope on 9/15/16.
//  Copyright © 2016 Andrew Cope. All rights reserved.
//

import UIKit


protocol StreakCalculator {
    func calculateLongestStreak(sentPoops:[SentPoop]) -> Int
    func caluclateCurrentStreak(array: [SentPoop]) -> Int
    
    func getNextDay(date:Date) -> Date
    func getPreviousDay(date:Date) -> Date
    func find(date:Date, in array:[SentPoop]) -> Bool
}


extension StreakCalculator where Self: UIViewController {
    func calculateLongestStreak(sentPoops:[SentPoop]) -> Int {
        
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
    
    func getNextDay(date:Date) -> Date {
        var dayComponent = DateComponents()
        dayComponent.day = 1
        
        let theCalendar = NSCalendar.current
        let nextDate = theCalendar.date(byAdding: dayComponent, to: date)
        return nextDate!
    }
    
    func getPreviousDay(date:Date) -> Date {
        var dayComponent = DateComponents()
        dayComponent.day = -1
        
        let theCalendar = NSCalendar.current
        let prevDate = theCalendar.date(byAdding: dayComponent, to: date)
        return prevDate!
    }
    
    func find(date:Date, in array:[SentPoop]) -> Bool {
        for poop in array {
            if NSCalendar.current.isDate(poop.timeStamp, inSameDayAs: date) {
                return true
            }
        }
        
        return false
    }
    
    func caluclateCurrentStreak(array: [SentPoop]) -> Int {
        
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
