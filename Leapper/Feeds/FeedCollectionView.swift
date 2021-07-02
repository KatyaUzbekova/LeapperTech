//
//  FeedCollectionView.swift
//  Leapper
//
//  Created by Kratos on 1/20/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import SDWebImage
import Kingfisher
import ImageSlideshow

class FeedCollectionView: UICollectionViewCell {
    
    weak var parent: UIViewController!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var fullname: UILabel!
    @IBOutlet weak var hinter: UILabel!
    @IBOutlet weak var proAvatar: UIImageView!
    @IBOutlet weak var proName: UILabel!
    @IBOutlet weak var proProfession: UILabel!

    @IBOutlet weak var mainHeader: UIStackView!
    
    @IBOutlet weak var isNewLabel: UILabel!
    @IBOutlet weak var viewForPosted: UIView!
    
    @IBOutlet weak var slider: ImageSlideshow!
    @IBOutlet weak var sliderView: UIView!

    @IBOutlet weak var proUserCreds: UIStackView!
    let uiView:UIImagetView = UIImagetView()
    
    var feed: FeedsModel? {
        didSet {
                setFeed(feed)
           }
    }



    @objc func openRecommender(_ sender: UITapGestureRecognizer? = nil) {
        if ReachabilityTest.isConnectedToNetwork() {

        switch feed?.roleWho {
        case .client:
            let cl = parent.storyboard?.instantiateViewController(withIdentifier: "ClientView") as? ProfileViewClient
            parent.present(cl!, animated: true, completion: nil)
            break
        case .professional:
            let proView = parent.storyboard?.instantiateViewController(withIdentifier: "ProView") as? ProfileViewPro
            proView?._id = feed!._idWho
            proView?.NAME = feed!.proName
            parent.present(proView!, animated: true, completion: nil)
            break
        default:
            break
        }
        }
    }
    
    
    
    func setFeed(_ feed:FeedsModel?){
        
        // Set time in a appropriate format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let timeInDateFormat = dateFormatter.date(from: feed!.time) {
        
            if Calendar.autoupdatingCurrent.isDateInToday(timeInDateFormat) {
            dateFormatter.dateFormat = "HH:mm"
                time.text = dateFormatter.string(from: timeInDateFormat)
        }
        else {
            dateFormatter.dateFormat = "HH:mm dd/MM/yyyy"
            time.text = dateFormatter.string(from: timeInDateFormat)
        }
        }
        
        
        if feed!.isNew {
            isNewLabel.isHidden = false
        }
        else {
            isNewLabel.isHidden = true
        }


        // Set Names
        fullname.text = feed?.fullname
        proName.text = feed?.proName

        // Set Recommendations
        let image1Attachment = NSTextAttachment()

        
        if let recommendedOn = feed?.socialNetwork {
            image1Attachment.image = UIImage(named: recommendedOn.lowercased())?
                .resize(maxWidthHeight: 16)
            
            let recommendedString = NSLocalizedString("FeedCells.Label.RecommendedOn", comment: "Recommended on")
            let finalString = String.localizedStringWithFormat(recommendedString, recommendedOn)
            let fullString = NSMutableAttributedString(string: finalString)
            if let tempImage =  image1Attachment.image {
                let imageOffsetY: CGFloat = -3.0
                image1Attachment.bounds = CGRect(x: 0, y: imageOffsetY, width: tempImage.size.width, height: tempImage.size.height)
                let image1String = NSAttributedString(attachment: image1Attachment)
                fullString.append(image1String)
            }
            hinter.attributedText = fullString
        }
        else {
            hinter.text = NSLocalizedString("recommended", comment: "Recommended")
        }
        
        proProfession.text = feed?.profession

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.openRecommender(_:)))
        viewForPosted.isUserInteractionEnabled = true
        
        viewForPosted.addGestureRecognizer(tap)
        var photosForSlider = [KingfisherSource]()

        if let photos = feed?.photosForSliderView {
            
            if photos.count > 0 {
                sliderView.isHidden = false
                slider.contentScaleMode = .scaleAspectFill
                for photo in photos {
                    photosForSlider.append(KingfisherSource(urlString: photo)!)
                 }
                slider.setImageInputs(photosForSlider)
            }
            else {
                sliderView.isHidden = true
            }
        }
        else {
            sliderView.isHidden = true
        }
    }
  
}


