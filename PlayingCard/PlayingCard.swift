//
//  PlayingCard.swift
//  PlayingCard
//
//  Created by Amaan on 2018-01-23.
//  Copyright © 2018 amaancan. All rights reserved.
//

import Foundation

struct PlayingCard: CustomStringConvertible {
    var description: String {
        return "\(rank) \(suit)"
    }
    
    var suit: Suit
    var rank: Rank
    
    enum Suit: String, CustomStringConvertible {
        case spade = "♠️"
        case heart = "♥️"
        case clubs = "♣️"
        case diamonds = "♦️"
        
        static var all = [Suit.spade, .heart, .clubs, .diamonds] // Swift infers other elements are type Suit based on first element
        
        var description: String {
            return rawValue
        }
    }
    
    enum Rank: CustomStringConvertible {
        case ace
        case two
        case three
        case four
        case five
        case six
        case seven
        case eight
        case nine
        case ten
        case jack
        case queen
        case king
        
        var order: Int {
            switch self {
            case .ace: return 1
            case .two: return 2
            case .three: return 3
            case .four: return 4
            case.five: return 5
            case.six: return 6
            case.seven: return 7
            case.eight: return 8
            case.nine: return 9
            case.ten: return 10
            case.jack: return 11
            case.queen: return 12
            case.king: return 13
            }
        }
        
        static var all =  [Rank.ace, .two, .three, .four, .five, .six, .seven, .eight, .nine, .ten, .jack, .queen, .king]
        
        var description: String {
            switch self {
            case .ace: return "A"
            case .two: return "2"
            case .three: return "3"
            case .four: return "4"
            case.five: return "5"
            case.six: return "6"
            case.seven: return "7"
            case.eight: return "8"
            case.nine: return "9"
            case.ten: return "10"
            case.jack: return "J"
            case.queen: return "Q"
            case.king: return "K"
            }
        }
    }
}
