//
//  MapViewController.swift
//  ExchangeAGram
//
//  Created by Isaiah Belle on 1/24/16.
//  Copyright © 2016 Isaiah Belle. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    let appDelegate:AppDelegate =  UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let request = NSFetchRequest(entityName: "FeedItem")
        let context:NSManagedObjectContext = appDelegate.managedObjectContext
        let feedItemArray = try! context.executeFetchRequest(request)
        print("Feed Items \(feedItemArray)")
        //Create Map Region centered on last photo/feeditem
        let lastFeedItem = feedItemArray.last  as! FeedItem
        let lastLoc = CLLocationCoordinate2D(latitude: Double(lastFeedItem.lat!), longitude: Double(lastFeedItem.long!))
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(lastLoc, span)
        mapView.setRegion(region, animated: true)
        // Add Annotations to Map
        for item in feedItemArray as! [FeedItem]{
            let location = CLLocationCoordinate2D(latitude: Double(item.lat!), longitude: Double(item.long!))
            let annotation = MKPointAnnotation()
            annotation.coordinate=location
            annotation.title = item.caption
            mapView.addAnnotation(annotation)
        }
        
//        //Create Map Region
//        let location = CLLocationCoordinate2D(latitude: 48.868639224587, longitude: 2.37119161036255)
//        let span = MKCoordinateSpanMake(0.05, 0.05)
//        let region = MKCoordinateRegionMake(location, span)
//        mapView.setRegion(region, animated: true)
//        // Add Annotation to Map
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = location
//        annotation.title = "Canal Saint-Martin"
//        annotation.subtitle = "Paris"
//        mapView.addAnnotation(annotation)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
