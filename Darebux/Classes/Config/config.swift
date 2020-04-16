//
//  config.swift
//  Raydaar
//
//  Created by manish shrimal on 22/07/16.
//  Copyright © 2016 LogicSpice. All rights reserved.
//

import Foundation
import UIKit

//MARK:- Enum for Alert
enum alertType
{    
    case okAlert
    case okAlertwithDelegate
    case YNAlert
    case YNClickAlert
    case OkCancelAlert
}

//MARK:- Enum for Alert
let NOT_ACTIVE   = "0"
let PENDING      = "1"
let DECLINED     = "2"
let ACCEPTED     = "3"
let COMPLETED    = "4"
let CANCELLED    = "5"
let REFUNDED     = "6"
let REPORTED     = "7"

//MARK:- Common Methods
func window_Width()->CGFloat
{
    return UIScreen.main.bounds.size.width
}

func window_Height()->CGFloat
{
    return UIScreen.main.bounds.size.height
}

func main_base_url()->String
{
    return "http://darebux.logicspice.com/"
}

func base_url()->String
{
    return "\(main_base_url())api/"
}

func api_key()->String
{
    return "d54a87e45b2ux"
}

func app_color()->UIColor
{
    return UIColor.init(red: 34.0/255.0, green: 163.0/255.0, blue: 49.0/255.0, alpha: 1.0)
}

func profile_image_url()->String
{
    return "\(main_base_url())webroot/files/users/full/"
}

func dare_image_url()->String
{
    return "\(main_base_url())webroot/files/dares/images/"
}

func dare_video_url()->String
{
    return "\(main_base_url())webroot/files/dares/videos/"
}

func faq_page_url()->String
{
    return "\(main_base_url())page/faq"
}

func terms_and_conditions_url()->String
{
    return "\(main_base_url())page/terms_and_conditions"
}

func about_us_url()->String
{
    return "\(main_base_url())page/about"
}

func App_Delegate()->AppDelegate
{
    return UIApplication.shared.delegate as! AppDelegate
}

func GDP_Obj()->GlobalClass
{
    return GlobalClass.sharedInstance
}

func AppName()->String
{
    return "darebux"
}

func kDeviceType()->String
{
    return "iPhone"
}

func kNo_Internet()->String
{
    return "No Internet Connection"
}

func ServerErrorMsg()->String
{
    return "There seems to be some problem either with your connection or our server, please try again."
}

func Invalid_ResMsg()->String
{
    return "Invalid Server Response"
}

//MARK:- Quickblox Methods
func kQBApplicationID()->NSInteger
{
    return 68660
}

func kQBAuthKey()->String
{
    return "v-Zubv7kB52Rgwh"
}

func kQBAuthSecret()->String
{
    return "DNd63Pe5vtGnXdb"
}

func kQBAccountKey()->String
{
    return "aR_vwxPsXTn5Wrc9NsGs"
}

//MARK:- Methods for user Authentication
func kUserSignUp()->String
{
    return "users/register"
}

func kUserLogin()->String
{
    return "users/login"
}

func kUserForgotPassword()->String
{
    return "users/forgotPassword"
}

func kContactUs()->String
{
    return "contactus"
}

//*****************************

//MARK:- Methods for user profile
func kUserViewProfile()->String
{
    return "users/getprofile"
}

func kOtherUserProfile()->String
{
    return "users/getotheruserprofile"
}

func kUserEditProfile()->String
{
    return "users/editprofile"
}

func kEditProfileImg()->String
{
    return "changePicture"
}

func kChangePassword()->String
{
    return "users/changePassword"
}

func kLogoutUser()->String
{
    return "logout"
}

func kCreateDare()->String
{
    return "dares/create"
}

func kAllDareList()->String
{
    return "dares/dareList"
}

func kMyDares()->String
{
    return "dares/acceptedDarelist"
}

func kDareDetail()->String
{
    return "dares/getdareinfo"
}

func kAcceptRejectRequest()->String
{
    return "dares/updatedarestatus"
}

func kLikeUnlikeDare()->String
{
    return "dares/likeunlike"
}

func kFollowUnfollowUser()->String
{
    return "users/followunfollow"
}

func kFollowingList()->String
{
    return "users/followedbyme"
}

func kFollowerList()->String
{
    return "users/myfollowers"
}

func kReportCategoryList()->String
{
    return "dares/categories"
}

func kReport()->String
{
    return "dares/report"
}

func kDashboardData()->String
{
    return "users/dashboard"
}

func kSentList()->String
{
    return "dares/sentdarelist"
}

func kInviteList()->String
{
    return "dares/receivedarelist"
}

func kgetAllUsers()->String
{
    return "users/userslist"
}

func kuploadResponseVideo()->String
{
    return "dares/postResponseVideo"
}

func kpostComment()->String
{
    return "dares/postComment"
}

func kcommentList()->String
{
    return "dares/commentList"
}

func kGetVerificationCode()->String
{
    return "dares/getVerificationCode"
}

func kVerifyCode()->String
{
    return "dares/verifyCode"
}

func kContributeAmount()->String
{
    return "dares/contribute"
}

func kContributorList()->String
{
    return "dares/contributerList"
}

func kContributionList()->String
{
    return "dares/myContribution"
}

func kBalanceList()->String
{
    return "users/getTransactionList"
}

func kVerifyVideo()->String
{
    return "dares/verifyResponse"
}

func kSendWithdrawalRequest()->String
{
    return "users/sendWithdrawalRequest"
}
