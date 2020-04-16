//
//  Search_View.swift
//  Darebux
//
//  Created by logicspice on 14/03/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit

class Search_View: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, alertClassDelegate, WebCommunicationClassDelegate
{
    //MARK:- Outlets
    @IBOutlet var btnMenu: UIButton!
    @IBOutlet var txtfld_search: UITextField!
    @IBOutlet var tbl_users: UITableView!
    @IBOutlet var lbl_msg: UILabel!

    let GDP = GDP_Obj()
    let appdel = App_Delegate()

    var arr_users: NSArray!

    //MARK:- View Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        tbl_users.register(UINib(nibName: "FollowerCell", bundle: nil), forCellReuseIdentifier: "cell")
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        GDP.leftView.setRevealContrl(reveal: self)
        btnMenu.addTarget(GDP.leftView, action: #selector(CustomRevealController.btnLeftMenuActionCall), for: UIControlEvents.touchUpInside)
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

    //MARK: - Table View Methods
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arr_users.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if UIDevice().userInterfaceIdiom == .pad
        {
            return 120
        }
        else
        {
            return 60
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell: FollowerCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FollowerCell

        let tmp_dic = arr_users.object(at: indexPath.row) as! NSDictionary

        let imageWidth = cell.lblName.frame.origin.x
        var viFrame = cell.imgUser.frame
        var maxHeight: CGFloat = 60
        var tmp_pos: CGFloat = 50
        if UIDevice().userInterfaceIdiom == .pad
        {
            maxHeight = 120
            tmp_pos = 100
        }

        if imageWidth < tmp_pos
        {
            let tmp:CGFloat = maxHeight/2 - (imageWidth)/2
            viFrame.origin.x = 5
            viFrame.origin.y = tmp
            viFrame.size.height = imageWidth
            viFrame.size.width = imageWidth
        }
        else
        {
            viFrame.origin.x = imageWidth/2 - tmp_pos/2
            viFrame.origin.y = (maxHeight - tmp_pos)/2
            viFrame.size.height = tmp_pos
            viFrame.size.width = tmp_pos
        }

        cell.imgUser.frame = viFrame
        cell.imgUser.layer.cornerRadius = cell.imgUser.bounds.size.width/2

        if let str_img = tmp_dic.object(forKey: "profile_image") as? String
        {
            cell.imgUser.imageForUrlWithImage(baseUrl: profile_image_url(), urlString: str_img, placeHolderImage: "user_Profile.png")
        }

        cell.vw_Follow.isHidden = true

        cell.lblName.text = "\(tmp_dic.object(forKey: "username")!)"

        let str_address = "\(tmp_dic.object(forKey: "address")!)"
        if str_address.trimmingCharacters(in: NSCharacterSet.init(charactersIn: ", ") as CharacterSet) == ""
        {
            cell.lblAddress.text = ""
        }
        else
        {
            cell.lblAddress.text = str_address
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let tmp_dic = arr_users.object(at: indexPath.row) as! NSDictionary
        let user_id = "\(tmp_dic.object(forKey: "id")!)"
        self.viewUserProfile(tmp_id: user_id)
    }

    //MARK:- Text Field Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        if textField == txtfld_search
        {
            getAllUsers()
        }

        return true
    }

    //MARK:- Touch Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }

    //MARK:- Web Service Methods
    func getAllUsers()
    {
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self

            let tmp_dic: NSMutableDictionary = NSMutableDictionary()
            tmp_dic.setValue(txtfld_search.text!, forKey: "keyword")
            webclass.getAllUsersList(dic_data: tmp_dic)
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }

    func viewUserProfile(tmp_id: String)
    {
        self.view.endEditing(true)
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self

            let tmp_dic: NSMutableDictionary = NSMutableDictionary()
            tmp_dic.setValue(tmp_id, forKey: "user_id")
            webclass.otheruserProfile(dic_data: tmp_dic)
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }

    func dataDidFinishDowloading(aResponse: AnyObject?, methodname: String)
    {
        do {
            let JSONDict = try JSONSerialization.jsonObject(with: aResponse as! Data, options: []) as! NSDictionary
            print("Server Response: \(JSONDict)")

            if (kgetAllUsers().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg    = JSONDict.object(forKey: "response_msg") as! String

                if responseStatus == "success"
                {
                    if let responseArr = JSONDict.object(forKey: "response_data") as? NSArray
                    {
                        arr_users = responseArr
                        if arr_users.count > 0
                        {
                            tbl_users.isHidden = false
                            lbl_msg.isHidden = true

                            tbl_users.delegate = self
                            tbl_users.dataSource = self
                            tbl_users.reloadData()
                        }
                        else
                        {
                            tbl_users.isHidden = true
                            lbl_msg.isHidden = false
                        }
                    }
                }
                else
                {
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }

            else if (kOtherUserProfile().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg    = JSONDict.object(forKey: "response_msg") as! String

                if responseStatus == "success"
                {
                    if let responseDict    = JSONDict.object(forKey: "response_data") as? NSDictionary
                    {
                        let obj_view = ProfilePage(nibName: "ProfilePage", bundle: nil)
                        obj_view.dictUserData = responseDict
                        appdel.appNav?.pushViewController(obj_view, animated: true)
                    }
                }
                else
                {
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }
        }
        catch let error as NSError
        {
            self.alertType(type: .okAlert, alertMSG: Invalid_ResMsg(), delegate: self)
            print("Error from backend \(error)")
        }
    }

    func dataDidFail (methodname : String , error : Error)
    {
        self.alertType(type: .okAlert, alertMSG: ServerErrorMsg(), delegate: self)
    }
}
