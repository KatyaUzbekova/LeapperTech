//
//  MockPostTableViewCell.swift
//  Leapper
//
//  Created by Екатерина Узбекова on 03.05.2021.
//  Copyright © 2021 Leapper Technologies. All rights reserved.
//

import UIKit

class MockPostTableViewCell: UITableViewCell {
    var constraintFinished: NSLayoutConstraint!
    var constraintNotFinished: NSLayoutConstraint!
    
    
    
    var secondPost: Bool! {
        didSet {
            if SessionManager.shared.isPro() {
                if !secondPost {
                    promotionInterestedButton.isHidden = false
                    constraintNotFinished.isActive = true
                    constraintFinished.isActive = false
                    let titleText = NSLocalizedString("pro_feed_title_first_post_title", comment: "Pro Mock Title")
                    textLabelPromoTitle.text = titleText
                    
                    let simpleText = NSLocalizedString("pro_feed_title_first_post_feed", comment: "Pro Mock First Post")
                    textLabelPromo.text = simpleText
                }
                else {
                    let image1Attachment = NSTextAttachment()
                    image1Attachment.image = UIImage(named: "tabItemProfile")?                .resize(maxWidthHeight: 25)
                    let fullString = NSMutableAttributedString(string: NSLocalizedString("pro_feed_title_second_post_title", comment: "Second Post Title"))
                    if let tempImage =  image1Attachment.image {
                        let imageOffsetY: CGFloat = -10.0
                        image1Attachment.bounds = CGRect(x: 0, y: imageOffsetY, width: tempImage.size.width, height: tempImage.size.height)
                        let image1String = NSAttributedString(attachment: image1Attachment)
                        fullString.append(image1String)
                    }
                    
                    let image2Attachment = NSTextAttachment()
                    image2Attachment.image = UIImage(named: "tabBarLeapp")?
                        .resize(maxWidthHeight: 60)
                    fullString.append(NSMutableAttributedString(string:NSLocalizedString("pro_feed_title_second_post_second", comment: "Second Post Title")))
                    
                    
                    if let tempImage =  image2Attachment.image {
                        let imageOffsetY: CGFloat = -10.0
                        image2Attachment.bounds = CGRect(x: 0, y: imageOffsetY, width: tempImage.size.width, height: tempImage.size.height)
                        let image2String = NSAttributedString(attachment: image2Attachment)
                        fullString.append(image2String)
                    }
                    
                    textLabelPromo.attributedText = fullString
                    
                    promotionInterestedButton.isHidden = true
                    constraintNotFinished.isActive = false
                    
                    constraintFinished.isActive = true
                }
                
            }
            else {
                promotionInterestedButton.isHidden = true
                constraintFinished.isActive = true
                
                let titleText = NSLocalizedString("client_text_mock_feed_title", comment: "Client Mock Title")
                textLabelPromoTitle.text = titleText
                
                let simpleText = NSLocalizedString("client_text_mock_feed", comment: "Client Mock Simple Text")
                textLabelPromo.text = simpleText
            }
        }
    }
    var textLabelPromo = UILabel()
    var textLabelPromoTitle = UILabel()
    
    var whoView = UIView()
    var isNewLabel = UILabel()
    var promotionInterestedButton = UIButton()
    
    var isWhoFullname = UILabel()
    weak var parent: UIViewController!
    var avatar = UIImageView()
    var time = UILabel()
    var backgroundAvatar = UIView()
    var reccomendedOnLabel = UILabel()
    
    var dividerView = UIView()
    
    @objc func buttonAction(sender: UIButton!) {
        let portReg = parent.storyboard?.instantiateViewController(withIdentifier: "navPortfolioReg") as! UINavigationController
        parent.present(portReg, animated: true, completion: nil)
    }
    
    var chatMessage: FeedsModel! {
        didSet {
            if chatMessage.isNew {
                isNewLabel.isHidden = false
            }
            else {
                isNewLabel.isHidden = true
            }
        }
    }
    
