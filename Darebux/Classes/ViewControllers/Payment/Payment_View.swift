//
//  Payment_View.swift
//  Darebux
//
//  Created by logicspice on 12/06/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit

class Payment_View: UIViewController, UIWebViewDelegate
{
    //MARK:- Outlet
    @IBOutlet var webview_payment: UIWebView!
    @IBOutlet var view_waiting: UIView!
    @IBOutlet var indicator: UIActivityIndicatorView!

    let GDP = GDP_Obj()
    let appdel = App_Delegate()

    var dic_data: NSDictionary!
    var str_url: String!

    //MARK:- View Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        print(dic_data)
        str_url = "\(dic_data.object(forKey: "url")!)"

        view_waiting.isHidden = false
        indicator.startAnimating()

        let url = NSURL (string: str_url)
        let requestObj = NSURLRequest(url: url! as URL);
        webview_payment.loadRequest(requestObj as URLRequest)
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
    @IBAction func on_btnBack_click(_ sender: UIButton)
    {
        appdel.appNav.popViewController(animated: true)
    }

    //MARK:- Web View Methods
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        indicator.stopAnimating()
        view_waiting.isHidden = true

        let current_url = webView.request?.url?.absoluteString
        print("Current URL: \(current_url!)")
        if (current_url?.contains("http://darebux.logicspice.com/"))!
        {
            var isExists = false
            var frontView: UIViewController?

            for viObj in (appdel.appNav?.viewControllers)!
            {
                if viObj is DareDetailPage
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

            GDP.shouldShowAlert = true
        }
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error)
    {
        indicator.stopAnimating()
        view_waiting.isHidden = true
    }
}
