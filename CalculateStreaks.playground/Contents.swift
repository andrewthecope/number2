//: Playground - noun: a place where people can play

import UIKit


class SentPoop:NSObject {
    var timeStamp = Date()
    init(date:String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        if let d = dateFormatter.date(from: date) {
            timeStamp = d
        } else {
            print("not valid")
        }
    }
}

var sentPoops = [
                 SentPoop(date:"2016-09-9 02:19:34"),
                SentPoop(date:"2016-09-10 02:18:34"),
                
                SentPoop(date:"2016-09-11 02:12:34"),
                SentPoop(date:"2016-09-12 08:18:34"),
                SentPoop(date:"2016-09-14 03:09:34"),
                SentPoop(date:"2016-09-16 01:28:34"),

                ]

func calculateLongestStreak(sentPoops:[SentPoop]) -> Int {
    
    sentPoops.sorted(by: {(a,b) -> Bool in
        return a.timeStamp < b.timeStamp
    })
    
    
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
    
    sentPoops
    
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

caluclateCurrentStreak(array: sentPoops)
calculateLongestStreak(sentPoops: sentPoops)
