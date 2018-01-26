//
//  PlayingCardView.swift
//  PlayingCard
//
//  Created by Amaan on 2018-01-25.
//  Copyright © 2018 amaancan. All rights reserved.
//

import UIKit

class PlayingCardView: UIView {
    
    //** Interface Builder Notes:
    // UIView set to Background Color = 'Clear'  --> need to uncheck 'Opaque'
    
    // Different from our model which has rank/string as enums. But our view knows nothing about the model so it's okay to represent rank/suit in a different way. Controller will translate between the model and the view.
    
    // When we have vars that affect the way the view is drawn. Think about how how the view needs to change based on the var changing.
    // When these vars change --> tell system that draw(rect:) needs to be called to Redraw card, since we can't call draw(rect:) directly. And that subviews need to be redrawn.
    var rank: Int = 6 { didSet { setNeedsDisplay(); setNeedsLayout() } }
    var suit: String = "❤️" { didSet { setNeedsDisplay(); setNeedsLayout() } }
    var isFaceUp: Bool = true { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    override func draw(_ rect: CGRect) { // called by system via setNeedsDisplay()
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        roundedRect.addClip() // I want my roundedRect to be the clipping area for all my drawing. Don't want to draw outside that RoundedRect
        UIColor.white.setFill()
        roundedRect.fill()
    }
    
    private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        // preferred font instead of system font since it's user information
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: string,
                                  attributes: [NSAttributedStringKey.paragraphStyle: paragraphStyle, .font: font])
    }
    
    private var cornerString: NSAttributedString {
        // fontSize will depend on size of card
        return centeredAttributedString(rankString+"\n"+suit, fontSize: cornerFontSize)
    }
    
    // 'lazy': a var can't call own Type's methods until everything in the Type (class/struct etc.) is initialzed
    private lazy var upperLeftCornerLabel = createCornerLabel()
    private lazy var lowerRightCornerLabel = createCornerLabel()
    
    private func createCornerLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0 // 0 = as many as you need. Default = 1: but we need 2.
        addSubview(label)
        return label
    }
    private func configureCornerLabel (_ label: UILabel) {
        label.attributedText = cornerString
        label.frame.size = CGSize.zero // clear before sizeToFit()
        label.sizeToFit() // keeps old dimensions and adds to it, so should clear old dimensions before using it
        label.isHidden = !isFaceUp
    }
    override func layoutSubviews() {
        // Gets called by system anytime your subviews need to be laid out for any reason: e.g. bounds change, setNeedsLayout() called. Uses auto layout
        // Remember: frame is for positioning a UIView and bounds is for drawing

        super.layoutSubviews()
        
        configureCornerLabel(upperLeftCornerLabel)
        upperLeftCornerLabel.frame.origin = bounds.origin.offsetBy(dx: cornerOffset, dy: cornerOffset)

        configureCornerLabel(lowerRightCornerLabel)
        // Rotate it upside-down: An affine transformation is var on UIView, made up of 3 changes to the bits:
            // a scale, translation, and rotation
        lowerRightCornerLabel.transform = CGAffineTransform.identity
            .translatedBy(x: lowerRightCornerLabel.frame.size.width, y: lowerRightCornerLabel.frame.size.height)
            .rotated(by: CGFloat.pi)
        lowerRightCornerLabel.frame.origin = CGPoint(x: bounds.maxX, y: bounds.maxY)
            // Needed since origin point = upper left corner of any UIVIiew
            .offsetBy(dx: -cornerOffset, dy: -cornerOffset)
            .offsetBy(dx: -lowerRightCornerLabel.frame.size.width, dy: -lowerRightCornerLabel.frame.size.height)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // When someone changes dynamic font size in accessiblity: we need to respond by redrawing and re-laying out
        //Traits are: accessibility size of font, rotate, etc.
        setNeedsDisplay()
        setNeedsLayout()
    }
}



extension PlayingCardView {
    private struct SizeRatio {
        static let cornerFontSizeToBoundsHeight: CGFloat = 0.085
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
        static let cornerOffsetToCornerRadius: CGFloat = 0.33
        static let faceCardImageSizeToBoundsSize: CGFloat = 0.75
    }
    
    private var cornerRadius: CGFloat { return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight }
    private var cornerOffset: CGFloat { return cornerRadius * SizeRatio.cornerOffsetToCornerRadius}
    private var cornerFontSize: CGFloat { return bounds.size.height * SizeRatio.cornerFontSizeToBoundsHeight}
    
    private var rankString: String {
        switch rank {
        case 1: return "A"
        case 2...10: return String(rank)
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        default: return "?"
        }
    }
}


extension CGRect {
    //**TODO: see min vs. mid: may be a mistake?
    var leftHalf: CGRect { return CGRect (x: minX, y: minY, width: width/2, height: height) }
    var rightHalf: CGRect { return CGRect (x: midX, y: minY, width: width/2, height: height) }
    
    func inset(by size: CGSize) -> CGRect {
        return insetBy(dx: size.width, dy: size.height)
    }
    
    func sized(to size: CGSize) -> CGRect {
        return CGRect (origin: origin, size: size)
    }
    
    func zoom(by scale: CGFloat) -> CGRect {
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth) / 2, dy: (height - newHeight) / 2)
    }
}

extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint (x: x + dx, y: y + dy)
    }
}

