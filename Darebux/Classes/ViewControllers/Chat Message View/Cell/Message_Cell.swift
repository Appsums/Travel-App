//
//  Message_Cell.swift
//  Darebux
//
//  Created by logicspice on 28/02/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit

class Message_Cell: UITableViewCell
{
    //MARK:- Outlets
    @IBOutlet var message_view_receiver: UIView!
    @IBOutlet var message_view_sender: UIView!
    @IBOutlet var txt_view_receiver: UITextView!
    @IBOutlet var txt_view_sender: UITextView!
    @IBOutlet var img_attachment_receiver: UIImageView!
    @IBOutlet var img_attachment_sender: UIImageView!

    @IBOutlet var img_arrow_sender: UIImageView!
    var isSender: Bool!

    @IBOutlet var btn_attachment_receiver: UIButton!
    @IBOutlet var btn_attachment_sender: UIButton!
    @IBOutlet var lbl_msg_receive_time: UILabel!
    @IBOutlet var lbl_msg_sent_time: UILabel!

    //MARK:- Cell Methods
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code

        self.backgroundColor = UIColor.clear
        
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
