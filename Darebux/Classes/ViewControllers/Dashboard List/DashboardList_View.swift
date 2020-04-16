//
//  DashboardList_View.swift
//  Darebux
//
//  Created by logicspice on 22/02/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit

class DashboardList_View: UIViewController, UITableViewDelegate, UITableViewDataSource, WebCommunicationClassDelegate
{
    //MARK:- Outlets
    @IBOutlet var lbl_title: UILabel!
    @IBOutlet var tbl_list: UITableView!
    @IBOutlet var lbl_msg: UILabel!
    @IBOutlet var btnRetry: UIButton!

    let GDP = GDP_Obj()
    let appdel = App_Delegate()

    let refreshControl = UIRefreshControl()
    var str_title: String!
    var arr_data: NSArray!

    //MARK:- View Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        lbl_title.text = str_title
        tbl_list.register(UINib(nibName: "Invite_Cell", bundle: nil), forCellReuseIdentifier: "cell")

        tbl_list.addSubview(refreshControl)
        refreshControl.tintColor = app_color()
        refreshControl.addTarget(self, action: #selector(DashboardList_View.refreshData(sender:)), for: .valueChanged)
    }

    override func viewDidLayoutSubviews()
    {
        GDP.adjustView(tmp_view: self.view)
    }

    override func viewWillAppear(_ animated: Bool)
    {
        if str_title == "My Invitations"
        {
            lbl_msg.text = "No pending invitations"
            getInvitationList()
        }
        else if str_title == "Sent Dares"
        {
            lbl_msg.text = "No dares sent"
            getSentList()
        }
        else if str_title == "My Contribution"
        {
            lbl_msg.text = "No pending invitations"
        }
        else
        {
            lbl_msg.text = "No pending invitations"
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:- Other Methods
    @objc func refreshData(sender: UIRefreshControl)
    {
        if str_title == "My Invitations"
        {
            getInvitationList()
        }
        else if str_title == "Sent Dares"
        {
            getSentList()
        }

        refreshControl.endRefreshing()
    }

    //MARK: - Table View Methods
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return arr_data.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 4
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let vi = UIView()
        vi.backgroundColor = UIColor.init(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0)
        return vi
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let tmp_dic = arr_data.object(at: indexPath.section) as! NSDictionary

        let cell: Invite_Cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Invite_Cell

        cell.img_user.layer.cornerRadius = cell.img_user.frame.size.height/2

        if str_title == "My Invitations"
        {
            cell.lbl_status.isHidden = false
            cell.img_user.imageForUrlWithImage(baseUrl: profile_image_url(), urlString: "\(tmp_dic.object(forKey: "profile_image")!)", placeHolderImage: "user_Profile.png")

            let str_username = "\(tmp_dic.object(forKey: "user_name")!)"
            if str_username.trimmingCharacters(in: GDP.charSet).count == 0
            {
                cell.lbl_username.text = "User N/A"
            }
            else
            {
                cell.lbl_username.text = str_username
            }

            cell.lbl_daretitle.text = "\(tmp_dic.object(forKey: "title")!)"

            let tmp_status = "\(tmp_dic.object(forKey: "status")!)"
            if tmp_status == PENDING
            {
                cell.lbl_upload.isHidden = true
                cell.lbl_status.text = "PENDING"
                cell.lbl_status.textColor = UIColor.black
            }
            else if tmp_status == ACCEPTED || tmp_status == REPORTED
            {
                if "\(tmp_dic.object(forKey: "is_goal_reached")!)" == "1"
                {
                    cell.lbl_upload.isHidden = false

                    let remain_days = "\(tmp_dic.object(forKey: "video_uploading_remaining_days")!)"

                    if remain_days == "0" || remain_days == ""
                    {
                        cell.lbl_upload.text = "dare expired, response video not uploaded within 14 days"
                    }
                    else
                    {
                        cell.lbl_upload.text = "\(remain_days) days left to upload response video"
                    }
                }
                else
                {
                    cell.lbl_upload.isHidden = true
                }

                cell.lbl_status.text = "ACCEPTED"
                cell.lbl_status.textColor = app_color()
            }
            else if tmp_status == CANCELLED
            {
                cell.lbl_upload.isHidden = true
                cell.lbl_status.text = "CANCELLED"
                cell.lbl_status.textColor = UIColor.red

                if "\(tmp_dic.object(forKey: "is_goal_reached")!)" == "1"
                {
                    cell.lbl_upload.isHidden = false

                    let remain_days = "\(tmp_dic.object(forKey: "video_uploading_remaining_days")!)"

                    if remain_days == "0" || remain_days == ""
                    {
                        cell.lbl_upload.text = "dare expired, response video not uploaded within 14 days"
                    }
                    else
                    {
                        cell.lbl_upload.text = "\(remain_days) days left to upload response video"
                    }
                }
                else
                {
                    cell.lbl_upload.isHidden = true
                }
            }
            else if tmp_status == COMPLETED
            {
                cell.lbl_upload.isHidden = true
                cell.lbl_status.text = "COMPLETED"
                cell.lbl_status.textColor = app_color()
            }
            else if tmp_status == DECLINED
            {
                cell.lbl_upload.isHidden = true
                cell.lbl_status.text = "REJECTED"
                cell.lbl_status.textColor = UIColor.red
            }
            else if tmp_status == NOT_ACTIVE
            {
                cell.lbl_upload.isHidden = true
                cell.lbl_status.text = "INACTIVE"
                cell.lbl_status.textColor = UIColor.red
            }
            else if tmp_status == REFUNDED
            {
                cell.lbl_upload.isHidden = true
                cell.lbl_status.text = "REFUNDED"
                cell.lbl_status.textColor = UIColor.red
            }
        }
        else
        {
            cell.lbl_status.isHidden = false
            cell.img_user.imageForUrlWithImage(baseUrl: profile_image_url(), urlString: "\(tmp_dic.object(forKey: "rec_image")!)", placeHolderImage: "user_Profile.png")

            let str_username = "\(tmp_dic.object(forKey: "rec_username")!)"
            if str_username.trimmingCharacters(in: GDP.charSet).count == 0
            {
                cell.lbl_username.text = "User N/A"
            }
            else
            {
                cell.lbl_username.text = str_username
            }

            cell.lbl_daretitle.text = "\(tmp_dic.object(forKey: "title")!)"

            let tmp_status = "\(tmp_dic.object(forKey: "status")!)"
            if tmp_status == PENDING
            {
                cell.lbl_upload.isHidden = true
                cell.lbl_status.text = "PENDING"
                cell.lbl_status.textColor = UIColor.black
            }
            else if tmp_status == ACCEPTED || tmp_status == REPORTED
            {
                if "\(tmp_dic.object(forKey: "can_verify")!)" == "1"
                {
                    cell.lbl_upload.isHidden = false
                    cell.lbl_upload.text = "Verify Response Video"
                }
                else
                {
                    cell.lbl_upload.isHidden = true
                }

                cell.lbl_status.text = "ACCEPTED"
                cell.lbl_status.textColor = app_color()
            }
            else if tmp_status == CANCELLED
            {
                cell.lbl_upload.isHidden = true
                cell.lbl_status.text = "CANCELLED"
                cell.lbl_status.textColor = UIColor.red
            }
            else if tmp_status == COMPLETED
            {
                cell.lbl_upload.isHidden = true
                cell.lbl_status.text = "COMPLETED"
                cell.lbl_status.textColor = app_color()
            }
            else if tmp_status == DECLINED
            {
                cell.lbl_upload.isHidden = true
                cell.lbl_status.text = "REJECTED"
                cell.lbl_status.textColor = UIColor.red
            }
            else if tmp_status == NOT_ACTIVE
            {
                cell.lbl_upload.isHidden = true
                cell.lbl_status.text = "INACTIVE"
                cell.lbl_status.textColor = UIColor.red
            }
            else if tmp_status == REFUNDED
            {
                cell.lbl_upload.isHidden = true
                cell.lbl_status.text = "REFUNDED"
                cell.lbl_status.textColor = UIColor.red
            }
        }

        cell.lbl_date.text = GDP.changeDateFormate(tmp_string: "\(tmp_dic.object(forKey: "created")!)", cur_formate: "yyyy-MM-dd HH:mm:ss", new_formate: "dd MMM yyyy")

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let tmp_dic = arr_data.object(at: indexPath.section) as! NSDictionary

        let obj_view = DareDetailPage(nibName: "DareDetailPage", bundle: nil)
        obj_view.str_id = "\(tmp_dic.object(forKey: "id")!)"
        obj_view.shouldBack = true
        appdel.appNav?.pushViewController(obj_view, animated: true)
    }

    //MARK:- Button Action Methods
    @IBAction func on_btnBack_click(_ sender: UIButton)
    {
        appdel.appNav.popViewController(animated: true)
    }

    @IBAction func on_btnRetry_click(_ sender: UIButton)
    {
        if str_title == "My Invitations"
        {
            getInvitationList()
        }
        else if str_title == "Sent Dares"
        {
            getSentList()
        }
        else if str_title == "My Contribution"
        {

        }
        else
        {

        }
    }

    //MARK:- Web Services Methods
    func getInvitationList()
    {
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self
            webclass.inviteDareList()
        }
        else
        {
            tbl_list.isHidden = true
            lbl_msg.isHidden = true
            btnRetry.isHidden = false

            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }

    func getSentList()
    {
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self
            webclass.sentDareList()
        }
        else
        {
            tbl_list.isHidden = true
            lbl_msg.isHidden = true
            btnRetry.isHidden = false

            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }

    func dataDidFinishDowloading(aResponse: AnyObject?, methodname: String)
    {
        do {
            let JSONDict = try JSONSerialization.jsonObject(with: aResponse as! Data, options: []) as! NSDictionary
            print("Server Response: \(JSONDict)")

            if (kInviteList().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg = JSONDict.object(forKey: "response_msg") as! String

                if responseStatus == "success"
                {
                    btnRetry.isHidden = true

                    if let responseArr = JSONDict.object(forKey: "response_data") as? NSArray
                    {
                        arr_data = responseArr
                        if arr_data.count > 0
                        {
                            tbl_list.isHidden = false
                            lbl_msg.isHidden = true

                            tbl_list.delegate = self
                            tbl_list.dataSource = self
                            tbl_list.reloadData()
                        }
                        else
                        {
                            tbl_list.isHidden = true
                            lbl_msg.isHidden = false
                        }
                    }
                }
                else
                {
                    tbl_list.isHidden = true
                    lbl_msg.isHidden = true
                    btnRetry.isHidden = false

                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }

            else if (kSentList().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg = JSONDict.object(forKey: "response_msg") as! String

                if responseStatus == "success"
                {
                    btnRetry.isHidden = true

                    if let responseArr = JSONDict.object(forKey: "response_data") as? NSArray
                    {
                        arr_data = responseArr
                        if arr_data.count > 0
                        {
                            tbl_list.isHidden = false
                            lbl_msg.isHidden = true

                            tbl_list.delegate = self
                            tbl_list.dataSource = self
                            tbl_list.reloadData()
                        }
                        else
                        {
                            tbl_list.isHidden = true
                            lbl_msg.isHidden = false
                        }
                    }
                }
                else
                {
                    tbl_list.isHidden = true
                    lbl_msg.isHidden = true
                    btnRetry.isHidden = false

                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }
        }
        catch let error as NSError
        {
            tbl_list.isHidden = true
            lbl_msg.isHidden = true
            btnRetry.isHidden = false

            self.alertType(type: .okAlert, alertMSG: Invalid_ResMsg(), delegate: self)
            print("Error from backend \(error)")
        }
    }

    func dataDidFail (methodname : String , error : Error)
    {
        tbl_list.isHidden = true
        lbl_msg.isHidden = true
        btnRetry.isHidden = false

        self.alertType(type: .okAlert, alertMSG: ServerErrorMsg(), delegate: self)
    }
}
