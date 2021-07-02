//
//  apiServices.swift
//  Leapper
//
//  Created by Екатерина Узбекова on 09.04.2021.
//  Copyright © 2021 Leapper Technologies. All rights reserved.
//

protocol ApiServicesProtocol: class {
    
}

import Foundation
import SwiftKeychainWrapper
import Alamofire
import SwiftyJSON

class ApiServices {
    static let shared = ApiServices()

    private lazy var _id = KeychainWrapper.standard.string(forKey: "_id")!
    private lazy var accessToken = KeychainWrapper.standard.string(forKey: "accessToken")
    
    
    
    private let synchContactsURL = "https://api.leapper.com/api/mobi/synchContacts"
    func synchContactsRequest(with contactsList: [CLong]) {
        let headers: HTTPHeaders = [
            "Content-type": "application/json",
            "Authorization": "Bearer \(accessToken!)",
            "Accept": "application/json"
        ]
        let parameters =  [
            "contacts":
                contactsList
        ]
        
        AF.request(synchContactsURL, method : .post, parameters : parameters, encoding : JSONEncoding.default , headers : headers).responseData { dataResponse in
            if dataResponse.response?.statusCode == 403 {
                self.synchContactsRequest(with: contactsList)
            }
        }
    }
    
    func deleteChatApiUrl(by chatId: String) -> String {
        return "https://api.leapper.com/chats/\(chatId)"
    }
    func getUserInfo(_id: String, parentViewController: UIViewController, completion: @escaping (_ userModel: UserDataModel?, Error?) -> Void) {
        getSetProfileProApi(_id: _id, parentViewController: parentViewController, completion: completion)
    }
    
    func getPromotionApi(_id: String, controller: UIViewController, completion: @escaping (_ data: JSON?, Error?) -> Void) {
        
        /*
         method to send GET request to server and receive JSON with mutuals users
         */
        
        let promotionsApiURL = "https://api.leapper.com/api/mobi/getIdPromo/\(_id)"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken!)",
            "Accept": "application/json"
        ]
        AF.request(promotionsApiURL, method : .get, parameters : [:], encoding : URLEncoding.default , headers : headers).responseData { [self] dataResponse in
            
            if dataResponse.error != nil {
                return
            }
            switch dataResponse.response?.statusCode {
            case 200:
                let data = dataResponse.data!
                completion(JSON(data), nil)
                break
            case 403:
                getNewAccessByRefreshToken(currentViewController: controller)
                getPromotionApi(_id: _id, controller: controller, completion: completion)
                break
            default:
                break
            }
        }
    }
    
    private func getSetProfileProApi(_id: String, parentViewController: UIViewController, completion: @escaping (_ data: UserDataModel?, Error?) -> Void) {
        
        
        let allChatRoomsURL = "https://api.leapper.com/api/mobi/getUser/\(_id)"
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken!)",
            "Accept": "application/json"
        ]
        AF.request(allChatRoomsURL, method : .get, parameters : [:], encoding : URLEncoding.default , headers : headers).responseData { [self] dataResponse in
            if dataResponse.error != nil {
                parentViewController.view.makeToast(dataResponse.error?.localizedDescription, duration: 3, position: .center)
                return
            }
            switch dataResponse.response?.statusCode {
            case 200:
                let data = dataResponse.data!
                let jsonDecoder = JSONDecoder()
                do {
                    let decodedData = try jsonDecoder.decode(UserDataModel.self, from: data)
                    completion(decodedData, nil)
                }
                catch {
                    completion(nil, error)
                }
                break
            case 403:
                getNewAccessByRefreshToken(currentViewController: parentViewController)
                getSetProfileProApi(_id: _id, parentViewController: parentViewController, completion: completion)
                break
            default:
                completion(nil, dataResponse.error?.asAFError)
                break
            }
        }
    }
    
    func sharePromotion(isShared: Bool = false, lastController: UIViewController, _idPromo: String, isMy: Bool) {
        let alertController = UIAlertController()
        if isMy  {
            
            alertController.addAction(UIAlertAction(title: isShared ? NSLocalizedString("Promotion.Action.UnshareInFeed", comment: "Unshare in Feed") : NSLocalizedString("Promotion.Action.ShareByFeed", comment: "Share by Feed"),
                                                    style: UIAlertAction.Style.default){ [self]
                                        action in
                                        if isShared{
                                            apiSharePromotion(string: "unSharePromo", _idPromo: _idPromo, viewController: lastController)
                                        }
                                        else {
                                            apiSharePromotion(_idPromo: _idPromo, viewController: lastController)
                                        }})
        }
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Promotion.Action.ShareInChat", comment: "Share in chat"), style: UIAlertAction.Style.default, handler: {
            action in
            let proMessengerVar = (lastController.storyboard?.instantiateViewController(withIdentifier: "ShareInChatViewController") as! ShareInChatViewController)
            proMessengerVar._idPromo = _idPromo
            lastController.present(proMessengerVar, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title:NSLocalizedString("Action.Cancel", comment: "Cancel") , style: .cancel, handler: {
            action in
        }))
        lastController.present(alertController, animated: true, completion: nil)
    }
    
    func apiSharePromotion(string: String = "sharePromo", _idPromo: String, viewController: UIViewController) {
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken!)"
        ]
        AF.request("https://api.leapper.com/api/mobi/\(string)/\(_idPromo)", method: .put, parameters: nil, encoding: JSONEncoding.default, headers: headers).response { resp in
            
            
            if resp.error != nil{
                viewController.view.makeToast(resp.error?.localizedDescription, duration: 3, position: .center)
                return
            }
            
            if resp.response?.statusCode == 403 {
                getNewAccessByRefreshToken(currentViewController: viewController)
            }
            else if resp.response?.statusCode == 200 {
                viewController.dismiss(animated: true, completion: nil)
            }
            else {
                DispatchQueue.main.async {
                    Toast(NSLocalizedString("Toast.Message.Error", comment: "")).show(viewController)
                }
            }
            
            
        }
    }
}
