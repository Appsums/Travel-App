//
//  CreateDarePage.swift
//  Darebux
//
//  Created by LogicSpice on 30/01/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation
import AVKit

class CreateDarePage: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, WebCommunicationClassDelegate, alertClassDelegate
{
    //MARK:- Outlets
    @IBOutlet var btnDareMyself:UIButton!
    @IBOutlet var btnDareFriend:UIButton!
    @IBOutlet var vw_DareTitle: UIView!
    @IBOutlet var vw_DareFriend: UIView!
    @IBOutlet var vw_Other: UIView!
    @IBOutlet var vw_DareDesc: UIView!
    @IBOutlet var txtfld_title: UITextField!
    @IBOutlet var txtfld_friend: UITextField!
    @IBOutlet var txviDareDesc: UITextView!
    @IBOutlet var lblDareDesc:UILabel!
    @IBOutlet var lblTitleCount:UILabel!
    @IBOutlet var lblDescCount:UILabel!
    @IBOutlet var btnPrivate:UIButton!
    @IBOutlet var btnCrowd:UIButton!
    @IBOutlet var vw_GoalAmt:UIView!
    @IBOutlet var txtfld_amount: UITextField!
    @IBOutlet var lbl_msg: UILabel!
    @IBOutlet var lbl_msgfund: UILabel!

    @IBOutlet var vw_upVideo: UIView!
    @IBOutlet var img_upVideo: UIImageView!
    @IBOutlet var img_upImage: UIImageView!

    @IBOutlet var vw_goalAmount: UIView!

    //Choose Friend View
    @IBOutlet var vw_choose: UIView!
    @IBOutlet var txtfld_keyword: UITextField!
    @IBOutlet var tbl_friends: UITableView!
    @IBOutlet var lbl_noMsg: UILabel!
    
    let charSet = NSCharacterSet.whitespacesAndNewlines
    let GDP = GDP_Obj()
    let appdel = App_Delegate()

    var str_userID: String!
    var str_receiverId: String!
    var str_receiverName: String!
    var str_daretype: String!
    var str_fundtype: String!

    var regExp = try! NSRegularExpression(pattern: "^\\d{0,7}(([.]\\d{1,2})|([.]))?$", options: .caseInsensitive)
    var videoPath: URL!
    var data_dare_img = Data()
    var data_dare_video = Data()

    var str_dareId: String!
    var arr_friends: NSArray!

    var filterTable: UITableView!
    var arrFiltered = NSArray()

