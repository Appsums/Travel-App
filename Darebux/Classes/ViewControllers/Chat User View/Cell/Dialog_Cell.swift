//
//  Dialog_Cell.swift
//  Darebux
//
//  Created by logicspice on 19/02/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit

class Dialog_Cell: UITableViewCell
{
    //MARK:- Outlets
    @IBOutlet var img_user: UIImageView!
    @IBOutlet var lbl_name: UILabel!
    @IBOutlet var lbl_date: UILabel!
    @IBOutlet var lbl_message: UILabel!
    @IBOutlet var lbl_unread: UILabel!

    //MARK:- View Life Cycle
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
