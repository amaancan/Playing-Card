//
//  PlayingCardView.swift
//  PlayingCard
//
//  Created by Amaan on 2018-01-25.
//  Copyright © 2018 amaancan. All rights reserved.
//

import UIKit


@IBDesignable // Compiles this UIView and puts it in IB evnironment. But, UIImages initialiazed w/ UIImage(named:) init don't work in IB, use diff init UIImage(named:in:compatibleWith:) for cardBack and faceImages.
class PlayingCardView: UIView {
    
    //** Interface Builder Notes:
    // - PlayingCardView Content Mode = 'Redraw'
    // - PlayingCardView set to Background Color = 'Clear'  --> need to uncheck 'Opaque'
    // - PlayingCardView 'advisory contsraints >= X points from the edges, so view doesn't get bigger than safe area, but primary contraint is to maintain card-sized aspect ratio
    // - VC dragged UITapGR obj into PlayingCardView, then created it's handling action by ctrl-dragging into VC (which made it the 'target')
    
    // Different from our model which has rank/string as enums. But our view knows nothing about the model so it's okay to represent rank/suit in a different way. Controller will translate between the model and the view.
    
    // When we have vars that affect the way the view is drawn. Think about how how the view needs to change based on the var changing.
    // When these vars change --> tell system that draw(rect:) needs to be called to Redraw card, since we can't call draw(rect:) directly. And that subviews need to be redrawn.
    @IBInspectable var rank: Int = 5 { didSet { setNeedsDisplay(); setNeedsLayout() } }
    @IBInspectable var suit: String = "♠️" { didSet { setNeedsDisplay(); setNeedsLayout() } }
    @IBInspectable var isFaceUp: Bool = true { didSet { setNeedsDisplay(); setNeedsLayout() } }
    var faceCardScale: CGFloat = SizeRatio.faceCardImageSizeToBoundsSize { didSet { setNeedsDisplay() } } // this observer doesn't need setNeedsLayout() since zooming doesn't change size, nor displace other views
    
    override func draw(_ rect: CGRect) { // called by system via setNeedsDisplay()
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        // I want my roundedRect to be the clipping area for all my drawing. Don't want to draw outside that RoundedRect
        roundedRect.addClip()
        UIColor.white.setFill()
        roundedRect.fill()
        
        if isFaceUp {
            // Note: good practice to optionally unwrap instead of using image literal?
            if let faceCardImage = UIImage (named: rankString + suit, in: Bundle(for: self.classForCoder), compatibleWith: traitCollection) {
                faceCardImage.draw(in: bounds.zoom(by: faceCardScale))
            } else {
                drawPips() // for numbered card
            }
        } else {
            if let cardBackImage = UIImage(named: "cardback", in: Bundle(for: self.classForCoder), compatibleWith: traitCollection) {
                cardBackImage.draw(in: bounds)
            }
        }
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
    
    // ***Note: this GR is being handled in View itself, not VC, because it doesn't affect model or any other view. It just affects itself.
    @objc func handleFaceCardScaling(recognizedBy recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            faceCardScale *= recognizer.scale
            // I only want incremental changes because I'm changing the scale each time, otherwise the scaling would be exponential. Reset the recognizers scale to 1.0 each time pinch is changed or ended.
            recognizer.scale = 1.0
        default: break //ignore all other states
        }
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
    
    private func drawPips() {
        let pipsPerRowForRank = [[0], [1], [1,1], [1,1,1], [2,2], [2,1,2], [2,2,2], [2,1,2,2], [2,2,2,2], [2,2,1,2,2], [2,2,2,2,2]]
        
        //Embeded func: picks the right size pip to be drawn
        func createPipString(thatFits pipRect: CGRect) -> NSAttributedString {
            let maxVerticalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.count, $0)})
            let maxHorizontalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.max() ?? 0, $0)})
            let verticalPipRowSpacing = pipRect.size.height / maxVerticalPipCount
            let attemptedPipString = centeredAttributedString(suit, fontSize: verticalPipRowSpacing)
            let probablyOkayPipStringFontSize = verticalPipRowSpacing / (attemptedPipString.size().height / verticalPipRowSpacing)
            let probablyOkayPipString = centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize)
            if probablyOkayPipString.size().width > pipRect.size.width / maxHorizontalPipCount {
                return centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize /
                    (probablyOkayPipString.size().width / (pipRect.size.width / maxHorizontalPipCount)))
            } else {
                return probablyOkayPipString
            }
        }
        
        // draws pips based on rank
        if pipsPerRowForRank.indices.contains(rank) {
            let pipsPerRow = pipsPerRowForRank[rank]
            var pipRect = bounds.insetBy(dx: cornerOffset, dy: cornerOffset).insetBy(dx: cornerString.size().width, dy: cornerString.size().height / 2)
            let pipString = createPipString(thatFits: pipRect)
            let pipRowSpacing = pipRect.size.height / CGFloat(pipsPerRow.count)
            pipRect.size.height = pipString.size().height
            pipRect.origin.y += (pipRowSpacing - pipRect.size.height) / 2
            for pipCount in pipsPerRow {
                switch pipCount {
                case 1:
                    pipString.draw(in: pipRect)
                case 2:
                    pipString.draw(in: pipRect.leftHalf)
                    pipString.draw(in: pipRect.rightHalf)
                default:
                    break
                }
                pipRect.origin.y += pipRowSpacing
            }
        }
    }
}


extension CGRect {
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