    func setTextsFeatures() {
        time.font = UIFont(name: "roboto", size: 11)
        time.textColor = UIColor(displayP3Red: 126/255, green: 133/255, blue: 145/255, alpha: 1)
        isWhoFullname.font = UIFont(name: "roboto", size: 14)
        reccomendedOnLabel.font = UIFont(name: "roboto", size: 13)
        reccomendedOnLabel.textColor = UIColor(displayP3Red: 126/255, green: 133/255, blue: 145/255, alpha: 1)
        textLabelPromo.font = UIFont(name: "roboto", size: 14)
        textLabelPromoTitle.font = UIFont(name: "roboto-bold", size: 20)
        isNewLabel.font = UIFont(name: "roboto", size: 14)
        isNewLabel.textColor = UIColor(displayP3Red: 252/255, green: 33/255, blue: 95/255, alpha: 1)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setTextsFeatures()
        selectionStyle = .none
        reccomendedOnLabel.text = NSLocalizedString("recommended_on_leapper", comment: "Recommended on Leapper")
        avatar.contentMode = .scaleAspectFill
        avatar.clipsToBounds = true
        isWhoFullname.text = NSLocalizedString("leapper_team", comment: "Leapper Team")
        time.text = "30.04.2020"
        avatar.image = UIImage(named: "mockFeedAvatar")
        backgroundAvatar.backgroundColor = UIColor(displayP3Red: 255/255, green: 199/255, blue: 0, alpha: 1)
        dividerView.backgroundColor = UIColor(displayP3Red: 229/255, green: 229/255, blue: 229/255, alpha: 1)
        let titleText = NSLocalizedString("pro_feed_title_first_post_title", comment: "Pro Mock Title")
        textLabelPromoTitle.text = titleText
        
        let simpleText = NSLocalizedString("pro_feed_title_first_post_feed", comment: "Pro Mock First Post")
        textLabelPromo.text = simpleText
        
        let constraintsWhoView = [
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            
            whoView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            whoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            whoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            
            textLabelPromoTitle.topAnchor.constraint(equalTo: whoView.bottomAnchor, constant: 10),
            textLabelPromo.topAnchor.constraint(equalTo: textLabelPromoTitle.bottomAnchor, constant: 3),
            
            textLabelPromoTitle.leadingAnchor.constraint(equalTo: textLabelPromo.leadingAnchor, constant: 0),
            textLabelPromoTitle.trailingAnchor.constraint(equalTo: textLabelPromo.trailingAnchor, constant: 0),
            textLabelPromo.leadingAnchor.constraint(equalTo: whoView.leadingAnchor, constant: 40),
            textLabelPromo.trailingAnchor.constraint(equalTo: whoView.trailingAnchor, constant: -20),
            
            dividerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            dividerView.heightAnchor.constraint(equalToConstant: 3),
            dividerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            dividerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            
        ]
        
        let constraintsImage = [
            isNewLabel.trailingAnchor.constraint(equalTo: whoView.trailingAnchor, constant: -10),
            isNewLabel.topAnchor.constraint(equalTo: whoView.topAnchor, constant: 10),
            
            backgroundAvatar.topAnchor.constraint(equalTo: whoView.topAnchor, constant: 10),
            backgroundAvatar.leadingAnchor.constraint(equalTo: whoView.leadingAnchor, constant: 25),
            backgroundAvatar.widthAnchor.constraint(equalToConstant: 63),
            backgroundAvatar.heightAnchor.constraint(equalToConstant: 63),
            backgroundAvatar.bottomAnchor.constraint(equalTo: whoView.bottomAnchor, constant: 0),
            
            avatar.widthAnchor.constraint(equalToConstant: 60),
            avatar.heightAnchor.constraint(equalToConstant: 60),
            avatar.centerYAnchor.constraint(equalTo: backgroundAvatar.centerYAnchor, constant: 0),
            avatar.centerXAnchor.constraint(equalTo: backgroundAvatar.centerXAnchor, constant: 0),
            
            time.leadingAnchor.constraint(equalTo: backgroundAvatar.trailingAnchor, constant: 9),
            time.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            isWhoFullname.topAnchor.constraint(equalTo: time.bottomAnchor, constant: 8),
            isWhoFullname.leadingAnchor.constraint(equalTo: backgroundAvatar.trailingAnchor, constant: 9),
            reccomendedOnLabel.topAnchor.constraint(equalTo: isWhoFullname.bottomAnchor, constant: 8),
            reccomendedOnLabel.leadingAnchor.constraint(equalTo: backgroundAvatar.trailingAnchor, constant: 9),
            
            promotionInterestedButton.topAnchor.constraint(equalTo: textLabelPromo.bottomAnchor, constant: 10),
            promotionInterestedButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            promotionInterestedButton.heightAnchor.constraint(equalToConstant: 40),
            promotionInterestedButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            
            
        ]
        
        constraintNotFinished = promotionInterestedButton.bottomAnchor.constraint(equalTo: dividerView.topAnchor, constant: -10)
        constraintFinished = textLabelPromo.bottomAnchor.constraint(equalTo: dividerView.topAnchor, constant: -10)
        
        isNewLabel.text = NSLocalizedString("FeedCells.Label.New", comment: "Second Post Title")
        textLabelPromo.numberOfLines = 0
        textLabelPromoTitle.numberOfLines = 0
        promotionInterestedButton.setTitleColor(.black, for: .normal)
        promotionInterestedButton.layer.cornerRadius = 20
        
        
        promotionInterestedButton.text(NSLocalizedString("finish_registration_label_feed", comment: "Second Post Title"))
        
        promotionInterestedButton.backgroundColor = UIColor(displayP3Red: 225/255, green: 217/255, blue: 246/255, alpha: 0.8)
        promotionInterestedButton.titleLabel?.font =  UIFont(name: "roboto", size: 15)
        
        backgroundAvatar.translatesAutoresizingMaskIntoConstraints = false
        backgroundAvatar.layer.cornerRadius = 63/2
        avatar.translatesAutoresizingMaskIntoConstraints = false
        time.translatesAutoresizingMaskIntoConstraints = false
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        reccomendedOnLabel.translatesAutoresizingMaskIntoConstraints = false
        isWhoFullname.translatesAutoresizingMaskIntoConstraints = false
        
        whoView.translatesAutoresizingMaskIntoConstraints = false
        isNewLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabelPromo.translatesAutoresizingMaskIntoConstraints = false
        promotionInterestedButton.translatesAutoresizingMaskIntoConstraints = false
        textLabelPromoTitle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(whoView)
        
        whoView.addSubview(isNewLabel)
        whoView.addSubview(backgroundAvatar)
        whoView.addSubview(avatar)
        whoView.addSubview(time)
        whoView.addSubview(isWhoFullname)
        whoView.addSubview(reccomendedOnLabel)
        contentView.addSubview(textLabelPromoTitle)
        contentView.addSubview(textLabelPromo)
        contentView.addSubview(promotionInterestedButton)
        
        contentView.addSubview(dividerView)
        
        NSLayoutConstraint.activate(constraintsWhoView)
        NSLayoutConstraint.activate(constraintsImage)
        
        promotionInterestedButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
