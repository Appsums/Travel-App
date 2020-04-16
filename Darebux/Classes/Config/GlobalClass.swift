//
//  GlobalClass.swift
//  Raydaar
//
//  Created by manish shrimal on 25/07/16.
//  Copyright © 2016 LogicSpice. All rights reserved.
//

import Foundation
import CoreData

class GlobalClass
{
    static let sharedInstance = GlobalClass()
    
    var userID: String!
    var qb_id: String!
    var userFirstName: String!
    var userEmail: String!
    var device_ID: String!
    var device_token = Data()
    var leftView: LeftViewController!
    var jsonToken:String?
    var topSafeArea: CGFloat = 0
    var bottomSafeArea: CGFloat = 0
    var isBeforeLogin = true
    var shouldReloadData = false
    var shouldShowAlert = false

    let charSet = NSCharacterSet.whitespacesAndNewlines
    let regex = try! NSRegularExpression(pattern: "[a-zA-Z\\s]+", options: [])
    var arr_reportCategory: NSArray!

    var dic_notification: NSDictionary!
    
    func resetControl()
    {
        userID = nil
        qb_id = ""
        userEmail = ""
        userFirstName = ""
        jsonToken = nil
        isBeforeLogin = true
        shouldReloadData = false
        arr_reportCategory = nil
        dic_notification = nil
        
        leftView = LeftViewController(nibName: "LeftViewController", bundle: nil)

        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "token")
        defaults.removeObject(forKey: "email")
        defaults.removeObject(forKey: "first_name")
        defaults.removeObject(forKey: "profile_image")
    }
    
    func adjustView(tmp_view: UIView)
    {
        var frame = tmp_view.frame
        frame.origin.y = topSafeArea
        frame.size.height = window_Height() - (topSafeArea + bottomSafeArea)
        tmp_view.frame = frame
    }
    
    func setColorAttributedText(colorStr1: String, color1: UIColor, colorStr2: String, color2: UIColor, lblObj: UILabel, fontSize: CGFloat)
    {
        let Attr1 = [NSAttributedStringKey.foregroundColor: color1 , NSAttributedStringKey.font : UIFont.systemFont(ofSize: fontSize)]
        
        let Attr2 = [NSAttributedStringKey.foregroundColor: color2 , NSAttributedStringKey.font : UIFont.systemFont(ofSize: fontSize)]
        
        let partOne = NSMutableAttributedString(string: colorStr1, attributes: Attr1)
        let partTwo = NSMutableAttributedString(string: colorStr2, attributes: Attr2)
        
        let combination = NSMutableAttributedString()
        
        combination.append(partOne)
        combination.append(partTwo)
        
        lblObj.attributedText = combination
    }

    func setFourColorAttributedText(colorStr1: String, color1: UIColor, colorStr2: String, color2: UIColor, colorStr3: String, color3: UIColor, colorStr4: String, color4: UIColor, lblObj: UILabel, fontSize: CGFloat)
    {
        let Attr1 = [NSAttributedStringKey.foregroundColor: color1, NSAttributedStringKey.font : UIFont.systemFont(ofSize: fontSize)]

        let Attr2 = [NSAttributedStringKey.foregroundColor: color2, NSAttributedStringKey.font : UIFont.systemFont(ofSize: fontSize)]

        let Attr3 = [NSAttributedStringKey.foregroundColor: color3, NSAttributedStringKey.font : UIFont.systemFont(ofSize: fontSize)]

        let Attr4 = [NSAttributedStringKey.foregroundColor: color4, NSAttributedStringKey.font : UIFont.systemFont(ofSize: fontSize)]

        let partOne = NSMutableAttributedString(string: colorStr1, attributes: Attr1)
        let partTwo = NSMutableAttributedString(string: colorStr2, attributes: Attr2)
        let partThree = NSMutableAttributedString(string: colorStr3, attributes: Attr3)
        let partFour = NSMutableAttributedString(string: colorStr4, attributes: Attr4)

        let combination = NSMutableAttributedString()

        combination.append(partOne)
        combination.append(partTwo)
        combination.append(partThree)
        combination.append(partFour)

        lblObj.attributedText = combination
    }

    func changeDateFormate(tmp_string: String, cur_formate: String, new_formate: String) -> String
    {
        let dateString = tmp_string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = cur_formate
        let dateObj = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = new_formate

        if dateObj == nil
        {
            return "N/A"
        }
        else
        {
            return dateFormatter.string(from: dateObj!)
        }
    }

    func getIPAddresses() -> String
    {
        var addresses = [String]()

        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return "" }
        guard let firstAddr = ifaddr else { return "" }

        // For each interface ...
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next })
        {
            let flags = Int32(ptr.pointee.ifa_flags)
            var addr = ptr.pointee.ifa_addr.pointee

            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING)
            {
                if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6)
                {
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST) == 0)
                    {
                        let address = String(cString: hostname)
                        addresses.append(address)
                    }
                }
            }
        }

        freeifaddrs(ifaddr)

        var tmp_ip: String! = ""
        if addresses.count > 0
        {
            tmp_ip = addresses[0]
        }

        return tmp_ip
    }

    func changeStringtoFloat(str: String) -> Float
    {
        if str.trimmingCharacters(in: charSet).count == 0
        {
            return 0
        }
        else
        {
            return Float(str)!
        }
    }
}
