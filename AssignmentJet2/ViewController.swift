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

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //Create Activity Indicator
        let myActivityIndicator = UIActivityIndicatorView()
        myActivityIndicator.center = view.center
        myActivityIndicator.hidesWhenStopped = false
        myActivityIndicator.startAnimating()
        view.addSubview(myActivityIndicator)

        GlobalMethod.sharedInstance.getViewData() { (isResult, result) in
            print(result ?? "Error")
            DispatchQueue.main.async {
            self.arr = result as! [[String : Any]]
            self.tableView.reloadData()
                //  stop activity indicator
                myActivityIndicator.stopAnimating()
                myActivityIndicator.removeFromSuperview()
            }
        }

    }


}


extension ViewController : UITableViewDelegate,UITableViewDataSource
{
    
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
            cell.byline.text = dir["content"] as? String
            cell.published_date.text = "Comments"
            cell.img.layer.cornerRadius = cell.img.frame.size.height/2
            
            if let urlStr = ((dir["media"] as! [[String:Any]])[0])["image"] as? String
            {
                print(urlStr)
                cell.mediaImg.isHidden = false
                cell.mediaImg.image = #imageLiteral(resourceName: "defaultImage.png")
            }
            else
            {
                cell.mediaImg.isHidden = true
                cell.mediaImg.image = nil
            }
        }
        return cell
    }
}



