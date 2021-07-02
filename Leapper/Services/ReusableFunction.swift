//
//  ReusableFunction.swift
//  Leapper
//
//  Created by Екатерина Узбекова on 06.01.2021.
//  Copyright © 2021 Leapper Technologies. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper
import CoreLocation
import SwiftyJSON
import Alamofire
import Kingfisher



func setTimeFromJson(time: String, isOnlyTimeNeeded: Bool = false, isOnlyDate: Bool = false) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    if isOnlyDate {
        if let timeInDateFormat = dateFormatter.date(from: time) {
            dateFormatter.dateFormat = "dd-MM"
            return dateFormatter.string(from: timeInDateFormat)
    }
        return ""
    }
    if isOnlyTimeNeeded {
        if let timeInDateFormat = dateFormatter.date(from: time) {
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: timeInDateFormat)
    }
        return ""
    }
    if let timeInDateFormat = dateFormatter.date(from: time) {
    
        if Calendar.autoupdatingCurrent.isDateInToday(timeInDateFormat) {
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: timeInDateFormat)
    }
    else {
        dateFormatter.dateFormat = "HH:mm dd/MM/yyyy"
        return dateFormatter.string(from: timeInDateFormat)
    }
    }
    return ""
}
func setNewImage(linkToPhoto: String?, imageInput: UIImageView, isRounded: Bool, placeholderPic: String = "placeholderPic.png") {
    
    let url = URL(string: linkToPhoto ?? "")
    DispatchQueue.main.async {
        let processor = DownsamplingImageProcessor(size: imageInput.bounds.size)
        imageInput.kf.indicatorType = .activity
        imageInput.kf.setImage(
            with: url,
            placeholder: UIImage(named: placeholderPic),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ], completionHandler:
                {
                    result in
                })
        if isRounded {
            imageInput.setRounded()
        }
    }
}


func generateURLShare(id idUrl:String)->String{
    return "https://leapper.com/a/pro/\(idUrl)"
}

extension UIImageView{
    func setRounded() {
        
        //self.layer.borderWidth = 1
        self.layer.masksToBounds = false
       // self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
        self.contentMode = .scaleAspectFill
    }
}

enum UsersType: String {
    case professional = "professional"
    case client = "client"
    case pro = "pro"
}

/*
 To verify whether string - url or not
 */
func verifyUrl (urlString: String?) -> Bool {
   if let urlString = urlString {
       if let url = NSURL(string: urlString) {
           
        
        return  UIApplication.shared.canOpenURL(url as URL)
       }
   }
   return false
}


func convertStringToDateFormat(from string: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    let timeInDateFormat = dateFormatter.date(from: string)
    return timeInDateFormat!
}

func getNewAccessByRefreshToken(currentViewController parent: UIViewController) {

      let decoder = JSONDecoder()
    let parameters = ["refreshToken": KeychainWrapper.standard.string(forKey: "refreshToken")]
      let url = URL(string: "https://api.leapper.com/api/auth/token")! //change the url
      let session = URLSession.shared
      var request = URLRequest(url: url)
      request.httpMethod = "POST"

      do {
          request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
      } catch _ {
                }

      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      request.addValue("application/json", forHTTPHeaderField: "Accept")
      let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
          guard error == nil else {
              return
          }
          
          struct Tokens: Decodable {
            let accessToken: String
          }
          // let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
          if let httpResponse = response as? HTTPURLResponse{
              if httpResponse.statusCode == 401{
                  DispatchQueue.main.async {
                    Toast(NSLocalizedString("Toast.Message.WrongCodeFromSMS", comment: "")).show(parent)
                  }
              }
              else if httpResponse.statusCode == 200 {
                  if let safeData = data {
                      do {
                          let decodedData = try decoder.decode(Tokens.self, from: safeData)
                          KeychainWrapper.standard.set(decodedData.accessToken, forKey: "accessToken")
                        
                      }
                      catch {
                      }
                  }
              }
              else {
                SessionManager.shared.logOutUser(parent)
              }
              
          }
      })
      task.resume()
}

