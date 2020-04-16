//
//  Comment_Cell.swift
//  Darebux
//
//  Created by logicspice on 27/02/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit

class Comment_Cell: UITableViewCell
{
    @IBOutlet var img_profile: UIImageView!
    @IBOutlet var lbl_username: UILabel!
    @IBOutlet var lbl_comment: UILabel!
    @IBOutlet var lbl_date: UILabel!
    @IBOutlet var vw_report: UIView!
    @IBOutlet var btn_report: UIButton!

    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code

        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
