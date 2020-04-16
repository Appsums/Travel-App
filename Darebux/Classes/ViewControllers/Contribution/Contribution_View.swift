//
//  Contribution_View.swift
//  Darebux
//
//  Created by logicspice on 17/03/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit

class Contribution_View: UIViewController, UITableViewDelegate, UITableViewDataSource, WebCommunicationClassDelegate
{
    //MARK:- Outlets
    @IBOutlet var vw_Retry:UIView!
    @IBOutlet var btnRetry:UIButton!

    @IBOutlet var lbl_count: UILabel!
    @IBOutlet var lbl_amount: UILabel!
    @IBOutlet var tblList: UITableView!
    @IBOutlet var lbl_msg: UILabel!

    let GDP = GDP_Obj()
    let appdel = App_Delegate()
    var arr_data: NSArray!

    //MARK:- View Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        tblList.register(UINib(nibName: "Contributor_Cell", bundle: nil), forCellReuseIdentifier: "cell")

        getContributionList()
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

    //MARK: - Table View Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arr_data.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if UIDevice().userInterfaceIdiom == .pad
        {
            return 90
        }
        else
        {
            return 60
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell: Contributor_Cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Contributor_Cell

        let tmp_dic = arr_data.object(at: indexPath.row) as! NSDictionary

        cell.img_profile.imageForUrlWithImage(baseUrl: profile_image_url(), urlString: "\(tmp_dic.object(forKey: "profile_image")!)", placeHolderImage: "user_Profile.png")

        let posX = 4.0
        let posY = 7.0
        let width = cell.lbl_username.frame.origin.x - 8
        let height = cell.contentView.frame.size.height - 14

        if width > height
        {
            cell.img_profile.frame = CGRect(x: CGFloat(posX), y: CGFloat(posY), width: height, height: height)
            cell.img_profile.layer.cornerRadius = height/2
        }
        else
        {
            cell.img_profile.frame = CGRect(x: CGFloat(posX), y: CGFloat(posY), width: width, height: width)
            cell.img_profile.layer.cornerRadius = width/2
        }

        cell.lbl_username.text = "\(tmp_dic.object(forKey: "user_name")!)"
        cell.lbl_title.text = "\(tmp_dic.object(forKey: "dare_title")!)"
        cell.lbl_amount.text = "$\(tmp_dic.object(forKey: "amount")!)"

        let dateString = "\(tmp_dic.object(forKey: "created")!)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateObj = dateFormatter.date(from: dateString)
        let currentDate = dateFormatter.date(from: "\(tmp_dic.object(forKey: "current_date")!)")!
        cell.lbl_time.text = "\(currentDate.offsetFrom(date: dateObj!)) ago"

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let tmp_dic = arr_data.object(at: indexPath.row) as! NSDictionary

        let obj_view = DareDetailPage(nibName: "DareDetailPage", bundle: nil)
        obj_view.str_id = "\(tmp_dic.object(forKey: "dare_id")!)"
        obj_view.shouldBack = true
        appdel.appNav?.pushViewController(obj_view, animated: true)

//        if "\(tmp_dic.object(forKey: "user_name")!)" != "Anonymous"
//        {
//            let user_id = "\(tmp_dic.object(forKey: "user_id")!)"
//            self.viewUserProfile(tmp_id: user_id)
//        }
    }

    //MARK:- Button Action Methods
    @IBAction func on_btnBack_click(_ sender: UIButton)
    {
        self.appdel.appNav.popViewController(animated: true)
    }

    @IBAction func btn_Retry_Click(_ sender: UIButton)
    {

    }

    //MARK:- Touch Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }

    //MARK:- Web Service Methods
    func getContributionList()
    {
        self.view.endEditing(true)

        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self
            webclass.contributionList()
        }
        else
        {
            vw_Retry.isHidden = false
            btnRetry.isHidden = false
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

    func dataDidFinishDowloading(aResponse: AnyObject?, methodname: String)
    {
        do {
            let JSONDict = try JSONSerialization.jsonObject(with: aResponse as! Data, options: []) as! NSDictionary
            print("Server Response: \(JSONDict)")

            if (kContributionList().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg = JSONDict.object(forKey: "response_msg") as! String

                if responseStatus == "success"
                {
                    vw_Retry.isHidden = true

                    if let responseDic = JSONDict.object(forKey: "response_data") as? NSDictionary
                    {
                        arr_data = responseDic.object(forKey: "my_contributions") as! NSArray
                        if arr_data.count > 0
                        {
                            tblList.isHidden = false
                            lbl_msg.isHidden = true

                            tblList.delegate = self
                            tblList.dataSource = self
                            tblList.reloadData()
                        }
                        else
                        {
                            tblList.isHidden = true
                            lbl_msg.isHidden = false
                        }

                        lbl_count.text = "\(responseDic.object(forKey: "contribution_count")!) Contributions"
                        lbl_amount.text = "Total: $\(responseDic.object(forKey: "total_contribution")!)"
                    }
                }
                else
                {
                    tblList.isHidden = true
                    lbl_msg.isHidden = true

                    vw_Retry.isHidden = false
                    btnRetry.isHidden = false

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
            if (kContributionList().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                tblList.isHidden = true
                lbl_msg.isHidden = true

                vw_Retry.isHidden = false
                btnRetry.isHidden = false
            }

            self.alertType(type: .okAlert, alertMSG: Invalid_ResMsg(), delegate: self)
            print("Error from backend \(error)")
        }
    }

    func dataDidFail (methodname : String , error : Error)
    {
        if (kContributionList().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
        {
            tblList.isHidden = true
            lbl_msg.isHidden = true

            vw_Retry.isHidden = false
            btnRetry.isHidden = false
        }

        self.alertType(type: .okAlert, alertMSG: ServerErrorMsg(), delegate: self)
    }
}
