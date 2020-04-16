//
//  Balance_Cell.swift
//  Darebux
//
//  Created by logicspice on 13/03/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit

class Balance_Cell: UITableViewCell
{
    //MARK:- Outlets
    @IBOutlet var lbl_date: UILabel!
    @IBOutlet var lbl_detail: UILabel!
    @IBOutlet var lbl_amount: UILabel!

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
