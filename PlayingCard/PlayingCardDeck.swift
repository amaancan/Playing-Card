//
//  PlayingCardDeck.swift
//  PlayingCard
//
//  Created by Amaan on 2018-01-23.
//  Copyright © 2018 amaancan. All rights reserved.
//

import Foundation

struct PlayingCardDeck {
    private(set) var cards = [PlayingCard]()
    
    mutating func draw() -> PlayingCard? {
        if cards.count > 0 {
            return cards.remove(at: cards.count.arc4random)
        }
        return nil
    }
    
    init() {
        for suit in PlayingCard.Suit.all {
            for rank in PlayingCard.Rank.all {
                cards.append(PlayingCard(suit: suit, rank: rank))
            }
        }
    }
}

extension Int {
    // Returns a random number between 0 and the Int (exsluding the Int) by tapping into this computed var's getter.
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self))) //self is for instance not type here
        } else if self < 0 { // Won't crash if called by a negative Int now.
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}

