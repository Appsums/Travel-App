//
//  ChangePaswwordPage.swift
//  FoodOrderApp
//
//  Created by LogicSpice on 03/11/17.
//  Copyright © 2017 logicspice. All rights reserved.
//

import UIKit

class ChangePaswwordPage: UIViewController,WebCommunicationClassDelegate,alertClassDelegate {

    @IBOutlet var btnSubmit:UIButton!
    @IBOutlet var txtCurrPwd:UITextField!
    @IBOutlet var imgEye1: UIImageView!
    @IBOutlet var txtNewPwd:UITextField!
    @IBOutlet var imgEye2: UIImageView!
    
    let GDP = GDP_Obj()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()

        GDP.adjustView(tmp_view: self.view)
        btnSubmit.layer.cornerRadius = btnSubmit.frame.size.height/2
    }
    
    //MARK:- Button Action Methods
    @IBAction func on_btnBack_click(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func btn_HideShowPWD1_Click(_ sender: UIButton)
    {
        imgEye1.isHighlighted = !imgEye1.isHighlighted
        txtCurrPwd.isSecureTextEntry = !imgEye1.isHighlighted
    }

    @IBAction func btn_HideShowPWD2_Click(_ sender: UIButton)
    {
        imgEye2.isHighlighted = !imgEye2.isHighlighted
        txtNewPwd.isSecureTextEntry = !imgEye2.isHighlighted
    }
    
    @IBAction func on_btnSubmit_click(_ sender: UIButton)
    {
        if checkValidation()
        {
            if Reachability.isConnectedToNetwork()
            {
                let webclass = WebCommunicationClass()
                webclass.aCaller = self
                
                let tmp_dic:NSMutableDictionary = NSMutableDictionary()
                tmp_dic.setValue(txtCurrPwd.text, forKey: "old_password")
                tmp_dic.setValue(txtNewPwd.text, forKey: "new_password")
                webclass.changePassword(dic_forgotPassword: tmp_dic)
            }
            else
            {
                self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
            }
        }
    }
    
    func checkValidation() -> Bool
    {
        let charSet = NSCharacterSet.whitespacesAndNewlines
        if ((txtCurrPwd.text?.trimmingCharacters(in: charSet))?.count == 0)
        {
            self.alertType(type: .okAlert, alertMSG: "Please enter your old password", delegate: self)
            return false
        }
        else if ((txtNewPwd.text?.trimmingCharacters(in: charSet))?.count == 0)
        {
            self.alertType(type: .okAlert, alertMSG: "Please enter your new password", delegate: self)
            return false
        }
        else if (((txtNewPwd.text?.trimmingCharacters(in: charSet))?.count)! < 8)
        {
            self.alertType(type: .okAlert, alertMSG: "Password should be 8 characters", delegate: self)
            return false
        }        
        return true
    }
    
    //MARK:- Web Services delegate methods
    func dataDidFinishDowloading(aResponse: AnyObject?, methodname: String)
    {
        if (kChangePassword().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
        {
            let JSONDict = try! JSONSerialization.jsonObject(with: aResponse as! Data, options: .allowFragments) as! NSDictionary
            print("Response \(JSONDict)")
            
            let responseStatus = JSONDict.object(forKey: "response_status") as! String
            let responseMsg    = JSONDict.object(forKey: "response_msg") as! String
            
            if responseStatus == "success"
            {                
                self.alertType(type: .okAlertwithDelegate, alertMSG: responseMsg, delegate: self)
            }
                
            else
            {
                self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
            }
        }
    }
    
    func dataDidFail(methodname: String, error: Error) {
        self.alertType(type: .okAlert, alertMSG: ServerErrorMsg(), delegate: self)
    }
    
    //MARK:- Alert View Methods
    func alertOkClick()
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Touch Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
