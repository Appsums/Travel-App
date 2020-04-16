//
//  MyDares_View.swift
//  Darebux
//
//  Created by logicspice on 07/02/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit

class MyDares_View: UIViewController, UITableViewDelegate, UITableViewDataSource, WebCommunicationClassDelegate, alertClassDelegate
{
    //MARK:- Outlets
    @IBOutlet var seg_dare: UISegmentedControl!
    @IBOutlet var tbl_dares: UITableView!
    @IBOutlet var lbl_msg: UILabel!
    @IBOutlet var btn_retry: UIButton!

    let GDP = GDP_Obj()
    let appdel = App_Delegate()

    let refreshControl = UIRefreshControl()
    var arr_dares: NSArray!
    var arr_pending: NSArray!
    var arr_unverified: NSArray!
    var arr_completed: NSArray!

    //MARK:- View Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        tbl_dares.register(UINib(nibName: "DashboardCell", bundle: nil), forCellReuseIdentifier: "cell")

        tbl_dares.addSubview(refreshControl)
        refreshControl.tintColor = app_color()
        refreshControl.addTarget(self, action: #selector(MyDares_View.refreshData(sender:)), for: .valueChanged)

        getMyDaresList()
    }

    override func viewDidLayoutSubviews()
    {
        GDP_Obj().adjustView(tmp_view: self.view)
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

    //MARK: - Table View Methods
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if seg_dare.selectedSegmentIndex == 0
        {
            return arr_pending.count
        }
        else if seg_dare.selectedSegmentIndex == 1
        {
            return arr_unverified.count
        }
        else
        {
            return arr_completed.count
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if UIDevice().userInterfaceIdiom == .pad
        {
            return 500
        }
        else
        {
            return 300
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell: DashboardCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DashboardCell

        let tmp_dic: NSDictionary!

        if seg_dare.selectedSegmentIndex == 0
        {
            tmp_dic = arr_pending.object(at: indexPath.section) as! NSDictionary
        }
        else if seg_dare.selectedSegmentIndex == 1
        {
            tmp_dic = arr_unverified.object(at: indexPath.section) as! NSDictionary
        }
        else
        {
            tmp_dic = arr_completed.object(at: indexPath.section) as! NSDictionary
        }

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

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let tmp_dic: NSDictionary!

        if seg_dare.selectedSegmentIndex == 0
        {
            tmp_dic = arr_pending.object(at: indexPath.section) as! NSDictionary
        }
        else if seg_dare.selectedSegmentIndex == 1
        {
            tmp_dic = arr_unverified.object(at: indexPath.section) as! NSDictionary
        }
        else
        {
            tmp_dic = arr_completed.object(at: indexPath.section) as! NSDictionary
        }

        let obj_view = DareDetailPage(nibName: "DareDetailPage", bundle: nil)
        obj_view.str_id = "\(tmp_dic.object(forKey: "id")!)"
        obj_view.shouldBack = false
        appdel.appNav?.pushViewController(obj_view, animated: true)
    }

    //MARK:- Button Action Methods
    @IBAction func on_btnBack_click(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func on_segBtn_click(_ sender: UISegmentedControl)
    {
        if sender.selectedSegmentIndex == 0
        {
            if arr_pending.count > 0
            {
                lbl_msg.isHidden = true
                tbl_dares.isHidden = false

                tbl_dares.delegate = self
                tbl_dares.dataSource = self
                tbl_dares.reloadData()

                let indexPath = IndexPath(row: 0, section: 0)
                self.tbl_dares.scrollToRow(at: indexPath, at: .top, animated: true)
            }
            else
            {
                tbl_dares.isHidden = true
                lbl_msg.isHidden = false
            }
        }
        else if sender.selectedSegmentIndex == 1
        {
            if arr_unverified.count > 0
            {
                lbl_msg.isHidden = true
                tbl_dares.isHidden = false

                tbl_dares.delegate = self
                tbl_dares.dataSource = self
                tbl_dares.reloadData()

                let indexPath = IndexPath(row: 0, section: 0)
                self.tbl_dares.scrollToRow(at: indexPath, at: .top, animated: true)
            }
            else
            {
                tbl_dares.isHidden = true
                lbl_msg.isHidden = false
            }
        }
        else
        {
            if arr_completed.count > 0
            {
                lbl_msg.isHidden = true
                tbl_dares.isHidden = false

                tbl_dares.delegate = self
                tbl_dares.dataSource = self
                tbl_dares.reloadData()

                let indexPath = IndexPath(row: 0, section: 0)
                self.tbl_dares.scrollToRow(at: indexPath, at: .top, animated: true)
            }
            else
            {
                tbl_dares.isHidden = true
                lbl_msg.isHidden = false
            }
        }
    }


    @IBAction func on_btnRetry_click(_ sender: UIButton)
    {
        getMyDaresList()
    }

    //MARK:- Web Service Methods
    func getMyDaresList()
    {
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self

            let tmp_dic: NSMutableDictionary = NSMutableDictionary()
            tmp_dic.setValue("", forKey: "sort")
            tmp_dic.setValue("", forKey: "user_id")

            webclass.myDareList(dic_data: tmp_dic, isShowProgress: true)
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

            if (kMyDares().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg = JSONDict.object(forKey: "response_msg") as! String

                if responseStatus == "success"
                {
                    if let responseArr = JSONDict.object(forKey: "response_data") as? NSArray
                    {
                        tbl_dares.isHidden = false
                        btn_retry.isHidden = true

                        arr_dares = responseArr
                        if arr_dares.count > 0
                        {
                            let predicate_1 = NSPredicate(format: "response_status = 0")
                            let predicate_2 = NSPredicate(format: "response_status = 1")
                            let predicate_3 = NSPredicate(format: "response_status = 2")

                            arr_pending = arr_dares.filtered(using: predicate_1) as NSArray
                            arr_unverified = arr_dares.filtered(using: predicate_2) as NSArray
                            arr_completed = arr_dares.filtered(using: predicate_3) as NSArray

                            if arr_pending.count > 0 && seg_dare.selectedSegmentIndex == 0
                            {
                                lbl_msg.isHidden = true

                                tbl_dares.delegate = self
                                tbl_dares.dataSource = self
                                tbl_dares.reloadData()
                            }
                            else if arr_unverified.count > 0 && seg_dare.selectedSegmentIndex == 1
                            {
                                lbl_msg.isHidden = true

                                tbl_dares.delegate = self
                                tbl_dares.dataSource = self
                                tbl_dares.reloadData()
                            }
                            else if arr_completed.count > 0 && seg_dare.selectedSegmentIndex == 2
                            {
                                lbl_msg.isHidden = true

                                tbl_dares.delegate = self
                                tbl_dares.dataSource = self
                                tbl_dares.reloadData()
                            }
                            else
                            {
                                tbl_dares.isHidden = true
                                lbl_msg.isHidden = false
                            }
                        }
                        else
                        {
                            tbl_dares.isHidden = true
                            lbl_msg.isHidden = false
                        }
                    }
                }
                else
                {
                    tbl_dares.isHidden = true
                    btn_retry.isHidden = false
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }
        }
        catch let error as NSError
        {
            tbl_dares.isHidden = true
            btn_retry.isHidden = false
            self.alertType(type: .okAlert, alertMSG: Invalid_ResMsg(), delegate: self)
            print("Error from backend \(error)")
        }
    }

    func dataDidFail (methodname : String , error : Error)
    {
        tbl_dares.isHidden = true
        btn_retry.isHidden = false
        self.alertType(type: .okAlert, alertMSG: ServerErrorMsg(), delegate: self)
    }
}

extension Date
{
    func offsetFrom(date: Date) -> String
    {
        let dayHourMinuteSecond: Set<Calendar.Component> = [.day, .hour, .minute, .second]
        let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: date, to: self);

        let seconds = "\(difference.second ?? 0) seconds"
        let minutes = "\(difference.minute ?? 0) minutes"
        let hours = "\(difference.hour ?? 0) hours"
        let days = "\(difference.day ?? 0) days"

        if let day = difference.day, day          > 0 { return days }
        if let hour = difference.hour, hour       > 0 { return hours }
        if let minute = difference.minute, minute > 0 { return minutes }
        if let second = difference.second, second > 0 { return seconds }
        return ""
    }
}
