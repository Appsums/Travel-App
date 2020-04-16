//
//  ChatMessage_View.swift
//  Darebux
//
//  Created by logicspice on 15/02/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit

class ChatMessage_View: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, QBChatDelegate
{
    //MARK:- Outlets
    @IBOutlet var vw_header: UIView!
    @IBOutlet var vw_back: UIView!
    @IBOutlet var vw_receiverProfile: UIView!
    @IBOutlet var img_receiverProfile: UIImageView!
    @IBOutlet var lbl_username: UILabel!
    @IBOutlet var lbl_status_typing: UILabel!
    @IBOutlet var tbl_view_chat_msgs: UITableView!
    @IBOutlet var lbl_nomsg: UILabel!
    @IBOutlet var view_bottom_bar: UIView!
    @IBOutlet var img_btn_send: UIImageView!
    @IBOutlet var btn_send: UIButton!
    @IBOutlet var txt_view_message: UITextView!
    @IBOutlet var lbl_placeholder: UILabel!
    @IBOutlet var lbl_drag: UILabel!

    let GDP = GDP_Obj()
    let appdel = App_Delegate()

    let refreshControl = UIRefreshControl()
    var chat_dialog: QBChatDialog!
    var tmp_txtvw: UITextView!
    var arr_chat_msg = NSMutableArray()
    var typingTimer: Timer?

    var sender_id: NSNumber = 0;
    var receiver_id: NSNumber = 0;
    var total_msgs: NSInteger = 0
    var occBlobId: NSInteger = 0

    //MARK:- View Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        print(chat_dialog)
        QBChat.instance.addDelegate(self)

        QBRequest.user(withID: UInt(chat_dialog.recipientID), successBlock: { (response, user:QBUUser?) in

            self.img_receiverProfile.DownloadQBUserImage(occBlobID: (user?.blobID)!, userID: UInt(self.chat_dialog.recipientID), placeHolderImage: "user_Profile.png")

        }) { (response) in

            print("Error in get user \(response.error.debugDescription)")
        }

        if QBChat.instance.isConnected
        {
            tbl_view_chat_msgs.delegate = self
            tbl_view_chat_msgs.dataSource = self

            lbl_username.text = chat_dialog.name
            self.load_chat_messages()
            self.get_user_ids()
            self.check_user_typing()
        }
        else
        {
            QBSettings.autoReconnectEnabled = true
            SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)

            let user = QBUUser()
            user.id = UInt(GDP.qb_id)!
            user.password = "darebux@123"

