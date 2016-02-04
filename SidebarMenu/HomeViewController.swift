//
//  HomeViewController.swift
//  SidebarMenu
//
//  Created by Hai Nguyen on 2/1/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        searchAmazon("hai")
    }
    

    func searchAmazon(searchKey:String?=nil){
        
        
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
            print("Error=== \(error)")
            print("REQ=== \(req)")
            print("RESP== \(res)")
            print("Got results! \(data)")
        }
    }
    
}
