//
//  LoginView.swift
//  Darebux
//
//  Created by LogicSpice on 25/01/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginView: UIViewController, UITextFieldDelegate, WebCommunicationClassDelegate
{
    //MARK:- Outlets
    @IBOutlet var btnBackView: UIView!
    @IBOutlet var vw_whiteView: UIView!
    @IBOutlet var btnSignin: UIButton!
    @IBOutlet var btnFacebook: UIButton!
    @IBOutlet var lblNewHere: UILabel!
    @IBOutlet var imgEye: UIImageView!
    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var txtPassword: UITextField!
    
    let GDP = GDP_Obj()
    let appdel = App_Delegate()
    var social_id : String = ""
    var login_type: String = ""
    var socialEmail: String = ""
    var socialFirstName: String = ""
    var socialLastName: String = ""
    var isFromeHome = false

    var str_quickbloxId: String = ""
    var str_username: String = ""
    var isregistered_on_quickblox: Bool = false

    //MARK:- View Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()

       vw_whiteView.layer.cornerRadius = 4
       vw_whiteView.dropShadow()

        if isFromeHome
        {
            btnBackView.isHidden = false
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        GDP.adjustView(tmp_view: self.view)

        GDP.setColorAttributedText(colorStr1: "New Here? ", color1: UIColor.black, colorStr2: "Sign Up", color2: UIColor(red: 35/255.0, green: 166/255.0, blue: 46/255.0, alpha: 1), lblObj: lblNewHere, fontSize: lblNewHere.font.pointSize)

        btnSignin.layer.cornerRadius = btnSignin.bounds.size.height/2
        btnFacebook.layer.cornerRadius = btnFacebook.bounds.size.height/2
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Button Click Method
    @IBAction func btn_Back_Click(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_Signin_Click(_ sender: UIButton)
    {
        userLoginOnServer()
    }
    
    @IBAction func btn_Signup_Click(_ sender: UIButton)
    {
        var isExists = false
        var frontView:UIViewController?
        
        for viObj in (appdel.appNav?.viewControllers)!
        {
            if viObj is SignupView
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
            let obj_view = SignupView(nibName: "SignupView", bundle: nil)
            appdel.appNav?.pushViewController(obj_view, animated: true)
        }
    }
    
    @IBAction func btn_HideShowPWD_Click(_ sender: UIButton)
    {
        imgEye.isHighlighted = !imgEye.isHighlighted
        txtPassword.isSecureTextEntry = !imgEye.isHighlighted
    }
    
    @IBAction func btn_Forgot_Click(_ sender: UIButton)
    {
        let obj_view = ForgotPasswordPage(nibName: "ForgotPasswordPage", bundle: nil)
        appdel.appNav?.pushViewController(obj_view, animated: true)
    }
    
    @IBAction func btn_Facebook_Click(_ sender: UIButton)
    {
        if Reachability.isConnectedToNetwork()
        {
            login_type = "facebook"
            
            let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
            fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
                if (error == nil)
                {
                    let fbloginresult : FBSDKLoginManagerLoginResult = result!
                    if fbloginresult.grantedPermissions != nil
                    {
                        if(fbloginresult.grantedPermissions.contains("email"))
                        {
                            SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
                            self.getFacebookUserData()
                            fbLoginManager.logOut()
                        }
                    }
                }
            }
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }
    
    func getFacebookUserData()
    {
        if((FBSDKAccessToken.current()) != nil)
        {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil)
                {
                    SVProgressHUD .dismiss()
                    let JSONDict = result as! NSDictionary
                    print(JSONDict)
                    
                    self.social_id = JSONDict.object(forKey: "id") as! String!
                    self.socialEmail = JSONDict.object(forKey: "email") as! String!
                    self.socialFirstName = JSONDict.object(forKey: "first_name") as! String!
                    self.socialLastName = JSONDict.object(forKey: "last_name") as! String!

                    self.txtEmail.text = self.socialEmail
                    self.registerWithQuickblox()
                }
            })
        }
    }
    
    //MARK:- Validation Methods
    func checkValidation() -> Bool
    {
        let charSet = NSCharacterSet.whitespacesAndNewlines
        if ((txtEmail.text?.trimmingCharacters(in: charSet))?.count == 0)
        {
            self.alertType(type: .okAlert, alertMSG: "Please enter your email address or username", delegate: self)
            return false
        }
        else if ((txtPassword.text?.trimmingCharacters(in: charSet))?.count == 0)
        {
            self.alertType(type: .okAlert, alertMSG: "Please enter password", delegate: self)
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
    
    //MARK:- Web Services Methods
    func registerWithQuickblox()
    {
        if Reachability.isConnectedToNetwork()
        {
            SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
            let newUser = QBUUser()
            newUser.fullName = "\(socialFirstName) \(socialLastName)"
            newUser.email = "\(socialEmail)"
            newUser.password = "darebux@123"

            QBRequest.signUp(newUser, successBlock: { (response, user) in
                print("successfull")
                self.isregistered_on_quickblox = true
                self.str_quickbloxId = "\(user.id)"
                SVProgressHUD.dismiss()

                if self.login_type == "facebook"
                {
                    self.postSocialLoginData()
                }

            }, errorBlock: { (response) in
                self.isregistered_on_quickblox = false
                let str_error = response.error?.reasons?.description
                let char_set = (NSCharacterSet.alphanumerics).inverted
                let str_result = (str_error?.components(separatedBy: char_set) as! NSArray).componentsJoined(by: "")
                print(str_result)

                if str_result == "errorsemailhasalreadybeentaken"
                {
                    QBRequest.user(withEmail: self.txtEmail.text!, successBlock: { (response, user) in
                        self.str_quickbloxId = "\(user.id)"
                        SVProgressHUD.dismiss()

                        if self.login_type == "facebook"
                        {
                            self.postSocialLoginData()
                        }

                    }, errorBlock: { (response) in
                        SVProgressHUD.dismiss()
                        self.alertType(type: .okAlert, alertMSG: "Unable to register, please contact to admin.", delegate: self)
                    })
                }
                else
                {
                    SVProgressHUD.dismiss()
                    self.alertType(type: .okAlert, alertMSG: "Unable to register, please contact to admin.", delegate: self)
                }
            })
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }

    func loginWithQuickblox(tmp_email: String)
    {
        if Reachability.isConnectedToNetwork()
        {
            SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
            QBRequest.logIn(withUserEmail: tmp_email, password: "darebux@123", successBlock: { (response, user) in

                let device_uuid = UIDevice.current.identifierForVendor?.uuidString
                let subscription = QBMSubscription()
                subscription.notificationChannel = .APNS
                subscription.deviceUDID = device_uuid
                subscription.deviceToken = self.GDP.device_token

                QBRequest.subscriptions(successBlock: { (response, arrSubscription:[QBMSubscription]?) in

                    for value:QBMSubscription in arrSubscription!
                    {
                        QBRequest.deleteSubscription(withID:value.id , successBlock: { (response) in
                        }, errorBlock: { (response) in
                            print(response)
                        })
                    }

                    QBRequest.createSubscription(subscription, successBlock: { (response, objects: [QBMSubscription]?) in
                        print("This is an Success")
                        self.updateParameters()
                    }, errorBlock: { (response) in
                        print("This is an error")
                        self.updateParameters()
                    })

                }, errorBlock: { (errResponse) in

                    QBRequest.createSubscription(subscription, successBlock: { (response, objects: [QBMSubscription]?) in
                        print("This is an Success")
                        self.updateParameters()
                    }, errorBlock: { (response) in
                        print("This is an error")
                        self.updateParameters()
                    })

                    print(errResponse)
                })

            }, errorBlock: { (response) in
                self.updateParameters()
            })

            GDP.leftView = LeftViewController(nibName: "LeftViewController", bundle: nil)

            let mainView = HomePage(nibName: "HomePage", bundle: nil)
            appdel.appNav = UINavigationController(rootViewController: mainView)
            appdel.appNav?.isNavigationBarHidden = true;
            appdel.window!.rootViewController = appdel.appNav
            appdel.window!.makeKeyAndVisible()
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }

    func updateParameters()
    {
        let updateParameters = QBUpdateUserParameters()
        updateParameters.fullName = "\(str_username)"
        updateParameters.login = "\(str_username)"
        QBRequest.updateCurrentUser(updateParameters, successBlock: { (response, user) in

            print(user)
            print("Successs")

        }) { (response) in
            SVProgressHUD.dismiss()
            self.alertType(type: .okAlert, alertMSG: ServerErrorMsg(), delegate: self)
        }
    }

    func userLoginOnServer()
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
                tmp_dic.setValue(txtPassword.text, forKey: "password")
                tmp_dic.setValue(kDeviceType(), forKey: "device_type")
                tmp_dic.setValue(self.GDP.device_ID, forKey: "device_id")
                webclass.userLogin(dic_login: tmp_dic)
            }
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }
    
    func postSocialLoginData()
    {
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self
            
            let tmp_dic:NSMutableDictionary = NSMutableDictionary()

            tmp_dic.setValue(str_quickbloxId, forKey: "quickblox_id")
            tmp_dic.setValue(login_type, forKey: "type")
            tmp_dic.setValue(socialFirstName, forKey: "first_name")
            tmp_dic.setValue(socialLastName, forKey: "last_name")
            tmp_dic.setValue(socialEmail, forKey: "email")
             tmp_dic.setValue("", forKey: "password")
            tmp_dic.setValue("", forKey: "address")
            tmp_dic.setValue("", forKey: "latitude")
            tmp_dic.setValue("", forKey: "longitude")
            tmp_dic.setValue("", forKey: "gender")
            tmp_dic.setValue("", forKey: "dob")
            tmp_dic.setValue("", forKey: "contact")
            tmp_dic.setValue(kDeviceType(), forKey: "device_type")
            tmp_dic.setValue(self.GDP.device_ID, forKey: "device_id")
            webclass.userRegister(dic_register: tmp_dic)
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
            
            if (kUserLogin().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg    = JSONDict.object(forKey: "response_msg") as! String
                
                if responseStatus == "success"
                {
                    if let responseDict = JSONDict.object(forKey: "response_data") as? NSDictionary
                    {
                        UserDefaults.standard.set("\(responseDict.object(forKey: "token")!)", forKey: "token")
                        UserDefaults.standard.set("\(responseDict.object(forKey: "quickblox_id")!)", forKey: "quickblox_id")
                        UserDefaults.standard.set("\(responseDict.object(forKey: "user_id")!)", forKey: "user_id")
                        UserDefaults.standard.set(responseDict.object(forKey: "email_address"), forKey: "email")
                        UserDefaults.standard.set(responseDict.object(forKey: "first_name"), forKey: "first_name")
                        UserDefaults.standard.set(responseDict.object(forKey: "last_name"), forKey: "last_name")
                        UserDefaults.standard.set(responseDict.object(forKey: "profile_image"), forKey: "profile_image")
                        
                        GDP.isBeforeLogin = false
                        GDP.qb_id = "\(responseDict.object(forKey: "quickblox_id")!)"
                        GDP.userID = "\(responseDict.object(forKey: "user_id")!)"
                        GDP.userEmail = "\(responseDict.object(forKey: "email_address")!)"
                        GDP.userFirstName = "\(responseDict.object(forKey: "first_name")!)"
                        GDP.jsonToken = "\(responseDict.object(forKey: "token")!)"

                        print(GDP.jsonToken!)
                        str_username = "\(responseDict.object(forKey: "username")!)"

                        self.loginWithQuickblox(tmp_email: GDP.userEmail)
                    }
                }
                else
                {
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }
            else if (kUserSignUp().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg    = JSONDict.object(forKey: "response_msg") as! String
                
                if responseStatus == "success"
                {
                    if let responseDict = JSONDict.object(forKey: "response_data") as? NSDictionary
                    {
                        UserDefaults.standard.set("\(responseDict.object(forKey: "token")!)", forKey: "token")
                        UserDefaults.standard.set(responseDict.object(forKey: "email_address"), forKey: "email")
                        UserDefaults.standard.set(responseDict.object(forKey: "user_id"), forKey: "user_id")
                        UserDefaults.standard.set(responseDict.object(forKey: "first_name"), forKey: "first_name")
                        UserDefaults.standard.set(responseDict.object(forKey: "last_name"), forKey: "last_name")
                        UserDefaults.standard.set(responseDict.object(forKey: "profile_image"), forKey: "profile_image")
                        UserDefaults.standard.set("\(responseDict.object(forKey: "quickblox_id")!)", forKey: "quickblox_id")
                        
                        GDP.isBeforeLogin = false
                        GDP.userEmail = "\(responseDict.object(forKey: "email_address")!)"
                        GDP.userID = "\(responseDict.object(forKey: "user_id")!)"
                        GDP.userFirstName = "\(responseDict.object(forKey: "first_name")!)"
                        GDP.jsonToken = "\(responseDict.object(forKey: "token")!)"
                        GDP.qb_id = "\(responseDict.object(forKey: "quickblox_id")!)"

                        self.loginWithQuickblox(tmp_email: GDP.userEmail)
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
