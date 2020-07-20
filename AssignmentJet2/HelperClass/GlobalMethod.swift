//
//  GlobalMethod.swift
//  AssignmentJet2
//
//  Created by Apple on 20/07/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import CoreData


private let SharedInstance = GlobalMethod()

//https://5e99a9b1bc561b0016af3540.mockapi.io/jet2/api/v1/blogs?page=1&limit=10

enum Endpoint : String {
    
    case homeUrl                   = "/jet2/api/v1/blogs"
    case articleUrl                   = "2"
}
class GlobalMethod: NSObject {

    public let BaseApiPath:String = "https://5e99a9b1bc561b0016af3540.mockapi.io"
    
    var personData: [NSManagedObject] = []

    
//    var requestManager = AFHTTPSessionManager()
    
    class var sharedInstance : GlobalMethod {
        return SharedInstance
    }

    override init() {
    }

    
    //MARK: viewsAPI
    
    func getViewData(page : Int = 1, limit : Int = 10 , completionHandler:@escaping (_ result:Bool, _ responseObject:NSArray?) -> Void){
        let url = "\(BaseApiPath)\(Endpoint.homeUrl.rawValue)?page=\(page)&limit=\(limit)"

        if let url = URL(string: url) {
           URLSession.shared.dataTask(with: url) { data, response, error in
              if let data = data {
                 if let jsonString = String(data: data, encoding: .utf8) {
                    print(jsonString)
                    let json = jsonString.parseJSONString
                    completionHandler(true, json as? NSArray )
                 }
               }
            else
            {
                completionHandler(false, nil)
            }
           }.resume()
        }
    }
    
    
    
    /// Working on core data // Saving to Core Data
    
    func save(obj : [String : Any]) {
      
      guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
        return
      }
      
      // 1
      let managedContext =
        appDelegate.persistentContainer.viewContext
      
      // 2
      let entity =
        NSEntityDescription.entity(forEntityName: "CellData",
                                   in: managedContext)!
      
      let person = NSManagedObject(entity: entity,
                                   insertInto: managedContext)
      
      // 3
      person.setValue(obj["id"], forKeyPath: "cid")
      person.setValue(obj["createdAt"], forKeyPath: "createdAt")
      person.setValue(obj["content"], forKeyPath: "content")
        person.setValue(obj["comments"], forKeyPath: "comments")
        person.setValue(obj["likes"], forKeyPath: "likes")
        
        let dr = obj["media"] as? [[String:Any]]
        if dr?.count ?? 0 > 0
        {
            let mediaObj = dr?[0] ?? [:]
            person.setValue(mediaObj.jsonStringRepresentation , forKeyPath: "media")
        }
        else
        {
            let mediaObj =  [String:Any]()
            person.setValue(mediaObj.jsonStringRepresentation , forKeyPath: "media")
        }
        
        let ur = obj["user"] as? [[String:Any]]
        if ur?.count ?? 0 > 0
        {
            let userObj = ur?[0] ?? [:]
            person.setValue(userObj.jsonStringRepresentation , forKeyPath: "user")
        }
        else
        {
            let userObj =  [String:Any]()
            person.setValue(userObj.jsonStringRepresentation , forKeyPath: "user")
        }
        


      // 4
      do {
        try managedContext.save()
        personData.append(person)
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
    
}


extension String
{
var parseJSONString: AnyObject?
{
    let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)
    if let jsonData = data
    {
        // Will return an object or nil if JSON decoding fails
        do
        {
            let message = try JSONSerialization.jsonObject(with: jsonData, options:.mutableContainers)
            if let jsonResult = message as? NSMutableArray {
                return jsonResult //Will return the json array output
            } else if let jsonResult = message as? NSMutableDictionary {
                return jsonResult //Will return the json dictionary output
            } else {
                return nil
            }
        }
        catch let error as NSError
        {
            print("An error occurred: \(error)")
            return nil
        }
    }
    else
    {
        // Lossless conversion of the string was not possible
        return nil
    }
}

}


extension Double {
    var shortStringRepresentation: String {
        if self.isNaN {
            return "NaN"
        }
        if self.isInfinite {
            return "\(self < 0.0 ? "-" : "+")Infinity"
        }
        let units = ["", "k", "M"]
        var interval = self
        var i = 0
        while i < units.count - 1 {
            if abs(interval) < 1000.0 {
                break
            }
            i += 1
            interval /= 1000.0
        }
        // + 2 to have one digit after the comma, + 1 to not have any.
        // Remove the * and the number of digits argument to display all the digits after the comma.
        return "\(String(format: "%0.*g", Int(log10(abs(interval))) + 2, interval))\(units[i])"
    }
}