    //MARK:- View Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.setView()
    }

    override func viewDidLayoutSubviews()
    {
        GDP.adjustView(tmp_view: self.view)
        
        btnDareMyself.layer.cornerRadius = btnDareMyself.bounds.size.height/2
        btnDareFriend.layer.cornerRadius = btnDareFriend.bounds.size.height/2
        btnPrivate.layer.cornerRadius = btnPrivate.bounds.size.height/2
        btnCrowd.layer.cornerRadius = btnCrowd.bounds.size.height/2
        
        btnDareMyself.layer.borderWidth = 1
        btnDareMyself.layer.borderColor = UIColor.black.cgColor
        
        btnDareFriend.layer.borderWidth = 1
        btnDareFriend.layer.borderColor = UIColor.black.cgColor
        
        btnPrivate.layer.borderWidth = 1
        btnPrivate.layer.borderColor = UIColor.black.cgColor
        
        btnCrowd.layer.borderWidth = 1
        btnCrowd.layer.borderColor = UIColor.black.cgColor
        
        vw_GoalAmt.layer.cornerRadius = vw_GoalAmt.bounds.size.height/2
        vw_GoalAmt.layer.borderWidth = 1
        vw_GoalAmt.layer.borderColor = UIColor(red: 193/255.0, green: 193/255.0, blue: 193/255.0, alpha: 1).cgColor
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:- Other Methods
    func setView()
    {
        tbl_friends.register(UINib(nibName: "FollowerCell", bundle: nil), forCellReuseIdentifier: "cell")

        vw_DareTitle.layer.cornerRadius = 2
        vw_DareTitle.layer.borderWidth = 1
        vw_DareTitle.layer.borderColor = UIColor(red: 193/255.0, green: 193/255.0, blue: 193/255.0, alpha: 1).cgColor

        vw_DareFriend.layer.cornerRadius = 2
        vw_DareFriend.layer.borderWidth = 1
        vw_DareFriend.layer.borderColor = UIColor(red: 193/255.0, green: 193/255.0, blue: 193/255.0, alpha: 1).cgColor

        vw_DareDesc.layer.cornerRadius = 2
        vw_DareDesc.layer.borderWidth = 1
        vw_DareDesc.layer.borderColor = UIColor(red: 193/255.0, green: 193/255.0, blue: 193/255.0, alpha: 1).cgColor

        if str_userID == GDP.userID
        {
            str_receiverId = GDP.userID
            str_receiverName = ""
            str_daretype = "Myself"

            btnPrivate.isEnabled = false
            btnPrivate.alpha = 0.0
            lbl_msg.isHidden = false

            str_fundtype = "Crowdfunding"
            btnCrowd.backgroundColor = UIColor.black
            btnPrivate.backgroundColor = UIColor.white
            btnCrowd.setTitleColor(UIColor.white, for: .normal)
            btnPrivate.setTitleColor(UIColor.black, for: .normal)
        }
        else
        {
            str_fundtype = "Crowdfunding"
            
            btnCrowd.backgroundColor = UIColor.black
            btnPrivate.backgroundColor = UIColor.white
            btnCrowd.setTitleColor(UIColor.white, for: .normal)
            btnPrivate.setTitleColor(UIColor.black, for: .normal)

            str_receiverId = str_userID
            txtfld_friend.text = str_receiverName

            btnPrivate.isEnabled = true
            btnPrivate.alpha = 1.0
            str_daretype = "Friend"
            lbl_msgfund.text = "Private you will pay full goal amount yourself and crowdfunding is raised goal amount through crowdfunding."

            btnDareFriend.backgroundColor = UIColor.black
            btnDareMyself.backgroundColor = UIColor.white
            btnDareFriend.setTitleColor(UIColor.white, for: .normal)
            btnDareMyself.setTitleColor(UIColor.black, for: .normal)
        }
    }
   
    //MARK:- Alert View Methods
    func alertOkClick()
    {
        let obj_view = DareDetailPage(nibName: "DareDetailPage", bundle: nil)
        obj_view.str_id = str_dareId
        obj_view.shouldBack = false
        appdel.appNav?.pushViewController(obj_view, animated: true)
    }

    //MARK: - Table View Methods
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == tbl_friends
        {
            return arr_friends.count
        }
        else
        {
            return arrFiltered.count
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == tbl_friends
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

        else
        {
            if UIDevice().userInterfaceIdiom == .pad
            {
                return 88
            }
            else
            {
                return 44
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == tbl_friends
        {
            let cell: FollowerCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FollowerCell

            let tmp_dic = arr_friends.object(at: indexPath.row) as! NSDictionary

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

        else
        {
            let cell:SerachCell = tableView.dequeueReusableCell(withIdentifier: "searchcell") as! SerachCell

            let dict = arrFiltered.object(at: indexPath.row) as! NSDictionary
            cell.lblText.text = "\(dict.object(forKey: "username")!)"

            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView == tbl_friends
        {
            let tmp_dic = arr_friends.object(at: indexPath.row) as! NSDictionary
            str_receiverName = "\(tmp_dic.object(forKey: "username")!)"
            str_receiverId = "\(tmp_dic.object(forKey: "id")!)"
            txtfld_friend.text = str_receiverName

            vw_choose.removeFromSuperview()
        }
        else
        {
            let tmp_dic = arrFiltered.object(at: indexPath.row) as! NSDictionary
            txtfld_keyword.text = "\(tmp_dic.object(forKey: "username")!)"

            filterTable.delegate = nil
            filterTable.dataSource = nil
            filterTable.isHidden = true

            getAllUsers()
        }
    }
    
    //MARK:- Button Click Method
    @IBAction func btn_Back_Click(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_DareMyselfFriend_Click(_ sender: UIButton)
    {
        if sender.tag == 1
        {
            str_daretype = "Myself"
            str_userID = ""
            str_receiverId = GDP.userID
            str_receiverName = ""
            txtfld_friend.text = ""

            btnDareMyself.backgroundColor = UIColor.black
            btnDareFriend.backgroundColor = UIColor.white
            btnDareFriend.setTitleColor(UIColor.black, for: .normal)
            btnDareMyself.setTitleColor(UIColor.white, for: .normal)

            btnPrivate.isEnabled = false
            btnPrivate.alpha = 0.0
            str_fundtype = "Crowdfunding"
            lbl_msg.isHidden = false
            lbl_msgfund.text = ""

            btnCrowd.backgroundColor = UIColor.black
            btnPrivate.backgroundColor = UIColor.white
            btnCrowd.setTitleColor(UIColor.white, for: .normal)
            btnPrivate.setTitleColor(UIColor.black, for: .normal)

            UIView.animate(withDuration: 0.2, animations: {
                var frame = self.vw_Other.frame
                frame.origin.y = self.vw_DareTitle.frame.origin.y + self.vw_DareTitle.frame.size.height + 8
                self.vw_Other.frame = frame
            })
        }
        else
        {
            btnPrivate.isEnabled = true
            btnPrivate.alpha = 1.0
            str_daretype = "Friend"
            lbl_msgfund.text = "Private you will pay full goal amount yourself and crowdfunding is raised goal amount through crowdfunding."

            btnDareFriend.backgroundColor = UIColor.black
            btnDareMyself.backgroundColor = UIColor.white
            btnDareFriend.setTitleColor(UIColor.white, for: .normal)
            btnDareMyself.setTitleColor(UIColor.black, for: .normal)

            UIView.animate(withDuration: 0.2, animations: {
                var frame = self.vw_Other.frame
                frame.origin.y = self.vw_DareFriend.frame.origin.y + self.vw_DareFriend.frame.size.height + 8
                self.vw_Other.frame = frame
            })
        }
    }

    @IBAction func btn_Friend_Click(_ sender: UIButton)
    {
        self.view.endEditing(true)
        getAllUsers()
    }
    
    @IBAction func btn_FundSource_Click(_ sender: UIButton)
    {
        if sender.tag == 3
        {
            lbl_msg.isHidden = true
            str_fundtype = "Private"

            btnPrivate.backgroundColor = UIColor.black
            btnCrowd.backgroundColor = UIColor.white
            btnPrivate.setTitleColor(UIColor.white, for: .normal)
            btnCrowd.setTitleColor(UIColor.black, for: .normal)
        }
        else
        {
            lbl_msg.isHidden = false
            str_fundtype = "Crowdfunding"

            btnCrowd.backgroundColor = UIColor.black
            btnPrivate.backgroundColor = UIColor.white
            btnCrowd.setTitleColor(UIColor.white, for: .normal)
            btnPrivate.setTitleColor(UIColor.black, for: .normal)
        }
    }
    
    @IBAction func btn_CreateDare_Click(_ sender: UIButton)
    {
        if checkValidation()
        {
            createDare()
        }
    }
    
    @IBAction func btn_UploadVideo_Click(_ sender: UIButton)
    {
        self.view.endEditing(true)
        guard let button = sender as? UIView else
        {
            return
        }

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.mediaTypes = [kUTTypeMovie as String]
        imagePicker.allowsEditing = true

        let chooseMenu = UIAlertController(title: nil, message: NSLocalizedString("Choose Video", comment: ""), preferredStyle: .actionSheet)
        chooseMenu.modalPresentationStyle = .popover

        let libraryAction = UIAlertAction(title: NSLocalizedString("Video Library", comment: ""), style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
            self.present(imagePicker, animated: true, completion: nil)
        })

        let takephotoAction = UIAlertAction(title: NSLocalizedString("Record Video", comment: ""), style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            if UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
            {
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                self.present(imagePicker, animated: true, completion: nil)
            }
            else
            {
                self.alertType(type: .okAlert, alertMSG: "Camera is not supported.", delegate: self)
            }
        })

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler:
        {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })

        chooseMenu.addAction(takephotoAction)
        chooseMenu.addAction(libraryAction)
        chooseMenu.addAction(cancelAction)
        if let presenter = chooseMenu.popoverPresentationController {
            presenter.sourceView = button
            presenter.sourceRect = button.bounds
        }
        self.present(chooseMenu, animated: true, completion: nil)
    }
    
    @IBAction func btn_UploadImage_Click(_ sender: UIButton)
    {
        self.view.endEditing(true)
        guard let button = sender as? UIView else
        {
            return
        }

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true

        let chooseMenu = UIAlertController(title: nil, message: NSLocalizedString("Choose Image", comment: ""), preferredStyle: .actionSheet)
        chooseMenu.modalPresentationStyle = .popover

        let libraryAction = UIAlertAction(title: NSLocalizedString("Photo Library", comment: ""), style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        })

        let takephotoAction = UIAlertAction(title: NSLocalizedString("Take Photo", comment: ""), style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            if UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
            {
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                self.present(imagePicker, animated: true, completion: nil)
            }
            else
            {
                self.alertType(type: .okAlert, alertMSG: "Camera is not supported.", delegate: self)
            }
        })

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler:
        {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })

        chooseMenu.addAction(takephotoAction)
        chooseMenu.addAction(libraryAction)
        chooseMenu.addAction(cancelAction)
        if let presenter = chooseMenu.popoverPresentationController {
            presenter.sourceView = button
            presenter.sourceRect = button.bounds
        }
        self.present(chooseMenu, animated: true, completion: nil)
    }

    @IBAction func btn_VideoPlay_Click(_ sender: UIButton)
    {
        if videoPath != nil
        {
            loadVideo()
        }
    }

    @IBAction func on_btnClose_click(_ sender: UIButton)
    {
        self.vw_choose.removeFromSuperview()
    }

    //MARK:- Image Picker Methods
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        if mediaType == (kUTTypeMovie as String)
        {
            videoPath = info[UIImagePickerControllerMediaURL] as? URL

            do {
                data_dare_video = try NSData(contentsOfFile: (videoPath?.relativePath)!, options: NSData.ReadingOptions.alwaysMapped) as Data
                img_upVideo.image = UIImage(named: "ic_play.png")
            } catch _ {
                data_dare_video = Data()
                return
            }
        }
        else
        {
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            {
                img_upImage.image = pickedImage
                data_dare_img = UIImageJPEGRepresentation(pickedImage, 1.0)!
            }
        }

        picker.dismiss(animated: true, completion: nil)
    }

    func loadVideo()
    {
        let videoPlayer = AVPlayer(url: videoPath)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = videoPlayer

        self.present(playerViewController, animated: true)
        {
            playerViewController.player!.play()
        }
    }
    
    //MARK:- Touch Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    //MARK:- Validation Methods
    func checkValidation() -> Bool
    {
        var amount = 0.0
        if ((txtfld_amount.text?.trimmingCharacters(in: charSet))?.count != 0)
        {
            amount = Double(txtfld_amount.text!)!
        }

        if ((txtfld_title.text?.trimmingCharacters(in: charSet))?.count == 0)
        {
            self.alertType(type: .okAlert, alertMSG: "Please enter dare title", delegate: self)
            return false
        }

        else if (str_daretype == "Friend" && ((txtfld_friend.text?.trimmingCharacters(in: charSet))?.count == 0))
        {
            self.alertType(type: .okAlert, alertMSG: "Please choose a friend", delegate: self)
            return false
        }

        else if ((txtfld_amount.text?.trimmingCharacters(in: charSet))?.count == 0)
        {
            self.alertType(type: .okAlert, alertMSG: "Please enter goal amount", delegate: self)
            return false
        }
        else if (amount < 5.0)
        {
            self.alertType(type: .okAlert, alertMSG: "Goal amount must be atleast $5", delegate: self)
            return false
        }

        return true
    }

    //MARK:- Text Field Methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField == txtfld_amount
        {
            if string.count == 0
            {
                return true
            }

            let existingText = textField.text!
            var completeText = "\(existingText)\(string)"

            let characterCount = completeText.count

            if(regExp.numberOfMatches(in: completeText, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, characterCount)) == 1)
            {
                if completeText == "."
                {
                    textField.insertText("0")
                }

                return true
            }
            else
            {
                return false
            }
        }

        else if textField == txtfld_title
        {
            let newString = (txtfld_title.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
            if newString.count <= 150
            {
                lblTitleCount.text = "\(newString.count)/150 Max"
                return true
            }
            else
            {
                return false
            }
        }

        else if textField == txtfld_keyword
        {
            var searchStr = ""
            var newString = ""
            var placesTableFrame: CGRect!

            searchStr = textField.text!
            newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string

            placesTableFrame = CGRect(x: txtfld_keyword.frame.origin.x, y: txtfld_keyword.frame.origin.y + txtfld_keyword.frame.size.height + 2, width: txtfld_keyword.frame.size.width, height: 140)

            if (string == "" && newString.count == 0)
            {
                filterTable.isHidden = true;
                searchStr = searchStr.substring(to: searchStr.index(before: searchStr.endIndex))
            }
            else
            {
                searchStr = searchStr.appending(string)
                if (searchStr.count == 1 && string != "")
                {
                    filterTable = UITableView(frame: placesTableFrame)
                    filterTable.register(UINib(nibName: "SerachCell", bundle: nil), forCellReuseIdentifier: "searchcell")
                    filterTable.isHidden = true;
                    filterTable.separatorStyle = .none
                    self.view.addSubview(filterTable)
                }

                let predicate = NSPredicate(format: "username contains[c] %@ AND full_name contains[c] %@", newString, newString)
                arrFiltered = arr_friends.filtered(using: predicate) as NSArray
                filterTable.delegate = self
                filterTable.dataSource = self
                filterTable.reloadData()

                filterTable.isHidden = false;
                print("filtered data \(arrFiltered)")

                if (searchStr == "" && newString.count == 0)
                {
                    filterTable.isHidden = true;
                    filterTable.removeFromSuperview()
                }
                else
                {
                    if (arrFiltered.count > 0)
                    {
                        filterTable.isHidden = false;
                        filterTable.reloadData()
                    }
                    else
                    {
                        filterTable.isHidden = true;
                    }
                }
            }

            return true
        }

        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        if textField == txtfld_keyword
        {
            getAllUsers()
        }

        return true
    }
    
    //MARK:- Text View Methods
    public func textViewDidChange(_ textView: UITextView)
    {
        if textView == txviDareDesc
        {
            if txviDareDesc.text!.trimmingCharacters(in: charSet).count == 0
            {
                lblDareDesc.isHidden = false
            }
            else
            {
                lblDareDesc.isHidden = true
            }
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView)
    {
        if textView == txviDareDesc
        {
            if txviDareDesc.text!.trimmingCharacters(in: charSet).count == 0
            {
                lblDareDesc.isHidden = false
            }
            else
            {
                lblDareDesc.isHidden = true
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        let newString = (txviDareDesc.text as NSString?)?.replacingCharacters(in: range, with: text) ?? text
        if newString.count <= 1200
        {
            lblDescCount.text = "\(newString.count)/1200 Max"
            return true
        }
        else
        {
            return false
        }
    }

    //MARK:- Web Service Methods
    func createDare()
    {
        if Reachability.isConnectedToNetwork()
        {
            let currentDate = Date()
            var dateComponent = DateComponents()
            dateComponent.day = 14

            let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
            let str_deadline = NSDate.string(from: futureDate, withFormat: "yyyy-MM-dd HH:mm:ss")

            let webclass = WebCommunicationClass()
            webclass.aCaller = self

            let tmp_dic:NSMutableDictionary = NSMutableDictionary()
            tmp_dic.setValue(txtfld_title.text!, forKey: "title")
            tmp_dic.setValue(str_daretype, forKey: "type")
            tmp_dic.setValue(str_receiverId, forKey: "receiver_id")
            tmp_dic.setValue("", forKey: "receiver_email")
            tmp_dic.setValue(str_fundtype, forKey: "fund_source")
            tmp_dic.setValue(txviDareDesc.text!, forKey: "description")
            tmp_dic.setValue(str_deadline, forKey: "deadline")
            tmp_dic.setValue(txtfld_amount.text!, forKey: "goal_amount")
            webclass.createDare(dic_editprofile: tmp_dic, imgData: data_dare_img, videoData: data_dare_video)
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }

    func getAllUsers()
    {
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self

            let tmp_dic: NSMutableDictionary = NSMutableDictionary()
            tmp_dic.setValue(txtfld_keyword.text!, forKey: "keyword")
            webclass.getAllUsersList(dic_data: tmp_dic)
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

            if (kCreateDare().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg    = JSONDict.object(forKey: "response_msg") as! String

                if responseStatus == "success"
                {
                    if let responseDict    = JSONDict.object(forKey: "response_data") as? NSDictionary
                    {
                        GDP.shouldReloadData = true
                        str_dareId = "\(responseDict.object(forKey: "id")!)"

                        self.alertType(type: .okAlertwithDelegate, alertMSG: responseMsg, delegate: self)
                    }
                }
                else
                {
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }

            else if (kgetAllUsers().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg    = JSONDict.object(forKey: "response_msg") as! String

                if responseStatus == "success"
                {
                    if let responseArr = JSONDict.object(forKey: "response_data") as? NSArray
                    {
                        arr_friends = responseArr
                        if arr_friends.count > 0
                        {
                            tbl_friends.isHidden = false
                            lbl_noMsg.isHidden = true

                            if txtfld_keyword.text?.trimmingCharacters(in: GDP.charSet).count == 0
                            {
                                vw_choose.frame = CGRect(x: 0, y: window_Height(), width: window_Width(), height: window_Height() - (self.GDP.topSafeArea + self.GDP.bottomSafeArea))
                                self.view.addSubview(vw_choose)

                                UIView.animate(withDuration: 0.3) {

                                    self.vw_choose.frame = CGRect(x: 0, y: 0, width: window_Width(), height: window_Height() - (self.GDP.topSafeArea + self.GDP.bottomSafeArea))
                                }
                            }

                            else
                            {
                                tbl_friends.delegate = self
                                tbl_friends.dataSource = self
                                tbl_friends.reloadData()
                            }
                        }
                        else
                        {
                            if txtfld_keyword.text?.trimmingCharacters(in: GDP.charSet).count == 0
                            {
                                vw_choose.frame = CGRect(x: 0, y: window_Height(), width: window_Width(), height: window_Height() - (self.GDP.topSafeArea + self.GDP.bottomSafeArea))
                                self.view.addSubview(vw_choose)

                                UIView.animate(withDuration: 0.3) {

                                    self.vw_choose.frame = CGRect(x: 0, y: 0, width: window_Width(), height: window_Height() - (self.GDP.topSafeArea + self.GDP.bottomSafeArea))
                                }
                            }

                            tbl_friends.isHidden = true
                            lbl_noMsg.isHidden = false

                            self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                        }
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
