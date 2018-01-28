//
//  ViewController.swift
//  PlayingCard
//
//  Created by Amaan on 2018-01-23.
//  Copyright © 2018 amaancan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var deck = PlayingCardDeck()
    
    // Note: a good place to add gesture recognizers is in didSet of Outlets
    @IBOutlet weak var playingCardView: PlayingCardView! {
        didSet {
            // target = self = Controller: Since this swipe will change my model, can't have target = view because don't want view talking to model directly
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeToRandomCard))
            swipe.direction = [.left, .right]
            playingCardView.addGestureRecognizer(swipe)
            
            let pinch = UIPinchGestureRecognizer(target: playingCardView, action: #selector(playingCardView.handleFaceCardScaling(recognizedBy:)))
            playingCardView.addGestureRecognizer(pinch)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let card = deck.draw()
        print("\(card!)")
    }
    
    // MARK: Gesture Recognizers
    // Needs to expose this func to Objective-C because this mechanism triggering an action caused by user interactin is from Obj-C. Marking @objc exports this method out of Swift, into Obj-C runtime, which underlies running of iOS.
    @objc func handleSwipeToRandomCard () {
        if let card = deck.draw() {
            playingCardView.rank = card.rank.order
            playingCardView.suit = card.suit.rawValue
        }
    }
    
    // ** Should switch on case even though it works without doing so since it's avoids problems later
    @IBAction func handleFlipCard(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:  playingCardView.isFaceUp = !playingCardView.isFaceUp
        default: break
        }
    }


}

