//
//  Product.swift
//  SidebarMenu
//
//  Created by Hai Nguyen on 2/9/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import Foundation

class Product {
    var totalOffer:Int
    var title:String
    var category:String
    var salesRank:String
    var imageURL:String
    
    init(title :String, totalOffer:Int, category:String, salesRank:String, imageURL:String){
        self.title = title
        self.totalOffer = totalOffer
        self.category = category
        self.salesRank = salesRank
        self.imageURL = imageURL
    }

    
}