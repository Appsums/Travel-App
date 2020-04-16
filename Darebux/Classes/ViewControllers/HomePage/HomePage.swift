//
//  HomePage.swift
//  Darebux
//
//  Created by LogicSpice on 30/01/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit
import CZPicker

class HomePage: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CZPickerViewDelegate, CZPickerViewDataSource, WebCommunicationClassDelegate
{
    //MARK:- Outlets
    @IBOutlet var btnMenu: UIButton!
    @IBOutlet var vw_header: UIView!
    @IBOutlet var vw_Search:UIView!
    @IBOutlet var txtSearch:UITextField!
    @IBOutlet var lbl_results: UILabel!
    @IBOutlet var tblList: UITableView!
    @IBOutlet var lbl_msg: UILabel!
    @IBOutlet var btn_retry: UIButton!
    @IBOutlet var vw_Profile:UIView!

    @IBOutlet var vw_filterOption: UIView!
    @IBOutlet var imgTrending:UIImageView!
    @IBOutlet var imgLatest:UIImageView!
    @IBOutlet var imgPopular:UIImageView!
    @IBOutlet var lblTrending:UILabel!
    @IBOutlet var lblLatest:UILabel!
    @IBOutlet var lblPopular:UILabel!

    //Filter View
    @IBOutlet var vw_filter:UIView!
    @IBOutlet var vw_innerFilter:UIView!
    @IBOutlet var btnApply:UIButton!

    //Report Message View
    @IBOutlet var vw_reportMsg: UIView!
    @IBOutlet var txtfld_category: UITextField!
    @IBOutlet var vw_subject: UIView!
    @IBOutlet var txtfld_subject: UITextField!
    @IBOutlet var vw_message: UIView!
    @IBOutlet var txtvw_msg: UITextView!

    let GDP = GDP_Obj()
    let appdel = App_Delegate()

    let refreshControl = UIRefreshControl()
    var arrList: NSArray!
    var str_sorting: String!

    var filterTable:UITableView!
    var arrFiltered = NSArray()
    var str_reportDareId: String!
    var str_selectedIds: String! = ""

    //MARK:- View Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tblList.register(UINib(nibName: "DashboardCell", bundle: nil), forCellReuseIdentifier: "cell")

