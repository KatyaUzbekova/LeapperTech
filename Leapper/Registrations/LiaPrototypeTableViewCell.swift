//
//  LiaPrototypeTableViewCell.swift
//  Leapper
//
//  Created by Екатерина Узбекова on 05.05.2021.
//  Copyright © 2021 Leapper Technologies. All rights reserved.
//

import UIKit

class LiaPrototypeTableViewCell: UITableViewCell {
    
    let messageLabel = UILabel()
    var imageAvatar = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        imageAvatar.layer.cornerRadius = 50
        imageAvatar.contentMode = .scaleAspectFill
        imageAvatar.image = UIImage(named: "liaImage.png")!
        imageAvatar.clipsToBounds = true
        
        messageLabel.text = NSLocalizedString("LiaPrototypeTableViewCell.Label", comment: "Lia Prototype Cell")
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        
        let labelConstraints = [
            messageLabel.widthAnchor.constraint(equalToConstant: 200),
            messageLabel.topAnchor.constraint(equalTo: imageAvatar.bottomAnchor, constant: 10),
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
            
        ]
        let constraintsImage = [
            imageAvatar.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            imageAvatar.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            imageAvatar.widthAnchor.constraint(equalToConstant: 100),
            imageAvatar.heightAnchor.constraint(equalToConstant: 100),
            
        ]
        
        imageAvatar.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(messageLabel)
        addSubview(imageAvatar)
        NSLayoutConstraint.activate(constraintsImage)
        NSLayoutConstraint.activate(labelConstraints)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

