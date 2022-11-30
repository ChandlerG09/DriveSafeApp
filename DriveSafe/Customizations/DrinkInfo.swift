//
//  DrinkInfo.swift
//  DriveSafe
//
//  Created by Chandler Glowicki on 4/20/22.
//

import Foundation
import UIKit
class DrinkInfo {
    
    var drinkCount: Double = 0.0
    var date: Date = Date.now
    
    init(drinks: Double, date: Date){
        self.drinkCount = drinks
        self.date = date
    }
    
    func addDrink(amt: Double){
        self.drinkCount += amt
        //Date is already assigned when the object is created
        //self.date = date.now
    }
    
    func getDrink()->Double{
        return self.drinkCount
    }
    
    func getDate()->Date{
        return self.date
    }
}
