//
//  SubscriptionViewController.swift
//  Leapper
//
//  Created by Екатерина Узбекова on 04.02.2021.
//  Copyright © 2021 Leapper Technologies. All rights reserved.
//

import UIKit
import StoreKit

class SubscriptionViewController: UIViewController {
    let selectedColor = UIColor(displayP3Red: 252/255, green: 33/255, blue: 95/255, alpha: 1).cgColor
    let unselectedColor = UIColor(displayP3Red: 126/255, green: 133/255, blue: 145/255, alpha: 1).cgColor

    @IBOutlet weak var viewOptionThird: ViewWithBorders!
    @IBOutlet weak var viewOptionSecond: ViewWithBorders!
    @IBOutlet weak var viewOptionFirst: ViewWithBorders!
    @IBOutlet weak var pageChanger: UIPageControl!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var motivationLabel: UILabel!
    @IBOutlet weak var tarif: UILabel!
    @IBOutlet weak var oneMonthSubscription: UILabel!
    @IBOutlet weak var twelveMonthSubscription: UILabel!

    @IBOutlet weak var paymentButton: UIButton!
    var selectedView = 1
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
       if gesture.direction == .right {
        if pageChanger.currentPage == 1 {
            tarif.text = "BASIC"
            pageChanger.currentPage = 0
            oneMonthSubscription.text = "$14.99/mth"
            twelveMonthSubscription.text = "$12.99/mth"
            motivationLabel.text = "Search among friends and friends of friends"
            image.image = UIImage(named:  "BasicSubscription")
        }
        
        else {
            pageChanger.currentPage = 1

            tarif.text = "PREMIUM"
            oneMonthSubscription.text = "$19.99/mth"
            twelveMonthSubscription.text = "$15.99/mth"
            motivationLabel.text = "Search by all users"
            image.image = UIImage(named: "PremiumSubscription")
        }
       }
       else if gesture.direction == .left {
            if pageChanger.currentPage == 1 {
                tarif.text = "BASIC"
                pageChanger.currentPage = 0
                oneMonthSubscription.text = "$14.99/mth"
                twelveMonthSubscription.text = "$12.99/mth"
                motivationLabel.text = "Search among friends and friends of friends"
                image.image = UIImage(named:  "BasicSubscription")
            }
            
            else {
                pageChanger.currentPage = 1

                tarif.text = "PREMIUM"
                oneMonthSubscription.text = "$19.99/mth"
                twelveMonthSubscription.text = "$15.99/mth"
                motivationLabel.text = "Search by all users"
                image.image = UIImage(named: "PremiumSubscription")
            }
            
            
        }
    }
    
    @objc func viewRecognizer(_ sender: UITapGestureRecognizer? = nil) {
        selectedView = 0
        DispatchQueue.main.async {
            self.paymentButton.isEnabled = true
            self.viewOptionFirst.layer.borderColor = self.selectedColor
            self.viewOptionSecond.layer.borderColor = self.unselectedColor
            self.viewOptionThird.layer.borderColor = self.unselectedColor
        }
    }
    
    @objc func viewSecondRecognizer(_ sender: UITapGestureRecognizer? = nil) {
        selectedView = 1
        DispatchQueue.main.async {
            self.paymentButton.isEnabled = false
            self.viewOptionFirst.layer.borderColor = self.unselectedColor
            self.viewOptionSecond.layer.borderColor = self.selectedColor
            self.viewOptionThird.layer.borderColor = self.unselectedColor
        }
    }
    
    @objc func viewThirdRecognizer(_ sender: UITapGestureRecognizer? = nil) {
        selectedView = 2
        DispatchQueue.main.async {
            self.paymentButton.isEnabled = true
            self.viewOptionFirst.layer.borderColor = self.unselectedColor
            self.viewOptionSecond.layer.borderColor = self.unselectedColor
            self.viewOptionThird.layer.borderColor = self.selectedColor
        }
    }
    
    private let productPurchaseMonthly = "com.leapper.leapperios.LeapperPremium"
    private let productPurchaseAnnually = "com.leapper.leapperios.LeapperPremiumAnnually"
    private let productBasicPurchaseMonthly = "com.leapper.leapperios.BasicPremiumMonthly"
    private let productBasicPurchaseAnnually = "com.leapper.leapperios.BasicPremiumAnnually"

    func purchase(with productId: String) {
    }
    func buyPremiumLeapper() {
        if pageChanger.currentPage == 0 {
            // BASIC
            switch selectedView {
            case 0:
                
                purchase(with: productBasicPurchaseMonthly)
                break
            case 2:
                purchase(with: productBasicPurchaseAnnually)
                break
            default:
                break
            }
        }
        else {
            // PREMIUM
            switch selectedView {
            case 0:
                purchase(with: productPurchaseMonthly)
                break
            case 2:
                purchase(with: productPurchaseAnnually)
                break
            default:
                break
            }
        }
    }
    func updateInterface(products: [SKProduct]) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let alertController = UIAlertController(title: "Unavailable", message: "You already have premium account", preferredStyle: UIAlertController.Style.alert)
        let purchaseAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default){_ in
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
        alertController.addAction(purchaseAction)
        present(alertController, animated: true, completion: nil)
        
        let viewOneGesture = UITapGestureRecognizer(target: self, action: #selector(viewRecognizer(_:)))
        
        viewOptionFirst.isUserInteractionEnabled = true
        viewOptionFirst.addGestureRecognizer(viewOneGesture)
        
        let viewSecondGesture = UITapGestureRecognizer(target: self, action: #selector(viewSecondRecognizer(_:)))

        viewOptionSecond.isUserInteractionEnabled = true
        viewOptionSecond.addGestureRecognizer(viewSecondGesture)
        
        
        let viewThirdGesture = UITapGestureRecognizer(target: self, action: #selector(viewThirdRecognizer(_:)))

        viewOptionThird.isUserInteractionEnabled = true
        viewOptionThird.addGestureRecognizer(viewThirdGesture)


        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    @IBAction func goToPayments(_ sender: Any) {
        buyPremiumLeapper()
    }
    @IBAction func restorePurchases(_ sender: Any) {
        
    }

    func restorePurchasesFunction() {
        
    }
    func pageChangerFunction(currentPage: Int) {
        if currentPage == 0 {
            tarif.text = "BASIC"
            oneMonthSubscription.text = "$11/mth"
            twelveMonthSubscription.text = "$7.99/mth"
            motivationLabel.text = "Search among friends and friends of friends"
            image.image = UIImage(named:  "BasicSubscription")
        }
        
        else {
            tarif.text = "PREMIUM"
            oneMonthSubscription.text = "$37/mth"
            twelveMonthSubscription.text = "$29.99/mth"
            motivationLabel.text = "Search by all users"
            image.image = UIImage(named: "PremiumSubscription")
        }
    }
    @IBAction func pageChanged(_ sender: UIPageControl) {
        pageChangerFunction(currentPage: sender.currentPage)
    }
}
