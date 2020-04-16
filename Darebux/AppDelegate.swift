//
//  AppDelegate.swift
//  Darebux
//
//  Created by LogicSpice on 25/01/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import UserNotifications
import Quickblox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    var appNav: UINavigationController!
    var mainView:UIViewController?
    let GDP = GDP_Obj()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        QBSettings.applicationID = UInt(kQBApplicationID())
        QBSettings.authKey = kQBAuthKey()
        QBSettings.authSecret = kQBAuthSecret()
        QBSettings.accountKey = kQBAccountKey()
        QBSettings.carbonsEnabled = true

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.backgroundColor = UIColor.black

        UIApplication.shared.applicationIconBadgeNumber = 0
        
        if #available(iOS 11.0, *)
        {
            if window_Height() == 812
            {
                GDP_Obj().topSafeArea = window!.safeAreaInsets.top
                GDP_Obj().bottomSafeArea = window!.safeAreaInsets.bottom
            }
            else
            {
                GDP_Obj().topSafeArea = 20
                GDP_Obj().bottomSafeArea = 0
            }
        }
        else
        {
            GDP_Obj().topSafeArea = 20
            GDP_Obj().bottomSafeArea = 0
        }
        
        let defaults = UserDefaults.standard
        let jsonToken = defaults.value(forKey: "token")
        if jsonToken == nil
        {
            GDP.isBeforeLogin = true
            mainView = FirstView(nibName: "FirstView", bundle: nil)
        }
        else
        {
            GDP.isBeforeLogin = false
            GDP.jsonToken = jsonToken as? String
            GDP.qb_id = "\(defaults.value(forKey: "quickblox_id")!)"
            GDP.userID = "\(defaults.value(forKey: "user_id")!)"
            GDP.userFirstName = "\(defaults.value(forKey: "first_name")!)"
            GDP.userEmail = "\(defaults.value(forKey: "email")!)"
            mainView = HomePage(nibName: "HomePage", bundle: nil)
            GDP.leftView = LeftViewController(nibName: "LeftViewController", bundle: nil)

            print(GDP.jsonToken!)
        }
        
        appNav = UINavigationController(rootViewController: mainView!)
        appNav?.isNavigationBarHidden = true;
        window!.rootViewController = self.appNav
        window!.makeKeyAndVisible()
        
        // iOS 10 support
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            application.registerForRemoteNotifications()
        }
            // iOS 9 support
        else if #available(iOS 9, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 8 support
        else if #available(iOS 8, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 7 support
        else {
            application.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
    {
        let sourceApplication: String? = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: sourceApplication, annotation: nil)

    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        QBChat.instance.disconnect(completionBlock: nil)
    }

    //MARK:- Notification Methods
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        GDP.device_ID = deviceTokenString
        GDP.device_token = deviceToken
        print("Registered device: \(GDP.device_ID)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    {
        print(error.localizedDescription);
        print("Did fail to register device token")
        
        GDP.device_ID = "123"
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any])
    {
        print("notification detail \(userInfo)")
        if application.applicationState != UIApplicationState.active
        {
            if let tmp_dic = ((userInfo as NSDictionary).object(forKey: "aps") as! NSDictionary).object(forKey: "body") as? NSDictionary
            {
                GDP.dic_notification = tmp_dic

                let defaults = UserDefaults.standard
                let jsonToken = defaults.value(forKey: "token")
                if jsonToken != nil
                {
                    GDP.isBeforeLogin = false
                    GDP.jsonToken = jsonToken as? String
                    GDP.qb_id = "\(defaults.value(forKey: "quickblox_id")!)"
                    GDP.userID = "\(defaults.value(forKey: "user_id")!)"
                    GDP.userFirstName = "\(defaults.value(forKey: "first_name")!)"
                    GDP.userEmail = "\(defaults.value(forKey: "email")!)"
                    GDP.leftView = LeftViewController(nibName: "LeftViewController", bundle: nil)

                    let notiView = HomePage(nibName: "HomePage", bundle: nil)
                    appNav = UINavigationController(rootViewController: notiView)
                    appNav?.isNavigationBarHidden = true;
                    window!.rootViewController = self.appNav
                    window!.makeKeyAndVisible()
                }
            }
        }
    }

    //MARK:- Other Methods
    func getDirectoryPath() -> String
    {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    func showLoginAlert(controller: UIViewController!)
    {
        let alert = UIAlertController(title: AppName(), message: "To access this feature you need to either login or register into the app", preferredStyle: UIAlertControllerStyle.alert)

        alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { action in
            switch action.style
            {
            case .default:

                let loginView = FirstView(nibName: "FirstView", bundle: nil)
                self.appNav = UINavigationController(rootViewController: loginView)
                self.appNav?.setNavigationBarHidden(true, animated: false)
                self.window?.rootViewController = self.appNav
                self.window?.makeKeyAndVisible()

            case .cancel:
                print("cancel")

            case .destructive:
                print("destructive")
            }}))

        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            switch action.style
            {
            case .default:
                print("default")

            case .cancel:
                print("cancel")

            case .destructive:
                print("destructive")
            }}))

        controller.present(alert, animated: true, completion: nil)
    }
}

