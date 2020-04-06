//
//  CaptureButton.swift
//  Number 2
//
//  Created by Andrew Cope on 7/31/16.
//  Copyright © 2016 Andrew Cope. All rights reserved.
//

import UIKit


@IBDesignable
class CaptureButton: UIView {


    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        
        
        
//        let boundary = CGFloat(10.0)
//        
//        let innerCircle = UIBezierPath(ovalIn: CGRect(x: frame.origin.x - boundary, y: frame.origin.x - boundary, width:  frame.width - boundary * 2, height: frame.height - boundary * 2))
//        UIColor(red: 195/255, green: 210/255, blue: 119/255, alpha: 1).setFill()
//        UIColor(red: 195/255, green: 210/255, blue: 119/255, alpha: 1).setStroke()
//
//        innerCircle.fill()
//        
//        let outerCircle = UIBezierPath(ovalIn: frame)
//        outerCircle.lineWidth = 8
//        outerCircle.stroke()
        
        UIColor.blue.setFill()
        UIBezierPath(ovalIn: frame).fill()
        
    }
 

}
