//
//  UIImageView+DownloadQBUserImage.swift
//  Traders Connect
//
//  Created by LogicSpice on 19/04/17.
//  Copyright © 2017 logicspice. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView
{
    func DownloadQBUserImage(occBlobID:Int, userID:UInt ,placeHolderImage: String)
    {
        let appdel = App_Delegate()
        
        if occBlobID == 0
        {
            self.image = UIImage(named: placeHolderImage)
        }
            
        else
        {
            let fileManager = FileManager.default
            let imagePAth = (appdel.getDirectoryPath() as NSString).appendingPathComponent(String(occBlobID))
            if fileManager.fileExists(atPath: imagePAth)
            {
                self.image = UIImage(contentsOfFile: imagePAth)
            }
            else
            {
                let indicater = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
                indicater.color = UIColor.black
                indicater.frame = CGRect(x: self.frame.size.width/2 - 10, y: self.frame.size.height/2 - 10, width: 20, height: 20)
                self.addSubview(indicater)
                indicater.startAnimating()
                
                QBRequest.downloadFile(withID: UInt(occBlobID), successBlock: { (response,filedata: Data) in
                    
                    indicater.stopAnimating()
                    
                    let image = UIImage(data: filedata)
                    
                    self.image = image
                    
                    let fileManager = FileManager.default
                    let paths = (appdel.getDirectoryPath() as NSString).appendingPathComponent(String(occBlobID))
                    
                    fileManager.createFile(atPath: paths as String, contents: filedata, attributes: nil)
                    
                    print("downloaded image")
                    
                }, statusBlock: { (request, status: QBRequestStatus?) in
                    
                }, errorBlock: { (response) in
                    indicater.stopAnimating()
                    print("error in download image \(String(describing: response.error?.reasons))")
                })

            }
        }
    }
}
