//
//  ProfilePage.swift
//  Darebux
//
//  Created by LogicSpice on 25/01/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit

class ProfilePage: UIViewController, UITableViewDelegate, UITableViewDataSource, WebCommunicationClassDelegate
{
    @IBOutlet var lblLogoText: UIImageView!
    @IBOutlet var btnMenu:UIButton!
    @IBOutlet var imgHeart:UIImageView!
    @IBOutlet var lblHeartCount:UILabel!
    @IBOutlet var lblMiddleLine: UILabel!
    @IBOutlet var imgBackView:UIView!
    @IBOutlet var lbl_joinDate: UILabel!
    @IBOutlet var imgUser:UIImageView!
    @IBOutlet var lblName:UILabel!
    @IBOutlet var lblAboutme:UILabel!
    @IBOutlet var lblAddress:UILabel!
    
    @IBOutlet var lblFollowersCount:UILabel!
    @IBOutlet var lblFollowingCount:UILabel!
    @IBOutlet var lblDaresCount:UILabel!
    
    @IBOutlet var vw_dareMe: UIView!
    @IBOutlet var vw_dareFriend: UIView!
    @IBOutlet var ic_following: UIImageView!
    @IBOutlet var lbl_follow: UILabel!

    @IBOutlet var lblNoList:UILabel!
    @IBOutlet var tblFollowList: UITableView!
    @IBOutlet var vw_follower:UIView!
    @IBOutlet var vw_following:UIView!
    @IBOutlet var vw_dares:UIView!
    @IBOutlet var activity: UIActivityIndicatorView!

    @IBOutlet var vw_back: UIView!
    @IBOutlet var vw_like: UIView!
    @IBOutlet var vw_edit: UIView!
    
    @IBOutlet var vw_Retry:UIView!
    @IBOutlet var btnRetry:UIButton!
    
    @IBOutlet var vwtbl_dares: UIView!
    @IBOutlet var vw_sort: UIView!
    @IBOutlet var tbl_dares: UITableView!
    
    let refreshControl = UIRefreshControl()
    var arr_dares: NSArray!
    
    let GDP = GDP_Obj()
    let appdel = App_Delegate()

    var str_userid: String!
    
    var dictUserData: NSDictionary!
    var current_list: Int = 1
    var arr_followData: NSArray!

    var arr_sort: NSArray!
    var str_sortString: String! = "All Dares"
    var str_sort: String! = ""

    //MARK:- View Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()

