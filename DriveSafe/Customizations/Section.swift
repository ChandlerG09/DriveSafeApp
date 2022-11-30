//
//  Section.swift
//  DriveSafe
//
//  Created by Chandler Glowicki on 4/22/22.
//

import Foundation
import UIKit

class Section{
    let date: String
    var drinks: [DrinkList]
    
    init(date: String, drinks: [DrinkList]) {
        self.date = date
        self.drinks = drinks
    }
}
