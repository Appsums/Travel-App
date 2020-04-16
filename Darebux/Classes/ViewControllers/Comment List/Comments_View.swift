//
//  Comments_View.swift
//  Darebux
//
//  Created by logicspice on 27/02/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit
import CZPicker

class Comments_View: UIViewController, UITableViewDelegate, UITableViewDataSource, CZPickerViewDelegate, CZPickerViewDataSource, WebCommunicationClassDelegate
{
    //MARK:- Outlets
    @IBOutlet var btn_retry: UIButton!
    @IBOutlet var tbl_comment: UITableView!
    @IBOutlet var lbl_msg: UILabel!

    @IBOutlet var vw_comment: UIView!
    @IBOutlet var txtvw_msg: UITextView!
    @IBOutlet var lbl_placeholder: UILabel!
    @IBOutlet var btn_post: UIButton!
    @IBOutlet var ic_send: UIImageView!

    //Report Message View
    @IBOutlet var vw_reportMsg: UIView!
    @IBOutlet var txtfld_category: UITextField!
    @IBOutlet var vw_subject: UIView!
    @IBOutlet var txtfld_subject: UITextField!
    @IBOutlet var vw_message: UIView!
    @IBOutlet var txtvw_comment: UITextView!

    let GDP = GDP_Obj()
    let appdel = App_Delegate()
    var font_size: CGFloat = 0.0

    let refreshControl = UIRefreshControl()
    var str_dareId: String!
    var str_commentId: String!
    var arr_comment = NSMutableArray()
    var str_currentDate: String!
    var str_selectedIds: String! = ""

    //MARK:- View Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        tbl_comment.register(UINib(nibName: "Comment_Cell", bundle: nil), forCellReuseIdentifier: "cell")

        tbl_comment.addSubview(refreshControl)
        refreshControl.tintColor = app_color()
        refreshControl.addTarget(self, action: #selector(Comments_View.refreshData(sender:)), for: .valueChanged)

        if UIDevice().userInterfaceIdiom == .pad
        {
            font_size = 18.0
        }
        else
        {
            font_size = 12.0
        }

        getCommentList()
    }

    override func viewDidLayoutSubviews()
    {
        GDP_Obj().adjustView(tmp_view: self.view)

        txtvw_comment.layer.borderWidth = 1.0
        txtvw_comment.layer.borderColor = UIColor.black.cgColor
        txtvw_comment.clipsToBounds = true
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
        getCommentList()
    }

    //MARK:- Picker View Methods
    func showPickerView()
    {
        self.view.endEditing(true)
        let arr_names = GDP.arr_reportCategory.value(forKey: "name") as? NSArray

        let picker = CZPickerView(headerTitle: "Report", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
        picker?.delegate = self
        picker?.dataSource = self
        picker?.needFooterView = true
        picker?.allowMultipleSelection = false
        picker?.headerBackgroundColor = app_color()
        picker?.confirmButtonBackgroundColor = app_color()
        if (arr_names?.contains("Abusive"))! && txtfld_category.text == ""
        {
            let arr_selected = NSMutableArray()
            let index = arr_names?.index(of: "Abusive")
            arr_selected.add(index!)
            picker?.setSelectedRows(arr_selected as! [Any])
        }

        picker?.show()
    }

    func numberOfRows(in pickerView: CZPickerView!) -> Int
    {
        return GDP.arr_reportCategory.count
    }

    func czpickerView(_ pickerView: CZPickerView!, titleForRow row: Int) -> String!
    {
        return (GDP.arr_reportCategory.object(at: row) as! NSDictionary).value(forKey: "name") as! String
    }

    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int)
    {
        str_selectedIds = "\((GDP.arr_reportCategory.object(at: row) as! NSDictionary).object(forKey: "id")!)"
        txtfld_category.text = "\((GDP.arr_reportCategory.object(at: row) as! NSDictionary).object(forKey: "name")!)"

        if txtfld_category.text!.contains("Other")
        {
            UIView.animate(withDuration: 0.2, animations: {
                var frame = self.vw_message.frame
                frame.origin.y = self.vw_subject.frame.origin.y + self.vw_subject.frame.size.height + 8
                self.vw_message.frame = frame
            })
        }
        else
        {
            UIView.animate(withDuration: 0.2, animations: {
                var frame = self.vw_message.frame
                frame.origin.y = self.vw_subject.frame.origin.y
                self.vw_message.frame = frame
            })

            txtfld_subject.text = ""
        }
    }

