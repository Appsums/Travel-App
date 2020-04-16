//
//  CustomRevealController.swift
//  Beeland_Artisan
//
//  Created by LS on 09/01/17.
//  Copyright © 2017 LS. All rights reserved.
//

import UIKit

class CustomRevealController: UIViewController,UIGestureRecognizerDelegate
{
    //MARK: - Outlet Declarations
    @IBOutlet var imgTap: UIImageView!

    var isOpenLeftView:Bool = false
    var imgTranBG:UIImageView?

    var isLeft:Bool?
    var deductHeight:CGFloat?
    
    var tapRecognizer:UITapGestureRecognizer?
    var leftViewControl:UIViewController?;
    var rightViewControl:UIViewController?
    var objview:UIViewController?
    
    let appdel = App_Delegate()
    
    //MARK: - View Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        deductHeight = 0
    }

    //MARK: - Set Left/Right Reveal controller
    func setLeftViewControl(leftViewControl:UIViewController)
    {
        self.setRevealContrl(reveal: leftViewControl)
    }

    func setRevealContrl(reveal: UIViewController)
    {
        objview = reveal
        
        let pan = UIScreenEdgePanGestureRecognizer(target:self, action:#selector(btnLeftMenuActionCall))
        pan.edges = UIRectEdge.left
        pan.delegate = self
        objview?.view.addGestureRecognizer(pan)
    }

    //MARK: - Menu Button Action Method
    @objc func btnLeftMenuActionCall()
    {
        if Reachability.isConnectedToNetwork()
        {
            isLeft = true;
            objview?.view.endEditing(true)
            
            if isOpenLeftView == false
            {
                isOpenLeftView = true;
                
                if (imgTranBG == nil)
                {
                    imgTranBG = UIImageView(frame: CGRect(x: 0, y: 0, width: window_Width(), height: window_Height()))
                    imgTranBG?.backgroundColor = UIColor.black
                    imgTranBG?.alpha = 0.4
                    appdel.window?.addSubview(imgTranBG!)
                }
                
                self.view.frame = CGRect(x: -window_Width(), y: deductHeight!, width: window_Width(), height: window_Height()-deductHeight!)
                appdel.window?.addSubview(self.view)
                
                UIView.animate(withDuration: 0.3, animations:
                    {
                        self.view.frame = CGRect(x: 0, y: self.deductHeight!, width: window_Width(), height: window_Height()-self.deductHeight!)
                        
                }, completion:nil)
            }
            
            self.addTapGesturerecognizer()
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }
    
    //MARK: - Add Tap Gesture Recognizer
    func addTapGesturerecognizer()
    {
        if isOpenLeftView == true
        {
            tapRecognizer = UITapGestureRecognizer(target: self, action:#selector(handleTap))
            tapRecognizer?.numberOfTouchesRequired = 1
            tapRecognizer?.delegate = self
            self.imgTap?.addGestureRecognizer(tapRecognizer!)
            
            let pan = UISwipeGestureRecognizer(target:self, action:#selector(handleTap))
            pan.direction = UISwipeGestureRecognizerDirection.left
            self.imgTap?.addGestureRecognizer(pan)
            
            self.imgTap?.isUserInteractionEnabled = true
        }
    }
    
    //MARK: - Tap Gesture Handler
    @objc func handleTap()
    {
        isOpenLeftView = false
        
        if isLeft == true
        {
            self.view.frame = CGRect(x:0, y:deductHeight!, width: window_Width(), height: self.view.frame.size.height)
            UIView.animate(withDuration: 0.3, animations:{

                self.view.frame = CGRect(x: -window_Width(), y: self.deductHeight!, width: window_Width(), height: window_Height()-self.deductHeight!)
                self.imgTranBG?.alpha = 0
                self.imgTranBG?.removeGestureRecognizer(self.tapRecognizer!)
                self.imgTranBG = nil
                
            }, completion: { (finished: Bool) in
                self.view.removeFromSuperview()
            })            
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
