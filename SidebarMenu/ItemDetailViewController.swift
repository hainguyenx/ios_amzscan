//
//  ItemDetailViewController.swift
//  SidebarMenu
//
//  Created by Hai Nguyen on 2/12/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit

class ItemDetailViewController: UIViewController {

    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemCatagory: UILabel!
    @IBOutlet weak var itemSalesRank: UILabel!
    @IBOutlet weak var itemOffer: UILabel!
    
    var prodAmzTitle: String = ""
    var prodAmzRank: Int = 0
    var prodAmzCatagory: String = ""
    var prodAmzImageURL: String = ""
    var prodAmzOffer: Int = 0
    
    
    /*override func viewWillAppear(animated: Bool){
        itemTitle.text = blogName
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        itemTitle.text = prodAmzTitle
        itemImage.imageFromUrl(prodAmzImageURL)
        itemSalesRank.text = String(prodAmzRank)
        itemCatagory.text = prodAmzCatagory
        itemOffer.text = String(prodAmzOffer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
