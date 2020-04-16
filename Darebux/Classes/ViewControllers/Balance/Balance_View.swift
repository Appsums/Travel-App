//
//  Balance_View.swift
//  Darebux
//
//  Created by logicspice on 15/03/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit
import ActiveLabel

class Balance_View: UIViewController, UITableViewDelegate, UITableViewDataSource, WebCommunicationClassDelegate, alertClassDelegate
{
    //MARK:- Outlets
    @IBOutlet var vw_Retry:UIView!
    @IBOutlet var btnRetry:UIButton!

    @IBOutlet var lbl_pendingText: UILabel!
    @IBOutlet var lbl_pending: UILabel!
    @IBOutlet var lbl_account: UILabel!
    @IBOutlet var tblList: UITableView!
    @IBOutlet var lbl_msg: UILabel!

    @IBOutlet var vw_request: UIView!
    @IBOutlet var txtfld_amount: UITextField!
    @IBOutlet var txtfld_address: UITextField!
    @IBOutlet var lbl_terms: ActiveLabel!

    //View Verify
    @IBOutlet var vw_verify: UIView!
    @IBOutlet var txtfld_code: UITextField!

    let GDP = GDP_Obj()
    let appdel = App_Delegate()

    var arr_pendingtrans: NSArray!
    var arr_completetrans: NSArray!
    var total_balace: Float = 0

    var font_size: CGFloat!

    //MARK:- View Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        tblList.register(UINib(nibName: "Balance_Cell", bundle: nil), forCellReuseIdentifier: "cell")

        if UIDevice().userInterfaceIdiom == .pad
        {
            font_size = 19.0
        }
        else
        {
            font_size = 13.0
        }

        formatTermsLabel()
        getBalanceList()
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
    func formatTermsLabel()
    {
        let customType1 = ActiveType.custom(pattern: "\\sterms\\b") //Looks for "terms"
        let customType2 = ActiveType.custom(pattern: "\\sprivacy policy\\b") //Looks for "privacy policy"
        let customType3 = ActiveType.custom(pattern: "\\sdisclaimer\\b") //Looks for "disclaimer"

        lbl_terms.enabledTypes.append(customType1)
        lbl_terms.enabledTypes.append(customType2)
        lbl_terms.enabledTypes.append(customType3)

        lbl_terms.customize { label in
            label.text = "By continuing, you agree with darebux terms, privacy policy and disclaimer"
            label.numberOfLines = 2
            label.lineSpacing = 4
            label.textColor = UIColor.black

            //Custom types
            label.customColor[customType1] = UIColor.blue
            label.customSelectedColor[customType1] = UIColor.gray
            label.customColor[customType2] = UIColor.blue
            label.customSelectedColor[customType2] = UIColor.gray
            label.customColor[customType3] = UIColor.blue
            label.customSelectedColor[customType3] = UIColor.gray

            label.handleCustomTap(for: customType1, handler: { (str) in
                let obj_view = Web_View(nibName: "Web_View", bundle: nil)
                obj_view.str_title = "Terms & Conditions"
                obj_view.str_url = "http://darebux.logicspice.com/terms-and-conditions"
                self.appdel.appNav?.pushViewController(obj_view, animated: true)
            })

            label.handleCustomTap(for: customType2, handler: { (str) in
                let obj_view = Web_View(nibName: "Web_View", bundle: nil)
                obj_view.str_title = "Privacy Policy"
                obj_view.str_url = "http://darebux.logicspice.com/privacy-policy"
                self.appdel.appNav?.pushViewController(obj_view, animated: true)
            })

            label.handleCustomTap(for: customType3, handler: { (str) in
                let obj_view = Web_View(nibName: "Web_View", bundle: nil)
                obj_view.str_title = "Disclaimer"
                obj_view.str_url = "http://darebux.logicspice.com/disclaimer"
                self.appdel.appNav?.pushViewController(obj_view, animated: true)
            })
        }
    }

    //MARK:- Alert View Methods
    func alertOkClick()
    {
        getBalanceList()
    }

