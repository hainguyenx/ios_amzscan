//
//  CustomCell.swift
//  SidebarMenu
//
//  Created by Hai Nguyen on 2/9/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell{

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var salesRank: UILabel!
    @IBOutlet weak var offer: UILabel!
    @IBOutlet weak var productImage: UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated:animated)
    }
}
