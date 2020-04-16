//
//  FirstView.swift
//  Darebux
//
//  Created by LogicSpice on 25/01/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit

class FirstView: UIViewController
{
    //MARK:- Outlets
    @IBOutlet var btnSignin: UIButton!
    @IBOutlet var btnSignup: UIButton!
    @IBOutlet var btnGuest: UIButton!
    
    let GDP = GDP_Obj()
    let appdel = App_Delegate()

    //MARK:- View Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews()
    {
        GDP.adjustView(tmp_view: self.view)
        btnSignin.layer.cornerRadius = btnSignin.bounds.size.height/2

        btnSignup.layer.cornerRadius = btnSignup.bounds.size.height/2
        btnSignup.layer.borderWidth = 1
        btnSignup.layer.borderColor = UIColor.white.cgColor
        
        btnGuest.layer.cornerRadius = btnGuest.bounds.size.height/2
        btnGuest.layer.borderWidth = 1
        btnGuest.layer.borderColor = UIColor.white.cgColor
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Button Action Methods
    @IBAction func btn_Signin_Click(_ sender: UIButton)
    {
        let objView = LoginView(nibName: "LoginView", bundle: nil)
        self.navigationController?.pushViewController(objView, animated: true)
    }
    
    @IBAction func btn_Signup_Click(_ sender: UIButton)
    {
        let objView = SignupView(nibName: "SignupView", bundle: nil)
        self.navigationController?.pushViewController(objView, animated: true)
    }
    
    @IBAction func btn_Guest_Click(_ sender: UIButton)
    {
        GDP.isBeforeLogin = true
        GDP.leftView = LeftViewController(nibName: "LeftViewController", bundle: nil)

        let mainView = HomePage(nibName: "HomePage", bundle: nil)
        appdel.appNav = UINavigationController(rootViewController: mainView)
        appdel.appNav?.isNavigationBarHidden = true;
        appdel.window!.rootViewController = appdel.appNav
        appdel.window!.makeKeyAndVisible()
    }
}
