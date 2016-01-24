//
//  FeedViewController.swift
//  ExchangeAGram
//
//  Created by Isaiah Belle on 11/22/15.
//  Copyright © 2015 Isaiah Belle. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData
import MapKit

class FeedViewController: UIViewController,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var galleryCollectionView: UICollectionView!

    let appDelegate:AppDelegate =  UIApplication.sharedApplication().delegate as! AppDelegate
    var feedArray:[AnyObject] = []
    var locationManager:CLLocationManager!
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 100.0
        locationManager.startUpdatingLocation()
        
        
    }

    override func viewDidAppear(animated: Bool) {
        let request = NSFetchRequest(entityName: "FeedItem")
        let context:NSManagedObjectContext = appDelegate.managedObjectContext
        feedArray = try! context.executeFetchRequest(request)
        self.collectionView.reloadData()
        //Wrap is full do-catch in prod!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func profileButtonTapped(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("profileSegue", sender: nil)
    }
    @IBAction func snapBarButtonItemTapped(sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            let cameraController = self.getImagePickerController(UIImagePickerControllerSourceType.Camera, allowEditing: false)
        
            self.presentViewController(cameraController, animated: true, completion: nil)
        }else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
            let photoLibraryController = self.getImagePickerController(UIImagePickerControllerSourceType.PhotoLibrary, allowEditing: false)
            
            self.presentViewController(photoLibraryController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Alert", message: "Your device does not support the camera or photo Library", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

    //Misc
    func getImagePickerController(sourceType: UIImagePickerControllerSourceType, allowEditing: Bool) -> UIImagePickerController {
    
        let pickerController: UIImagePickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = sourceType
        let mediaTypes = [kUTTypeImage]
        pickerController.mediaTypes = mediaTypes as! [String]
        pickerController.allowsEditing = allowEditing
        return pickerController
    }
    
    //UIIMagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        print("IMAGE SELECTED\(image)")
        
        let imageData = UIImageJPEGRepresentation(image, 1.0)//Convert image to manageable data
        let thumbNailData = UIImageJPEGRepresentation(image, 0.1)//
        
        
        let managedObjectContext = self.appDelegate.managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("FeedItem", inManagedObjectContext: managedObjectContext)
        let feedItem = FeedItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
        
        feedItem.image = imageData
        feedItem.thumbNail = thumbNailData
        feedItem.creationDate = NSDate()
        feedItem.caption = "test caption"
        
        self.appDelegate.saveContext()
        
        self.feedArray.append(feedItem)
        self.dismissViewControllerAnimated(true, completion: nil)
        print("Size of FeedArray After Selection \(self.feedArray.count)")
        self.collectionView.reloadData()
    }
    
    
    //UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    

    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Size of FeedArray in CollectionViewCallback \(self.feedArray.count)")
        return self.feedArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:FeedCell =  collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as! FeedCell
        let thisItem = feedArray[indexPath.row] as! FeedItem
        //print("Location \(indexPath.row), Item\(thisItem)")
        cell.imageView.image = UIImage(data: thisItem.image!)
        cell.imageCaptionLabel.text = thisItem.caption
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let thisItem = feedArray[indexPath.row] as! FeedItem
        
        //print("Selected Location \(indexPath.row), Item\(thisItem)")
        let filterVC = FilterViewController()//TODO: I feel some type of way about this
        
        filterVC.thisFeedItem = thisItem
        filterVC.title = "FilterVC"
        self.navigationController?.pushViewController(filterVC, animated: false)
    }

    //CllocationManager
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Locations \(locations)")
    }
}
