//
//  LeftViewController.swift
//  Beeland_Artisan
//
//  Created by LS on 09/01/17.
//  Copyright © 2017 LS. All rights reserved.
//

import UIKit

class LeftViewController: CustomRevealController, UITableViewDelegate, UITableViewDataSource, alertClassDelegate,WebCommunicationClassDelegate
{
    //MARK: - Outlet Declarations
    @IBOutlet var lblMiddleLine: UILabel!    
    @IBOutlet var img_userProfile: UIImageView!
    @IBOutlet var lbl_username: UILabel!
    @IBOutlet var tblList: UITableView!
    @IBOutlet var vw_userView: UIView!
    @IBOutlet var vw_LogoView: UIView!

    let GDP = GDP_Obj()
    var selectedRow = 0
    var arrSideMenuText: NSMutableArray!
    
    //MARK: - View Method
    override func viewDidLoad()
    {
        super.viewDidLoad()
       
        if GDP.isBeforeLogin
        {
            arrSideMenuText = ["Home", "Login", "Signup"]
        }
        else
        {
            arrSideMenuText = ["Home", "Search Users", "Dashboard", "Profile", "Messages", "Change Password", "Logout"]
        }

        tblList.register(UINib(nibName: "LeftTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
    }

    override func viewWillAppear(_ animated: Bool)
    {
        if GDP.isBeforeLogin
        {
            vw_LogoView.isHidden = false
            vw_userView.isHidden = true
        }
        else
        {
            vw_LogoView.isHidden = true
            vw_userView.isHidden = false
            
            lbl_username.text = GDP_Obj().userFirstName
            
            if let str_img = UserDefaults.standard.value(forKey: "profile_image") as? String
            {
                img_userProfile.imageForUrlWithImage(baseUrl: profile_image_url(), urlString: str_img, placeHolderImage: "user_Profile.png")
            }
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        if GDP.isBeforeLogin == false
        {
            let imageWidth = lbl_username.frame.origin.x - 30
            
            var viFrame = img_userProfile.frame
            viFrame.origin.x = 10
            viFrame.origin.y = vw_userView.frame.size.height/2 - imageWidth/2
            viFrame.size.height = imageWidth
            viFrame.size.width = imageWidth
            img_userProfile.frame = viFrame
            
            img_userProfile.layer.cornerRadius = img_userProfile.frame.size.width/2.0
            img_userProfile.clipsToBounds = true
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func on_btnProfile_click(_ sender: UIButton)
    {
        isOpenLeftView = false
        let obj_view = ProfilePage(nibName: "ProfilePage", bundle: nil)
        appdel.appNav?.pushViewController(obj_view, animated: true)
        self.imgTranBG?.alpha = 0
        self.imgTranBG?.removeGestureRecognizer(self.tapRecognizer!)
        self.imgTranBG = nil
        self.view.removeFromSuperview()
    }
    
    //MARK: - UITableView Delegate method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrSideMenuText.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIDevice().userInterfaceIdiom == .pad
        {
            return 100
        }
        else
        {
            return 50
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell: LeftTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LeftTableViewCell

       cell.lblText.text = arrSideMenuText.object(at: indexPath.row) as? String
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        isOpenLeftView = false
        var isExists = false

        var frontView: UIViewController?
        if tableView == tblList
        {
            switch indexPath.row
            {
                case 0:

                    for viObj in (appdel.appNav?.viewControllers)!
                    {
                        if viObj is HomePage
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
                        let obj_view = HomePage(nibName: "HomePage", bundle: nil)
                        appdel.appNav?.pushViewController(obj_view, animated: true)
                    }

                    break

                case 1:

                    if GDP.isBeforeLogin
                    {
                        let obj_view = LoginView(nibName: "LoginView", bundle: nil)
                        obj_view.isFromeHome = true
                        appdel.appNav?.pushViewController(obj_view, animated: true)
                    }
                    else
                    {
                        for viObj in (appdel.appNav?.viewControllers)!
                        {
                            if viObj is Search_View
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
                            let obj_view = Search_View(nibName: "Search_View", bundle: nil)
                            appdel.appNav?.pushViewController(obj_view, animated: true)
                        }
                    }

                    break

                case 2:

                    if GDP.isBeforeLogin
                    {
                        let obj_view = SignupView(nibName: "SignupView", bundle: nil)
                        obj_view.isFromeHome = true
                        appdel.appNav?.pushViewController(obj_view, animated: true)
                    }
                    else
                    {
                        for viObj in (appdel.appNav?.viewControllers)!
                        {
                            if viObj is Dashboard_View
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
                            let obj_view = Dashboard_View(nibName: "Dashboard_View", bundle: nil)
                            appdel.appNav?.pushViewController(obj_view, animated: true)
                        }
                    }

                    break

            case 3:

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

                break

            case 4:

                for viObj in (appdel.appNav?.viewControllers)!
                {
                    if viObj is ChatUser_View
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
                    let obj_view = ChatUser_View(nibName: "ChatUser_View", bundle: nil)
                    appdel.appNav?.pushViewController(obj_view, animated: true)
                }

                break

            case 5:

                for viObj in (appdel.appNav?.viewControllers)!
                {
                    if viObj is ChangePaswwordPage
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
                    let obj_view = ChangePaswwordPage(nibName: "ChangePaswwordPage", bundle: nil)
                    appdel.appNav?.pushViewController(obj_view, animated: true)
                }

                break

            case 6:
                
                self.alertType(type: .YNAlert, alertMSG: "Do you want to logout?", delegate: self)

                break

            default:
                print("default")
            }

            self.imgTranBG?.alpha = 0
            self.imgTranBG?.removeGestureRecognizer(self.tapRecognizer!)
            self.imgTranBG = nil
            self.view.removeFromSuperview()
        }
    }
    
    func alertYesClick()
    {
        logoutfromQuickblox()
    }

    func logoutfromQuickblox()
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        let deviceUdid = UIDevice.current.identifierForVendor?.uuidString
        QBRequest.unregisterSubscription(forUniqueDeviceIdentifier: deviceUdid!, successBlock: { (response) in

            QBRequest.logOut(successBlock: { (response) in
                SVProgressHUD.dismiss()
                QBChat.instance.disconnect(completionBlock: nil)
                self.logoutUser()

            }, errorBlock: { (response) in
                SVProgressHUD.dismiss()
                QBChat.instance.disconnect(completionBlock: nil)
                self.logoutUser()
            })

        }) { (error) in
            QBRequest.logOut(successBlock: { (response) in
                SVProgressHUD.dismiss()
                QBChat.instance.disconnect(completionBlock: nil)
                self.logoutUser()

            }, errorBlock: { (response) in
                SVProgressHUD.dismiss()
                QBChat.instance.disconnect(completionBlock: nil)
                self.logoutUser()
            })
        }
    }
    
    func logoutUser()
    {
        GDP.resetControl()

        let loginView = FirstView(nibName: "FirstView", bundle: nil)
        appdel.appNav = UINavigationController(rootViewController: loginView)
        appdel.appNav?.setNavigationBarHidden(true, animated: false)
        appdel.window?.rootViewController = appdel.appNav
        appdel.window?.makeKeyAndVisible()
    }
    
    func dataDidFinishDowloading(aResponse: AnyObject?, methodname: String)
    {
        do {
            
            let JSONDict = try JSONSerialization.jsonObject(with: aResponse as! Data, options: []) as! NSDictionary
            if (kLogoutUser().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg    = JSONDict.object(forKey: "response_msg") as! String
                
                if responseStatus == "success"
                {
                    GDP.resetControl()
                
                    let loginView = FirstView(nibName: "FirstView", bundle: nil)
                    appdel.appNav = UINavigationController(rootViewController: loginView)
                    appdel.appNav?.setNavigationBarHidden(true, animated: false)
                    appdel.window?.rootViewController = appdel.appNav
                    appdel.window?.makeKeyAndVisible()
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
