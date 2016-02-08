//
//  HomeViewController.swift
//  SidebarMenu
//
//  Created by Hai Nguyen on 2/1/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import SwiftyJSON

class HomeViewController: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        amazonItemSearch("312547427951")
    }
    

    func amazonItemLookup(searchKey:String){
        
        
        let asin = "B00DVDMRX6" // an amazon id to search for
        
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
//            print("DATA= \(json)")
           // print("-----------------")
            print(json)
            let totalResults = json["ItemSearchResponse"]["Items"]["TotalResults"].intValue
           
            
            
            
            print("INDEx=\(totalResults)")
            let item =  json["ItemSearchResponse"]["Items"]["Item"]

            for var index = 0; index < totalResults; ++index{
                 print("ASIN is \(item[index]["ASIN"])")
                print("SalesRank is \(item[index]["SalesRank"].intValue)")
                
                let totalNew = item[index]["OfferSummary"]["TotalNew"].intValue
                print("totalNew=\(totalNew)")
                
                let totalRefurbished = item[index]["OfferSummary"]["TotalRefurbished"].intValue
                print("totalRef=\(totalRefurbished)")
                
                
                let totalUsed = item[index]["OfferSummary"]["TotalUsed"].intValue
                print("totalUse = \(totalUsed)")
                
                let totalOffer = totalNew + totalRefurbished + totalUsed
                print("Offer is \(totalOffer)")
                
                let title = item[index]["ItemAttributes"]["Title"]
                print("Title is \(title)")
                
                let category = item[index]["ItemAttributes"]["ProductGroup"]
                print("Category is \(category)")
                print("---------")
                
            }
            
 //           let item =  json["ItemSearchResponse"]["Items"]["Item"]
//                print(item[0]["ASIN"])
//                print(item[1]["ASIN"])
//                print("--------------")
            
            //ItemSearchErrorResponse

        }
    }

    
}
