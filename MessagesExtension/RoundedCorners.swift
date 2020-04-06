//
//  RoundedCorners.swift
//  Number 2
//
//  Created by Andrew Cope on 7/27/16.
//  Copyright © 2016 Andrew Cope. All rights reserved.
//

import UIKit

@IBDesignable class RoundedCorners: UIButton {
    
    @IBInspectable var background: UIColor = UIColor.white
    @IBInspectable var cornerRadius: Double = 5.0
    @IBInspectable var width: Double = 0.6
    @IBInspectable var outlineColor: UIColor = UIColor.black
    
    
    override func draw(_ rect: CGRect) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight, .bottomRight, .bottomLeft], cornerRadii: CGSize(width: cornerRadius,height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path  = maskPath.cgPath
        self.layer.mask = maskLayer
        layer.borderColor = outlineColor.cgColor
        layer.backgroundColor = background.cgColor
        layer.cornerRadius = CGFloat(cornerRadius)
        layer.borderWidth = CGFloat(width)
 
    }
    
    override func layoutSubviews() {
        setNeedsDisplay()
    }

    func bounceDown() {
        UIView.animate(withDuration: 2.0, delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 6.0,
            options: UIViewAnimationOptions.allowUserInteraction,
            animations: {
              self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }, completion: nil)
    }
    
    func bounceUp() {
        UIView.animate(withDuration: 2.0, delay: 0,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 6.0,
                       options: UIViewAnimationOptions.allowUserInteraction,
                       animations: {
                        self.transform = CGAffineTransform(scaleX: 1, y: 1)
                        self.alpha = 1
            }, completion: nil)
    }
    
    func setUpForBounce() {
        self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.alpha = 0
    }
    
}

@IBDesignable class TopCorners: UIButton {
    
    @IBInspectable var background: UIColor = UIColor.white
    @IBInspectable var cornerRadius: Double = 5.0
    @IBInspectable var width: Double = 0.6
    @IBInspectable var outlineColor: UIColor = UIColor.black
    
    
    override func draw(_ rect: CGRect) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadius,height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path  = maskPath.cgPath
        self.layer.mask = maskLayer
        layer.borderColor = outlineColor.cgColor
        layer.backgroundColor = background.cgColor
        //layer.cornerRadius = CGFloat(cornerRadius)
        layer.borderWidth = CGFloat(width)
        
    }
    
    override func layoutSubviews() {
        setNeedsDisplay()
    }
    
}

@IBDesignable class BottomCorners: UIButton {
    
    @IBInspectable var background: UIColor = UIColor.white
    @IBInspectable var cornerRadius: Double = 5.0
    @IBInspectable var width: Double = 0.6
    @IBInspectable var outlineColor: UIColor = UIColor.black
    
    
    override func draw(_ rect: CGRect) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: cornerRadius,height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path  = maskPath.cgPath
        self.layer.mask = maskLayer
        layer.borderColor = outlineColor.cgColor
        layer.backgroundColor = background.cgColor
        layer.cornerRadius = CGFloat(cornerRadius)
        layer.borderWidth = CGFloat(width)
        
    }
    
    override func layoutSubviews() {
        setNeedsDisplay()
    }
    
}
