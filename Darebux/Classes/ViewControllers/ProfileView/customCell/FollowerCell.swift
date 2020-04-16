//
//  FollowerCell.swift
//  Darebux
//
//  Created by LogicSpice on 01/02/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit

class FollowerCell: UITableViewCell {

    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblAddress: UILabel!
    @IBOutlet var vw_Follow: UIView!
    @IBOutlet var lbl_CellFollow: UILabel!
    @IBOutlet var btn_CellFollow: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        vw_Follow.layer.cornerRadius = 4
        vw_Follow.layer.borderWidth = 1
        vw_Follow.layer.borderColor = UIColor.lightGray.cgColor

        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
