//
//  GlobalMethod.swift
//  AssignmentJet2
//
//  Created by Apple on 20/07/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit


private let SharedInstance = GlobalMethod()

//https://5e99a9b1bc561b0016af3540.mockapi.io/jet2/api/v1/blogs?page=1&limit=10

enum Endpoint : String {
    
    case mostviewed                   = "/jet2/api/v1/blogs?page=1&limit=10"
    case articleUrl                   = "2"
}
class GlobalMethod: NSObject {

    public let BaseApiPath:String = "https://5e99a9b1bc561b0016af3540.mockapi.io"
    private let APIKey:String = ""
    
//    var requestManager = AFHTTPSessionManager()
    
    class var sharedInstance : GlobalMethod {
        return SharedInstance
    }

    override init() {
    }

    
    //MARK: viewsAPI
    
    func getViewData(completionHandler:@escaping (_ result:Bool, _ responseObject:NSArray?) -> Void){
        let url = "\(BaseApiPath)\(Endpoint.mostviewed.rawValue)"

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




