//
//  ChatUser_View.swift
//  Darebux
//
//  Created by logicspice on 15/02/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit

class ChatUser_View: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, QBChatDelegate
{
    //MARK:- Outlets
    @IBOutlet var vw_header: UIView!
    @IBOutlet var btnMenu: UIButton!
    @IBOutlet var vw_search: UIView!
    @IBOutlet var txtfld_search: UITextField!
    @IBOutlet var tbl_users: UITableView!
    @IBOutlet var lbl_msg: UILabel!

    let GDP = GDP_Obj()
    let appdel = App_Delegate()

    let refreshControl = UIRefreshControl()
    var arr_dialogs = NSMutableArray()
    var arr_filter: NSArray!
    var isfilter: Bool = false

    //MARK:- View Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        QBChat.instance.addDelegate(self)
        tbl_users.register(UINib(nibName: "Dialog_Cell", bundle: nil), forCellReuseIdentifier: "cell")

        tbl_users.addSubview(refreshControl)
        refreshControl.tintColor = app_color()
        refreshControl.addTarget(self, action: #selector(MyDares_View.refreshData(sender:)), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        GDP.leftView.setRevealContrl(reveal: self)
        btnMenu.addTarget(GDP.leftView, action: #selector(CustomRevealController.btnLeftMenuActionCall), for: UIControlEvents.touchUpInside)

        self.load_users()
    }

    override func viewDidLayoutSubviews()
    {
        GDP.adjustView(tmp_view: self.view)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:- Other Methods
    @objc func refreshData(sender: UIRefreshControl)
    {
        load_users()
        refreshControl.endRefreshing()
    }

    func load_users()
    {
        if Reachability.isConnectedToNetwork()
        {
            if QBChat.instance.isConnected
            {
                get_all_users()
            }
            else
            {
                self.connect_user()
            }
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }

    //MARK:- Text Field Methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField == txtfld_search
        {
            var newString = ""
            newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string

            if newString.trimmingCharacters(in: GDP.charSet).count == 0
            {
                isfilter = false
            }
            else
            {
                isfilter = true
                let predicate = NSPredicate(format: "name contains[c] %@", newString)
                arr_filter = arr_dialogs.filtered(using: predicate) as NSArray
            }

            tbl_users.delegate = self
            tbl_users.dataSource = self
            tbl_users.reloadData()
        }

        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if textField.text!.trimmingCharacters(in: GDP.charSet).count == 0
        {
            isfilter = false
        }
        else
        {
            isfilter = true
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return true
    }

    //MARK: - Table View Methods
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if isfilter == true
        {
            return arr_filter.count
        }
        else
        {
            return arr_dialogs.count
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if UIDevice().userInterfaceIdiom == .pad
        {
            return 90
        }
        else
        {
            return 56
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell: Dialog_Cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Dialog_Cell

        var tmp_dialog: QBChatDialog!
        if isfilter == true
        {
            tmp_dialog = arr_filter.object(at: indexPath.row) as! QBChatDialog
        }
        else
        {
            tmp_dialog = arr_dialogs.object(at: indexPath.row) as! QBChatDialog
        }

        cell.lbl_name.text = tmp_dialog.name
        cell.lbl_message.text = tmp_dialog.lastMessageText

        let msg_date = tmp_dialog.lastMessageDate
        if msg_date != nil
        {
            cell.lbl_date.text = NSDate.stringForDisplay(from: msg_date)
        }
        else
        {
            cell.lbl_date.text = ""
        }

        cell.lbl_unread.layer.cornerRadius = cell.lbl_unread.frame.size.width/2
        cell.lbl_unread.clipsToBounds = true

        let unread_count = tmp_dialog.unreadMessagesCount
        if unread_count <= 0
        {
            cell.lbl_unread.isHidden = true
        }
        else
        {
            cell.lbl_unread.isHidden = false
            cell.lbl_unread.text = "\(unread_count)"
        }

        let height = cell.contentView.frame.size.height - 8
        let width = cell.lbl_name.frame.origin.x - 12
        if height > width
        {
            cell.img_user.frame = CGRect(x: 4.0, y: 4.0, width: width, height: width)
            cell.img_user.layer.cornerRadius = width/2
        }
        else
        {
            cell.img_user.frame = CGRect(x: 4.0, y: 4.0, width: height, height: height)
            cell.img_user.layer.cornerRadius = height/2
        }

        cell.img_user.layer.cornerRadius = cell.img_user.frame.size.width/2
        cell.img_user.clipsToBounds = true

        QBRequest.user(withID: UInt(tmp_dialog.recipientID), successBlock: { (response, user:QBUUser?) in

            cell.img_user.DownloadQBUserImage(occBlobID: (user?.blobID)!, userID: UInt(tmp_dialog.recipientID), placeHolderImage: "user_Profile.png")

        }) { (response) in

            print("Error in get user \(response.error.debugDescription)")
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        var tmp_dialog: QBChatDialog!
        if isfilter == true
        {
            tmp_dialog = arr_filter.object(at: indexPath.row) as! QBChatDialog
        }
        else
        {
            tmp_dialog = arr_dialogs.object(at: indexPath.row) as! QBChatDialog
        }

        let obj_view = ChatMessage_View(nibName: "ChatMessage_View", bundle: nil)
        obj_view.chat_dialog = tmp_dialog
        appdel.appNav?.pushViewController(obj_view, animated: true)
    }

    //MARK:- Quickblox Methods
    func connect_user()
    {
        if Reachability.isConnectedToNetwork()
        {
            SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
            let user = QBUUser()
            print(GDP.qb_id)
            user.id = UInt(GDP.qb_id)!
            user.password = "darebux@123"

            QBChat.instance.connect(with: user, completion: { (error) in
                SVProgressHUD.dismiss()
                if error == nil
                {
                    self.get_all_users()
                }
                else
                {
                    self.alertType(type: .okAlert, alertMSG: "Unable to connect to server. Please check your internet connection or try restarting the app.", delegate: self)
                }
            })
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }

    func get_all_users()
    {
        if Reachability.isConnectedToNetwork()
        {
            SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
            arr_dialogs.removeAllObjects()

            let extendedRequest = ["sort_desc" : "_id"]
            let page = QBResponsePage(limit: 100, skip: 0)

            QBRequest.dialogs(for: page, extendedRequest: extendedRequest, successBlock: { (response: QBResponse, dialogs: [QBChatDialog]?, dialogsUsersIDs: Set<NSNumber>?, page: QBResponsePage?) -> Void in

                SVProgressHUD.dismiss()
                self.arr_dialogs.addObjects(from: dialogs!)
                print(self.arr_dialogs)

                if self.arr_dialogs.count == 0
                {
                    self.tbl_users.isHidden = true
                    self.lbl_msg.isHidden = false
                }
                else
                {
                    self.tbl_users.delegate = self
                    self.tbl_users.dataSource = self
                    self.tbl_users.reloadData()

                    self.tbl_users.isHidden = false
                    self.lbl_msg.isHidden = true
                }

            }) { (response: QBResponse) -> Void in
                SVProgressHUD.dismiss()
            }
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }

    //MARK:- Touch Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
}
