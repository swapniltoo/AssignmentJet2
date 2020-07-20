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