    func czpickerViewDidClickCancelButton(_ pickerView: CZPickerView!)
    {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    //MARK: - Table View Methods
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arr_comment.count
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 70
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell: Comment_Cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Comment_Cell

        let tmp_dic = arr_comment.object(at: indexPath.row) as! NSDictionary

        cell.img_profile.layer.cornerRadius = cell.img_profile.frame.size.height/2

        cell.img_profile.imageForUrlWithImage(baseUrl: profile_image_url(), urlString: "\(tmp_dic.object(forKey: "profile_image")!)", placeHolderImage: "user_Profile.png")

        cell.lbl_username.text = "\(tmp_dic.object(forKey: "username")!)"

        let comment = "\(tmp_dic.object(forKey: "comment")!)"
        cell.lbl_comment.text = comment.decodeEmoji

        let dateString = "\(tmp_dic.object(forKey: "created")!)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateObj = dateFormatter.date(from: dateString)
        let currentDate = dateFormatter.date(from: str_currentDate)!
        cell.lbl_date.text = "\(currentDate.offsetFrom(date: dateObj!)) ago"

        cell.btn_report.addTarget(self, action: #selector(action_reportBtn(_:)), for: .touchUpInside)
        cell.btn_report.layer.setValue(indexPath, forKey: "btnIndex")

        if GDP.userID == nil
        {
            cell.vw_report.isHidden = true
        }
        else
        {
            cell.vw_report.isHidden = false
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let tmp_dic = arr_comment.object(at: indexPath.row) as! NSDictionary
        if "\(tmp_dic.object(forKey: "username")!)" != "Anonymous"
        {
            if GDP.userID == nil || GDP.userID == ""
            {
                appdel.showLoginAlert(controller: self)
            }
            else
            {
                let user_id = "\(tmp_dic.object(forKey: "user_id")!)"
                self.viewUserProfile(tmp_id: user_id)
            }
        }
    }

    //MARK:- Button Click Method
    @IBAction func btn_Back_Click(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func on_btnCloseKeyboard_click(_ sender: UIButton)
    {
        self.view.endEditing(true)
    }

    @IBAction func on_btnCategory_click(_ sender: UIButton)
    {
        if GDP.arr_reportCategory == nil
        {
            getReportCategoryList()
        }
        else
        {
            showPickerView()
        }
    }

    @IBAction func on_btnCloseView_click(_ sender: UIButton)
    {
        txtfld_category.text = ""
        txtfld_subject.text = ""
        txtvw_comment.text = ""
        vw_reportMsg.removeFromSuperview()
    }

    @IBAction func on_btnSubmitReport_click(_ sender: UIButton)
    {
        if txtfld_category.text == ""
        {
            self.alertType(type: .okAlert, alertMSG: "Please select report category", delegate: self)
        }
        else if txtfld_category.text!.contains("Other") == true
        {
            if txtfld_subject.text!.trimmingCharacters(in: GDP.charSet).count == 0
            {
                self.alertType(type: .okAlert, alertMSG: "Please enter subject", delegate: self)
            }
            else
            {
                postReport(tmp_dareId: str_commentId, tmp_reportId: str_selectedIds)
            }
        }
        else
        {
            postReport(tmp_dareId: str_commentId, tmp_reportId: str_selectedIds)
        }
    }

    @IBAction func btn_Retry_Click(_ sender: UIButton)
    {
        getCommentList()
    }

    @objc func action_reportBtn(_ sender: UIButton)
    {
        let cell_index = sender.layer.value(forKey: "btnIndex") as! IndexPath
        let tmp_dic = arr_comment.object(at: cell_index.row) as! NSDictionary
        str_commentId = "\(tmp_dic.object(forKey: "id")!)"

        vw_reportMsg.frame = CGRect(x: 0, y: window_Height(), width: window_Width(), height: window_Height() - (self.GDP.topSafeArea + self.GDP.bottomSafeArea))
        self.view.addSubview(vw_reportMsg)
        
        var frame = self.vw_message.frame
        frame.origin.y = self.vw_subject.frame.origin.y
        self.vw_message.frame = frame

        UIView.animate(withDuration: 0.3)
        {
            self.vw_reportMsg.frame = CGRect(x: 0, y: 0, width: window_Width(), height: window_Height() - (self.GDP.topSafeArea + self.GDP.bottomSafeArea))
        }
    }

    //MARK:- Web Service Methods
    func getCommentList()
    {
        self.view.endEditing(true)
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self

            let tmp_dic: NSMutableDictionary = NSMutableDictionary()
            tmp_dic.setValue(str_dareId, forKey: "dare_id")
            webclass.commentsList(dic_data: tmp_dic)
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }

    func postMyComment()
    {
        self.view.endEditing(true)
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self

            let str_comment = txtvw_msg.text!.trimmingCharacters(in: GDP.charSet)

            let tmp_dic: NSMutableDictionary = NSMutableDictionary()
            tmp_dic.setValue(str_dareId, forKey: "dare_id")
            tmp_dic.setValue(str_comment, forKey: "comment")
            webclass.postComment(dic_data: tmp_dic)
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }

    func getReportCategoryList()
    {
        self.view.endEditing(true)
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self
            webclass.reportCategoryList()
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }

    func postReport(tmp_dareId: String, tmp_reportId: String)
    {
        self.view.endEditing(true)
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self

            let tmp_dic: NSMutableDictionary = NSMutableDictionary()
            tmp_dic.setValue(tmp_dareId, forKey: "dare_id")
            tmp_dic.setValue(tmp_reportId, forKey: "category_id")
            tmp_dic.setValue(txtfld_subject.text!, forKey: "subject")
            tmp_dic.setValue(txtvw_comment.text!, forKey: "message")
            tmp_dic.setValue("comment", forKey: "type")
            webclass.sendReport(dic_data: tmp_dic)
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }

    func viewUserProfile(tmp_id: String)
    {
        self.view.endEditing(true)
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self

            let tmp_dic: NSMutableDictionary = NSMutableDictionary()
            tmp_dic.setValue(tmp_id, forKey: "user_id")
            webclass.otheruserProfile(dic_data: tmp_dic)
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }

    func dataDidFinishDowloading(aResponse: AnyObject?, methodname: String)
    {
        do {
            let JSONDict = try JSONSerialization.jsonObject(with: aResponse as! Data, options: []) as! NSDictionary
            print("Server Response: \(JSONDict)")

            if (kcommentList().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg = JSONDict.object(forKey: "response_msg") as! String

                if responseStatus == "success"
                {
                    if let responseDic = JSONDict.object(forKey: "response_data") as? NSDictionary
                    {
                        btn_retry.isHidden = true

                        arr_comment.removeAllObjects()
                        let arr = responseDic.object(forKey: "comment_list") as! NSArray
                        arr_comment.addObjects(from: arr as! [Any])

                        if arr_comment.count > 0
                        {
                            str_currentDate = "\(responseDic.object(forKey: "current_date")!)"

                            tbl_comment.isHidden = false
                            lbl_msg.isHidden = true

                            tbl_comment.delegate = self
                            tbl_comment.dataSource = self
                            tbl_comment.reloadData()
                        }
                        else
                        {
                            tbl_comment.isHidden = true
                            lbl_msg.isHidden = false
                        }
                    }
                }
                else
                {
                    btn_retry.isHidden = false
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }

            else if (kpostComment().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg = JSONDict.object(forKey: "response_msg") as! String

                if responseStatus == "success"
                {
                    txtvw_msg.text = ""

                    lbl_placeholder.isHidden = false
                    btn_post.isEnabled = false
                    ic_send.alpha = 0.3
                }
                else
                {
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }

            else if (kReportCategoryList().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg    = JSONDict.object(forKey: "response_msg") as! String

                if responseStatus == "success"
                {
                    if let responseArr = JSONDict.object(forKey: "response_data") as? NSArray
                    {
                        GDP.arr_reportCategory = responseArr
                        showPickerView()
                    }
                }
                else
                {
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }

            else if (kReport().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg = JSONDict.object(forKey: "response_msg") as! String

                if responseStatus == "success"
                {
                    txtfld_category.text = ""
                    txtfld_subject.text = ""
                    txtvw_comment.text = ""
                    vw_reportMsg.removeFromSuperview()
                    
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
                else
                {
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }

            else if (kOtherUserProfile().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg    = JSONDict.object(forKey: "response_msg") as! String

                if responseStatus == "success"
                {
                    if let responseDict    = JSONDict.object(forKey: "response_data") as? NSDictionary
                    {
                        let obj_view = ProfilePage(nibName: "ProfilePage", bundle: nil)
                        obj_view.dictUserData = responseDict
                        appdel.appNav?.pushViewController(obj_view, animated: true)
                    }
                }
                else
                {
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }
        }
        catch let error as NSError
        {
            if (kcommentList().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                btn_retry.isHidden = false
            }

            self.alertType(type: .okAlert, alertMSG: Invalid_ResMsg(), delegate: self)
            print("Error from backend \(error)")
        }
    }

    func dataDidFail (methodname : String , error : Error)
    {
        if (kcommentList().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
        {
            btn_retry.isHidden = false
        }

        self.alertType(type: .okAlert, alertMSG: ServerErrorMsg(), delegate: self)
    }
}

extension String
{
    var encodeEmoji: String
    {
        if let encodeStr = NSString(cString: self.cString(using: .nonLossyASCII)!, encoding: String.Encoding.utf8.rawValue)
        {
            return encodeStr as String
        }

        return self
    }
}

extension String
{
    var decodeEmoji: String
    {
        let data = self.data(using: String.Encoding.utf8);
        let decodedStr = NSString(data: data!, encoding: String.Encoding.nonLossyASCII.rawValue)
        if let str = decodedStr
        {
            return str as String
        }

        return self
    }
}