func postToUnregister(complete:  @escaping ()->()) {
    let deviceId = UIDevice.current.identifierForVendor!.uuidString
    let deleteTokenURL = "https://api.leapper.com/api/mobi/deleteNotificationToken/\(deviceId)"
    let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!
    
    let headers: HTTPHeaders = [
        "Content-Type": "application/json",
        "Authorization": "Bearer \(accessToken)"
    ]
    AF.request(deleteTokenURL, method: .delete, parameters: nil, headers: headers).responseJSON { AFdata in
        complete()
    }
}
func postToRegister(deviceToken: String, registrationToken:String, controller: UIViewController = UIViewController()) {
    let parameters: [String:Any] = [
        "device": deviceToken,
        "registrationToken": registrationToken
    ]
    let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")!

    let headers: HTTPHeaders = [
        "Content-Type": "application/json",
        "Authorization": "Bearer \(accessToken)"
    ]


    AF.request("https://api.leapper.com/api/mobi/postNotificationToken", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { resp in
        if let err = resp.error{
            print(err)
            return
        }
        if resp.response?.statusCode == 403 {
            getNewAccessByRefreshToken(currentViewController: controller)
            postToRegister(deviceToken: deviceToken, registrationToken: registrationToken, controller: controller)
        }
        else if resp.response?.statusCode == 200 {
            _ = resp.data
        }
}
}


extension String {
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}

func createUserDir(phone username: String, _ parent: UIViewController) {
    let parameters = ["username": username]
    
    let url = URL(string: "https://api.leapper.com/files/api/createDir")! //change the url
    let session = URLSession.shared
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
    } catch let error {
        Toast(error.localizedDescription).show(parent.self)
    }
    
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    
    let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
        guard error == nil else {
            return
        }
    })
    task.resume()
}



func getCity(latitude lat:Double?, longitude lon:Double?,locationLabel label:UILabel) {
    /*
     function, gets latitude and longitude of user position as Doubles
     gets label, where result will be put
     no returns
     */
    let geoCoder = CLGeocoder()
    let location = CLLocation(latitude: lat ?? 41.40338, longitude: lon ?? 2.17403)
    geoCoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, _) -> Void in
        placemarks?.forEach{(placemark) in
            if let city  = placemark.locality{
                print(city)
                DispatchQueue.main.async {
                    label.text = city
                }
            }else{
                DispatchQueue.main.async {
                    label.text = NSLocalizedString("ReusableFunction.Label.LocationNotDefined", comment: "Location not defined")
                }
            }
        }
    })
}





extension UIImage {

    func resize(maxWidthHeight : Double)-> UIImage? {

        let actualHeight = Double(size.height)
        let actualWidth = Double(size.width)
        var maxWidth = 0.0
        var maxHeight = 0.0

        if actualWidth > actualHeight {
            maxWidth = maxWidthHeight
            let per = (100.0 * maxWidthHeight / actualWidth)
            maxHeight = (actualHeight * per) / 100.0
        }else{
            maxHeight = maxWidthHeight
            let per = (100.0 * maxWidthHeight / actualHeight)
            maxWidth = (actualWidth * per) / 100.0
        }

        let hasAlpha = true
        let scale: CGFloat = 0.0

        UIGraphicsBeginImageContextWithOptions(CGSize(width: maxWidth, height: maxHeight), !hasAlpha, scale)
        self.draw(in: CGRect(origin: .zero, size: CGSize(width: maxWidth, height: maxHeight)))

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }

}


func createSpinnerView(controllerParent: UIViewController, viewParent: UIView) -> SpinnerViewController {
    let child = SpinnerViewController()

    // add the spinner view controller
    controllerParent.addChild(child)
    child.view.frame = viewParent.frame
    viewParent.addSubview(child.view)
    child.didMove(toParent: controllerParent)

    return child
}



class SpinnerViewController: UIViewController {
    var spinner = UIActivityIndicatorView(style: .whiteLarge)

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 230/255, alpha: 0.7)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

@IBDesignable
class ViewWithBorders: UIView {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
}


extension UIImage{
    var roundedImage: UIImage {
        let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: 50
            ).addClip()
        self.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}

