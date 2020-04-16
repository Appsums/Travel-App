//
//  Contribute_View.swift
//  Darebux
//
//  Created by logicspice on 15/02/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit
import ActiveLabel

class Contribute_View: UIViewController, UITextFieldDelegate, UITextViewDelegate, alertClassDelegate, WebCommunicationClassDelegate
{
    //MARK:- Outlets
    @IBOutlet var lbl_dareTitle: UILabel!
    @IBOutlet var txtfld_amount: UITextField!
    @IBOutlet var txtvw_comment: UITextView!
    @IBOutlet var lbl_placeholder: UILabel!

    @IBOutlet var ic_check: UIImageView!
    @IBOutlet var ic_optionCard: UIImageView!
    @IBOutlet var ic_optionGateway: UIImageView!
    @IBOutlet var ic_optionCredits: UIImageView!
    @IBOutlet var lbl_darebuxcredits: UILabel!

    @IBOutlet var vw_cardpay: UIView!
    @IBOutlet var ic_cardtype: UIImageView!
    @IBOutlet var vw_cardnumber: UIView!
    @IBOutlet var txtfld_cardnum: UITextField!
    @IBOutlet var vw_cardholder: UIView!
    @IBOutlet var txtfld_cardholder: UITextField!
    @IBOutlet var vw_expdate: UIView!
    @IBOutlet var txtfld_expdate: UITextField!
    @IBOutlet var lbl_error: UILabel!
    @IBOutlet var vw_cvv: UIView!
    @IBOutlet var txtfld_cvv: UITextField!

    @IBOutlet var lbl_terms: ActiveLabel!
    @IBOutlet var btnContinue: UIButton!
    @IBOutlet var lbl_msg: UILabel!

    //View Verify
    @IBOutlet var vw_verify: UIView!
    @IBOutlet var txtfld_code: UITextField!

    let GDP = GDP_Obj()
    let appdel = App_Delegate()
    var regExp = try! NSRegularExpression(pattern: "^\\d{0,7}(([.]\\d{1,2})|([.]))?$", options: .caseInsensitive)

    var str_dareId: String!
    var str_dareTitle: String!
    var str_credits: String!
    var remaining_amount: Float!

    var ischecked: String!
    var str_paymentMethod: String!
    var iscardpay: Bool!
    var isgatewaypay: Bool!
    var iscreditspay: Bool!

    var arr_years = NSMutableArray()
    var cur_month: Int!
    var cur_year: Int!

    //MARK:- View Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        ischecked = "0"

        str_paymentMethod = "Bitcoin"

        iscardpay = false
        isgatewaypay = true
        iscreditspay = false

        ic_optionCard.image = UIImage(named: "radio-off.png")
        ic_optionGateway.image = UIImage(named: "radio-on.png")
        ic_optionCredits.image = UIImage(named: "radio-off.png")

        lbl_dareTitle.text = str_dareTitle

        getYearArray()

        let dtformat = DateFormatter()
        dtformat.dateFormat = "MM"
        let month = dtformat.string(from: NSDate() as Date)
        cur_month = Int(month)!

