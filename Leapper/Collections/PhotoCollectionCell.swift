//
//  PhotoCollectionCell.swift
//  Leapper
//
//  Created by Kratos on 3/1/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
class PhotoCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var pp: UIImageView!
    
    
    var link:String?{
        didSet{
            self.pp.sd_setImage(with: URL(string: link!), completed: nil)
        }
    }
    
}
