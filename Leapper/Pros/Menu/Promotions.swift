//
//  Promotions.swift
//  Leapper
//
//  Created by Kratos on 2/13/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import MessageUI
import SwiftKeychainWrapper
import SwiftyJSON
import Alamofire

class Promotions: UIViewController {
    @IBOutlet weak var proms: UITableView!

    @IBAction func addPromotions(_ sender: Any) {
        let pr = self.storyboard?.instantiateViewController(withIdentifier: "PromEditor") as? PromotionAddOrEdit
        pr?.isEdit = false
        pr?.parentView = self
        self.present(pr!, animated: true, completion: nil)
    }
    var phone = String()
    var fullname = String()
    var profession = String()
    var location = String()
    var leappCount = String()
    
    @IBOutlet weak var noPromotionsLabel: UILabel!
    var promItems = [PromotionModel]()
    
    @objc func loadList(notification: NSNotification) {        
        getAllUserPromotions()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadList(notification:)), name: NSNotification.Name(rawValue: "load"), object: nil)

        proms.separatorStyle = .none
        proms.delegate = self
        proms.dataSource  = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAllUserPromotions()
    }

    func getAllUserPromotions() {
        
        /*
         method to send GET request to server and receive JSON with user's promotions
        */
        
        promItems = []
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!

        let url = URL(string: "https://api.leapper.com/api/mobi/getPromo")! //change the url
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                return
            }
            if let httpResponse = response as? HTTPURLResponse{
                if httpResponse.statusCode == 200{
                        
                    if let safeData = data {
                        if let jsonPromotionsData = JSON(safeData)["promo"]["promotions"].array {
                            for item in jsonPromotionsData {
                                                                
                                self.promItems.append(PromotionModel(_id: item["_id"].string!, name: item["title"].string, amount: "\(item["discount"].string!)", description: item["description"].string, imageUrl: item["imageUrl"].string, isShared: item["isShared"].bool!, senderId: ""))
                                }

                            if self.promItems.count == 0 {
                                DispatchQueue.main.async {
                                    self.noPromotionsLabel.isHidden = false
                                    let pr = self.storyboard?.instantiateViewController(withIdentifier: "PromEditor") as? PromotionAddOrEdit
                                    pr?.isEdit = false
                                    self.present(pr!, animated: true, completion: nil)
                                }
                            }
                            else {
                                DispatchQueue.main.async {
                                    self.noPromotionsLabel.isHidden = true
                                    self.proms.reloadData()
                                }
                            }
                        }
                    }
                }
                else if httpResponse.statusCode == 403{
                    getNewAccessByRefreshToken(currentViewController: self)
                    self.getAllUserPromotions()
                }
                else {
                    DispatchQueue.main.async {
                        Toast(NSLocalizedString("Toast.Message.Error", comment: "")).show(self)
                    }
                }
            }
            })
        task.resume()
    }
}

extension Promotions: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        switch (result) {
            case .cancelled:
                print("Message was cancelled")
                dismiss(animated: true, completion: nil)
            case .failed:
                print("Message failed")
                dismiss(animated: true, completion: nil)
            case .sent:
                print("Message was sent")
                dismiss(animated: true, completion: nil)
            default:
            break
        }
    }
    func deletePromotionApi(_id: String, index: Int){
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ]
            AF.request("https://api.leapper.com/api/mobi/deletePromo/\(_id)", method: .delete, parameters: nil, headers: headers).responseJSON { AFdata in
                do {
                    print(AFdata.result)
                    DispatchQueue.main.async {
                        self.promItems.remove(at: index)
                        
                        if self.promItems.count == 0 {
                            self.noPromotionsLabel.isHidden = false
                        }
                        
                        self.proms.reloadData()
                    }
                } catch {
                    print("Error: Trying to convert JSON data to string")
                    return
                }
        }
        
    }
}

extension Promotions: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.promItems.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let itemCell = tableView.dequeueReusableCell(withIdentifier: "Proms", for: indexPath) as? PromotionsTableSwipeCell {
            itemCell.parent  = self
            itemCell.prom = promItems[indexPath.row]
            
            return itemCell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
       
       
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
         let edit = editAction(at: indexPath)
         return UISwipeActionsConfiguration(actions: [edit])
    }
    func editAction(at indexPath:IndexPath) -> UIContextualAction{
        let action = UIContextualAction(style: .normal, title: NSLocalizedString("Promotions.Action.Edit", comment: "Edit")) {(action, view, completion) in
            let pr = self.storyboard?.instantiateViewController(withIdentifier: "PromEditor") as? PromotionAddOrEdit
            pr?.isEdit = true
            pr?.parentView = self
            pr!.idPromo = self.promItems[indexPath.row]._id
            pr!.descValue = self.promItems[indexPath.row].description ?? ""
            pr!.discountValue = self.promItems[indexPath.row].amount.replacingOccurrences(of: " ", with: "")
            pr!.nameOfActionValue = self.promItems[indexPath.row].name ?? ""
            pr!.imageUrl = self.promItems[indexPath.row].imageUrl ?? ""

            self.present(pr!, animated: true, completion: nil)
            completion(true)
        }
        action.image = UIImage(named: "edit")
        action.backgroundColor = .blue
        return action
    }
    
    func deleteAction(at indexPath:IndexPath) -> UIContextualAction{
        let action = UIContextualAction(style: .normal, title: NSLocalizedString("Promotions.Action.PromotionDelete", comment: "Delete promotion")){(action, view, completion) in
            self.deleteProm(at: indexPath)
            completion(true)
        }
        action.image = UIImage(named: "delete")
        action.backgroundColor = .red
        return action
    }
    
    
    
    func deleteProm(at indexPath:IndexPath){
        let alert = UIAlertController(title: NSLocalizedString("Promotions.Action.PromotionDelete", comment: "Delete promotion"), message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Promotions.Action.NoReturn", comment: "No,return"), style: .default))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Promotions.Action.YesReturn", comment: "Yes, delete"), style: .default, handler: { action in
              switch action.style{
              case .default:
                let pm = self.promItems[indexPath.row]
                self.deletePromotionApi(_id: pm._id, index: indexPath.row)

              case .cancel:
                    print("cancel")

              case .destructive:
                   print("dest")
              @unknown default:
                print("error")
              }}))
        self.present(alert, animated: true, completion: nil)
    }
}
