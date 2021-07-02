//
//  PortfolioCollections.swift
//  Leapper
//
//  Created by Kratos on 2/29/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import ImageViewer


class PortfolioCollections: UICollectionViewCell{
    weak var parent:UIViewController!
    
    @IBOutlet weak var photos: UIImageView!

    
    var link: String?{
        didSet{
            setNewImage(linkToPhoto: link, imageInput: photos, isRounded: false)
        }
    }
}
