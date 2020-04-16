//
//  MyDaresCell.swift
//  Darebux
//
//  Created by LogicSpice on 08/03/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit
import GTProgressBar

class MyDaresCell: UITableViewCell {

    @IBOutlet var img_dare: UIImageView!
    @IBOutlet var img_user: UIImageView!
    @IBOutlet var btn_img: UIButton!
    @IBOutlet var lbl_title: UILabel!
    @IBOutlet var vw_report: UIView!
    @IBOutlet var btn_report: UIButton!
    @IBOutlet var goal_bar: GTProgressBar!
    @IBOutlet var lbl_amount: UILabel!
    @IBOutlet var lbl_username: UILabel!
    @IBOutlet var lbl_views: UILabel!
    @IBOutlet var lbl_time: UILabel!
    @IBOutlet var lbl_Status: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
