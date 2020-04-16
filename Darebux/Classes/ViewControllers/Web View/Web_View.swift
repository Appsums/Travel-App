//
//  Web_View.swift
//  Darebux
//
//  Created by logicspice on 22/03/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit

class Web_View: UIViewController, UIWebViewDelegate
{
    //MARK:- Outlet
    @IBOutlet var lbl_title: UILabel!
    @IBOutlet var webview_about: UIWebView!
    @IBOutlet var view_waiting: UIView!
    @IBOutlet var indicator: UIActivityIndicatorView!

    let GDP = GDP_Obj()
    let appdel = App_Delegate()

    var str_url: String!
    var str_title: String!

    //MARK:- View Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        view_waiting.isHidden = false
        indicator.startAnimating()

        lbl_title.text = str_title

        let url = NSURL (string: str_url)
        let requestObj = NSURLRequest(url: url! as URL);
        webview_about.loadRequest(requestObj as URLRequest)
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

    //MARK:- Other Methods
    func loadPageUrl(_ tmpStr: String, title: String)
    {
        lbl_title.text = title
        view_waiting.isHidden = false
        indicator.startAnimating()

        let url = NSURL (string: tmpStr)
        let requestObj = NSURLRequest(url: url! as URL);
        webview_about.loadRequest(requestObj as URLRequest)
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
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error)
    {
        indicator.stopAnimating()
        view_waiting.isHidden = true
    }
}
