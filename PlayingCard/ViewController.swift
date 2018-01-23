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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let card = deck.draw()
        print("\(card!)")
    }


}

