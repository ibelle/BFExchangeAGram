//
//  FilterViewController.swift
//  ExchangeAGram
//
//  Created by Isaiah Belle on 11/25/15.
//  Copyright © 2015 Isaiah Belle. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit

class FilterViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate,FBSDKSharingDelegate{

    var thisFeedItem: FeedItem!
    var collectionView: UICollectionView!
    let context:CIContext = CIContext(options: nil)
    var filters:[String] = []
    let kIntensity = 0.7
    let placeHolderImage:UIImage = UIImage(named: "Placeholder")!
    let tmpDir:String = NSTemporaryDirectory()
    let appDelegate:AppDelegate =  UIApplication.sharedApplication().delegate as! AppDelegate
    //let myFileManager:NSFileManager = NSFileManager()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //CREATE COLLECTIONVIEW
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 150.0, height: 150.0)
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerClass(FilterCell.self, forCellWithReuseIdentifier: "FltrCell")
        self.view.addSubview(collectionView)
        filters = self.photoFilters()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return  self.filters.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FltrCell", forIndexPath: indexPath) as! FilterCell
        
        cell.imageView.image = self.placeHolderImage
        let filter_queue:dispatch_queue_t  = dispatch_queue_create("filter queue", nil)
        
        //Apply filter in background
        dispatch_async(filter_queue, { () -> Void in
            let filteredImage = self.getCachedImage(indexPath.row)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.imageView.image = filteredImage
            })
        })
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.createUIAlertContoller(indexPath)
    }
    
    //Misc
    //UIAlert Controllers
    func createUIAlertContoller(indexPath: NSIndexPath){
        let alert = UIAlertController(title: "Photo Options", message: "Please choose an option", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "Add Caption!"
            textField.secureTextEntry = false
            })
        
       
        let textField = alert.textFields![0] as UITextField
        
        let photoAction = UIAlertAction(title: "Post Photo to Facebook with Caption", style: UIAlertActionStyle.Destructive, handler: {(UIAlertAction) -> Void in
            let text = (textField.text != nil && !textField.text!.isEmpty) ? textField.text! : "Untitled"

             self.shareToFacebook(indexPath)
            
             self.saveFilterToCoreData(indexPath, caption: text)
        })
        alert.addAction(photoAction)
        
        let saveFilterAction = UIAlertAction(title: "Save Filter without Posting", style: UIAlertActionStyle.Default, handler: {(UIAlertAction) -> Void in
            let text = (textField.text != nil && !textField.text!.isEmpty  ) ? textField.text! : "Untitled"
            self.saveFilterToCoreData(indexPath, caption: text)
        })
        alert.addAction(saveFilterAction)
        
        let cancelAction = UIAlertAction(title: "Select Another Filter", style: UIAlertActionStyle.Cancel, handler: {(UIAlertAction) -> Void in
        //TODO
        })
        alert.addAction(cancelAction)
        
        
        self.presentViewController(alert, animated: true, completion: nil)
        }
    
    //Action Helpers
    func createFileTSFromDate(date: NSDate) -> String
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd:HH:mm:ss:SS"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        let date = dateFormatter.stringFromDate(date)
        return date
    }
    
   
    
    func saveFilterToCoreData (indexPath: NSIndexPath, caption: String) {
        let filter = self.createFilter(self.filters[indexPath.row])!
        let filterImage  = self.filteredImageForImage(self.thisFeedItem.image!, filter: filter)
        let imageData = UIImageJPEGRepresentation(filterImage, 1.0)
        self.thisFeedItem.image = imageData
        let thumbNailData = UIImageJPEGRepresentation(filterImage, 0.1)
        self.thisFeedItem.thumbNail = thumbNailData
        self.thisFeedItem.caption = caption
        self.appDelegate.saveContext()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func quickAlert(header: String, message: String) {
        let alert: UIAlertController = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let closeAction: UIAlertAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in }
        alert.addAction(closeAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //FB Helpers & FB Sharing Delegate
    func shareToFacebook(indexPath: NSIndexPath){
        let filter = self.createFilter(self.filters[indexPath.row])!
        let filterImage  = self.filteredImageForImage(self.thisFeedItem.image!, filter: filter)
        let photo:FBSDKSharePhoto = FBSDKSharePhoto()
        photo.image = filterImage
        photo.userGenerated = true
        let sharePhotoContent: FBSDKSharePhotoContent = FBSDKSharePhotoContent()
        sharePhotoContent.photos = [photo]
        
        let shareDialogue : FBSDKShareDialog = FBSDKShareDialog()
        shareDialogue.fromViewController = self
        shareDialogue.shareContent = sharePhotoContent
       
        
        FBSDKShareDialog.showFromViewController(self, withContent: sharePhotoContent, delegate: self)

    }
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print("Share Results\(results)")
         self.quickAlert( "Success Sharing to Facebook", message: "Photo posted to Facebook." )
        
    }
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
         self.quickAlert( "Error Sharing to Facebook", message: "Problem sharing photo.\r\nError description: \(error.localizedDescription)")
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
         self.quickAlert( "Sharing Cancelled", message: "Sharing Action Cancelled" )
    }
    
    
    //Filters and Caching
    func createFilter(filterName: String) -> CIFilter?{
        switch filterName {
        case "blur"://Blur
            return CIFilter(name: "CIGaussianBlur")!
        case "instant": //Instant
            return CIFilter(name: "CIPhotoEffectInstant")!
        case "noir"://Noir
            return CIFilter(name: "CIPhotoEffectNoir")!
        case "transfer"://Transfer
            return CIFilter(name: "CIPhotoEffectTransfer")!
        case "unsharpen":// UnSharpen
            return CIFilter(name: "CIUnsharpMask")!
        case "monochrome"://MonoChrome
            return CIFilter(name: "CIColorMonochrome")!
        case "color_controls"://Color Controls
            let colorControls = CIFilter(name: "CIColorControls")!
            colorControls.setValue(0.5, forKey: kCIInputSaturationKey)
            return colorControls
        case "sepia"://Sepia
            let sepia = CIFilter(name: "CISepiaTone")!
            sepia.setValue(kIntensity, forKey: kCIInputIntensityKey)
            return sepia
        case "color_clamp"://ColorClamp
            let colorClamp = CIFilter(name: "CIColorClamp")! //TODO: Comeback and Fix
            colorClamp.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")
            colorClamp.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents")
            return colorClamp
        case "composite"://Composite
            let composite = CIFilter(name: "CIHardLightBlendMode")!
            composite.setValue(createFilter("sepia")!.outputImage, forKey: kCIInputImageKey)
            return composite
        case "vignette"://Vignette
            let vignette = CIFilter(name: "CIVignette")!
            vignette.setValue(createFilter("composite")!.outputImage, forKey: kCIInputImageKey)
            vignette.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
            vignette.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)
            return vignette
        default:
            print("Invalid Filter \(filterName)")
        }
        return nil
    }
    
    /*func photoFilters() -> [CIFilter] {
        let blur = CIFilter(name: "CIGaussianBlur")!
        let instant = CIFilter(name: "CIPhotoEffectInstant")!
        let noir = CIFilter(name: "CIPhotoEffectNoir")!
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")!
        let unsharpen = CIFilter(name: "CIUnsharpMask")!
        let monochrome = CIFilter(name: "CIColorMonochrome")!
        
        let colorControls = CIFilter(name: "CIColorControls")!
        colorControls.setValue(0.5, forKey: kCIInputSaturationKey)
        
        let sepia = CIFilter(name: "CISepiaTone")!
        sepia.setValue(kIntensity, forKey: kCIInputIntensityKey)
        
        let colorClamp = CIFilter(name: "CIColorClamp")! //TODO: Comeback and Fix
        colorClamp.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")
        colorClamp.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents")
        
        
        let composite = CIFilter(name: "CIHardLightBlendMode")!
        composite.setValue(sepia.outputImage, forKey: kCIInputImageKey)
        
        let vignette = CIFilter(name: "CIVignette")!
        vignette.setValue(composite.outputImage, forKey: kCIInputImageKey)
        vignette.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
        vignette.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)
        
        return [
            blur,
            instant,
            noir,
            transfer,
            unsharpen,
            monochrome,
            colorControls,
            sepia,
            //colorClamp,
            composite,
            vignette
        ]
    }*/
    func photoFilters() -> [String] {
        
        return [
            "blur",
            "instant",
            "noir",
            "transfer",
            "unsharpen",
            "monochrome",
            "color_controls",
            "sepia",
            //color_clamp",
            "composite",
            "vignette"
        ]
    }
    
    func filteredImageForImage(imageData: NSData, filter: CIFilter) -> UIImage {
        //RELEVANT Article on CGImage vs. UIImage vs. CIIMage 
        //https://medium.com/@ranleung/uiimage-vs-ciimage-vs-cgimage-3db9d8b83d94#.fbhnc2npb
        //1)Apply Filter
        let inputImage:CIImage = CIImage(data: imageData)!
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        let filteredImage:CIImage = filter.outputImage!
 
        //2) Sample CIImage into CG Image with bounds formed by extent )Optimizing for display in collection view)
        let rect = filteredImage.extent
        let cgImage:CGImageRef = self.context.createCGImage(filteredImage, fromRect: rect)
        
        //3) Convert Sampled CGImage into UI Image for display
        let finalImage:UIImage =  UIImage(CGImage: cgImage, scale: 1.0, orientation: UIImageOrientation.Up)
        
        return finalImage
    }
    
    func cacheImage(imageNumber:Int){
        let  fileName = "\(imageNumber)-\(self.createFileTSFromDate(self.thisFeedItem.creationDate!))"
        let uniquePath =  (tmpDir as NSString).stringByAppendingPathComponent(fileName)
        
        if !NSFileManager.defaultManager().fileExistsAtPath(uniquePath){
            let data = self.thisFeedItem.thumbNail
            let filter = self.createFilter(self.filters[imageNumber])!
            let image = filteredImageForImage(data!, filter: filter)
            let imageData = UIImageJPEGRepresentation(image, 1.0)// BAD ACCESS HERE STILL UNRESOLVED!!
            imageData!.writeToFile(uniquePath, atomically: true)
        }
    }
    
    func getCachedImage (imageNumber: Int) -> UIImage {
        let fileName = "\(imageNumber)-\(self.createFileTSFromDate(self.thisFeedItem.creationDate!))"
        let uniquePath = (tmpDir as NSString).stringByAppendingPathComponent(fileName)
        var image:UIImage
        
        if NSFileManager.defaultManager().fileExistsAtPath(uniquePath) {
            image = UIImage(contentsOfFile: uniquePath)!
        } else {
            self.cacheImage(imageNumber)
            image = UIImage(contentsOfFile: uniquePath)!
        }
        return image
    }
    
}
