//
//  FeedUsualWithPhotoTableViewCell.swift
//  Leapper
//
//  Created by Екатерина Узбекова on 20.03.2021.
//  Copyright © 2021 Leapper Technologies. All rights reserved.
//

import UIKit
import ImageSlideshow

class FeedUsualWithPhotoTableViewCell: UITableViewCell {
    
    var whoView = UIView()
    var isNewLabel = UILabel()
    
    var slider =  ImageSlideshow()
    var whomView = UIView()
    var isWhomFullname =  UILabel()
    var isWhomAvatar = UIImageView()
    var isWhomBackgroundAvatar = UIView()
    var profession = UILabel()
    var bottomLabel = UILabel()
    
    var isYouRecommended = false
    var isWhoFullname = UILabel()
    var parent: UIViewController!
    var avatar = UIImageView()
    var time = UILabel()
    var reccomendedOnLabel = UILabel()
    var backgroundAvatar = UIView()
    
    
    var dividerView = UIView()
    
    
    var chatMessage: FeedsModel! {
        didSet {
            if chatMessage.isNew {
                isNewLabel.isHidden = false
            }
            else {
                isNewLabel.isHidden = true
            }
            
            setNewImage(linkToPhoto: chatMessage.isWhoAvatar, imageInput: avatar, isRounded: true)
            setNewImage(linkToPhoto: chatMessage.isWhomAvatar, imageInput: isWhomAvatar, isRounded: true)
            
            setRecommendedOnLabel(recomenndedOnJson: chatMessage.socialNetwork)
            var photosForSlider = [KingfisherSource]()
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.openRecommender(_:)))
            
            whoView.isUserInteractionEnabled = true
            whoView.addGestureRecognizer(tap)
            
            
            if let photos = self.chatMessage.photosForSliderView {
                self.slider.contentScaleMode = .scaleAspectFill
                for photo in photos {
                    photosForSlider.append(KingfisherSource(urlString: photo)!)
                }
                self.slider.setImageInputs(photosForSlider)
            }
            
