//
//  FilterViewController.swift
//  ExchangeAGram
//
//  Created by Isaiah Belle on 11/25/15.
//  Copyright © 2015 Isaiah Belle. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate {

    var thisFeedItem: FeedItem!
    var collectionView: UICollectionView!
    var context:CIContext = CIContext(options: nil)
    var filters:[CIFilter] = []
    let kIntensity = 0.7
    let placeHolderImage:UIImage = UIImage(named: "Placeholder")!
    let tmp:String = NSTemporaryDirectory()
    
    
    
    
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
            
            //self.filteredImageForImage(self.thisFeedItem.thumbNail!, filter: self.filters[indexPath.row])
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.imageView.image = filteredImage
            })
        })
        
        return cell
    }
 
    //Misc
    func photoFilters() -> [CIFilter] {
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
        
        return [blur,instant,noir,transfer,unsharpen,monochrome,colorControls,sepia,composite,vignette]
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
        let cgImage:CGImageRef = context.createCGImage(filteredImage, fromRect: rect)
        
        //3) Convert Sampled CGImage into UI Image for display
        let finalImage:UIImage = UIImage(CGImage: cgImage)
        
        //let finalImage = UIImage(CIImage: filteredImage)
        return finalImage
    }
    
    func cacheImage(imageNumber:Int){
        let  fileName = "\(imageNumber)"
        let uniquePath =  (tmp as NSString).stringByAppendingPathComponent(fileName)
        
        if !NSFileManager.defaultManager().fileExistsAtPath(fileName){
            let data = self.thisFeedItem.thumbNail
            let filter = self.filters[imageNumber]
            let image = filteredImageForImage(data!, filter: filter)
            UIImageJPEGRepresentation(image, 1.0)!.writeToFile(uniquePath, atomically: true)
        }
    }
    
    func getCachedImage (imageNumber: Int) -> UIImage {
        let fileName = "\(imageNumber)"
        let uniquePath = (tmp as NSString).stringByAppendingPathComponent(fileName)
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
