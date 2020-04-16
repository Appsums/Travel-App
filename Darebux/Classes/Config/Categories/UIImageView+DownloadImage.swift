//
//  UIImageView+DownloadImage.swift
//  Beeland_Artisan
//
//  Created by LS on 11/01/17.
//  Copyright © 2017 LS. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView
{
    func imageForUrlWithImage(baseUrl: String, urlString: String, placeHolderImage: String)
    {
        let appdel = App_Delegate()
        
        if urlString == ""
        {
            self.image = UIImage(named: placeHolderImage)
        }

        else
        {
            let fileManager = FileManager.default
            let imagePAth = (appdel.getDirectoryPath() as NSString).appendingPathComponent(urlString)
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
                
                let encodeurl = urlString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                
                let fullurl = String(format: "%@%@",baseUrl, encodeurl!)
                
                DispatchQueue.global(qos: .background).async {
                    let downloadTask  = URLSession.shared.dataTask(with: URL(string: fullurl)!, completionHandler: { (data: Data?, response: URLResponse?,error: Error?) in
                        if (error != nil) {
                            //error
                            return
                        }
                        
                        if data != nil {
                            let image = UIImage(data: data!)
                            
                            let fileManager = FileManager.default
                            let paths = (appdel.getDirectoryPath() as NSString).appendingPathComponent(urlString)
                            
                            fileManager.createFile(atPath: paths as String, contents: data, attributes: nil)
                            
                            DispatchQueue.main.async(execute: {() in
                                self.image=image
                                indicater.stopAnimating()
                            })
                            return
                        }
                    })
                    
                    downloadTask.resume()
                }
            }
        }
    }
    
    func imageForUrl(_ baseUrl: String, urlString: String, placeHolderImage: String, completionHandler:@escaping (_ data: NSData?) -> ()) {
        
        let appdel = App_Delegate()
        
        if urlString == "" {
            self.image = UIImage(named: placeHolderImage)
        }else{
            
            let fileManager = FileManager.default
            let imagePAth = (appdel.getDirectoryPath() as NSString).appendingPathComponent(urlString)
            if fileManager.fileExists(atPath: imagePAth){
                
                let data = NSData(contentsOfFile: imagePAth)
                self.image = UIImage(data: data! as Data)
                completionHandler(data)
            }
            else
            {
                let indicater=UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
                indicater.color = UIColor.black
                indicater.frame = CGRect(x: self.center.x - 20 , y: self.center.y - 20,width: 20,height: 20)
                self.addSubview(indicater)
                indicater.startAnimating()
                
                let fullurl = String(format: "%@%@", baseUrl, urlString)
                
                DispatchQueue.global(qos: .background).async {
                    let downloadTask  = URLSession.shared.dataTask(with: URL(string: fullurl)!, completionHandler: { (data: Data?, response: URLResponse?,error: Error?) in
                        if (error != nil) {
                            print("Error occured:->\(String(describing: error?.localizedDescription))")
                            return
                        }
                        
                        if data != nil {
                            let image = UIImage(data: data!)
                            
                            let fileManager = FileManager.default
                            let paths = (appdel.getDirectoryPath() as NSString).appendingPathComponent(urlString)
                            
                            fileManager.createFile(atPath: paths as String, contents: data, attributes: nil)
                            
                            DispatchQueue.main.async(execute: {() in
                                
                                self.image = image
                                indicater.stopAnimating()
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
    
    func changeImageColor(color:UIColor)
    {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
    
    func changeImageColor()
    {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = UIColor(red: 19/255.0, green: 59/255.0, blue: 95/255.0, alpha: 1)
    }
    
    func changeWhiteImageColor()
    {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = UIColor.white
    }
}
