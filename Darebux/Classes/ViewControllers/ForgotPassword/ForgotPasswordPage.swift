//
//  ForgotPasswordPage.swift
//  Darebux
//
//  Created by LogicSpice on 30/01/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit

class ForgotPasswordPage: UIViewController, UITextFieldDelegate, alertClassDelegate, WebCommunicationClassDelegate
{
    //MARK:- Outlets
    @IBOutlet var vw_whiteView:UIView!
    @IBOutlet var btnSend:UIButton!
    @IBOutlet var txtEmail:UITextField!
    @IBOutlet var lblLogin:UILabel!
    
    let GDP = GDP_Obj()

    //MARK:- View Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        vw_whiteView.layer.cornerRadius = 4
        vw_whiteView.dropShadow()
    }
    
    override func viewDidLayoutSubviews()
    {
        GDP.adjustView(tmp_view: self.view)

        GDP.setColorAttributedText(colorStr1: "Remember Password? ", color1: UIColor.black, colorStr2: "Log in Now", color2: UIColor(red: 35/255.0, green: 166/255.0, blue: 46/255.0, alpha: 1), lblObj: lblLogin, fontSize: lblLogin.font.pointSize)

        btnSend.layer.cornerRadius = btnSend.bounds.size.height/2
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:- Alert View Methods
    func alertOkClick()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Button Click Method
    @IBAction func btn_Back_Click(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_Send_Click(_ sender: UIButton)
    {
        self.view.endEditing(true)
        if Reachability.isConnectedToNetwork()
        {
            if(checkValidation())
            {
                let webclass = WebCommunicationClass()
                webclass.aCaller = self
                
                let tmp_dic:NSMutableDictionary = NSMutableDictionary()
                tmp_dic.setValue(txtEmail.text!, forKey: "email")
                webclass.userForgotPassword(dic_forgotPassword: tmp_dic)
            }
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }
    
    //MARK:- Validation Methods
    func isValidEmail(testStr:String) -> Bool
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func checkValidation() -> Bool
    {
        let charSet = NSCharacterSet.whitespacesAndNewlines
        if ((txtEmail.text?.trimmingCharacters(in: charSet))?.count == 0)
        {
            self.alertType(type: .okAlert, alertMSG: "Please enter email", delegate: self)
            return false
        }

        else if ((isValidEmail(testStr: txtEmail.text!) == false))
        {
            self.alertType(type: .okAlert, alertMSG: "Please enter valid email address", delegate: self)
            return false
        }

        return true
    }

    //MARK:- Text Field Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return true
    }
    
    //MARK:- Touch Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    //MARK:- Web Services delegate methods
    func dataDidFinishDowloading(aResponse: AnyObject?, methodname: String)
    {
        do {
            let JSONDict = try JSONSerialization.jsonObject(with: aResponse as! Data, options: []) as! NSDictionary
            print("Server Response: \(JSONDict)")
            
            if (kUserForgotPassword().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg = JSONDict.object(forKey: "response_msg") as! String
                
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
