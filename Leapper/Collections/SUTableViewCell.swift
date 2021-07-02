//
//  SUTableViewCell.swift
//  Leapper
//
//  Created by Kratos on 3/1/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit

class SUTableViewCell: UITableViewCell {
    
   
    @IBOutlet weak var profName: UILabel!
    @IBOutlet weak var userCollections: UICollectionView!
    
    var links = [String]()
    var phoness = [String]()
    weak var parent:UIViewController!

}
extension SUTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return links.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? PhotoCollectionCell{
            cell.link = links[indexPath.row]
            return cell
        }
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var pvp:ProfileViewPro!
        pvp = parent.storyboard?.instantiateViewController(withIdentifier: "ProView") as? ProfileViewPro
        pvp.phoneNumber = phoness[indexPath.row]
        parent.present(pvp, animated: true, completion: nil)
    }
    
}
