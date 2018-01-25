//
//  PlayingCardView.swift
//  PlayingCard
//
//  Created by Amaan on 2018-01-25.
//  Copyright © 2018 amaancan. All rights reserved.
//

import UIKit

class PlayingCardView: UIView {

 
    override func draw(_ rect: CGRect) {
        // Draw circle using core graphics: need context first
        if let context = UIGraphicsGetCurrentContext() { // will never return nil inside draw(rect:) func
           //my bounds specifies my drawing area
            context.addArc(center: CGPoint(x: bounds.midX, y: bounds.midY), radius: 100.0, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
            context.setLineWidth(5.0)
            UIColor.green.setFill()
            UIColor.red.setStroke()
            context.strokePath() // When drawing in context: stroking consumes the path so need to draw path again
            context.fillPath() // Fill won't work since there is no path ... got consumed by stroke
        }
        
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint.init(x: bounds.midX, y: bounds.midY), radius: 70.0, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        path.lineWidth = 5.0
        UIColor.green.setFill()
        UIColor.purple.setStroke()
        path.stroke() // that UIBezierPath still exists, doesn't get consumed, so I can use it over and over again
        path.fill()
        // by default: when you change the bounds of your view (rotate landscape) it just takes the bits and scales them to the new size (circle becomes oval) --> **UIView's 'Content Mode' = 'Redraw' in IB**
        
    }
 

}
