//
//  Card+CoreDataProperties.swift
//  Card Scanner
//
//  Created by Owais on 06/08/24.
//
//

import Foundation
import CoreData


extension Card {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Card> {
        return NSFetchRequest<Card>(entityName: "Card")
    }

    @NSManaged public var cdAddress: String?
    @NSManaged public var cdCompany: String?
    @NSManaged public var cdDesignation: String?
    @NSManaged public var cdEmailAddress: String?
    @NSManaged public var cdMobilenumber: String?
    @NSManaged public var cdName: String?
    @NSManaged public var cdWebsite: String?
    @NSManaged public var cdOthers: String?
    @NSManaged public var data: Data?

}

extension Card : Identifiable {

}
