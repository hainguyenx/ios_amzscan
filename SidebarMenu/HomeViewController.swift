//
//  HomeViewController.swift
//  SidebarMenu
//
//  Created by Hai Nguyen on 2/1/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import SwiftyJSON

extension UIImageView {
    public func imageFromUrl(urlString: String) {
        if let url = NSURL(string: urlString) {
            let request = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                self.image = UIImage(data: data!)
            }
        }
    }
}


class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate{

    
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBox: UITextField!
  
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.searchBox.resignFirstResponder()
        amazonItemSearch(self.searchBox.text!)
        return true
    }
    
    @IBAction func scanButton(sender: UIBarButtonItem) {
          //amazonItemSearch("asdfasd312547427951sdfdfd")
          //tableView.reloadData()
        
    }
    var products:[Product] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBox.delegate = self
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    

    func amazonItemLookup(searchKey:String){
        
        
        let asin = "B00DdfgsdfaVDMRX6" // an amazon id to search for
        
        let serializer = AmazonSerializer(key: aws_key_default, secret: aws_secret_default)
        
        let amazonParams = [
            "Service" : "AWSECommerceService",
            "Operation" : "ItemLookup",
            "ResponseGroup" : "Images,ItemAttributes",
            "IdType" : "ASIN",
            "ItemId" : asin,
            "AssociateTag" : associate_tag_default,
        ]
        
        amazonRequest(amazonParams, serializer: serializer).responseXML { (req, res, data, error) -> Void in
            print("Got results! \(data)")
        }
    }
    
    func amazonItemSearch(searchKey:String){
        
        let serializer = AmazonSerializer(key: aws_key_default, secret: aws_secret_default)
        
        let amazonParams = [
            "Service" : "AWSECommerceService",
            "Operation" : "ItemSearch",
            "ResponseGroup" : "Images,ItemAttributes,ItemIds,Offers,SalesRank",
            "SearchIndex" : "All",
            "Keywords" : searchKey,
            "AssociateTag" : associate_tag_default,
        ]
        
        amazonRequest(amazonParams, serializer: serializer).responseXML { (req, res, data, error) -> Void in
            
            var json = JSON(data!)

            print(json)
            let totalResults = json["ItemSearchResponse"]["Items"]["TotalResults"].intValue
           
            print("INDEx=\(totalResults)")
            let item =  json["ItemSearchResponse"]["Items"]["Item"]
            self.products.removeAll()
            //if( totalResults > 0){
                for var index = 0; index < totalResults; ++index{
                    let salesRank = item[index]["SalesRank"].intValue
                    let totalNew = item[index]["OfferSummary"]["TotalNew"].intValue
                    let totalRefurbished = item[index]["OfferSummary"]["TotalRefurbished"].intValue
                    let totalUsed = item[index]["OfferSummary"]["TotalUsed"].intValue
                    let totalOffer = totalNew + totalRefurbished + totalUsed
                    let title = item[index]["ItemAttributes"]["Title"].stringValue
                    let category = item[index]["ItemAttributes"]["ProductGroup"].stringValue
                    let image = item[index]["SmallImage"]["URL"].stringValue
                    let product = Product(title:title, totalOffer: totalOffer,category: category,salesRank: salesRank, imageURL: image)
                    self.products.append(product)
                    
                }
//            }else{
//                //load an unfind message in the table view
//            }
            self.tableView.reloadData()
        }
    }
    
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products.count
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell",forIndexPath: indexPath) as! CustomCell
        
        let product = self.products[indexPath.row]
        cell.title.text = product.title
        cell.category?.text = product.category
        cell.salesRank?.text = String(product.salesRank)
        print("Image=\(product.imageURL)")
        cell.productImage.imageFromUrl(product.imageURL)
        cell.offer?.text = String(product.totalOffer)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        print("Inside table cell clicked")
        let product = self.products[indexPath.row]
        print(product)
        let itemDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ItemDetailViewController") as! ItemDetailViewController
        self.navigationController?.pushViewController(itemDetailViewController, animated: true)
    }
    

    
    
}
