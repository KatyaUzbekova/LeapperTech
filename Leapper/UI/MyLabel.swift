//
//  MyLabel.swift
//  Leapper
//
//  Created by Kratos on 8/20/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import Foundation

import UIKit
@IBDesignable class MyLabel:UILabel{
    @IBInspectable var topInset : CGFloat = 7.0
    
    @IBInspectable var bottomInset : CGFloat = 7.0
    
    @IBInspectable var leftInset : CGFloat = 7.0
    
    @IBInspectable var rightInset : CGFloat = 7.0
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super .drawText(in: rect.inset(by: insets))
    }
    override var intrinsicContentSize: CGSize{
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset, height: size.height + topInset + bottomInset)
    }
    
}
