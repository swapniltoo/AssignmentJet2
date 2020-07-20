//
//  ViewController.swift
//  AssignmentJet2
//
//  Created by Apple on 20/07/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var arr : [[String:Any]] = [[:]]
    var pagecount =  1
    
    fileprivate var activityIndicator: LoadMoreActivityIndicator!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //Create Activity Indicator
        let myActivityIndicator = UIActivityIndicatorView()
        myActivityIndicator.center = view.center
        myActivityIndicator.hidesWhenStopped = false
        myActivityIndicator.startAnimating()
        view.addSubview(myActivityIndicator)

        let network = NetworkListner.shared
        
        network.reachability.whenReachable = { reachability in
            
            GlobalMethod.sharedInstance.getViewData() { (isResult, result) in
                print(result ?? "Error")
                DispatchQueue.main.async {
                self.arr = result as? [[String : Any]] ?? []
                self.tableView.reloadData()
                    //  stop activity indicator
                    myActivityIndicator.stopAnimating()
                    myActivityIndicator.removeFromSuperview()
                }
            }
            
        }

        

        
        // Setting Table view for pagging by adding lodder at bottom
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        activityIndicator = LoadMoreActivityIndicator(scrollView: tableView, spacingFromLastCell: 10, spacingFromLastCellWhenLoadMoreActionStart: 60)

        // adding notification for network issue
        NotificationCenter.default.addObserver(self, selector: #selector(networkIssues), name: NSNotification.Name(rawValue: "networkIssue"), object: nil)
    }
    

  @objc  func networkIssues(notification : NSNotification){
        //do here code
    print(notification.object ?? "") //myObject
    print(notification.userInfo ?? "") //[AnyHashable("key"): "Value"]
    print(notification.userInfo?["flag"] ?? "no network triggred ")
    
    }


    override func viewWillDisappear(_ animated: Bool) {
        // Remove the network notification observer
        NotificationCenter.default.removeObserver(self, name: UIDevice.batteryLevelDidChangeNotification, object: nil)
    }

    
}


extension ViewController : UITableViewDelegate,UITableViewDataSource
{
    
    func getDateFromString(dateStr: String) -> (date: Date?,conversion: Bool)
    {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let dateComponentArray = dateStr.components(separatedBy: "/")

        if dateComponentArray.count == 3 {
            var components = DateComponents()
            components.year = Int(dateComponentArray[2])
            components.month = Int(dateComponentArray[1])
            components.day = Int(dateComponentArray[0])
            components.timeZone = TimeZone(abbreviation: "GMT+0:00")
            guard let date = calendar.date(from: components) else {
                return (nil , false)
            }

            return (date,true)
        } else {
            return (nil,false)
        }

    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arr.count > 1
        {
            return arr.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SkTableViewCell
        
        if arr.count > 0
        {        
            let dir = arr[indexPath.row]
            cell.cellData = dir
            let user = dir["user"] as! [[String : Any]]
            cell.title.text = (user[0])["name"] as? String ?? ""
            cell.usrDesg.text = (user[0])["designation"] as? String ?? ""
            cell.byline.text = dir["content"] as? String ?? ""
            cell.published_date.text = ""
            cell.img.layer.cornerRadius = cell.img.frame.size.height/2
            // check if the media obj
            let dr = dir["media"] as? [[String:Any]]
            if dr?.count ?? 0 > 0
            {
                if let mediaTitle = (dr?[0])?["title"] as? String
                {
                      cell.mediaTitle.text = mediaTitle
                }
                else
                {
                      cell.mediaTitle.text = "No Title"
                }
                
                
                if let urlStr = ((dir["media"] as! [[String:Any]])[0])["url"] as? String
                {
                    cell.linkBtn.setTitle(urlStr, for:.normal)
                }
                else
                {
                    cell.linkBtn.setTitle("", for:.normal)
                }
                
                if let urlStr = ((dir["media"] as! [[String:Any]])[0])["image"] as? String
                {
                    print(urlStr)
                    cell.mediaImgHeight.constant = 250
                    cell.mediaImg.downloaded(from: urlStr)
                    cell.mediaImg.isHidden = false
                    cell.mediaImg.image = #imageLiteral(resourceName: "defaultImage.png")
                }
                else
                {
                    cell.mediaImgHeight.constant = 0
                    cell.mediaImg.isHidden = true
                    cell.mediaImg.image = nil
                }
                
            }
            else
            {
                // remove the image and comments, title and ling if media obj not avl
                cell.mediaTitle.text = ""
                cell.linkBtn.setTitle("", for:.normal)
                cell.mediaImgHeight.constant = 0
                cell.mediaImg.isHidden = true
                cell.mediaImg.image = nil
            }
            
            if let likesCntStr = dir["likes"] as? Double
            {
                cell.likeCount.text = "\(likesCntStr.shortStringRepresentation) Likes"
            }
            else
            {
                  cell.mediaTitle.text = "0 Likes"
            }

            if let commentsCntStr = dir["comments"] as? Double
            {
                cell.commentCount.text = "\(commentsCntStr.shortStringRepresentation) Comments"
            }
            else
            {
                  cell.commentCount.text = "0 Comments"
            }

            if let dateTime = dir["createdAt"] as? String
            {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.timeZone = TimeZone.autoupdatingCurrent
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                let dataDate = dateFormatter.date(from: dateTime)!
                let dt = Date()
                cell.timeLbl.text = dt.timeIntervalSince(dataDate).stringFromTimeInterval()
                
                
            }
            else
            {
                  cell.commentCount.text = "1 min"
            }

        }
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        activityIndicator.start {
            self.pagecount += self.pagecount
            
            DispatchQueue.global(qos: .utility).async {
                
                GlobalMethod.sharedInstance.getViewData(page: self.pagecount) { (isResult, result) in
                    print(result ?? "Error")
                    DispatchQueue.main.async {
                    let new_arr =  result as? [[String : Any]] ?? []
                        self.arr.append(contentsOf: new_arr)
                    self.tableView.reloadData()
                        //  stop activity indicator
                        for i in 0..<3 {
                            print("!!!!!!!!! \(i)")
                            sleep(1)
                        }
                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicator.stop()
                        }

                    }
                }
                
            }
        }
    }
}