    //MARK: - Table View Methods
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0
        {
            if arr_pendingtrans == nil || arr_pendingtrans.count == 0
            {
                return 1
            }
            else
            {
                return arr_pendingtrans.count
            }
        }
        else
        {
            if arr_completetrans == nil || arr_completetrans.count == 0
            {
                return 1
            }
            else
            {
                return arr_completetrans.count
            }
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let view = UIView()
        view.frame = CGRect(x: 8, y: 0, width: tblList.frame.size.width, height: 30)
        view.backgroundColor = UIColor.init(red: 225.0/255.0, green: 225.0/255.0, blue: 225.0/255.0, alpha: 1.0)

        let lbl = UILabel(frame: CGRect(x: 8, y: 0, width: tblList.frame.size.width - 16, height: 30))
        lbl.font = UIFont.systemFont(ofSize: font_size, weight: .light)
        lbl.textColor = UIColor.black
        view.addSubview(lbl)

        if section == 0
        {
            lbl.text = "Pending Transactions"
        }
        else
        {
            lbl.text = "Completed Transactions"
        }

        return view
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 57
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell: Balance_Cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Balance_Cell

        if indexPath.section == 0
        {
            if arr_pendingtrans == nil || arr_pendingtrans.count == 0
            {
                cell.lbl_date.text = "No pending transations"
                cell.lbl_detail.isHidden = true
                cell.lbl_amount.isHidden = true
            }
            else
            {
                let tmp_dic = arr_pendingtrans.object(at: indexPath.row) as! NSDictionary

                cell.backgroundColor = UIColor.init(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0)

                cell.lbl_date.text = GDP.changeDateFormate(tmp_string: "\(tmp_dic.object(forKey: "date")!)", cur_formate: "yyyy-MM-dd HH:mm:ss", new_formate: "dd MMM, yyyy")

                let t_type = "\(tmp_dic.object(forKey: "type")!)"
                if t_type == "receive"
                {
                    cell.lbl_detail.text = "Payment From \(tmp_dic.object(forKey: "username")!), \(tmp_dic.object(forKey: "dare_title")!)"
                    cell.lbl_amount.text = "+$\(tmp_dic.object(forKey: "owner_amount")!)"
                }
                else if t_type == "contribution"
                {
                    cell.lbl_detail.text = "Contribution To \(tmp_dic.object(forKey: "username")!), \(tmp_dic.object(forKey: "dare_title")!)"
                    cell.lbl_amount.text = "-$\(tmp_dic.object(forKey: "amount")!)"
                }
                else if t_type == "withdrawal"
                {
                    cell.lbl_detail.text = "Withdrawal Request Sent"
                    cell.lbl_amount.text = "-$\(tmp_dic.object(forKey: "amount")!)"
                }

                cell.lbl_detail.sizeToFit()
                cell.lbl_detail.layoutIfNeeded()
            }
        }
        else
        {
            if arr_completetrans == nil || arr_completetrans.count == 0
            {
                cell.lbl_date.text = "No completed transations"
                cell.lbl_detail.isHidden = true
                cell.lbl_amount.isHidden = true
            }
            else
            {
                let tmp_dic = arr_completetrans.object(at: indexPath.row) as! NSDictionary

                cell.lbl_date.text = GDP.changeDateFormate(tmp_string: "\(tmp_dic.object(forKey: "date")!)", cur_formate: "yyyy-MM-dd HH:mm:ss", new_formate: "dd MMM, yyyy")

                let t_type = "\(tmp_dic.object(forKey: "type")!)"
                if t_type == "receive"
                {
                    cell.lbl_detail.text = "Payment From \(tmp_dic.object(forKey: "username")!), \(tmp_dic.object(forKey: "dare_title")!)"

                    cell.lbl_amount.text = "+$\(tmp_dic.object(forKey: "owner_amount")!)"
                }
                else if t_type == "contribution"
                {
                    cell.lbl_detail.text = "Contribution To \(tmp_dic.object(forKey: "username")!), \(tmp_dic.object(forKey: "dare_title")!)"

                    cell.lbl_amount.text = "-$\(tmp_dic.object(forKey: "amount")!)"
                }
                else if t_type == "withdrawal"
                {
                    cell.lbl_detail.text = "Withdrawal Request Approved"
                    cell.lbl_amount.text = "-$\(tmp_dic.object(forKey: "amount")!)"
                }
                else if t_type == "cancelled"
                {
                    cell.lbl_detail.text = "Cancelled - \(tmp_dic.object(forKey: "dare_title")!)"
                    cell.lbl_amount.text = "$\(tmp_dic.object(forKey: "owner_amount")!)"
                }
                else if t_type == "refunded"
                {
                    cell.lbl_detail.text = "Refund - \(tmp_dic.object(forKey: "dare_title")!)"
                    cell.lbl_amount.text = "+$\(tmp_dic.object(forKey: "amount")!)"
                }

                cell.lbl_detail.sizeToFit()
                cell.lbl_detail.layoutIfNeeded()
            }
        }

        return cell
    }

    //MARK:- Validation Methods
    func checkValidation() -> Bool
    {
        let charSet = NSCharacterSet.whitespacesAndNewlines
        if ((txtfld_amount.text?.trimmingCharacters(in: charSet))?.count == 0)
        {
            self.alertType(type: .okAlert, alertMSG: "Please enter withdrawal amount", delegate: self)
            return false
        }
        else if ((txtfld_address.text?.trimmingCharacters(in: charSet))?.count == 0)
        {
            self.alertType(type: .okAlert, alertMSG: "Please enter your bitcoin address", delegate: self)
            return false
        }
        else if ((((txtfld_address.text?.trimmingCharacters(in: charSet))?.count)! < 26) || (((txtfld_address.text?.trimmingCharacters(in: charSet))?.count)! > 35))
        {
            self.alertType(type: .okAlert, alertMSG: "Please enter valid bitcoin address", delegate: self)
            return false
        }

        return true
    }

