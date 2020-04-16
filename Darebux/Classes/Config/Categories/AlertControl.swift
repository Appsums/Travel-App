//
//  AlertControl.swift
//  Beeland_Artisan
//
//  Created by LS on 09/01/17.
//  Copyright © 2017 LS. All rights reserved.
//

import UIKit

@objc protocol alertClassDelegate
{
    @objc optional func alertYesClick()
    @objc optional func alertNoClick()
    @objc optional func alertOkClick()
}

class AlertControl: NSObject
{
    var  appdel = App_Delegate()
    
    func AlertViewOk(msg:String)
    {
        let alert =   UIAlertController(title: AppName(), message: NSLocalizedString(msg, comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title:NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default)
        { (action: UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        appdel.appNav?.present(alert, animated: true, completion: nil)
    }
    
    func AlertViewOkWithDelegate(msg:String, delegate: AnyObject?)
    {
        let alert =   UIAlertController(title: AppName(), message: NSLocalizedString(msg, comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title:  NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            
            if let delegate1 = delegate{
                delegate1.alertOkClick!()
            }
            alert.dismiss(animated: true, completion: nil)
            
        }
        
        alert.addAction(okAction)
        appdel.appNav?.present(alert, animated: true, completion: nil)
    }

    
    func AlertViewYClickNO(msg:String, delegate: AnyObject?)
    {
        let alert =   UIAlertController(title: AppName(), message: NSLocalizedString(msg, comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        
        let yesAction = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            
            if let delegate1 = delegate{
                delegate1.alertYesClick!()
            }
            alert.dismiss(animated: true, completion: nil)
        }
        
        let noAction = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: UIAlertActionStyle.default)
        { (action: UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        appdel.appNav?.present(alert, animated: true, completion: nil)
    }
    
    func AlertViewYNClick(msg:String, delegate: AnyObject?)
    {
        let alert =   UIAlertController(title: AppName(), message: NSLocalizedString(msg, comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        
        let yesAction = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            
            if let delegate1 = delegate{
                delegate1.alertYesClick!()
            }
            alert.dismiss(animated: true, completion: nil)
        }
        
        let noAction = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: UIAlertActionStyle.default)
        { (action: UIAlertAction) in
            if let delegate1 = delegate{
                delegate1.alertNoClick!()
            }
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        appdel.appNav?.present(alert, animated: true, completion: nil)
    }
    
    func AlertViewOKCancel(msg:String, delegate: AnyObject?)
    {
        let alert =   UIAlertController(title: AppName(), message: NSLocalizedString(msg, comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        
        let yesAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            
            if let delegate1 = delegate{
                delegate1.alertYesClick!()
            }
            alert.dismiss(animated: true, completion: nil)
        }
        
        let noAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.default)
        { (action: UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        appdel.appNav?.present(alert, animated: true, completion: nil)
    }
}

extension UIViewController
{
    func alertType(type:alertType,alertMSG:String,delegate:AnyObject) -> Void
    {
        let alert = AlertControl()
        
        switch type
        {
        case .okAlert:
            alert.AlertViewOk(msg: alertMSG)
        case .okAlertwithDelegate:
            alert.AlertViewOkWithDelegate(msg: alertMSG, delegate: delegate)
        case .YNAlert:
            alert.AlertViewYClickNO(msg: alertMSG, delegate: delegate)
        case .YNClickAlert:
            alert.AlertViewYNClick(msg: alertMSG, delegate: delegate)
        case .OkCancelAlert:
            alert.AlertViewOKCancel(msg: alertMSG, delegate: delegate)
        }
    }

    func datafromUrl(_ baseUrl: String, urlString: String, completionHandler:@escaping (_ data: NSData?) -> ())
    {
        let appdel = App_Delegate()

        if urlString != ""
        {
            let fileManager = FileManager.default
            let imagePAth = (appdel.getDirectoryPath() as NSString).appendingPathComponent(urlString)
            if fileManager.fileExists(atPath: imagePAth)
            {
                let data = NSData(contentsOfFile: imagePAth)
                completionHandler(data)
            }
            else
            {
                let fullurl = String(format: "%@%@", baseUrl, urlString)

                DispatchQueue.global(qos: .background).async {
                    let downloadTask  = URLSession.shared.dataTask(with: URL(string: fullurl)!, completionHandler: { (data: Data?, response: URLResponse?,error: Error?) in
                        if (error != nil)
                        {
                            //error occured
                            return
                        }

                        if data != nil
                        {
                            let fileManager = FileManager.default
                            let paths = (appdel.getDirectoryPath() as NSString).appendingPathComponent(urlString)

                            fileManager.createFile(atPath: paths as String, contents: data, attributes: nil)

                            DispatchQueue.main.async(execute: {() in

                                completionHandler(data as NSData?)
                            })

                            return
                        }
                    })
                    
                    downloadTask.resume()
                }
            }
        }
    }
}

extension UIView
{
    func dropShadow()
    {
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowRadius = 10
    }
}


