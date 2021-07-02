//
//  Professional.swift
//  Leapper
//
//  Created by Kratos on 1/19/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import SwiftyJSON

class SearchViewFullLeapper: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    var allUsers = [AllUsers]()
    @IBOutlet weak var viewDividerForColor: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var notFoundLabel: UILabel!
    @IBOutlet weak var searchTableView: UITableView!
    let slideInTrans = SlideInTransition()
    static var staticSelf:SearchViewFullLeapper?
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var viewForPreaload: UIView!
    
    var searchType = "global"
    var isPro = true
    
    
    
    var showKeyboard = false
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        if showKeyboard == false{
            showKeyboard = true
            constraintBottomBar.constant = keyboardSize.height + 5
        }
        
    }
    
    @IBOutlet weak var constraintBottomBar: NSLayoutConstraint!
    @objc func keyboardWillHide(notification: NSNotification) {
        guard ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil else {
            return
        }
        if showKeyboard {
            showKeyboard = false
            constraintBottomBar.constant = 10
            
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.becomeFirstResponder()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewFullLeapper.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewFullLeapper .keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if !isPro {
            self.searchBar.barTintColor = UIColor(displayP3Red: 106/256, green: 27/256, blue: 154/256, alpha: 1)
            self.viewDividerForColor.backgroundColor = UIColor(displayP3Red: 106/256, green: 27/256, blue: 154/256, alpha: 1)
            self.closeButton.backgroundColor = UIColor(displayP3Red: 106/256, green: 27/256, blue: 154/256, alpha: 1)
            self.view.backgroundColor = UIColor(displayP3Red: 106/256, green: 27/256, blue: 154/256, alpha: 1)
        }
        
        searchBar.becomeFirstResponder()
        searchBar.delegate = self
        SearchViewFullLeapper.staticSelf = self
        searchTableView.isHidden = true
        
        searchTableView.delegate  = self
        searchTableView.dataSource = self
        (UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])).clearButtonMode = .never
        searchBar.tintColor = .white
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.leftView?.tintColor = .white
        }
        
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = .white
        searchBar.isTranslucent = false
        
    }
    
    @IBAction func returnBack(_ sender: UIButton) {
        allUsers = []
        DispatchQueue.main.async {
            self.searchTableView.reloadData()
        }
        self.dismiss(animated: false) {
            let textFieldInsideSearchBar = self.searchBar.value(forKey: "searchField") as? UITextField
            textFieldInsideSearchBar?.text = ""
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func localSearchApiCall (_ searchText: String) {
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
        print(accessToken)
        DispatchQueue.main.async {
            self.searchBar.text = searchText
        }
        if !searchText.isEmpty{
            
            var components = URLComponents(string: "https://api.leapper.com/api/mobi/localSearch")!
            components.queryItems = [
                URLQueryItem(name: "text",
                             value: searchText),
            ]
            components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
            let url = components.url!
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
                
                let decoder = JSONDecoder()
                if let httpResponse = response as? HTTPURLResponse{
                    if httpResponse.statusCode == 200{
                        if let safeData = data {
                            do {
                                let decodedData = try decoder.decode(ResultsGlobalSearch.self, from: safeData)
                                self.allUsers.removeAll()
                                
                                DispatchQueue.main.async {
                                    self.searchTableView.reloadData()
                                }
                                if decodedData.search.count == 0 {
                                    DispatchQueue.main.async {
                                        
                                        self.notFoundLabel.isHidden = false
                                        self.notFoundLabel.text = NSLocalizedString("SearchViewFullLeapper.Action.NoResults", comment: "")
                                        self.searchTableView.backgroundColor = .gray
                                        self.searchTableView.isHidden = true
                                        // then remove the spinner view controller

                                    }
                                }
                                else {
                                    for user in decodedData.search {
                                        self.allUsers.append(AllUsers(isPro: true, phone: "", fullName: user.fullName ?? user.name! + " " + user.lastName!, profession: user.portfolio?.jobName?.lowercased().capitalizingFirstLetter(), linkToAvatar: user.avatar, mutualsCount: "0" +  NSLocalizedString("Leapper.MutualsCount", comment: ""), _id: user._id, role: user.role))
                                    }
                                    DispatchQueue.main.async {
                                        self.notFoundLabel.isHidden = true
                                        self.searchTableView.backgroundColor = .white
                                        
                                        self.searchTableView.isHidden = false
                                        self.searchTableView.reloadData()

                                    }
                                    
                                }
                                
                            }
                            catch {
                                print(error.localizedDescription)
                            }
                        }
                        
                    }
                    else if httpResponse.statusCode == 403{
                        getNewAccessByRefreshToken(currentViewController: self)
                        self.localSearchApiCall(searchText)
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
        else {
            DispatchQueue.main.async {
                
                self.notFoundLabel.isHidden = false
                self.notFoundLabel.text = NSLocalizedString("SearchViewFullLeapper.Action.NoResults", comment: "")
                self.searchTableView.backgroundColor = .gray
                self.searchTableView.isHidden = true
            }
        }
    }
    func globalSearchApiCall(_ searchText: String){
        let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
        DispatchQueue.main.async {
            
            self.searchBar.text = searchText
        }
        if !searchText.isEmpty{
            
            var components = URLComponents(string: "https://api.leapper.com/api/mobi/search")!
            components.queryItems = [
                URLQueryItem(name: "text",
                             value: searchText),
            ]
            components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
            let url = components.url!
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
                
                let decoder = JSONDecoder()
                if let httpResponse = response as? HTTPURLResponse{
                    if httpResponse.statusCode == 200{
                        if let safeData = data {
                            do {
                                self.allUsers.removeAll()
                                DispatchQueue.main.async {
                                    self.searchTableView.reloadData()
                                }
                                let decodedData = try decoder.decode(ResultsGlobalSearch.self, from: safeData)
                                if decodedData.search.count == 0 {
                                    DispatchQueue.main.async {
                                        
                                        self.notFoundLabel.isHidden = false
                                        self.notFoundLabel.text = NSLocalizedString("SearchViewFullLeapper.Action.NoResults", comment: "")
                                        self.searchTableView.backgroundColor = .gray
                                        self.searchTableView.isHidden = true
                                    }
                                }
                                else {
                                    for user in decodedData.search {
                                        self.allUsers.append(AllUsers(isPro: true, phone: "", fullName: user.fullName ?? user.name! + " " + user.lastName!, profession: user.portfolio?.jobName?.lowercased().capitalizingFirstLetter() ?? NSLocalizedString("ProfileViewPro.Label.ProfessionNotDefined", comment: ""), linkToAvatar: user.avatar, mutualsCount: "\(user.mutualsCount ?? 0)"  + NSLocalizedString("Leapper.MutualsCount", comment: ""), _id: user._id, role: user.role))
                                        
                                    }
                                   
                                    DispatchQueue.main.async {
                                        self.notFoundLabel.isHidden = true
                                        self.searchTableView.backgroundColor = .white
                                        
                                        self.searchTableView.isHidden = false
                                        self.searchTableView.reloadData()


                                    }
                                    
                                }
                            }
                            catch {
                                print(error.localizedDescription)
                            }
                        }
                        
                    }
                    else if httpResponse.statusCode == 403{
                        getNewAccessByRefreshToken(currentViewController: self)
                        self.globalSearchApiCall(searchText)
                    }
                    else {
                        DispatchQueue.main.async {
                            self.notFoundLabel.isHidden = false
                            self.notFoundLabel.text = NSLocalizedString("SearchViewFullLeapper.Action.NoResults", comment: "")
                            self.searchTableView.backgroundColor = .gray
                            self.searchTableView.isHidden = true
                            
                        }
                    }
                    
                }
            })
            task.resume()
        }
        else {
            DispatchQueue.main.async {
                
                self.notFoundLabel.isHidden = false
                self.notFoundLabel.text = NSLocalizedString("SearchViewFullLeapper.Action.NoResults", comment: "")
                self.searchTableView.backgroundColor = .gray
                self.searchTableView.isHidden = true
            }
        }
    }
    
    var isPreloader = false
    
}

extension SearchViewFullLeapper:UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchType == "global" {
            globalSearchApiCall(searchText)
        }
        else {
            localSearchApiCall(searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.becomeFirstResponder()
    }
    
}
extension SearchViewFullLeapper:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allUsers.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let itemCell = tableView.dequeueReusableCell(withIdentifier: "users", for: indexPath) as? SearchTableViewCell{
            if allUsers.count > indexPath.row {
                itemCell.user = allUsers[indexPath.row]
                itemCell.parent = self.self
                return itemCell
            }
        }
        
        
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = allUsers[indexPath.row]
        if user.role == "professional" {
            let pVP = self.storyboard?.instantiateViewController(withIdentifier: "ProView") as? ProfileViewPro
            pVP!._id = user._id
            self.present(pVP!, animated: true, completion: nil)
        }
        else if user.role == "client" {
            let pVC = self.storyboard?.instantiateViewController(withIdentifier: "ClientView") as? ProfileViewClient
            pVC!._id = user._id
            self.present(pVC!, animated: true, completion: nil)
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0

        UIView.animate(
            withDuration: 0.5,
            delay: 0.05 * Double(indexPath.row),
            animations: {
                cell.alpha = 1
        })
    }
    
    
    
    
}

extension SearchViewFullLeapper: UIViewControllerTransitioningDelegate{
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        slideInTrans.isPresention = true
        return slideInTrans
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        slideInTrans.isPresention = false
        return slideInTrans
    }
}


extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
