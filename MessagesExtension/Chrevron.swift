//
//  Chrevron.swift
//  Number 2
//
//  Created by Andrew Cope on 8/21/16.
//  Copyright © 2016 Andrew Cope. All rights reserved.
//

import UIKit

@IBDesignable class Chrevron: UIView {

    @IBInspectable var direction: Int = 0
    @IBInspectable var color: UIColor = UIColor.white
    @IBInspectable var width: Double = 5.0
    @IBInspectable var padding: Double = 3.0
    

    override func draw(_ rect: CGRect) {
        // Drawing code
        
        let refFrame = CGRect(x: padding, y: padding, width: Double(frame.width) - 2 * padding, height: Double(frame.height) - 2 * padding)
        
        let path = UIBezierPath()
        
        if direction == 0 { //Right
            
            path.move(to: CGPoint(x: refFrame.origin.x, y: refFrame.origin.y))
            path.addLine(to: CGPoint(x: refFrame.origin.x + refFrame.width, y: refFrame.origin.x + 0.5 * refFrame.height))
            path.addLine(to: CGPoint(x: refFrame.origin.x, y: refFrame.origin.y + refFrame.height))
            path.lineJoinStyle = CGLineJoin.miter
            path.lineWidth = CGFloat(width)
            color.setStroke()
            path.stroke()
            
        } else { //Left
            
            path.move(to: CGPoint(x: refFrame.origin.x + refFrame.width, y: refFrame.origin.y))
            path.addLine(to: CGPoint(x: refFrame.origin.x, y: refFrame.origin.x + 0.5 * refFrame.height))
            path.addLine(to: CGPoint(x: refFrame.origin.x + refFrame.width, y: refFrame.origin.y + refFrame.height))
            path.lineJoinStyle = CGLineJoin.miter
            path.lineWidth = CGFloat(width)
            color.setStroke()
            path.stroke()
            
        }

    }
 

}