        tblFollowList.register(UINib(nibName: "FollowerCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        tbl_dares.register(UINib(nibName: "MyDaresCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        tbl_dares.addSubview(refreshControl)
        refreshControl.tintColor = app_color()
        refreshControl.addTarget(self, action: #selector(refreshData(sender:)), for: .valueChanged)

        arr_sort = ["All Dares", "Created", "Pending", "Accepted", "Declined", "Completed"]
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        GDP.leftView.setRevealContrl(reveal: self)
        btnMenu.addTarget(GDP.leftView, action: #selector(CustomRevealController.btnLeftMenuActionCall), for: UIControlEvents.touchUpInside)

        if dictUserData == nil
        {
            vw_Retry.isHidden = false
            viewProfile()
        }
        else
        {
            vw_Retry.isHidden = true
            setUserData()
        }

        if GDP.shouldReloadData == true
        {
            GDP.shouldReloadData = false
            viewProfile()
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        GDP.adjustView(tmp_view: self.view)

        let xorigin = lblMiddleLine.frame.origin.x
        
        let imageHeight = lblName.frame.origin.y - (lblLogoText.frame.origin.y+lblLogoText.frame.size.height) - 20 - 5
        
        var viFrame = imgBackView.frame
        viFrame.origin.x = xorigin - imageHeight/2
        viFrame.origin.y = lblLogoText.frame.origin.y + lblLogoText.frame.size.height + 20
        viFrame.size.height = imageHeight
        viFrame.size.width = imageHeight
        imgBackView.frame = viFrame
        
        imgBackView.layer.cornerRadius = imgBackView.bounds.size.width/2
        imgBackView.layer.borderWidth =  5
        imgBackView.layer.borderColor = UIColor.darkGray.cgColor
        
        var lblSize = imgHeart.bounds.size.height - 5
        if imgHeart.bounds.size.width < imgHeart.bounds.size.height
        {
            lblSize = imgHeart.bounds.size.width - 5
        }
        
        var heartFrame = lblHeartCount.frame
        heartFrame.origin.y = imgHeart.frame.origin.y - 10
        heartFrame.origin.x = imgHeart.frame.origin.x + imgHeart.frame.size.width/2 + 2
        heartFrame.size.width = lblSize
        heartFrame.size.height = lblSize
        lblHeartCount.frame = heartFrame
        
        lblHeartCount.layer.cornerRadius = lblHeartCount.bounds.size.height/2
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:- Other Methods
    @objc func refreshData(sender: UIRefreshControl)
    {
        getMyDaresList()
        refreshControl.endRefreshing()
    }
    
    func setUserData()
    {
        if "\(dictUserData.object(forKey: "user_id")!)" == GDP.userID
        {
            vw_dareMe.isHidden = false
            vw_dareFriend.isHidden = true
            vw_back.isHidden = true
            vw_edit.isHidden = false
            vw_like.isHidden = true
        }
        else
        {
            vw_dareMe.isHidden = true
            vw_dareFriend.isHidden = false
            vw_back.isHidden = false
            vw_edit.isHidden = true
            vw_like.isHidden = true

            if "\(dictUserData.object(forKey: "is_following")!)" == "0"
            {
                ic_following.image = UIImage(named: "follow.png")
                lbl_follow.text = "Follow"
            }
            else
            {
                ic_following.image = UIImage(named: "ic_following.png")
                lbl_follow.text = "Following"
            }
        }
        
        if let str_img = dictUserData.object(forKey: "profile_image") as? String
        {
            imgUser.imageForUrlWithImage(baseUrl: profile_image_url(), urlString: str_img, placeHolderImage: "user_Profile.png")
        }

        lblName.text = "\(dictUserData.object(forKey: "username")!)"
        lbl_joinDate.text = "Joined on: \(GDP.changeDateFormate(tmp_string: "\(dictUserData.object(forKey: "created")!)", cur_formate: "yyyy-MM-dd HH:mm:ss", new_formate: "MMM dd, yyyy"))"
        lblAddress.text = "\(dictUserData.object(forKey: "city")!), \(dictUserData.object(forKey: "country")!)"
        lblAboutme.text = "\(dictUserData.object(forKey: "about_me")!)"
        
        lblFollowersCount.text = "\(dictUserData.object(forKey: "follower_count")!)"
        lblFollowingCount.text = "\(dictUserData.object(forKey: "following_count")!)"
        lblDaresCount.text = "\(dictUserData.object(forKey: "dare_me_count")!)"

        if current_list == 1
        {
            myFollowerList()
        }
    }
    
    //MARK:- Button Click methods
    @IBAction func btn_Retry_Click(_ sender: UIButton)
    {
        viewProfile()
    }

    @IBAction func btn_Back_Click(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func btn_EditProfile_Click(_ sender: UIButton)
    {
        let obj_view = EditProfilePage(nibName: "EditProfilePage", bundle: nil)
        obj_view.dictUserData = dictUserData
        appdel.appNav?.pushViewController(obj_view, animated: true)
    }
    
    @IBAction func btn_Notification_Click(_ sender: UIButton)
    {
        
    }

    @IBAction func btn_Follow_Click(_ sender: UIButton)
    {
        if lbl_follow.text == "Follow"
        {
            follow_unfollow_user(tmp_userId: "\(dictUserData.object(forKey: "user_id")!)", tmp_status: "follow")
        }
        else
        {
            follow_unfollow_user(tmp_userId: "\(dictUserData.object(forKey: "user_id")!)", tmp_status: "unfollow")
        }
    }

    @IBAction func btn_Chat_Click(_ sender: UIButton)
    {
        if Reachability.isConnectedToNetwork()
        {
            SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
            let occupant_id = Int("\(dictUserData.object(forKey: "quickblox_id")!)")!
            let new_dialog = QBChatDialog(dialogID: nil, type: .private)
            new_dialog.occupantIDs = [NSNumber.init(value: occupant_id)]
            new_dialog.userID = UInt(GDP.qb_id)!

            QBRequest.createDialog(new_dialog, successBlock: {(response: QBResponse?, createdDialog: QBChatDialog?) in

                SVProgressHUD.dismiss()

                let obj_view = ChatMessage_View(nibName: "ChatMessage_View", bundle: nil)
                obj_view.chat_dialog = createdDialog
                self.appdel.appNav?.pushViewController(obj_view, animated: true)

            }, errorBlock: {(response: QBResponse!) in

                SVProgressHUD.dismiss()
                self.alertType(type: .okAlert, alertMSG: "Unable to initiate chat. Try again later", delegate: self)
            })
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }

    @IBAction func btn_DareMe_Click(_ sender: UIButton)
    {
        let obj_view = CreateDarePage(nibName: "CreateDarePage", bundle: nil)
        obj_view.str_userID = "\(dictUserData.object(forKey: "user_id")!)"
        obj_view.str_receiverName = "\(dictUserData.object(forKey: "username")!)"
        appdel.appNav?.pushViewController(obj_view, animated: true)
    }

    @IBAction func btn_Followers_Click(_ sender: UIButton)
    {
        vw_follower.backgroundColor = UIColor(red: 28/255.0, green: 143/255.0, blue: 38/255.0, alpha: 1)
        vw_following.backgroundColor = UIColor(red: 34/255.0, green: 165/255.0, blue: 46/255.0, alpha: 1)
        vw_dares.backgroundColor = UIColor(red: 34/255.0, green: 165/255.0, blue: 46/255.0, alpha: 1)

        activity.startAnimating()
        activity.isHidden = false
        lblNoList.isHidden = true
        tblFollowList.isHidden = true
        vwtbl_dares.isHidden = true
        vw_sort.isHidden = true

        current_list = 1
        myFollowerList()
    }
    
    @IBAction func btn_Following_Click(_ sender: UIButton)
    {
        vw_following.backgroundColor = UIColor(red: 28/255.0, green: 143/255.0, blue: 38/255.0, alpha: 1)
        vw_follower.backgroundColor = UIColor(red: 34/255.0, green: 165/255.0, blue: 46/255.0, alpha: 1)
        vw_dares.backgroundColor = UIColor(red: 34/255.0, green: 165/255.0, blue: 46/255.0, alpha: 1)

        activity.startAnimating()
        activity.isHidden = false
        lblNoList.isHidden = true
        tblFollowList.isHidden = true
        vwtbl_dares.isHidden = true
        vw_sort.isHidden = true

        current_list = 2
        myFollowingList()
    }
    
    @IBAction func btn_Dares_Click(_ sender: UIButton)
    {
        vw_dares.backgroundColor = UIColor(red: 28/255.0, green: 143/255.0, blue: 38/255.0, alpha: 1)
        vw_following.backgroundColor = UIColor(red: 34/255.0, green: 165/255.0, blue: 46/255.0, alpha: 1)
        vw_follower.backgroundColor = UIColor(red: 34/255.0, green: 165/255.0, blue: 46/255.0, alpha: 1)

        lblNoList.text = "No dares!"
        str_sortString = "All Dares"
        str_sort = "all"

        activity.startAnimating()
        activity.isHidden = false
        lblNoList.isHidden = true
        tblFollowList.isHidden = true
        vwtbl_dares.isHidden = true
        vw_sort.isHidden = false
        
        current_list = 3

        if lblDaresCount.text == "0"
        {
            activity.stopAnimating()
            lblNoList.isHidden = false
            lblNoList.text = "No dares!"
        }
        else
        {
            activity.startAnimating()
            activity.isHidden = false
            lblNoList.isHidden = true
            tblFollowList.isHidden = true
            vwtbl_dares.isHidden = true

            getMyDaresList()
        }
    }

    @IBAction func on_btnSort_click(_ sender: UIButton)
    {
        var index = 0
        if (str_sortString.isEmpty) == false
        {
            index = arr_sort.index(of: str_sortString)
        }

        ActionSheetStringPicker.show(withTitle: "Sort By", rows: arr_sort as! [Any]!, initialSelection: index, doneBlock: {
            picker, indexes, values in

            if indexes == 0
            {
                self.str_sort = "all"
            }
            else if indexes == 1
            {
                self.str_sort = "created"
            }
            else if indexes == 2
            {
                self.str_sort = "pending"
            }
            else if indexes == 3
            {
                self.str_sort = "accepted"
            }
            else if indexes == 4
            {
                self.str_sort = "declined"
            }
            else if indexes == 5
            {
                self.str_sort = "completed"
            }

            self.str_sortString = values as? String
            self.getMyDaresList()

            return

        }, cancel: {ActionStringCancelBlock in
            return
        }, origin: sender)
    }

    @objc func action_tableFollow(_ sender: UIButton)
    {
        let cell_index = sender.layer.value(forKey: "btnIndex") as! IndexPath
        let tmp_dic = arr_followData.object(at: cell_index.row) as! NSDictionary
        var tmp_status: String = ""

        if current_list == 1
        {
            if "\(tmp_dic.object(forKey: "is_following")!)" == "0"
            {
                tmp_status = "follow"
            }
            else
            {
                tmp_status = "unfollow"
            }
        }

        else if current_list == 2
        {
            tmp_status = "unfollow"
        }

        self.follow_unfollow_user(tmp_userId: "\(tmp_dic.object(forKey: "friend_id")!)", tmp_status: tmp_status)
    }
    
    //MARK: - UITableView Delegate method
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if tableView == tbl_dares
        {
            return arr_dares.count
        }

        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == tbl_dares
        {
            return 1
        }

        return arr_followData.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == tbl_dares
        {
            if UIDevice().userInterfaceIdiom == .pad
            {
                return 399
            }
            else
            {
                return 266
            }
        }
        else
        {
            if UIDevice().userInterfaceIdiom == .pad
            {
                return 120
            }
            else
            {
                return 60
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let vi = UIView()
        vi.backgroundColor = UIColor.clear
        return vi
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == tblFollowList
        {
            let cell: FollowerCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FollowerCell
            
            let tmp_dic = arr_followData.object(at: indexPath.row) as! NSDictionary
            
            let imageWidth = cell.lblName.frame.origin.x
            var viFrame = cell.imgUser.frame
            var maxHeight: CGFloat = 60
            var tmp_pos: CGFloat = 50
            if UIDevice().userInterfaceIdiom == .pad
            {
                maxHeight = 120
                tmp_pos = 100
            }
            
            if imageWidth < tmp_pos
            {
                let tmp:CGFloat = maxHeight/2 - (imageWidth)/2
                viFrame.origin.x = 5
                viFrame.origin.y = tmp
                viFrame.size.height = imageWidth
                viFrame.size.width = imageWidth
            }
            else
            {
                viFrame.origin.x = imageWidth/2 - tmp_pos/2
                viFrame.origin.y = (maxHeight - tmp_pos)/2
                viFrame.size.height = tmp_pos
                viFrame.size.width = tmp_pos
            }
            
            cell.imgUser.frame = viFrame
            cell.imgUser.layer.cornerRadius = cell.imgUser.bounds.size.width/2
            
            if let str_img = tmp_dic.object(forKey: "profile_image") as? String
            {
                cell.imgUser.imageForUrlWithImage(baseUrl: profile_image_url(), urlString: str_img, placeHolderImage: "user_Profile.png")
            }
            
            cell.lblName.text = "\(tmp_dic.object(forKey: "username")!)"
            
            let str_address = "\(tmp_dic.object(forKey: "address")!)"
            if str_address.trimmingCharacters(in: NSCharacterSet.init(charactersIn: ", ") as CharacterSet) == ""
            {
                cell.lblAddress.text = ""
            }
            else
            {
                cell.lblAddress.text = str_address
            }
            
            if current_list == 1
            {
                if "\(tmp_dic.object(forKey: "friend_id")!)" == GDP.userID
                {
                    cell.vw_Follow.isHidden = true
                }
                else
                {
                    cell.vw_Follow.isHidden = false
                    
                    if "\(tmp_dic.object(forKey: "is_following")!)" == "0"
                    {
                        cell.lbl_CellFollow.text = "Follow"
                        cell.btn_CellFollow.addTarget(self, action: #selector(action_tableFollow(_:)), for: .touchUpInside)
                        cell.btn_CellFollow.layer.setValue(indexPath, forKey: "btnIndex")
                    }
                    else
                    {
                        cell.lbl_CellFollow.text = "Unfollow"
                        cell.btn_CellFollow.addTarget(self, action: #selector(action_tableFollow(_:)), for: .touchUpInside)
                        cell.btn_CellFollow.layer.setValue(indexPath, forKey: "btnIndex")
                    }
                }
            }
            else if current_list == 2
            {
                if "\(tmp_dic.object(forKey: "friend_id")!)" == GDP.userID
                {
                    cell.vw_Follow.isHidden = true
                }
                else
                {
                    cell.vw_Follow.isHidden = false
                    
                    if "\(tmp_dic.object(forKey: "is_following")!)" == "0"
                    {
                        cell.lbl_CellFollow.text = "Follow"
                        cell.btn_CellFollow.addTarget(self, action: #selector(action_tableFollow(_:)), for: .touchUpInside)
                        cell.btn_CellFollow.layer.setValue(indexPath, forKey: "btnIndex")
                    }
                    else
                    {
                        cell.lbl_CellFollow.text = "Unfollow"
                        cell.btn_CellFollow.addTarget(self, action: #selector(action_tableFollow(_:)), for: .touchUpInside)
                        cell.btn_CellFollow.layer.setValue(indexPath, forKey: "btnIndex")
                    }
                }
            }
            
            return cell
        }
        else
        {
            let cell: MyDaresCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyDaresCell
            
            let tmp_dic = arr_dares.object(at: indexPath.section) as! NSDictionary
            
            cell.img_dare.imageForUrlWithImage(baseUrl: dare_image_url(), urlString: "\(tmp_dic.object(forKey: "image")!)", placeHolderImage: "no_image.png")
            
            cell.img_user.imageForUrlWithImage(baseUrl: profile_image_url(), urlString: "\(tmp_dic.object(forKey: "profile_image")!)", placeHolderImage: "user_Profile.png")
            
            let posX = 2.0
            let posY = cell.lbl_title.frame.origin.y
            let height = cell.lbl_title.frame.size.height
            cell.img_user.frame = CGRect(x: CGFloat(posX), y: posY, width: height, height: height)
            cell.img_user.layer.cornerRadius = height/2
            
            cell.lbl_title.text = "\(tmp_dic.object(forKey: "title")!)"
            cell.lbl_amount.text = "$\(tmp_dic.object(forKey: "raised_amount")!)/$\(tmp_dic.object(forKey: "goal_amount")!)"
            cell.lbl_username.text = "\(tmp_dic.object(forKey: "user_name")!)"
            cell.lbl_views.text = "\(tmp_dic.object(forKey: "view_count")!) views"
            
            let dateString = "\(tmp_dic.object(forKey: "created")!)"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateObj = dateFormatter.date(from: dateString)
            let currentDate = dateFormatter.date(from: "\(tmp_dic.object(forKey: "current_date")!)")!
            cell.lbl_time.text = "\(currentDate.offsetFrom(date: dateObj!)) ago"
            
            let amount_raised = Float("\(tmp_dic.object(forKey: "raised_amount")!)")!
            let amount_goal = Float("\(tmp_dic.object(forKey: "goal_amount")!)")!
            cell.goal_bar.progress = CGFloat(amount_raised/amount_goal)

            let dare_status = "\(tmp_dic.object(forKey: "dare_status")!)"
            if dare_status == "created"
            {
                cell.lbl_Status.backgroundColor = UIColor(red: 60.0/255.0, green: 120.0/255.0, blue: 216.0/255.0, alpha: 1)
                cell.lbl_Status.text = "Created"
            }
            else if dare_status == "pending"
            {
                cell.lbl_Status.backgroundColor = UIColor(red: 102.0/255.0, green: 102.0/255.0, blue: 102.0/255.0, alpha: 1)
                cell.lbl_Status.text = "Pending"
            }
            else if dare_status == "accepted"
            {
                cell.lbl_Status.backgroundColor = UIColor(red: 106.0/255.0, green: 168.0/255.0, blue: 79.0/255.0, alpha: 1)
                cell.lbl_Status.text = "Accepted"
            }
            else if dare_status == "declined"
            {
                cell.lbl_Status.backgroundColor = UIColor(red: 236.0/255.0, green: 43.0/255.0, blue: 0.0/255.0, alpha: 1)
                cell.lbl_Status.text = "Declined"
            }
            else if dare_status == "completed"
            {
                cell.lbl_Status.backgroundColor = UIColor(red: 106.0/255.0, green: 168.0/255.0, blue: 79.0/255.0, alpha: 1)
                cell.lbl_Status.text = "Completed"
            }
            else if dare_status == "cancelled"
            {
                cell.lbl_Status.backgroundColor = UIColor(red: 236.0/255.0, green: 43.0/255.0, blue: 0.0/255.0, alpha: 1)
                cell.lbl_Status.text = "Cancelled"
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView == tblFollowList
        {
            let tmp_dic = arr_followData.object(at: indexPath.row) as! NSDictionary
            let str_id = "\(tmp_dic.object(forKey: "friend_id")!)"
            
            viewUserProfile(tmp_id: str_id)
        }
        else
        {
            let tmp_dic = arr_dares.object(at: indexPath.section) as! NSDictionary
                        
            let obj_view = DareDetailPage(nibName: "DareDetailPage", bundle: nil)
            obj_view.str_id = "\(tmp_dic.object(forKey: "id")!)"
            obj_view.shouldBack = true
            appdel.appNav?.pushViewController(obj_view, animated: true)
        }
    }
    
    //MARK:- Web Services methods
    func viewProfile()
    {
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self
            webclass.viewProfile()
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

    func follow_unfollow_user(tmp_userId: String, tmp_status: String)
    {
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self

            let tmp_dic: NSMutableDictionary = NSMutableDictionary()
            tmp_dic.setValue(tmp_userId, forKey: "friend_id")
            tmp_dic.setValue(tmp_status, forKey: "status")
            webclass.follow_unfollow(dic_data: tmp_dic)
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }

    func myFollowingList()
    {
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self

            let tmp_dic: NSMutableDictionary = NSMutableDictionary()
            let str_otherUserId = "\(dictUserData.object(forKey: "user_id")!)"

            if str_otherUserId == GDP.userID
            {
                tmp_dic.setValue("", forKey: "otheruser_id")
            }
            else
            {
                tmp_dic.setValue(str_otherUserId, forKey: "otheruser_id")
            }

            webclass.followingList(dic_data: tmp_dic)
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }

    func myFollowerList()
    {
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self

            let tmp_dic: NSMutableDictionary = NSMutableDictionary()
            let str_otherUserId = "\(dictUserData.object(forKey: "user_id")!)"

            if str_otherUserId == GDP.userID
            {
                tmp_dic.setValue("", forKey: "otheruser_id")
            }
            else
            {
                tmp_dic.setValue(str_otherUserId, forKey: "otheruser_id")
            }

            webclass.followerList(dic_data: tmp_dic)
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }
    
    func getMyDaresList()
    {
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self

            var str_userId: String!
            if "\(dictUserData.object(forKey: "user_id")!)" == GDP.userID
            {
                str_userId = ""
            }
            else
            {
                str_userId = "\(dictUserData.object(forKey: "user_id")!)"
            }

            let tmp_dic: NSMutableDictionary = NSMutableDictionary()
            tmp_dic.setValue(str_sort, forKey: "sort")
            tmp_dic.setValue(str_userId, forKey: "user_id")
            webclass.myDareList(dic_data: tmp_dic, isShowProgress: false)
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }
    
    //MARK:- Web Services delegate methods
    func dataDidFinishDowloading(aResponse: AnyObject?, methodname: String)
    {
        do {
            let JSONDict = try JSONSerialization.jsonObject(with: aResponse as! Data, options: []) as! NSDictionary
            print("Server Response: \(JSONDict)")
            
            if (kUserViewProfile().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg    = JSONDict.object(forKey: "response_msg") as! String
                
                if responseStatus == "success"
                {
                    vw_Retry.isHidden = true
                    if let responseDict    = JSONDict.object(forKey: "response_data") as? NSDictionary
                    {
                        dictUserData = responseDict
                        UserDefaults.standard.set(responseDict.object(forKey: "first_name"), forKey: "first_name")
                        UserDefaults.standard.set(responseDict.object(forKey: "last_name"), forKey: "last_name")
                        UserDefaults.standard.set(responseDict.object(forKey: "profile_image"), forKey: "profile_image")
                        
                        GDP.userFirstName = "\(responseDict.object(forKey: "first_name")!)"

                        setUserData()
                    }
                }
                else
                {
                    vw_Retry.isHidden = false
                    btnRetry.isHidden = false
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }

            else if (kFollowUnfollowUser().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg    = JSONDict.object(forKey: "response_msg") as! String

                if responseStatus == "success"
                {
                    if lbl_follow.text == "Following"
                    {
                        ic_following.image = UIImage(named: "follow.png")
                        lbl_follow.text = "Follow"
                    }
                    else
                    {
                        ic_following.image = UIImage(named: "ic_following.png")
                        lbl_follow.text = "Following"
                    }

                    if current_list == 1
                    {
                        myFollowerList()
                    }
                    else if current_list == 2
                    {
                        myFollowingList()
                    }
                }
                else
                {
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }

            else if (kFollowingList().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg    = JSONDict.object(forKey: "response_msg") as! String

                if responseStatus == "success"
                {
                    if let responseDic = JSONDict.object(forKey: "response_data") as? NSDictionary
                    {
                        arr_followData = responseDic.object(forKey: "following_listing") as! NSArray
                        activity.stopAnimating()

                        lblFollowingCount.text = "\(responseDic.object(forKey: "following_count")!)"
                        lblFollowersCount.text = "\(responseDic.object(forKey: "follower_count")!)"

                        if arr_followData.count > 0
                        {
                            lblNoList.isHidden = true
                            tblFollowList.isHidden = false

                            tblFollowList.delegate = self
                            tblFollowList.dataSource = self
                            tblFollowList.reloadData()
                        }
                        else
                        {
                            lblNoList.text = "No following!"
                            lblNoList.isHidden = false
                            tblFollowList.isHidden = true
                        }
                    }
                }
                else
                {
                    lbl_follow.isHidden = true
                    tblFollowList.isHidden = true

                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }

            else if (kFollowerList().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg    = JSONDict.object(forKey: "response_msg") as! String

                if responseStatus == "success"
                {
                    if let responseDic = JSONDict.object(forKey: "response_data") as? NSDictionary
                    {
                        arr_followData = responseDic.object(forKey: "follower_listing") as! NSArray
                        activity.stopAnimating()

                        lblFollowingCount.text = "\(responseDic.object(forKey: "following_count")!)"
                        lblFollowersCount.text = "\(responseDic.object(forKey: "follower_count")!)"

                        if arr_followData.count > 0
                        {
                            lblNoList.isHidden = true
                            tblFollowList.isHidden = false

                            tblFollowList.delegate = self
                            tblFollowList.dataSource = self
                            tblFollowList.reloadData()
                        }
                        else
                        {
                            lblNoList.text = "No followers!"
                            lblNoList.isHidden = false
                            tblFollowList.isHidden = true
                        }
                    }
                }
                else
                {
                    lbl_follow.isHidden = true
                    tblFollowList.isHidden = true

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
            else if (kMyDares().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg = JSONDict.object(forKey: "response_msg") as! String
                
                if responseStatus == "success"
                {
                    activity.stopAnimating()
                    
                    if let responseArr = JSONDict.object(forKey: "response_data") as? NSArray
                    {
                        btnRetry.isHidden = true
                        activity.stopAnimating()

                        arr_dares = responseArr
                        if arr_dares.count > 0
                        {
                            vwtbl_dares.isHidden = false
                            lblNoList.isHidden = true

                            tbl_dares.delegate = self
                            tbl_dares.dataSource = self
                            tbl_dares.reloadData()
                        }
                        else
                        {
                            lblNoList.isHidden = false
                            vwtbl_dares.isHidden = true
                        }
                    }
                }
                else
                {
                    vwtbl_dares.isHidden = true
                    btnRetry.isHidden = false
                    lblNoList.isHidden = true
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }
        }
        catch let error as NSError
        {
            if (kUserViewProfile().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                vw_Retry.isHidden = false
                btnRetry.isHidden = false
            }
            else
            {
                activity.stopAnimating()
            }
            self.alertType(type: .okAlert, alertMSG: Invalid_ResMsg(), delegate: self)
            print("Error from backend \(error)")
        }
    }
    
    func dataDidFail (methodname : String , error : Error)
    {
        if (kUserViewProfile().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
        {
            vw_Retry.isHidden = false
            btnRetry.isHidden = false
        }
        else
        {
            activity.stopAnimating()
        }
        self.alertType(type: .okAlert, alertMSG: ServerErrorMsg(), delegate: self)
    }
}