    //MARK:- Button Action Methods
    @IBAction func on_btnBack_click(_ sender: UIButton)
    {
        self.appdel.appNav.popViewController(animated: true)
    }

    @IBAction func on_btnWithdraw_click(_ sender: UIButton)
    {
        if total_balace < 5.0
        {
            self.alertType(type: .okAlert, alertMSG: "Insufficient fund! You cannot withdraw when balance is less than $5", delegate: self)
        }
        else
        {
            txtfld_amount.text = ""
            txtfld_address.text = ""

            vw_request.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            self.view.addSubview(vw_request)
        }
    }

    @IBAction func on_btnCloseKeyboard_click(_ sender: UIButton)
    {
        self.view.endEditing(true)
    }

    @IBAction func on_btnResend_Click(_ sender: UIButton)
    {
        self.view.endEditing(true)
        getVerificationCode()
    }

    @IBAction func on_btnVerify_Click(_ sender: UIButton)
    {
        self.view.endEditing(true)
        if txtfld_code.text?.trimmingCharacters(in: GDP.charSet).count == 0
        {
            self.alertType(type: .okAlert, alertMSG: "Please enter verification code", delegate: self)
        }
        else
        {
            verifyCode()
        }
    }

    @IBAction func on_btnCancelVerify_click(_ sender: UIButton)
    {
        self.view.endEditing(true)
        txtfld_code.text = ""
        vw_verify.removeFromSuperview()
    }

    @IBAction func on_btnSend_click(_ sender: UIButton)
    {
        if checkValidation() == true
        {
            getVerificationCode()
        }
    }

    @IBAction func on_btnCancel_click(_ sender: UIButton)
    {
        txtfld_amount.text = ""
        txtfld_address.text = ""
        vw_request.removeFromSuperview()
    }

    @IBAction func btn_Retry_Click(_ sender: UIButton)
    {
        getBalanceList()
    }

    //MARK:- Touch Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }

    //MARK:- Web Service Methods
    func getBalanceList()
    {
        self.view.endEditing(true)

        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self
            webclass.balanceList()
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

    func getVerificationCode()
    {
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self

            let tmp_dic:NSMutableDictionary = NSMutableDictionary()
            tmp_dic.setValue("", forKey: "dare_id")
            tmp_dic.setValue("withdraw", forKey: "type")
            tmp_dic.setValue(txtfld_address.text!, forKey: "bitcoin_address")
            tmp_dic.setValue(txtfld_amount.text!, forKey: "amount")
            webclass.getVerificationCode(dic_data: tmp_dic)
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }

    func verifyCode()
    {
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self

            let tmp_dic:NSMutableDictionary = NSMutableDictionary()
            tmp_dic.setValue("", forKey: "dare_id")
            tmp_dic.setValue(txtfld_code.text!, forKey: "code")
            tmp_dic.setValue("withdraw", forKey: "type")
            tmp_dic.setValue(txtfld_address.text!, forKey: "bitcoin_address")
            webclass.verifyCode(dic_data: tmp_dic)
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

            if (kBalanceList().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg = JSONDict.object(forKey: "response_msg") as! String

                if responseStatus == "success"
                {
                    vw_Retry.isHidden = true

                    if let responseDic = JSONDict.object(forKey: "response_data") as? NSDictionary
                    {
                        arr_completetrans = responseDic.object(forKey: "completed_array") as! NSArray
                        arr_pendingtrans = responseDic.object(forKey: "pending_array") as! NSArray

                        if (arr_completetrans.count + arr_pendingtrans.count)  > 0
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

                        lbl_pendingText.text = "Balance"
                        lbl_pending.text = "$\(responseDic.object(forKey: "pending_balance")!)"

                        lbl_account.text = "$\(responseDic.object(forKey: "total_balance")!)"
                        total_balace = Float("\(responseDic.object(forKey: "total_balance")!)")!
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

            else if (kGetVerificationCode().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg = JSONDict.object(forKey: "response_msg") as! String

                if responseStatus == "success"
                {
                    vw_request.removeFromSuperview()

                    vw_verify.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                    self.view.addSubview(vw_verify)
                }
                else
                {
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }

            else if (kVerifyCode().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg = JSONDict.object(forKey: "response_msg") as! String

                if responseStatus == "success"
                {
                    txtfld_code.text = ""
                    vw_verify.removeFromSuperview()
                    
                    self.alertType(type: .okAlertwithDelegate, alertMSG: responseMsg, delegate: self)
                }
                else
                {
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }
        }
        catch let error as NSError
        {
            if (kBalanceList().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
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
        if (kBalanceList().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
        {
            tblList.isHidden = true
            lbl_msg.isHidden = true

            vw_Retry.isHidden = false
            btnRetry.isHidden = false
        }

        self.alertType(type: .okAlert, alertMSG: ServerErrorMsg(), delegate: self)
    }
}
