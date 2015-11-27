//
//  FilterCell.swift
//  ExchangeAGram
//
//  Created by Isaiah Belle on 11/26/15.
//  Copyright © 2015 Isaiah Belle. All rights reserved.
//

import UIKit

class FilterCell: UICollectionViewCell {
 
    var imageView:UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        self.contentView.addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
