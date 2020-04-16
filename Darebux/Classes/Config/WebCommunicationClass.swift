//
//  WebCommunicationClass.swift
//  HolaHotel
//
//  Created by Test on 4/18/16.
//  Copyright © 2016 DreamSoft4u. All rights reserved.
//

import AFNetworking

@objc protocol WebCommunicationClassDelegate
{
    @objc optional func dataDidFinishDowloading (aResponse : AnyObject?, methodname : String) -> (Void)

    @objc optional func dataDidFail (methodname : String , error : Error) -> (Void)
}

class WebCommunicationClass: NSObject
{
    var aCaller:AnyObject?;
    var delegate:WebCommunicationClassDelegate?
    var blanckDict = NSMutableDictionary()
    let GDP = GDP_Obj()
       
    //MARK:- Methods for user authentication
    func userRegister(dic_register:NSMutableDictionary) -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kUserSignUp(), paramDict: dic_register, dataDict: blanckDict)
    }
    
    func userLogin(dic_login:NSMutableDictionary) -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kUserLogin(), paramDict: dic_login, dataDict: blanckDict)
    }
    
    func userForgotPassword(dic_forgotPassword:NSMutableDictionary) -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kUserForgotPassword(), paramDict: dic_forgotPassword, dataDict: blanckDict)
    }
    
    func contactUs(dic_contact:NSMutableDictionary) -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kContactUs(), paramDict: dic_contact, dataDict: blanckDict)
    }
    
    //MARK:- Not used methods
    
    func changePassword(dic_forgotPassword:NSMutableDictionary) -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kChangePassword(), paramDict: dic_forgotPassword, dataDict: blanckDict)
    }
    
    func viewProfile() -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNameGet(functionName: kUserViewProfile())
    }

    func otheruserProfile(dic_data: NSMutableDictionary) -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kOtherUserProfile(), paramDict: dic_data, dataDict: blanckDict)
    }

    func alldareList(dic_data: NSMutableDictionary) -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kAllDareList(), paramDict: dic_data, dataDict: blanckDict)
    }

    func myDareList(dic_data: NSMutableDictionary, isShowProgress:Bool) -> Void
    {
        if isShowProgress
        {
            SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        }

        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kMyDares(), paramDict: dic_data, dataDict: blanckDict)
    }

    func dareDetail(dic_data: NSMutableDictionary) -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kDareDetail(), paramDict: dic_data, dataDict: blanckDict)
    }

    func acceptRejectRequest(dic_data: NSMutableDictionary) -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kAcceptRejectRequest(), paramDict: dic_data, dataDict: blanckDict)
    }

    func likeUnlikeDare(dic_data: NSMutableDictionary) -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kLikeUnlikeDare(), paramDict: dic_data, dataDict: blanckDict)
    }

    func follow_unfollow(dic_data: NSMutableDictionary) -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kFollowUnfollowUser(), paramDict: dic_data, dataDict: blanckDict)
    }

    func followingList(dic_data: NSMutableDictionary) -> Void
    {
        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kFollowingList(), paramDict: dic_data, dataDict: blanckDict)
    }

    func followerList(dic_data: NSMutableDictionary) -> Void
    {
        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kFollowerList(), paramDict: dic_data, dataDict: blanckDict)
    }

    func reportCategoryList() -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNameGet(functionName: kReportCategoryList())
    }

    func sendReport(dic_data: NSMutableDictionary) -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kReport(), paramDict: dic_data, dataDict: blanckDict)
    }

    func dashboardData() -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNameGet(functionName: kDashboardData())
    }

    func sentDareList() -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNameGet(functionName: kSentList())
    }

    func inviteDareList() -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNameGet(functionName: kInviteList())
    }

    func getAllUsersList(dic_data: NSMutableDictionary) -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kgetAllUsers(), paramDict: dic_data, dataDict: blanckDict)
    }
    
    //MARK:- Methods for user profile
    func editUserProfile(dic_editprofile:NSMutableDictionary,imgData:Data?) -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        if imgData != nil
        {
            blanckDict.setValue(imgData!, forKey: "profile_image")
        }
        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kUserEditProfile(), paramDict: dic_editprofile, dataDict: blanckDict)
    }
    
    func updateProfileImg(imgData:Data) -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        blanckDict.setValue(imgData, forKey: "profile_image")
        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kEditProfileImg(), paramDict: nil, dataDict: blanckDict)
    }    
    
    func logoutUser(dict:NSMutableDictionary) -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kLogoutUser(), paramDict: dict, dataDict: blanckDict)
    }

    func createDare(dic_editprofile: NSMutableDictionary, imgData: Data?, videoData: Data?) -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        if imgData != nil
        {
            blanckDict.setValue(imgData!, forKey: "image")
        }
        if videoData != nil
        {
            blanckDict.setValue(videoData!, forKey: "video")
        }
        
        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kCreateDare(), paramDict: dic_editprofile, dataDict: blanckDict)
    }

    func uploadResponseVideo(dic_data: NSMutableDictionary, videoData: Data?) -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        if videoData != nil
        {
            blanckDict.setValue(videoData!, forKey: "video")
        }

        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kuploadResponseVideo(), paramDict: dic_data, dataDict: blanckDict)
    }

    func postComment(dic_data: NSMutableDictionary) -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kpostComment(), paramDict: dic_data, dataDict: blanckDict)
    }

    func commentsList(dic_data: NSMutableDictionary) -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kcommentList(), paramDict: dic_data, dataDict: blanckDict)
    }

    func contributeAmount(dic_data: NSMutableDictionary) -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kContributeAmount(), paramDict: dic_data, dataDict: blanckDict)
    }

    func getVerificationCode(dic_data: NSMutableDictionary) -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kGetVerificationCode(), paramDict: dic_data, dataDict: blanckDict)
    }

    func verifyCode(dic_data: NSMutableDictionary) -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kVerifyCode(), paramDict: dic_data, dataDict: blanckDict)
    }

    func contributorList(dic_data: NSMutableDictionary) -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kContributorList(), paramDict: dic_data, dataDict: blanckDict)
    }

    func balanceList() -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNameGet(functionName: kBalanceList())
    }

    func contributionList() -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNameGet(functionName: kContributionList())
    }

    func verifyVideo(dic_data: NSMutableDictionary) -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kVerifyVideo(), paramDict: dic_data, dataDict: blanckDict)
    }

    func sendWithdrawRequest(dic_data: NSMutableDictionary) -> Void
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
        AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName: kSendWithdrawalRequest(), paramDict: dic_data, dataDict: blanckDict)
    }
    
    //MARK:- Server Response Methods
    func AFHTTPCallSyncToServerWithFunctionNameGet(functionName : String)
    {
        let manager = AFHTTPSessionManager()
        
        let finalURL = "\(base_url())\(functionName)"
        
        print(finalURL)
        
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        manager.requestSerializer.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.setValue(api_key(), forHTTPHeaderField: "key")
        if GDP.jsonToken != nil
        {
            manager.requestSerializer.setValue(GDP.jsonToken!, forHTTPHeaderField: "token")
        }
        
        manager.get(finalURL, parameters: nil, progress: nil, success: { (task: URLSessionDataTask,responseObject: Any?) in
            
            SVProgressHUD.dismiss()
            
            (self.aCaller?.dataDidFinishDowloading!(aResponse: responseObject as AnyObject? , methodname: functionName))!
            
        }, failure: { (oper: URLSessionDataTask?, weberror:Error) in
            
            SVProgressHUD.dismiss()
            
            (self.aCaller?.dataDidFail!(methodname: functionName, error: weberror))
            
            print("Error: " + weberror.localizedDescription)
        })
    }
    
    func AFHTTPCallSyncToServerWithFunctionNamePostWithJson(FunctionName : String, paramDict : NSMutableDictionary? , dataDict : NSMutableDictionary)
    {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: paramDict!, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
            
            let finalURL = "\(base_url())\(FunctionName)"
            print(finalURL)
            
            let manager = AFHTTPSessionManager()
            manager.responseSerializer = AFHTTPResponseSerializer()
            manager.requestSerializer.setValue(api_key(), forHTTPHeaderField: "key")
            print(api_key())
            
            if GDP.jsonToken != nil
            {
                manager.requestSerializer.setValue(GDP.jsonToken!, forHTTPHeaderField: "token")
            }
            
            manager.securityPolicy.allowInvalidCertificates = true
            manager.securityPolicy.validatesDomainName = false
            print(jsonString! as Any)
            
            manager.post(finalURL, parameters: nil, constructingBodyWith: { (fromdata: AFMultipartFormData) in
                
                fromdata.appendPart(withForm: jsonData, name: "jsonData")
                
                for str in dataDict.keyEnumerator()
                {
                    print(str)
                    print((dataDict.object(forKey: str) as! Data).count)
                    if str as! String == "video"
                    {
                        fromdata.appendPart(withFileData: dataDict.object(forKey: str) as! Data, name: str as! String, fileName: "darevideo.mp4", mimeType: "video/mp4")
                    }
                    else
                    {
                        fromdata.appendPart(withFileData: dataDict.object(forKey: str) as! Data, name: str as! String, fileName: "image.jpg", mimeType: "image/jpeg")
                    }
                }
                
            }, progress: nil, success: { (task: URLSessionDataTask,responseObject: Any?) in

                SVProgressHUD.dismiss()
                
                let str1 = NSString(data: responseObject as! Data, encoding: String.Encoding.utf8.rawValue)
                
                print("Server response in  string \(str1!)")

               (self.aCaller?.dataDidFinishDowloading!(aResponse: responseObject as AnyObject? , methodname: FunctionName))!
                
            }, failure: { (task: URLSessionDataTask?,error: Error) in
                
                SVProgressHUD.dismiss()
                (self.aCaller?.dataDidFail!(methodname: FunctionName, error: error))
                print("Error: " + error.localizedDescription)
            })
            
        } catch let error as NSError {
            print(error)
        }
    }

    func getLocationFromAddress(address : String, completionHandler:@escaping (_ location: CLLocationCoordinate2D?, _ error:Error? ) -> ()) {
        
        var lat : Double = 0.0
        var lon : Double = 0.0
        
        SVProgressHUD.show(with: .gradient)
        let manager = AFHTTPSessionManager()
        
        let finalURL = String(format: "https://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", (address.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!))
        
        print(finalURL)
        
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        manager.requestSerializer.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        manager.get(finalURL, parameters: nil, progress: nil, success: { (task: URLSessionDataTask,responseObject: Any?) in
            
            SVProgressHUD.dismiss()
            
            do {
                let JSONDict = try JSONSerialization.jsonObject(with: responseObject as! Data, options: []) as! NSDictionary
                
                if let resultarray = JSONDict.object(forKey: "results") as? NSArray
                {
                    if resultarray.count > 0
                    {
                        let resultDict = resultarray.object(at:0)as! NSDictionary
                        
                        if let geoDict = resultDict.object(forKey: "geometry") as? NSDictionary
                        {
                            if let locationDict = geoDict.object(forKey: "location") as? NSDictionary
                            {
                                lat = locationDict.object(forKey: "lat") as! Double
                                lon = locationDict.object(forKey: "lng") as! Double
                                
                                completionHandler(CLLocationCoordinate2D(latitude: lat, longitude: lon), nil)
                            }
                        }
                    }
                }
            }
            catch let error as NSError
            {
                print("Error from backend \(error)")
            }
            
        }, failure: { (oper: URLSessionDataTask?, weberror:Error) in
            
            SVProgressHUD.dismiss()
            
            print("Error: " + weberror.localizedDescription)
            completionHandler(nil, weberror)
        })
    }
}
