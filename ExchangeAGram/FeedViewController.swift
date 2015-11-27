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

class FeedViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate  {

    let appDelegate:AppDelegate =  UIApplication.sharedApplication().delegate as! AppDelegate
    var feedArray:[AnyObject] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let request  = NSFetchRequest(entityName: "FeedItem")
        let context:NSManagedObjectContext = self.appDelegate.managedObjectContext
        
        feedArray = try! context.executeFetchRequest(request) //Wrap is full do-catch in prod!

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
        print(image)
        
        let imageData = UIImageJPEGRepresentation(image, 1.0)//Convert image to manageable data
        let managedObjectContext = self.appDelegate.managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("FeedItem", inManagedObjectContext: managedObjectContext)
        let feedItem = FeedItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
        
        feedItem.image = imageData
        feedItem.caption = "test caption"
        
        self.appDelegate.saveContext()
        self.feedArray.append(feedItem)
        self.dismissViewControllerAnimated(true, completion: nil)
        self.collectionView.reloadData()
    }
    
    
    //UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    

    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:FeedCell =  collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as! FeedCell
        let thisItem = feedArray[indexPath.row] as! FeedItem
        cell.imageView.image = UIImage(data: thisItem.image!)
        cell.imageCaptionLabel.text = thisItem.caption
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let thisItem = feedArray[indexPath.row] as! FeedItem
        
        let filterVC = FilterViewController()//TODO: I feel some type of way about this
        
        filterVC.thisFeedItem = thisItem
        filterVC.title = "FIlterVC"
        self.navigationController?.pushViewController(filterVC, animated: false)
    }

}
