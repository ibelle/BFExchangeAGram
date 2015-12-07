//
//  FeedItem+CoreDataProperties.swift
//  ExchangeAGram
//
//  Created by Isaiah Belle on 12/2/15.
//  Copyright © 2015 Isaiah Belle. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension FeedItem {

    @NSManaged var caption: String?
    @NSManaged var image: NSData?
    @NSManaged var thumbNail: NSData?
    @NSManaged var creationDate: NSDate?

}
