//
//  FeedItem+CoreDataProperties.swift
//  ExchangeAGram
//
//  Created by Isaiah Belle on 1/24/16.
//  Copyright © 2016 Isaiah Belle. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension FeedItem {

    @NSManaged var caption: String?
    @NSManaged var creationDate: NSDate?
    @NSManaged var image: NSData?
    @NSManaged var thumbNail: NSData?
    @NSManaged var lat: NSNumber?
    @NSManaged var long: NSNumber?
    @NSManaged var uid: String?
    @NSManaged var filtered: NSNumber?

}