extension Date {

    func years(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.year], from: sinceDate, to: self).year
    }

    func months(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.month], from: sinceDate, to: self).month
    }

    func days(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.day], from: sinceDate, to: self).day
    }

    func hours(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.hour], from: sinceDate, to: self).hour
    }

    func minutes(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.minute], from: sinceDate, to: self).minute
    }

    func seconds(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.second], from: sinceDate, to: self).second
    }

}


extension TimeInterval{
    func stringFromTimeInterval() -> String {
        let time = NSInteger(self)
//        let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
//        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        if hours > 23
        {
            let dy = hours/24
            let hr = hours%24
            return String(format: "%0.0dD:%0.2dhr:%0.2dmin",dy,hr,minutes)
        }
        
        return String(format: "%0.2dhr:%0.2dmin",hours,minutes)

    }
}


extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}



class LoadMoreActivityIndicator {

    private let spacingFromLastCell: CGFloat
    private let spacingFromLastCellWhenLoadMoreActionStart: CGFloat
    private weak var activityIndicatorView: UIActivityIndicatorView?
    private weak var scrollView: UIScrollView?

    private var defaultY: CGFloat {
        guard let height = scrollView?.contentSize.height else { return 0.0 }
        return height + spacingFromLastCell
    }

    deinit { activityIndicatorView?.removeFromSuperview() }

    init (scrollView: UIScrollView, spacingFromLastCell: CGFloat, spacingFromLastCellWhenLoadMoreActionStart: CGFloat) {
        self.scrollView = scrollView
        self.spacingFromLastCell = spacingFromLastCell
        self.spacingFromLastCellWhenLoadMoreActionStart = spacingFromLastCellWhenLoadMoreActionStart
        let size:CGFloat = 40
        let frame = CGRect(x: (scrollView.frame.width-size)/2, y: scrollView.contentSize.height + spacingFromLastCell, width: size, height: size)
        let activityIndicatorView = UIActivityIndicatorView(frame: frame)
        activityIndicatorView.color = .black
        activityIndicatorView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        activityIndicatorView.hidesWhenStopped = true
        scrollView.addSubview(activityIndicatorView)
        self.activityIndicatorView = activityIndicatorView
    }

    private var isHidden: Bool {
        guard let scrollView = scrollView else { return true }
        return scrollView.contentSize.height < scrollView.frame.size.height
    }

    func start(closure: (() -> Void)?) {
        guard let scrollView = scrollView, let activityIndicatorView = activityIndicatorView else { return }
        let offsetY = scrollView.contentOffset.y
        activityIndicatorView.isHidden = isHidden
        if !isHidden && offsetY >= 0 {
            let contentDelta = scrollView.contentSize.height - scrollView.frame.size.height
            let offsetDelta = offsetY - contentDelta

            let newY = defaultY-offsetDelta
            if newY < scrollView.frame.height {
                activityIndicatorView.frame.origin.y = newY
            } else {
                if activityIndicatorView.frame.origin.y != defaultY {
                    activityIndicatorView.frame.origin.y = defaultY
                }
            }

            if !activityIndicatorView.isAnimating {
                if offsetY > contentDelta && offsetDelta >= spacingFromLastCellWhenLoadMoreActionStart && !activityIndicatorView.isAnimating {
                    activityIndicatorView.startAnimating()
                    closure?()
                }
            }

            if scrollView.isDecelerating {
                if activityIndicatorView.isAnimating && scrollView.contentInset.bottom == 0 {
                    UIView.animate(withDuration: 0.3) { [weak self] in
                        if let bottom = self?.spacingFromLastCellWhenLoadMoreActionStart {
                            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
                        }
                    }
                }
            }
        }
    }

    func stop(completion: (() -> Void)? = nil) {
        guard let scrollView = scrollView , let activityIndicatorView = activityIndicatorView else { return }
        let contentDelta = scrollView.contentSize.height - scrollView.frame.size.height
        let offsetDelta = scrollView.contentOffset.y - contentDelta
        if offsetDelta >= 0 {
            UIView.animate(withDuration: 0.3, animations: {
                scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }) { _ in completion?() }
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            completion?()
        }
        activityIndicatorView.stopAnimating()
    }
}


extension Dictionary {
    var jsonStringRepresentation: String? {
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: self,
                                                            options: [.prettyPrinted]) else {
            return nil
        }

        return String(data: theJSONData, encoding: .ascii)
    }
}