        formatTermsLabel()
    }

    override func viewWillLayoutSubviews()
    {
        GDP.adjustView(tmp_view: self.view)

        let str = "     \(str_credits!) Credits Available"

        GDP.setColorAttributedText(colorStr1: "Darebux Credits", color1: UIColor.black, colorStr2: str, color2: app_color(), lblObj: lbl_darebuxcredits, fontSize: lbl_darebuxcredits.font.pointSize)

        var frame1 = lbl_terms.frame
        frame1.origin.y = 0
        lbl_terms.frame = frame1

        var frame2 = btnContinue.frame
        frame2.origin.y = lbl_terms.frame.origin.y + lbl_terms.frame.size.height + 4
        btnContinue.frame = frame2

        var frame3 = lbl_msg.frame
        frame3.origin.y = btnContinue.frame.origin.y + btnContinue.frame.size.height + 4
        lbl_msg.frame = frame3

        vw_cardnumber.layer.borderColor = UIColor.lightGray.cgColor
        vw_cardnumber.layer.borderWidth = 1.0

        vw_cardholder.layer.borderColor = UIColor.lightGray.cgColor
        vw_cardholder.layer.borderWidth = 1.0

        vw_expdate.layer.borderColor = UIColor.lightGray.cgColor
        vw_expdate.layer.borderWidth = 1.0

        vw_cvv.layer.borderColor = UIColor.lightGray.cgColor
        vw_cvv.layer.borderWidth = 1.0
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:- Other Methods
    func getYearArray()
    {
        let dtformat = DateFormatter()
        dtformat.dateFormat = "yyyy"

        let currYear = dtformat.string(from: NSDate() as Date)
        let yearInt = Int(currYear)!
        cur_year = yearInt

        for i in (yearInt...yearInt+10)
        {
            arr_years.add(String(i))
        }
    }

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
        self.navigationController?.popViewController(animated: true)
    }

    //MARK:- Text Field Methods
    func checkValidation1() -> Bool
    {
        var str_msg: String = ""
        var contribute_amount: Float = 0

        if ((txtfld_amount.text?.trimmingCharacters(in: GDP.charSet))?.count != 0)
        {
            contribute_amount = Float(txtfld_amount.text!)!
            str_msg = "Your contribution cannot exceed the dare goal amount. You can contribute maximum $\(remaining_amount!) on this dare"
        }

        if ((txtfld_amount.text?.trimmingCharacters(in: GDP.charSet))?.count == 0)
        {
            self.alertType(type: .okAlert, alertMSG: "Please enter contribution amount", delegate: self)
            return false
        }

        else if contribute_amount > remaining_amount
        {
            self.alertType(type: .okAlert, alertMSG: str_msg, delegate: self)
            return false
        }

        else if iscardpay == false && isgatewaypay == false && iscreditspay == false
        {
            self.alertType(type: .okAlert, alertMSG: "Please select a payment method to continue", delegate: self)
            return false
        }

        return true
    }

    func checkValidation2() -> Bool
    {
        if ((txtfld_cardnum.text?.trimmingCharacters(in: GDP.charSet))?.count == 0)
        {
            self.alertType(type: .okAlert, alertMSG: "Please enter card number", delegate: self)
            return false
        }
        else if (((txtfld_cardnum.text?.trimmingCharacters(in: GDP.charSet))?.count)! < 16)
        {
            self.alertType(type: .okAlert, alertMSG: "Please enter valid card number", delegate: self)
            return false
        }
        else if ((txtfld_cardholder.text?.trimmingCharacters(in: GDP.charSet))?.count == 0)
        {
            self.alertType(type: .okAlert, alertMSG: "Please enter cardholder name", delegate: self)
            return false
        }
        else if ((txtfld_expdate.text?.trimmingCharacters(in: GDP.charSet))?.count == 0)
        {
            self.alertType(type: .okAlert, alertMSG: "Please select card expiry date", delegate: self)
            return false
        }
        else if ((txtfld_cvv.text?.trimmingCharacters(in: GDP.charSet))?.count == 0)
        {
            self.alertType(type: .okAlert, alertMSG: "Please enter cvv number", delegate: self)
            return false
        }

        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let existingText = textField.text!
        var completeText = "\(existingText)\(string)"
        let characterCount = completeText.count

        if textField == txtfld_amount
        {
            if string.characters.count == 0
            {
                return true
            }

            if(regExp.numberOfMatches(in: completeText, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, characterCount)) == 1)
            {
                if completeText == "." || completeText == "0"
                {
                    return false
                }

                return true
            }
            else
            {
                return false
            }
        }

        else if textField == txtfld_cardnum
        {
            if string.characters.count == 0
            {
                return true
            }

            if characterCount >= 17
            {
                return false
            }
            else
            {
                return true
            }
        }

        else if textField == txtfld_cvv
        {
            if string.characters.count == 0
            {
                return true
            }

            if characterCount >= 4
            {
                return false
            }
            else
            {
                return true
            }
        }

        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return true
    }

    //MARK:- Text View Methods
    func textViewDidChange(_ textView: UITextView)
    {
        if txtvw_comment.text!.trimmingCharacters(in: GDP.charSet).count == 0
        {
            lbl_placeholder.isHidden = false
        }
        else
        {
            lbl_placeholder.isHidden = true
        }
    }

    //MARK:- Button Action Methods
    @IBAction func on_btnBack_click(_ sender: UIButton)
    {
        _ = appdel.appNav?.popViewController(animated: true)
    }

    @IBAction func on_btnAnonymous_click(_ sender: UIButton)
    {
        if ischecked == "0"
        {
            ischecked = "1"
            ic_check.image = UIImage(named: "ic_checkboxYes.png")
        }
        else
        {
            ischecked = "0"
            ic_check.image = UIImage(named: "ic_checkboxNo.png")
        }
    }

    @IBAction func on_btnCard_click(_ sender: UIButton)
    {
        str_paymentMethod = "Credit Card"

        iscardpay = true
        isgatewaypay = false
        iscreditspay = false

        ic_optionCard.image = UIImage(named: "radio-on.png")
        ic_optionGateway.image = UIImage(named: "radio-off.png")
        ic_optionCredits.image = UIImage(named: "radio-off.png")
    }

    @IBAction func on_btnGateway_click(_ sender: UIButton)
    {
        str_paymentMethod = "Bitcoin"

        iscardpay = false
        isgatewaypay = true
        iscreditspay = false

        ic_optionCard.image = UIImage(named: "radio-off.png")
        ic_optionGateway.image = UIImage(named: "radio-on.png")
        ic_optionCredits.image = UIImage(named: "radio-off.png")
    }

    @IBAction func on_btnDarebux_click(_ sender: UIButton)
    {
        self.view.endEditing(true)
        let amount = GDP.changeStringtoFloat(str: txtfld_amount.text!)
        let credits = GDP.changeStringtoFloat(str: str_credits)

        if amount <= 0
        {
            self.alertType(type: .okAlert, alertMSG: "Please enter contribution amount $1 or more", delegate: self)
        }
        else if amount > credits
        {
            self.alertType(type: .okAlert, alertMSG: "You do not have enough darebux credits to make this transaction. Please choose another payment option.", delegate: self)
        }
        else
        {
            str_paymentMethod = "Darebux Credits"

            iscardpay = false
            isgatewaypay = false
            iscreditspay = true

            ic_optionCard.image = UIImage(named: "radio-off.png")
            ic_optionGateway.image = UIImage(named: "radio-off.png")
            ic_optionCredits.image = UIImage(named: "radio-on.png")
        }
    }

    @IBAction func on_btnContinue_click(_ sender: UIButton)
    {
        self.view.endEditing(true)
        if checkValidation1() == true
        {
            if iscardpay == true
            {
                vw_cardpay.frame = CGRect(x: 0, y: window_Height(), width: window_Width(), height: window_Height() - (self.GDP.topSafeArea + self.GDP.bottomSafeArea))
                self.view.addSubview(vw_cardpay)

                UIView.animate(withDuration: 0.3) {

                    self.lbl_error.isHidden = true
                    self.vw_cardpay.frame = CGRect(x: 0, y: 0, width: window_Width(), height: window_Height() - (self.GDP.topSafeArea + self.GDP.bottomSafeArea))
                }
            }
            else if isgatewaypay == true
            {
                contributeAmount()
            }
            else
            {
                let amount = Float(txtfld_amount.text!)!
                let credits = Float(str_credits)!

                if amount > credits
                {
                    self.alertType(type: .okAlert, alertMSG: "You do not have enough darebux credits to make this transaction. Please choose another payment option.", delegate: self)
                }
                else
                {
                    getVerificationCode()
                }
            }
        }
    }

    @IBAction func on_btnClose_click(_ sender: UIButton)
    {
        vw_cardpay.removeFromSuperview()

        txtfld_cardnum.text = ""
        txtfld_cardholder.text = ""
        txtfld_expdate.text = ""
        txtfld_cvv.text = ""
    }

    @IBAction func on_btnExpiry_click(_ sender: UIButton)
    {
        ActionSheetMultipleStringPicker.show(withTitle: "Expiry Date", rows: [
            ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"],
            arr_years], initialSelection: [0, 0], doneBlock: {
                picker, indexes, values in

                let selected_month = Int("\((values as! NSArray).object(at: 0) as! String)")!
                let selected_year = Int("\((values as! NSArray).object(at: 1) as! String)")!

                if selected_month < self.cur_month && selected_year == self.cur_year
                {
                    self.lbl_error.isHidden = false
                }
                else
                {
                    self.lbl_error.isHidden = true

                    self.txtfld_expdate.text = "\((values as! NSArray).object(at: 0) as! String) / \((values as! NSArray).object(at: 1) as! String)"
                }

                return
        }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
    }

    @IBAction func on_btnPayNow_click(_ sender: UIButton)
    {
        if checkValidation2()
        {
            contributeAmount()
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
    
    //MARK:- Touch Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }

    //MARK:- Web Service Methods
    func getVerificationCode()
    {
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self

            let tmp_dic:NSMutableDictionary = NSMutableDictionary()
            tmp_dic.setValue(str_dareId!, forKey: "dare_id")
            tmp_dic.setValue("", forKey: "type")
            tmp_dic.setValue("", forKey: "bitcoin_address")
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
            tmp_dic.setValue(str_dareId!, forKey: "dare_id")
            tmp_dic.setValue(txtfld_code.text!, forKey: "code")
            tmp_dic.setValue("", forKey: "type")
            tmp_dic.setValue("", forKey: "bitcoin_address")
            webclass.verifyCode(dic_data: tmp_dic)
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }

    func contributeAmount()
    {
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self

            let tmp_dic:NSMutableDictionary = NSMutableDictionary()
            tmp_dic.setValue(str_dareId, forKey: "dare_id")
            tmp_dic.setValue(txtfld_amount.text!, forKey: "amount")
            tmp_dic.setValue(txtvw_comment.text!, forKey: "comment")
            tmp_dic.setValue(ischecked, forKey: "anonymous")
            tmp_dic.setValue(str_paymentMethod, forKey: "payment_method")
            webclass.contributeAmount(dic_data: tmp_dic)
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

            if (kGetVerificationCode().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg = JSONDict.object(forKey: "response_msg") as! String

                if responseStatus == "success"
                {
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
                    vw_verify.removeFromSuperview()
                    txtfld_code.text = ""
                    contributeAmount()
                }
                else
                {
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }

            else if (kContributeAmount().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg = JSONDict.object(forKey: "response_msg") as! String

                if responseStatus == "success"
                {
                    if str_paymentMethod == "Bitcoin"
                    {
                        if let responseDict = JSONDict.object(forKey: "response_data") as? NSDictionary
                        {
                            if let error = responseDict.object(forKey: "error") as? String
                            {
                                self.alertType(type: .okAlert, alertMSG: error, delegate: self)
                            }
                            else
                            {
                                let obj_view = Payment_View(nibName: "Payment_View", bundle: nil)
                                obj_view.dic_data = responseDict
                                appdel.appNav?.pushViewController(obj_view, animated: true)
                            }
                        }
                    }
                    else
                    {
                        self.alertType(type: .okAlertwithDelegate, alertMSG: responseMsg, delegate: self)
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
            self.alertType(type: .okAlert, alertMSG: Invalid_ResMsg(), delegate: self)
            print("Error from backend \(error)")
        }
    }

    func dataDidFail (methodname : String , error : Error)
    {
        self.alertType(type: .okAlert, alertMSG: ServerErrorMsg(), delegate: self)
    }
}