            QBChat.instance.connect(with: user, completion: { (error) in
                self.tbl_view_chat_msgs.delegate = self
                self.tbl_view_chat_msgs.dataSource = self

                self.lbl_username.text = self.chat_dialog.name
                self.load_chat_messages()
                self.get_user_ids()
                self.check_user_typing()
            })
        }

        tbl_view_chat_msgs.register(UINib(nibName: "Message_Cell", bundle: nil), forCellReuseIdentifier: "cell")

        tbl_view_chat_msgs.addSubview(refreshControl)
        refreshControl.tintColor = app_color()
        refreshControl.addTarget(self, action: #selector(ChatMessage_View.refreshData(sender:)), for: .valueChanged)
        tbl_view_chat_msgs.alwaysBounceVertical = true
    }

    override func viewWillAppear(_ animated: Bool)
    {
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMessage_View.adjustViewForKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(ChatMessage_View.adjustViewForKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func viewDidLayoutSubviews()
    {
        GDP.adjustView(tmp_view: self.view)

        var tbl_frame = tbl_view_chat_msgs.frame
        tbl_frame.size.height = self.view.frame.size.height - (view_bottom_bar.frame.size.height + tbl_view_chat_msgs.frame.origin.y)
        tbl_view_chat_msgs.frame = tbl_frame

        let height = vw_header.frame.size.height - 8
        let width = lbl_username.frame.origin.x - (vw_back.frame.origin.x + vw_back.frame.size.width) - 18

        if height > width
        {
            vw_receiverProfile.frame = CGRect(x: (vw_back.frame.origin.x + vw_back.frame.size.width + 8), y: 4.0, width: width, height: width)
            vw_receiverProfile.layer.cornerRadius = width/2
        }
        else
        {
            vw_receiverProfile.frame = CGRect(x: (vw_back.frame.origin.x + vw_back.frame.size.width + 8), y: 4.0, width: height, height: height)
            vw_receiverProfile.layer.cornerRadius = height/2
        }

        vw_receiverProfile.layer.cornerRadius = vw_receiverProfile.frame.size.width/2
        vw_receiverProfile.clipsToBounds = true
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:- Other Methods
    @objc func refreshData(sender: UIRefreshControl)
    {
        refreshControl.endRefreshing()

        if arr_chat_msg.count < total_msgs
        {
            tbl_view_chat_msgs.delegate = nil
            tbl_view_chat_msgs.dataSource = nil
            self.load_chat_messages()
        }
        else
        {
            lbl_drag.isHidden = true
        }

    }

    @objc func adjustViewForKeyboardNotification(notification: NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            var bottomBarFrame = view_bottom_bar.frame
            bottomBarFrame.origin.y = keyboardSize.origin.y - bottomBarFrame.size.height - GDP.topSafeArea

            var tblFrame = tbl_view_chat_msgs.frame
            tblFrame.size.height = bottomBarFrame.origin.y - tblFrame.origin.y

            view_bottom_bar.frame = bottomBarFrame
            tbl_view_chat_msgs.frame = tblFrame

            scrolltable()
        }
    }

    func scrolltable()
    {
        let lastRow = tbl_view_chat_msgs.numberOfRows(inSection: 0) - 1
        let index = IndexPath.init(row: lastRow, section: 0)

        if lastRow > 0
        {
            tbl_view_chat_msgs.scrollToRow(at: index, at: UITableViewScrollPosition.top, animated: true)
        }
    }

    func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController?
    {
        if let navigationController = controller as? UINavigationController
        {
            return topViewController(controller: navigationController.visibleViewController)
        }

        if let presented = controller?.presentedViewController
        {
            return topViewController(controller: presented)
        }

        return controller
    }

    //MARK: - Table View Methods
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arr_chat_msg.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let tmptxt = UITextView(frame: CGRect(x: 0, y: 0, width: tbl_view_chat_msgs.frame.size.width - 90, height: 30))
        let tmp_msg = arr_chat_msg.object(at: indexPath.row) as! QBChatMessage
        tmptxt.font = UIFont.systemFont(ofSize: 14.0)
        tmptxt.text = tmp_msg.text
        tmptxt.layoutIfNeeded()
        tmptxt.sizeToFit()

        let height = tmptxt.frame.size.height
        if height > 45
        {
            return height + 18
        }
        else
        {
            return 45
        }

//        if UIDevice().userInterfaceIdiom == .pad
//        {
//            return 112
//        }
//        else
//        {
//            return 56
//        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell: Message_Cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Message_Cell

        let tmp_msg = arr_chat_msg.object(at: indexPath.row) as! QBChatMessage
        var dateString: String!

        if tmp_msg.dateSent == nil
        {
            dateString = NSDate.stringForDisplay(from: Date(), prefixed: false, alwaysDisplayTime: true)
        }
        else
        {
            dateString = NSDate.stringForDisplay(from: tmp_msg.dateSent, prefixed: false, alwaysDisplayTime: true)
        }

        cell.lbl_msg_sent_time.text = dateString
        cell.lbl_msg_receive_time.text = dateString

        if tmp_msg.senderID == currentUser().id
        {
            cell.message_view_receiver.isHidden = true;
            cell.message_view_sender.isHidden = false;
            cell.lbl_msg_sent_time.isHidden = false;

            cell.txt_view_sender.layer.cornerRadius = 5.0;
            cell.txt_view_sender.clipsToBounds = true;
            cell.txt_view_sender.text = tmp_msg.text;
            cell.txt_view_sender.layoutIfNeeded()
            cell.txt_view_sender.sizeToFit()

            let posX = cell.message_view_sender.frame.size.width - cell.txt_view_sender.frame.size.width
            var frame = cell.txt_view_sender.frame
            frame.origin.x = posX
            cell.txt_view_sender.frame = frame
        }
        else
        {
            cell.message_view_receiver.isHidden = false;
            cell.message_view_sender.isHidden = true;
            cell.lbl_msg_receive_time.isHidden = false;

            cell.txt_view_receiver.layer.cornerRadius = 5.0;
            cell.txt_view_receiver.clipsToBounds = true;
            cell.txt_view_receiver.text = tmp_msg.text;
            cell.txt_view_receiver.layoutIfNeeded()
            cell.txt_view_receiver.sizeToFit()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {

    }

    //MARK:- Table Scroll View Methods
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    {
        if tbl_view_chat_msgs.contentOffset.y > 0
        {
            lbl_drag.isHidden = true
        }
        else
        {
            if arr_chat_msg.count < total_msgs
            {
                lbl_drag.isHidden = false
            }
            else
            {
                lbl_drag.isHidden = true
            }
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        if tbl_view_chat_msgs.contentOffset.y > 0
        {
            lbl_drag.isHidden = true
        }
        else
        {
            if arr_chat_msg.count < total_msgs
            {
                lbl_drag.isHidden = false
            }
            else
            {
                lbl_drag.isHidden = true
            }
        }
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView)
    {
        if tbl_view_chat_msgs.contentOffset.y > 0
        {
            lbl_drag.isHidden = true
        }
        else
        {
            if arr_chat_msg.count < total_msgs
            {
                lbl_drag.isHidden = false
            }
            else
            {
                lbl_drag.isHidden = true
            }
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        if tbl_view_chat_msgs.contentOffset.y > 0
        {
            lbl_drag.isHidden = true
        }
        else
        {
            if arr_chat_msg.count < total_msgs
            {
                lbl_drag.isHidden = false
            }
            else
            {
                lbl_drag.isHidden = true
            }
        }
    }

    //MARK:- Quickblox Methods
    func currentUser() -> QBUUser
    {
        return QBSession.current.currentUser!
    }

    func get_user_ids()
    {
        let arr_ids = chat_dialog.occupantIDs
        if arr_ids![0] == NSNumber.init(value: NSInteger(GDP.qb_id)!)
        {
            sender_id = arr_ids![0]
            receiver_id = arr_ids![1]
        }
        else
        {
            sender_id = arr_ids![1]
            receiver_id = arr_ids![0]
        }
    }

    func is_user_sender(index: NSIndexPath)->Bool
    {
        if String(describing: (arr_chat_msg.object(at: index.row) as! NSArray).value(forKey: "senderID")) == GDP.qb_id
        {
            return true
        }
        else
        {
            return false
        }
    }

    func load_chat_messages()
    {
        if Reachability.isConnectedToNetwork()
        {
            let load_limit = 10 + arr_chat_msg.count
            lbl_drag.isHidden = true

            let extendedRequest = ["sort_desc" : "_id"]
            let page = QBResponsePage(limit: load_limit, skip: 0)

            SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
            arr_chat_msg = NSMutableArray()

            QBRequest.messages(withDialogID: chat_dialog.id!, extendedRequest: extendedRequest, for: page, successBlock: {(response: QBResponse, messages: [QBChatMessage]?, responcePage: QBResponsePage?) in

                self.arr_chat_msg.removeAllObjects()
                for arrayIndex in stride(from:(messages?.count)! - 1, through: 0, by: -1)
                {
                    self.arr_chat_msg.add(messages![arrayIndex])
                }

                if self.arr_chat_msg.count > 0
                {
                    self.lbl_nomsg.isHidden = true
                    self.tbl_view_chat_msgs.isHidden = false

                    self.tbl_view_chat_msgs.delegate = self
                    self.tbl_view_chat_msgs.dataSource = self
                    self.tbl_view_chat_msgs.reloadData()

                    self.scrolltable()

                    QBRequest.countOfMessages(forDialogID: self.chat_dialog.id!, extendedRequest: nil, successBlock: { (response: QBResponse, count: UInt) in
                        self.total_msgs = NSInteger(count)
                        SVProgressHUD.dismiss()

                    }, errorBlock: { (response: QBResponse) in
                        SVProgressHUD.dismiss()
                    })
                }

                else
                {
                    SVProgressHUD.dismiss()

                    self.tbl_view_chat_msgs.isHidden = true
                    self.lbl_nomsg.isHidden = false
                }

            }, errorBlock: {(response: QBResponse!) in
                SVProgressHUD.dismiss()
            })
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }

    func check_user_typing()
    {
        if chat_dialog.type == QBChatDialogType.private
        {
            chat_dialog.onUserIsTyping = {
                [weak self] (userID)-> Void in

                if QBChat.instance.currentUser?.id == userID
                {
                    return
                }

                self?.lbl_status_typing.text = "typing..."
            }

            chat_dialog.onUserStoppedTyping = {
                [weak self] (userID)-> Void in

                if QBChat.instance.currentUser?.id == userID
                {
                    return
                }

                self?.lbl_status_typing.text = ""
            }
        }

    }

    @objc func fireSendStopTypingIfNecessary() -> Void
    {
        if let timer = self.typingTimer
        {
            timer.invalidate()
        }

        self.typingTimer = nil
        self.chat_dialog.sendUserStoppedTyping()
    }

    func chatDidReceive(_ message: QBChatMessage)
    {
        if message.senderID == currentUser().id
        {
            print("the messages comes here from carbons")
        }

        let topview = topViewController()
        if (topview as? ChatMessage_View) != nil
        {
            QBChat.instance.read(message) { (error) in

                if error == nil
                {
                    print("receive message \(message)")
                    self.arr_chat_msg.add(message)
                    self.tbl_view_chat_msgs.reloadData()
                    self.scrolltable()
                }
            }
        }
    }

    func loadUserImage()
    {
        let appdel = App_Delegate()
        let occ_id = chat_dialog.recipientID

        DispatchQueue.global(qos: .background).async {
            QBRequest.user(withID: UInt(occ_id), successBlock: { (response, user) in

                let occ_blobId = user.blobID
                QBRequest.downloadFile(withID: UInt(occ_blobId), successBlock: { (response, data) in

                    self.img_receiverProfile.image = UIImage(data: data)

                }, statusBlock: { (request, status) in

                }, errorBlock: { (response) in

                })

            }) { (response) in

            }
        }
    }

    //MARK:- Text View Methods
    func textViewDidBeginEditing(_ textView: UITextView)
    {

    }

    func textViewDidEndEditing(_ textView: UITextView)
    {

    }

    func textViewDidChange(_ textView: UITextView)
    {
        let str_msg = txt_view_message.text!.trimmingCharacters(in: GDP.charSet)
        if str_msg.count == 0
        {
            lbl_placeholder.isHidden = false
            btn_send.isEnabled = false
            img_btn_send.alpha = 0.3
        }
        else
        {
            lbl_placeholder.isHidden = true
            btn_send.isEnabled = true
            img_btn_send.alpha = 1.0
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if !QBChat.instance.isConnected { return true }

        if let timer = self.typingTimer {
            timer.invalidate()
            self.typingTimer = nil

        } else {

            self.chat_dialog.sendUserIsTyping()
        }

        self.typingTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(ChatMessage_View.fireSendStopTypingIfNecessary), userInfo: nil, repeats: false)

        return true
    }


    //MARK:- Button Action Methods
    @IBAction func on_btnBack_click(_ sender: UIButton)
    {
        _ = appdel.appNav?.popViewController(animated: true)
    }

    @IBAction func on_btnSend_click(_ sender: UIButton)
    {
        self.view.endEditing(true)
        lbl_nomsg.isHidden = true

        if Reachability.isConnectedToNetwork()
        {
            let str_msg = txt_view_message.text!.trimmingCharacters(in: GDP.charSet)

            let message = QBChatMessage()
            message.deliveredIDs = chat_dialog.occupantIDs
            message.dialogID = chat_dialog.id
            message.text = str_msg

            arr_chat_msg.add(message)
            if tbl_view_chat_msgs.isHidden == true
            {
                tbl_view_chat_msgs.isHidden = false
            }

            tbl_view_chat_msgs.reloadData()

            txt_view_message.text = ""
            lbl_placeholder.isHidden = false
            lbl_nomsg.isEnabled = true
            btn_send.isEnabled = false
            img_btn_send.alpha = 0.3

            scrolltable()

            let param = NSMutableDictionary()
            param["save_to_history"] = true
            message.customParameters = param
            message.recipientID = UInt(self.chat_dialog.recipientID)

            self.chat_dialog.send(message, completionBlock: { (error:Error?) in
                if (error == nil)
                {
                    let qbevent = QBMEvent()
                    qbevent.notificationType = QBMNotificationType.push
                    qbevent.usersIDs = String(message.recipientID)

                    let customMsgParams = NSMutableDictionary()
                    customMsgParams["type"] = "QBNotification"
                    customMsgParams["senderid"] = message.senderID
                    customMsgParams["sendername"] = self.GDP.userFirstName
                    customMsgParams["message"] = message.text
                    customMsgParams["chatdiaid"] = self.chat_dialog.id

                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: customMsgParams, options: JSONSerialization.WritingOptions.prettyPrinted)

                        let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)

                        qbevent.message = jsonString

                        QBRequest.createEvent(qbevent, successBlock: { (response, arrevent: [QBMEvent]?) in

                        }, errorBlock: { (response) in

                            print("error in event")
                        })
                    } catch let error as NSError {
                        print(error)
                    }
                }
                else
                {
                    print("Error in send message \(String(describing: error?.localizedDescription))")
                }
            })
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
