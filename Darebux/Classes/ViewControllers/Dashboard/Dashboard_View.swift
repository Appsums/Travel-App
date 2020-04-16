//
//  Dashboard_View.swift
//  Darebux
//
//  Created by logicspice on 09/02/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit

class Dashboard_View: UIViewController, WebCommunicationClassDelegate
{
    //MARK:- Outlets
    @IBOutlet var vw_Retry: UIView!
    @IBOutlet var btnRetry: UIButton!

    @IBOutlet var btn_menu: UIButton!
    @IBOutlet var vw_invites: UIView!
    @IBOutlet var lbl_invites: UILabel!

    @IBOutlet var vw_balance: UIView!
    @IBOutlet var lbl_balance: UILabel!

    @IBOutlet var vw_sent: UIView!
    @IBOutlet var lbl_sent: UILabel!

    @IBOutlet var vw_contribution: UIView!
    @IBOutlet var lbl_contribution: UILabel!

    let GDP = GDP_Obj()
    let appdel = App_Delegate()
    
    //MARK:- View Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        vw_invites.layer.cornerRadius = 4
        vw_invites.dropShadow()

        vw_balance.layer.cornerRadius = 4
        vw_balance.dropShadow()

        vw_sent.layer.cornerRadius = 4
        vw_sent.dropShadow()

        vw_contribution.layer.cornerRadius = 4
        vw_contribution.dropShadow()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        GDP.leftView.setRevealContrl(reveal: self)
        btn_menu.addTarget(GDP.leftView, action: #selector(CustomRevealController.btnLeftMenuActionCall), for: UIControlEvents.touchUpInside)

        getDashboardData()
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

    //MARK:- Button Action Methods
    @IBAction func on_btnProfile_click(_ sender: UIButton)
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

    @IBAction func on_btnInvite_click(_ sender: UIButton)
    {
        let obj_view = DashboardList_View(nibName: "DashboardList_View", bundle: nil)
        obj_view.str_title = "My Invitations"
        appdel.appNav?.pushViewController(obj_view, animated: true)
    }

    @IBAction func on_btnBalance_click(_ sender: UIButton)
    {
        let obj_view = Balance_View(nibName: "Balance_View", bundle: nil)
        appdel.appNav?.pushViewController(obj_view, animated: true)
    }

    @IBAction func on_btnSent_click(_ sender: UIButton)
    {
        let obj_view = DashboardList_View(nibName: "DashboardList_View", bundle: nil)
        obj_view.str_title = "Sent Dares"
        appdel.appNav?.pushViewController(obj_view, animated: true)
    }

    @IBAction func on_btnContribution_click(_ sender: UIButton)
    {
        let obj_view = Contribution_View(nibName: "Contribution_View", bundle: nil)
        appdel.appNav?.pushViewController(obj_view, animated: true)
    }

    @IBAction func on_btnRetry_click(_ sender: UIButton)
    {
        getDashboardData()
    }

    //MARK:- Web Services Methods
    func getDashboardData()
    {
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self
            webclass.dashboardData()
        }
        else
        {
            vw_Retry.isHidden = false
            btnRetry.isHidden = false
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }

    func dataDidFinishDowloading(aResponse: AnyObject?, methodname: String)
    {
        do {
            let JSONDict = try JSONSerialization.jsonObject(with: aResponse as! Data, options: []) as! NSDictionary
            print("Server Response: \(JSONDict)")

            if (kDashboardData().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg = JSONDict.object(forKey: "response_msg") as! String

                if responseStatus == "success"
                {
                    vw_Retry.isHidden = true
                    btnRetry.isHidden = true

                    if let responseDic = JSONDict.object(forKey: "response_data") as? NSDictionary
                    {
                        lbl_invites.text = "\(responseDic.object(forKey: "receiveDareCount")!)"
                        lbl_balance.text = "\(responseDic.object(forKey: "walletAmount")!)"
                        lbl_sent.text = "\(responseDic.object(forKey: "sentDareCount")!)"
                        lbl_contribution.text = "\(responseDic.object(forKey: "contributerAmount")!)"
                    }
                }
                else
                {
                    vw_Retry.isHidden = false
                    btnRetry.isHidden = false
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }
        }
        catch let error as NSError
        {
            if (kDashboardData().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                vw_Retry.isHidden = false
                btnRetry.isHidden = false
            }

            self.alertType(type: .okAlert, alertMSG: Invalid_ResMsg(), delegate: self)
            print("Error from backend \(error)")
        }
    }

    func dataDidFail (methodname : String , error : Error)
    {
        if (kDashboardData().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
        {
            vw_Retry.isHidden = false
            btnRetry.isHidden = false
        }

        self.alertType(type: .okAlert, alertMSG: ServerErrorMsg(), delegate: self)
    }
}
