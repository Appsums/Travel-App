//
//  Invite_Cell.swift
//  Darebux
//
//  Created by logicspice on 22/02/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit

class Invite_Cell: UITableViewCell
{
    @IBOutlet var img_user: UIImageView!
    @IBOutlet var lbl_username: UILabel!
    @IBOutlet var lbl_date: UILabel!
    @IBOutlet var lbl_daretitle: UILabel!
    @IBOutlet var lbl_status: UILabel!
    @IBOutlet var lbl_upload: UILabel!

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