            DispatchQueue.main.async {
                self.time.text = setTimeFromJson(time: self.chatMessage.time)
                self.isWhoFullname.text = self.chatMessage.fullname
                self.isWhomFullname.text = self.chatMessage.proName
                self.profession.text = self.chatMessage.profession
                
                
                
            }
        }
    }
    
    func setRecommendedOnLabel(recomenndedOnJson: String?) {
        let image1Attachment = NSTextAttachment()
        if let recommendedOn = recomenndedOnJson {
            image1Attachment.image = UIImage(named: recommendedOn.lowercased())?                .resize(maxWidthHeight: 32)
            
            
            let recommendedString = NSLocalizedString("FeedCells.Label.RecommendedOn", comment: "Recommended on")
            let finalString = String.localizedStringWithFormat(recommendedString, recommendedOn)
            let fullString = NSMutableAttributedString(string: finalString)
            if let tempImage =  image1Attachment.image {
                let imageOffsetY: CGFloat = -10.0
                image1Attachment.bounds = CGRect(x: 0, y: imageOffsetY, width: tempImage.size.width, height: tempImage.size.height)
                let image1String = NSAttributedString(attachment: image1Attachment)
                fullString.append(image1String)
            }
            DispatchQueue.main.async {
                self.reccomendedOnLabel.attributedText = fullString
            }
        }
        else {
            DispatchQueue.main.async {
                let image2Attachment = NSTextAttachment()
                image2Attachment.image = UIImage(named: "tabBarLeapp")?
                    .resize(maxWidthHeight: 30)
                var fullString = NSMutableAttributedString(string: "")

                if self.chatMessage.isMeRecommended {
                    
                    fullString = NSMutableAttributedString(string:  NSLocalizedString("FeedCells.Label.RecommendedYouOnLeapper", comment: "Recommended you on Leapper"))
                }
                else {
                    fullString = NSMutableAttributedString(string: NSLocalizedString("FeedCells.Label.RecommendedOnLeapper", comment: "Recommended you on Leapper"))
                }
                if let tempImage =  image2Attachment.image {
                    let imageOffsetY: CGFloat = -5.0
                    image2Attachment.bounds = CGRect(x: 0, y: imageOffsetY, width: tempImage.size.width, height: tempImage.size.height)
                    let image1String = NSAttributedString(attachment: image2Attachment)
                    fullString.append(image1String)
                }
                self.reccomendedOnLabel.attributedText = fullString
            }
        }
    }
    
    func setTextsFeatures() {
        time.font = UIFont(name: "roboto", size: 11)
        time.textColor = UIColor(displayP3Red: 126/255, green: 133/255, blue: 145/255, alpha: 1)
        
        isWhoFullname.font = UIFont(name: "roboto", size: 14)
        reccomendedOnLabel.font = UIFont(name: "roboto", size: 13)
        reccomendedOnLabel.textColor = UIColor(displayP3Red: 126/255, green: 133/255, blue: 145/255, alpha: 1)
        
        
        isNewLabel.font = UIFont(name: "roboto", size: 14)
        isNewLabel.textColor = UIColor(displayP3Red: 252/255, green: 33/255, blue: 95/255, alpha: 1)
        
        isWhomFullname.font = UIFont(name: "roboto", size: 14)
        isWhomFullname.textColor = UIColor(displayP3Red: 27/255, green: 32/255, blue: 154/255, alpha: 1)
        
        profession.font = UIFont(name: "roboto", size: 12)
        profession.textColor = UIColor(displayP3Red: 126/255, green: 133/255, blue: 145/255, alpha: 1)
        
        bottomLabel.textAlignment = .center
        bottomLabel.font = UIFont(name: "roboto", size: 13)
        bottomLabel.textColor = UIColor(displayP3Red: 126/255, green: 133/255, blue: 145/255, alpha: 1)
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setTextsFeatures()
        
        
        bottomLabel.text = NSLocalizedString("FeedUsualTableViewCell.Action.CheckServicesUsers", comment: "Click to see who used services")
        avatar.contentMode = .scaleAspectFill
        avatar.clipsToBounds = true
        backgroundAvatar.backgroundColor = UIColor(displayP3Red: 255/255, green: 199/255, blue: 0, alpha: 1)
        backgroundAvatar.layer.cornerRadius = 63/2
        
        isWhomBackgroundAvatar.backgroundColor = UIColor(displayP3Red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        isWhomBackgroundAvatar.layer.cornerRadius = 47/2
        
        dividerView.backgroundColor = UIColor(displayP3Red: 229/255, green: 229/255, blue: 229/255, alpha: 1)
        let constraintsWhoView = [
            whoView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            whoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            whoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            
            whomView.topAnchor.constraint(equalTo: whoView.bottomAnchor, constant: 0),
            whomView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            whomView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            whomView.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -8),
            
            slider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            slider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            slider.bottomAnchor.constraint(equalTo: bottomLabel.topAnchor, constant: -8),
            slider.heightAnchor.constraint(equalToConstant: 300),
            
            bottomLabel.bottomAnchor.constraint(equalTo: dividerView.topAnchor, constant: -10),
            bottomLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            bottomLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            
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
            backgroundAvatar.bottomAnchor.constraint(equalTo: whoView.bottomAnchor, constant: -11),
            
            avatar.widthAnchor.constraint(equalToConstant: 60),
            avatar.heightAnchor.constraint(equalToConstant: 60),
            avatar.centerYAnchor.constraint(equalTo: backgroundAvatar.centerYAnchor, constant: 0),
            avatar.centerXAnchor.constraint(equalTo: backgroundAvatar.centerXAnchor, constant: 0),
            
            time.leadingAnchor.constraint(equalTo: backgroundAvatar.trailingAnchor, constant: 9),
            time.topAnchor.constraint(equalTo: whoView.topAnchor, constant: 10),
            
            isWhoFullname.topAnchor.constraint(equalTo: time.bottomAnchor, constant: 8),
            isWhoFullname.leadingAnchor.constraint(equalTo: backgroundAvatar.trailingAnchor, constant: 9),
            
            reccomendedOnLabel.topAnchor.constraint(equalTo: isWhoFullname.bottomAnchor, constant: 4),
            reccomendedOnLabel.leadingAnchor.constraint(equalTo: backgroundAvatar.trailingAnchor, constant: 9),
            
            isWhomBackgroundAvatar.leadingAnchor.constraint(equalTo: whomView.leadingAnchor, constant: 40),
            isWhomBackgroundAvatar.topAnchor.constraint(equalTo: whomView.topAnchor, constant: 0),
            isWhomBackgroundAvatar.widthAnchor.constraint(equalToConstant: 47),
            isWhomBackgroundAvatar.heightAnchor.constraint(equalToConstant: 47),
            isWhomBackgroundAvatar.bottomAnchor.constraint(equalTo: whomView.bottomAnchor, constant: -5),
            
            isWhomAvatar.widthAnchor.constraint(equalToConstant: 45),
            isWhomAvatar.heightAnchor.constraint(equalToConstant: 45),
            isWhomAvatar.centerYAnchor.constraint(equalTo: isWhomBackgroundAvatar.centerYAnchor, constant: 0),
            isWhomAvatar.centerXAnchor.constraint(equalTo: isWhomBackgroundAvatar.centerXAnchor, constant: 0),
            
            isWhomFullname.topAnchor.constraint(equalTo: whomView.topAnchor, constant: 0),
            isWhomFullname.leadingAnchor.constraint(equalTo: isWhomBackgroundAvatar.trailingAnchor, constant: 9),
            
            profession.topAnchor.constraint(equalTo: isWhomFullname.bottomAnchor, constant: 5),
            profession.leadingAnchor.constraint(equalTo: isWhomBackgroundAvatar.trailingAnchor, constant: 9)
            
        ]
        slider.circular = true
        isNewLabel.text = NSLocalizedString("FeedCells.Label.New", comment: "NEW")
        
        whoView.translatesAutoresizingMaskIntoConstraints = false
        whomView.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundAvatar.translatesAutoresizingMaskIntoConstraints = false
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        avatar.translatesAutoresizingMaskIntoConstraints = false
        time.translatesAutoresizingMaskIntoConstraints = false
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        reccomendedOnLabel.translatesAutoresizingMaskIntoConstraints = false
        isWhoFullname.translatesAutoresizingMaskIntoConstraints = false
        isWhomFullname.translatesAutoresizingMaskIntoConstraints = false
        isNewLabel.translatesAutoresizingMaskIntoConstraints = false
        
        isWhomBackgroundAvatar.translatesAutoresizingMaskIntoConstraints = false
        isWhomAvatar.translatesAutoresizingMaskIntoConstraints = false
        profession.translatesAutoresizingMaskIntoConstraints = false
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        contentView.addSubview(whoView)
        contentView.addSubview(whomView)
        
        whoView.addSubview(isNewLabel)
        
        
        whoView.addSubview(backgroundAvatar)
        whoView.addSubview(avatar)
        whoView.addSubview(time)
        whoView.addSubview(isWhoFullname)
        contentView.addSubview(dividerView)
        whoView.addSubview(reccomendedOnLabel)
        
        whomView.addSubview(isWhomBackgroundAvatar)
        whomView.addSubview(isWhomAvatar)
        whomView.addSubview(isWhomFullname)
        whomView.addSubview(profession)
        contentView.addSubview(slider)
        contentView.addSubview(bottomLabel)
        
        NSLayoutConstraint.activate(constraintsWhoView)
        NSLayoutConstraint.activate(constraintsImage)
    }
    @objc func openRecommender(_ sender: UITapGestureRecognizer? = nil) {
        if ReachabilityTest.isConnectedToNetwork() {
            switch chatMessage?.roleWho {
            case .client:
                let cl = parent.storyboard?.instantiateViewController(withIdentifier: "ClientView") as? ProfileViewClient
                cl?._id = chatMessage!._idWho
                parent.present(cl!, animated: true, completion: nil)
                break
            case .professional:
                let proView = parent.storyboard?.instantiateViewController(withIdentifier: "ProView") as? ProfileViewPro
                proView?._id = chatMessage!._idWho
                proView?.NAME = chatMessage!.fullname
                parent.present(proView!, animated: true, completion: nil)
                break
            default:
                break
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
