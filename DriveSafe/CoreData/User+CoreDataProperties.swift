//
//  User+CoreDataProperties.swift
//  DriveSafe
//
//  Created by Chandler Glowicki on 4/28/22.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var name: String?
    @NSManaged public var weight: Double
    @NSManaged public var gender: String?
    @NSManaged public var bacLevel: Double
    @NSManaged public var age: Int64

}

extension User : Identifiable {

}
