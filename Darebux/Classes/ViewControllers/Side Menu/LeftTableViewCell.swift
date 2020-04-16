//
//  LeftTableViewCell.swift
//  Beeland_Artisan
//
//  Created by LS on 09/01/17.
//  Copyright © 2017 LS. All rights reserved.
//

import UIKit

class LeftTableViewCell: UITableViewCell
{
    @IBOutlet var lblText: UILabel!
    @IBOutlet var imgIcon: UIImageView!
    @IBOutlet var lblButtom: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code

        self.selectionStyle = UITableViewCellSelectionStyle.none
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
