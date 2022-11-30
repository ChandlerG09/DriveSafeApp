//
//  DrinkList+CoreDataClass.swift
//  DriveSafe
//
//  Created by Chandler Glowicki on 4/28/22.
//
//

import Foundation
import CoreData

@objc(DrinkList)
public class DrinkList: NSManagedObject {
    
    func addDrink(amt: Double){
        self.drinkCount += amt
        //Date is already assigned when the object is created
        //self.date = date.now
    }
    
    func getDrink()->Double{
        return self.drinkCount
    }
    
    func getDate()->Date{
        return self.date!
    }
    
}
