//
//  DrinkList+CoreDataProperties.swift
//  DriveSafe
//
//  Created by Chandler Glowicki on 4/28/22.
//
//

import Foundation
import CoreData


extension DrinkList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DrinkList> {
        return NSFetchRequest<DrinkList>(entityName: "DrinkList")
    }

    @NSManaged public var drinkCount: Double
    @NSManaged public var date: Date?

}

extension DrinkList : Identifiable {

}