        tblList.addSubview(refreshControl)
        refreshControl.tintColor = app_color()
        refreshControl.addTarget(self, action: #selector(HomePage.refreshData(sender:)), for: .valueChanged)

        setTabBarColor(strSelected: lblTrending.text!)
        str_sorting = "trending"
        
        if GDP.isBeforeLogin
        {
            vw_Profile.isHidden = true
        }

        //getAllDaresList()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        GDP.leftView.setRevealContrl(reveal: self)
        btnMenu.addTarget(GDP.leftView, action: #selector(CustomRevealController.btnLeftMenuActionCall), for: UIControlEvents.touchUpInside)

        if GDP.dic_notification == nil
        {
            getAllDaresList()
        }
        else
        {
            pushToNotificationView()
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        GDP.adjustView(tmp_view: self.view)
        
        vw_Search.layer.cornerRadius = vw_Search.bounds.size.height/2
        vw_innerFilter.layer.cornerRadius = 4
        btnApply.layer.cornerRadius = 4

        txtvw_msg.layer.borderWidth = 1.0
        txtvw_msg.layer.borderColor = UIColor.black.cgColor
        txtvw_msg.clipsToBounds = true
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Other Methods
    func setTabBarColor(strSelected:String)
    {
        let selectedColor = UIColor.black
        let unSelColor = UIColor(red: 173/255.0, green: 173/255.0, blue: 173/255.0, alpha: 1)
        
        if strSelected == lblTrending.text!
        {
            lblTrending.textColor = selectedColor
            imgTrending.changeImageColor(color: selectedColor)
            
            lblLatest.textColor = unSelColor
            imgLatest.changeImageColor(color: unSelColor)
            
            lblPopular.textColor = unSelColor
            imgPopular.changeImageColor(color: unSelColor)
        }
        else if strSelected == lblLatest.text!
        {
            lblLatest.textColor = selectedColor
            imgLatest.changeImageColor(color: selectedColor)
            
            lblTrending.textColor = unSelColor
            imgTrending.changeImageColor(color: unSelColor)
            
            lblPopular.textColor = unSelColor
            imgPopular.changeImageColor(color: unSelColor)
        }
        else
        {
            lblPopular.textColor = selectedColor
            imgPopular.changeImageColor(color: selectedColor)
            
            lblTrending.textColor = unSelColor
            imgTrending.changeImageColor(color: unSelColor)
            
            lblLatest.textColor = unSelColor
            imgLatest.changeImageColor(color: unSelColor)
        }
    }

    @objc func refreshData(sender: UIRefreshControl)
    {
        getAllDaresList()
        refreshControl.endRefreshing()
    }

    func shift_table_position()
    {
        if lbl_results.text == ""
        {
            var frame = tblList.frame
            frame.origin.y = vw_header.frame.origin.y + vw_header.frame.size.height
            frame.size.height = self.view.frame.size.height - (vw_header.frame.size.height + vw_filterOption.frame.size.height)
            tblList.frame = frame
        }
        else
        {
            var frame = tblList.frame
            frame.origin.y = lbl_results.frame.origin.y + lbl_results.frame.size.height
            frame.size.height = self.view.frame.size.height - (vw_header.frame.size.height + vw_filterOption.frame.size.height + lbl_results.frame.size.height)
            tblList.frame = frame
        }
    }
    
    func openFilterView()
    {
        vw_filter.frame = self.view.frame
        vw_filter.alpha = 0
        self.view.addSubview(vw_filter)
        UIView.animate(withDuration: 0.3) {
            self.vw_filter.alpha = 1
        }
    }
    
    func closeFilterView()
    {
        vw_filter.alpha = 1
        UIView.animate(withDuration: 0.3, animations: {
            self.vw_filter.alpha = 0
        }) { (finish) in
            self.vw_filter.removeFromSuperview()
        }
    }

    func pushToNotificationView()
    {
        let notification_type = "\(GDP.dic_notification.object(forKey: "type")!)"
        if notification_type == "create_dare"
        {
            let dare_id = "\(GDP.dic_notification.object(forKey: "dare_id")!)"
            let obj_view = DareDetailPage(nibName: "DareDetailPage", bundle: nil)
            obj_view.str_id = dare_id
            obj_view.shouldBack = true
            appdel.appNav?.pushViewController(obj_view, animated: true)
        }
        else if notification_type == "accept_dare"
        {
            let dare_id = "\(GDP.dic_notification.object(forKey: "dare_id")!)"
            let obj_view = DareDetailPage(nibName: "DareDetailPage", bundle: nil)
            obj_view.str_id = dare_id
            obj_view.shouldBack = true
            appdel.appNav?.pushViewController(obj_view, animated: true)
        }
        else if notification_type == "decline_dare"
        {
            let dare_id = "\(GDP.dic_notification.object(forKey: "dare_id")!)"
            let obj_view = DareDetailPage(nibName: "DareDetailPage", bundle: nil)
            obj_view.str_id = dare_id
            obj_view.shouldBack = true
            appdel.appNav?.pushViewController(obj_view, animated: true)
        }
        else if notification_type == "verify_response"
        {
            let dare_id = "\(GDP.dic_notification.object(forKey: "dare_id")!)"
            let obj_view = DareDetailPage(nibName: "DareDetailPage", bundle: nil)
            obj_view.str_id = dare_id
            obj_view.shouldBack = true
            appdel.appNav?.pushViewController(obj_view, animated: true)
        }
        else if notification_type == "upload_response_video"
        {
            let dare_id = "\(GDP.dic_notification.object(forKey: "dare_id")!)"
            let obj_view = DareDetailPage(nibName: "DareDetailPage", bundle: nil)
            obj_view.str_id = dare_id
            obj_view.shouldBack = true
            appdel.appNav?.pushViewController(obj_view, animated: true)
        }
        else if notification_type == "goal_amount_deadline_expired"
        {
            let dare_id = "\(GDP.dic_notification.object(forKey: "dare_id")!)"
            let obj_view = DareDetailPage(nibName: "DareDetailPage", bundle: nil)
            obj_view.str_id = dare_id
            obj_view.shouldBack = true
            appdel.appNav?.pushViewController(obj_view, animated: true)
        }
        else if notification_type == "response_deadline_reminder"
        {
            let dare_id = "\(GDP.dic_notification.object(forKey: "dare_id")!)"
            let obj_view = DareDetailPage(nibName: "DareDetailPage", bundle: nil)
            obj_view.str_id = dare_id
            obj_view.shouldBack = true
            appdel.appNav?.pushViewController(obj_view, animated: true)
        }

        GDP.dic_notification = nil
    }

    //MARK:- Text Field Methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField == txtSearch
        {
            var searchStr = ""
            var newString = ""
            var placesTableFrame: CGRect!

            searchStr = textField.text!
            newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string

            placesTableFrame = CGRect(x: tblList.frame.origin.x, y: vw_header.frame.origin.y + vw_header.frame.size.height + 1, width: tblList.frame.size.width, height: 140)

            if (string == "" && newString.count == 0)
            {
                filterTable.isHidden = true;
                searchStr = searchStr.substring(to: searchStr.index(before: searchStr.endIndex))
            }
            else
            {
                searchStr = searchStr.appending(string)
                if (searchStr.count == 1 && string != "")
                {
                    filterTable = UITableView(frame: placesTableFrame)
                    filterTable.register(UINib(nibName: "SerachCell", bundle: nil), forCellReuseIdentifier: "searchcell")
                    filterTable.isHidden = true;
                    filterTable.separatorStyle = .none
                    self.view.addSubview(filterTable)
                }

                let predicate = NSPredicate(format: "title contains[c] %@", newString)
                arrFiltered = arrList.filtered(using: predicate) as NSArray
                filterTable.delegate = self
                filterTable.dataSource = self
                filterTable.reloadData()

                filterTable.isHidden = false;
                print("filtered data \(arrFiltered)")

                if (searchStr == "" && newString.count == 0)
                {
                    filterTable.isHidden = true;
                    filterTable.removeFromSuperview()
                }
                else
                {
                    if (arrFiltered.count > 0)
                    {
                        filterTable.isHidden = false;
                        filterTable.reloadData()
                    }
                    else
                    {
                        filterTable.isHidden = true;
                    }
                }
            }
        }

        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if textField == txtSearch
        {
            if (filterTable != nil)
            {
                filterTable.delegate = nil
                filterTable.dataSource = nil
                filterTable.isHidden = true
            }
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        if textField == txtSearch
        {
            getAllDaresList()
        }

        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool
    {
        txtSearch.text = ""
        getAllDaresList()

        if (filterTable != nil)
        {
            filterTable.delegate = nil
            filterTable.dataSource = nil
            filterTable.removeFromSuperview()
        }

        return true
    }
    
    //MARK:- Button Click Method
    @IBAction func btn_CloseFilter_Click(_ sender: UIButton)
    {
        closeFilterView()
    }

    @IBAction func btn_Profile_Click(_ sender: UIButton)
    {
        var isExists = false
        var frontView:UIViewController?
        
        for viObj in (appdel.appNav?.viewControllers)!
        {
            if viObj is ProfilePage
            {
                isExists = true
                frontView = viObj
                break
            }
        }
        if isExists
        {
            _ = appdel.appNav?.popToViewController(frontView!, animated: false)
        }
        else
        {
            let obj_view = ProfilePage(nibName: "ProfilePage", bundle: nil)
            appdel.appNav?.pushViewController(obj_view, animated: true)
        }        
    }
    
    @IBAction func btn_Filter_Click(_ sender: UIButton)
    {
        openFilterView()
    }
    
    @IBAction func btn_Trending_Click(_ sender: UIButton)
    {
        setTabBarColor(strSelected: lblTrending.text!)
        str_sorting = "trending"
        getAllDaresList()
    }
    
    @IBAction func btn_Latest_Click(_ sender: UIButton)
    {
        setTabBarColor(strSelected: lblLatest.text!)
        str_sorting = ""
        getAllDaresList()
    }
    
    @IBAction func btn_Popular_Click(_ sender: UIButton)
    {
        setTabBarColor(strSelected: lblPopular.text!)
        str_sorting = "most_viewed"
        getAllDaresList()
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
        txtvw_msg.text = ""
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
                postReport(tmp_dareId: str_reportDareId, tmp_reportId: str_selectedIds)
            }
        }
        else
        {
            postReport(tmp_dareId: str_reportDareId, tmp_reportId: str_selectedIds)
        }
    }

    @IBAction func btn_Retry_Click(_ sender: UIButton)
    {
        getAllDaresList()
    }

    @objc func action_userBtn(_ sender: UIButton)
    {
        if GDP.userID == nil || GDP.userID == ""
        {
            appdel.showLoginAlert(controller: self)
        }
        else
        {
            let cell_index = sender.layer.value(forKey: "btnIndex") as! IndexPath
            let tmp_dic = arrList.object(at: cell_index.section) as! NSDictionary

            self.viewUserProfile(tmp_id: "\(tmp_dic.object(forKey: "user_id")!)")
        }
    }

    @objc func action_reportBtn(_ sender: UIButton)
    {
        let cell_index = sender.layer.value(forKey: "btnIndex") as! IndexPath
        let tmp_dic = arrList.object(at: cell_index.section) as! NSDictionary
        str_reportDareId = "\(tmp_dic.object(forKey: "id")!)"
        
        var frame = self.vw_message.frame
        frame.origin.y = self.vw_subject.frame.origin.y
        self.vw_message.frame = frame
        
        vw_reportMsg.frame = CGRect(x: 0, y: window_Height(), width: window_Width(), height: window_Height() - (self.GDP.topSafeArea + self.GDP.bottomSafeArea))
        self.view.addSubview(vw_reportMsg)

        UIView.animate(withDuration: 0.3)
        {
            self.vw_reportMsg.frame = CGRect(x: 0, y: 0, width: window_Width(), height: window_Height() - (self.GDP.topSafeArea + self.GDP.bottomSafeArea))
        }
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
        if tableView == tblList
        {
            return arrList.count
        }
        else
        {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == tblList
        {
            return 1
        }
        else
        {
            return arrFiltered.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if tableView == tblList
        {
            return 10
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let vi = UIView()
        vi.backgroundColor = UIColor.clear
        return vi
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == tblList
        {
            if UIDevice().userInterfaceIdiom == .pad
            {
                return 600
            }
            else
            {
                return 300
            }
        }

        else
        {
            if UIDevice().userInterfaceIdiom == .pad
            {
                return 88
            }
            else
            {
                return 44
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == tblList
        {
            let cell: DashboardCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DashboardCell

            let tmp_dic = arrList.object(at: indexPath.section) as! NSDictionary

            cell.img_dare.imageForUrlWithImage(baseUrl: dare_image_url(), urlString: "\(tmp_dic.object(forKey: "image")!)", placeHolderImage: "no_image.png")

            cell.img_user.imageForUrlWithImage(baseUrl: profile_image_url(), urlString: "\(tmp_dic.object(forKey: "profile_image")!)", placeHolderImage: "user_Profile.png")

            let posX = 2.0
            let posY = cell.lbl_title.frame.origin.y
            let height = cell.lbl_title.frame.size.height
            cell.img_user.frame = CGRect(x: CGFloat(posX), y: posY, width: height, height: height)
            cell.img_user.layer.cornerRadius = height/2

            cell.btn_img.frame = cell.img_user.frame

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

            cell.btn_img.addTarget(self, action: #selector(action_userBtn(_:)), for: .touchUpInside)
            cell.btn_img.layer.setValue(indexPath, forKey: "btnIndex")

            cell.btn_img.addTarget(self, action: #selector(action_userBtn(_:)), for: .touchUpInside)
            cell.btn_img.layer.setValue(indexPath, forKey: "btnIndex")

            cell.btn_report.addTarget(self, action: #selector(action_reportBtn(_:)), for: .touchUpInside)
            cell.btn_report.layer.setValue(indexPath, forKey: "btnIndex")

            if "\(tmp_dic.object(forKey: "user_id")!)" == GDP.userID || GDP.userID == nil
            {
                cell.vw_report.isHidden = true
            }
            else
            {
                cell.vw_report.isHidden = false
            }

            return cell
        }

        else
        {
            let cell:SerachCell = tableView.dequeueReusableCell(withIdentifier: "searchcell") as! SerachCell

            let dict = arrFiltered.object(at: indexPath.row) as! NSDictionary
            cell.lblText.text = "\(dict.object(forKey: "title")!)"
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView == tblList
        {
            let tmp_dic = arrList.object(at: indexPath.section) as! NSDictionary

            let obj_view = DareDetailPage(nibName: "DareDetailPage", bundle: nil)
            obj_view.str_id = "\(tmp_dic.object(forKey: "id")!)"
            obj_view.shouldBack = true
            appdel.appNav?.pushViewController(obj_view, animated: true)
        }
        else
        {
            self.view.endEditing(true)

            let cell = filterTable.cellForRow(at: indexPath) as! SerachCell
            txtSearch.text = cell.lblText.text!

            filterTable.delegate = nil
            filterTable.dataSource = nil
            filterTable.isHidden = true

            getAllDaresList()
        }
    }
    
    //MARK:- Touch Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }

    //MARK:- Web Service Methods
    func getAllDaresList()
    {
        self.view.endEditing(true)

        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self

            let tmp_dic: NSMutableDictionary = NSMutableDictionary()
            tmp_dic.setValue(txtSearch.text!, forKey: "keyword")
            tmp_dic.setValue(str_sorting, forKey: "sort")
            webclass.alldareList(dic_data: tmp_dic)
        }
        else
        {
            btn_retry.isHidden = false
            lbl_msg.isHidden = true
            tblList.isHidden = true
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
            tmp_dic.setValue(txtvw_msg.text!, forKey: "message")
            tmp_dic.setValue("dare", forKey: "type")
            webclass.sendReport(dic_data: tmp_dic)
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

            if (kAllDareList().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg = JSONDict.object(forKey: "response_msg") as! String

                if responseStatus == "success"
                {
                    if let responseArr = JSONDict.object(forKey: "response_data") as? NSArray
                    {
                        tblList.isHidden = false
                        btn_retry.isHidden = true

                        arrList = responseArr
                        if arrList.count > 0
                        {
                            if arrList.count == 1
                            {
                                if txtSearch.text == ""
                                {
                                    lbl_results.text = ""
                                }
                                else
                                {
                                    lbl_results.text = "1 result for \(txtSearch.text!)"
                                }
                            }
                            else
                            {
                                if txtSearch.text == ""
                                {
                                    lbl_results.text = ""
                                }
                                else
                                {
                                    lbl_results.text = "\(arrList.count) results for \(txtSearch.text!)"
                                }
                            }

                            lbl_msg.isHidden = true
                            tblList.delegate = self
                            tblList.dataSource = self
                            tblList.reloadData()

                            let indexPath = IndexPath(row: 0, section: 0)
                            self.tblList.scrollToRow(at: indexPath, at: .top, animated: true)
                        }
                        else
                        {
                            if txtSearch.text == ""
                            {
                                lbl_results.text = ""
                            }
                            else
                            {
                                lbl_results.text = "0 results for \(txtSearch.text!)"
                            }

                            tblList.isHidden = true
                            lbl_msg.isHidden = false
                        }

                        shift_table_position()
                    }
                }
                else
                {
                    tblList.isHidden = true
                    btn_retry.isHidden = false
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
                    txtvw_msg.text = ""
                    vw_reportMsg.removeFromSuperview()

                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
                else
                {
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }
        }
        catch let error as NSError
        {
            if (kAllDareList().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                tblList.isHidden = true
                btn_retry.isHidden = false
            }
            self.alertType(type: .okAlert, alertMSG: Invalid_ResMsg(), delegate: self)
            print("Error from backend \(error)")
        }
    }

    func dataDidFail (methodname : String , error : Error)
    {
        if (kAllDareList().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
        {
            tblList.isHidden = true
            btn_retry.isHidden = false
        }

        self.alertType(type: .okAlert, alertMSG: ServerErrorMsg(), delegate: self)
    }
}
