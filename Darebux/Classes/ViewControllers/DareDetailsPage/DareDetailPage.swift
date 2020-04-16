//
//  DareDetailPage.swift
//  Darebux
//
//  Created by LogicSpice on 03/02/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit
import MediaPlayer
import GTProgressBar
import CZPicker
import MobileCoreServices
import AVFoundation
import AVKit

class DareDetailPage: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, CZPickerViewDelegate, CZPickerViewDataSource, WebCommunicationClassDelegate, alertClassDelegate
{
    //MARK:- Outlets
    @IBOutlet var vw_retry: UIView!
    @IBOutlet var btn_retry: UIButton!
    
    @IBOutlet var scrl_main: TPKeyboardAvoidingScrollView!
    
    @IBOutlet var vw_request: UIView!
    @IBOutlet var img_sender: UIImageView!
    @IBOutlet var lbl_senderName: UILabel!
    
    @IBOutlet var vw_detail: UIView!
    @IBOutlet var vw_report: UIView!
    @IBOutlet var ic_report: UIImageView!
    
    @IBOutlet var vw_video: UIView!
    @IBOutlet var lbl_darevideo: UILabel!
    
    @IBOutlet var vw_image: UIView!
    @IBOutlet var img_dare: UIImageView!
    
    @IBOutlet var vw_resvideo: UIView!
    @IBOutlet var lbl_resvideo: UILabel!
    
    @IBOutlet var lbl_taskVideo: UILabel!
    @IBOutlet var lbl_taskVideoBottom: UILabel!
    @IBOutlet var lbl_taskImage: UILabel!
    @IBOutlet var lbl_taskImageBottom: UILabel!
    @IBOutlet var lbl_responseVideo: UILabel!
    @IBOutlet var lbl_responseVideoBottom: UILabel!
    
    @IBOutlet var vw_about: UIView!
    @IBOutlet var lbl_title: UILabel!
    @IBOutlet var img_creator: UIImageView!
    @IBOutlet var btn_creator: UIButton!
    @IBOutlet var lbl_creator: UILabel!
    @IBOutlet var lbl_status: UILabel!
    @IBOutlet var img_acceptor: UIImageView!
    @IBOutlet var btn_acceptor: UIButton!
    @IBOutlet var lbl_acceptor: UILabel!
    
    @IBOutlet var lbl_views: UILabel!
    @IBOutlet var lbl_deadline: UILabel!
    @IBOutlet var ic_like: UIImageView!
    @IBOutlet var lbl_likes: UILabel!
    @IBOutlet var btn_contribute: UIButton!
    
    @IBOutlet var vw_verify: UIView!
    @IBOutlet var ic_verify: UIImageView!
    @IBOutlet var btn_verify: UIButton!
    
    @IBOutlet var lbl_contributors: UILabel!
    @IBOutlet var ic_down1: UIImageView!
    @IBOutlet var lbl_comments: UILabel!
    @IBOutlet var goal_bar: GTProgressBar!
    @IBOutlet var lbl_goalAmount: UILabel!
    @IBOutlet var lbl_postdate: UILabel!
    @IBOutlet var txtvw_description: UITextView!
    @IBOutlet var btn_ReadMore: UIButton!
    
    @IBOutlet var txtvw_msg: UITextView!
    @IBOutlet var lbl_placeholder: UILabel!
    @IBOutlet var btn_post: UIButton!
    @IBOutlet var ic_send: UIImageView!
    
    //Report Message View
    @IBOutlet var vw_reportMsg: UIView!
    @IBOutlet var txtfld_conType: UITextField!
    @IBOutlet var txtfld_category: UITextField!
    @IBOutlet var vw_subject: UIView!
    @IBOutlet var txtfld_subject: UITextField!
    @IBOutlet var vw_message: UIView!
    @IBOutlet var txtvw_comment: UITextView!
    
    //Contributor List
    @IBOutlet var vw_contributors: UIView!
    @IBOutlet var lbl_count: UILabel!
    @IBOutlet var lbl_amount: UILabel!
    @IBOutlet var tbl_contributor: UITableView!
    
    let GDP = GDP_Obj()
    let appdel = App_Delegate()
    
    var str_id: String!
    var str_invite: String!
    var dic_daredata: NSDictionary!
    var str_likeStatus: String!
    var str_selectedIds: String! = ""
    var str_status: String! = ""
    
    var shouldUploadResponseVideo: Bool!
    var videoPath: URL!
    var data_dare_video = Data()
    
    var dare_videoPlayer: MPMoviePlayerController!
    var response_videoPlayer: MPMoviePlayerController!
    
    var arr_contributor: NSArray!
    var arr_comments: NSArray!
    var isReadMore: Bool = false
    var shouldBack: Bool!
    var isCallApi: Bool! = true
    var is_video_reported: String = ""
    
    //MARK:- View Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tbl_contributor.register(UINib(nibName: "Custom_Cell", bundle: nil), forCellReuseIdentifier: "cell")
        
        //ic_report.changeWhiteImageColor()
        ic_down1.changeImageColor(color: UIColor.init(red: 48.0/255.0, green: 100.0/255.0, blue: 225.0/255.0, alpha: 1.0))
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        if isCallApi == false
        {
            isCallApi = true
        }
        else
        {
            getDareDetail()
        }
        
        if GDP.shouldShowAlert == true
        {
            GDP.shouldShowAlert = false
            self.alertType(type: .okAlert, alertMSG: "Thanks for contributing, the contribution progress bar will be updated shortly", delegate: self)
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        GDP_Obj().adjustView(tmp_view: self.view)
        
        let width = lbl_acceptor.frame.origin.x - 4
        let height = vw_about.frame.size.height - 14
        
        if width > height
        {
            img_creator.frame = CGRect(x: 0, y: 7, width: height, height: height)
            img_acceptor.frame = CGRect(x: vw_about.frame.size.width - height, y: 7, width: height, height: height)
        }
        else
        {
            img_creator.frame = CGRect(x: 0, y: 7, width: width, height: width)
            img_acceptor.frame = CGRect(x: vw_about.frame.size.width - width, y: 7, width: width, height: width)
        }
        
        btn_creator.frame = img_creator.frame
        btn_acceptor.frame = img_acceptor.frame
        
        img_creator.layer.cornerRadius = img_creator.frame.size.height/2
        img_creator.layer.borderWidth = 1.0
        img_creator.layer.borderColor = UIColor.white.cgColor
        
        img_acceptor.layer.cornerRadius = img_acceptor.frame.size.height/2
        img_acceptor.layer.borderWidth = 1.0
        img_acceptor.layer.borderColor = UIColor.white.cgColor
        
        txtvw_comment.layer.borderWidth = 1.0
        txtvw_comment.layer.borderColor = UIColor.black.cgColor
        txtvw_comment.clipsToBounds = true
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        if dare_videoPlayer != nil
        {
            dare_videoPlayer.stop()
        }
        
        if response_videoPlayer != nil
        {
            response_videoPlayer.stop()
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Other Methods
    func loadDareData()
    {
        showFirstView()
        
        let task_image = "\(dic_daredata.object(forKey: "image")!)"
        if task_image.trimmingCharacters(in: GDP.charSet).count > 0
        {
            img_dare.contentMode = .scaleAspectFit
        }
        else
        {
            img_dare.contentMode = .scaleAspectFill
        }
        
        is_video_reported = "\(dic_daredata.object(forKey: "is_video_reported")!)"
        if "\(dic_daredata.object(forKey: "user_id")!)" == GDP.userID || GDP.userID == nil
        {
            vw_report.isHidden = true
        }
        else
        {
            vw_report.isHidden = false
        }
        
        let goal_amount = Float("\(dic_daredata.object(forKey: "goal_amount")!)")!
        let raised_amount = Float("\(dic_daredata.object(forKey: "raised_amount")!)")!
        
        if "\(dic_daredata.object(forKey: "acceptor_id")!)" == GDP.userID && "\(dic_daredata.object(forKey: "response_video")!)" == "" && ("\(dic_daredata.object(forKey: "status")!)" == ACCEPTED || "\(dic_daredata.object(forKey: "status")!)" == REPORTED)
        {
            if raised_amount >= goal_amount
            {
                shouldUploadResponseVideo = true
                lbl_responseVideo.text = "Upload Response Video"
            }
            else
            {
                shouldUploadResponseVideo = false
                lbl_responseVideo.text = "Response Video"
            }
        }
        else
        {
            shouldUploadResponseVideo = false
            lbl_responseVideo.text = "Response Video"
        }
        
        if "\(dic_daredata.object(forKey: "status")!)" == PENDING || "\(dic_daredata.object(forKey: "status")!)" == DECLINED || "\(dic_daredata.object(forKey: "status")!)" == CANCELLED || "\(dic_daredata.object(forKey: "status")!)" == NOT_ACTIVE || "\(dic_daredata.object(forKey: "status")!)" == REFUNDED
        {
            btn_contribute.isHidden = true
            vw_verify.isHidden = true
        }
        else if ("\(dic_daredata.object(forKey: "status")!)" == COMPLETED)
        {
            vw_verify.isHidden = false
            ic_verify.image = UIImage(named: "btn_verified.png")
            btn_verify.isEnabled = false
        }
        else
        {
            if "\(dic_daredata.object(forKey: "fund_source")!)" == "Private"
            {
                if "\(dic_daredata.object(forKey: "user_id")!)" == GDP.userID
                {
                    if raised_amount >= goal_amount
                    {
                        btn_contribute.isHidden = true
                        lbl_deadline.isHidden = true
                    }
                    else
                    {
                        btn_contribute.isHidden = false
                    }
                }
                else
                {
                    if GDP.userID == nil || GDP.userID == ""
                    {
                        btn_contribute.isHidden = true
                    }
                    else
                    {
                        btn_contribute.isHidden = false
                    }
                }
            }
            else
            {
                //source=public
                if "\(dic_daredata.object(forKey: "acceptor_id")!)" == GDP.userID
                {
                    btn_contribute.isHidden = true
                }
                else
                {
                    if raised_amount >= goal_amount
                    {
                        btn_contribute.isHidden = true
                        lbl_deadline.isHidden = true
                    }
                    else
                    {
                        if GDP.userID == nil || GDP.userID == ""
                        {
                            btn_contribute.isHidden = true
                        }
                        else
                        {
                            btn_contribute.isHidden = false
                        }
                    }
                }
            }
        }
        
        if "\(dic_daredata.object(forKey: "is_verified")!)" == "1"
        {
            vw_verify.isHidden = false
            ic_verify.image = UIImage(named: "btn_verified.png")
            btn_verify.isEnabled = false
        }
        else
        {
            if "\(dic_daredata.object(forKey: "can_verify")!)" == "0"
            {
                vw_verify.isHidden = true
            }
            else
            {
                vw_verify.isHidden = false
                ic_verify.image = UIImage(named: "btn_verify.png")
                btn_verify.isEnabled = true
            }
        }
        
        img_dare.imageForUrlWithImage(baseUrl: dare_image_url(), urlString: "\(dic_daredata.object(forKey: "image")!)", placeHolderImage: "no_image.png")
        
        img_creator.imageForUrlWithImage(baseUrl: profile_image_url(), urlString: "\(dic_daredata.object(forKey: "creator_image")!)", placeHolderImage: "user_Profile.png")
        
        img_acceptor.imageForUrlWithImage(baseUrl: profile_image_url(), urlString: "\(dic_daredata.object(forKey: "acceptor_image")!)", placeHolderImage: "user_Profile.png")
        
        lbl_title.text = "\(dic_daredata.object(forKey: "title")!)"
        lbl_creator.text = "\(dic_daredata.object(forKey: "creator_name")!)"
        if "\(dic_daredata.object(forKey: "type")!)" == "Myself"
        {
            lbl_acceptor.text = "\(dic_daredata.object(forKey: "creator_name")!) (SELF)"
        }
        else
        {
            lbl_acceptor.text = "\(dic_daredata.object(forKey: "acceptor_name")!)"
        }
        
        let status = "\(dic_daredata.object(forKey: "status")!)"
        if status == PENDING
        {
            lbl_status.text = "PENDING"
            lbl_status.backgroundColor = UIColor.gray
        }
        else if status == ACCEPTED || status == REPORTED
        {
            lbl_status.text = "ACCEPTED"
            lbl_status.backgroundColor = app_color()
        }
        else if status == CANCELLED
        {
            lbl_status.text = "CANCELLED"
            lbl_status.backgroundColor = UIColor.red
        }
        else if status == COMPLETED
        {
            lbl_status.text = "COMPLETED"
            lbl_status.backgroundColor = app_color()
        }
        else if status == DECLINED
        {
            lbl_status.text = "REJECTED"
            lbl_status.backgroundColor = UIColor.red
            lbl_deadline.isHidden = true
        }
        else if status == REFUNDED
        {
            lbl_status.text = "REFUNDED"
            lbl_status.backgroundColor = UIColor.red
            lbl_deadline.isHidden = true
        }
        else if status == NOT_ACTIVE
        {
            lbl_status.text = "INACTIVE"
            lbl_status.backgroundColor = UIColor.red
        }
        
        lbl_postdate.text = "Created: \(dic_daredata.object(forKey: "posted_on")!)"
        lbl_views.text = "\(dic_daredata.object(forKey: "view_count")!) views"
        
        lbl_likes.text = "\(dic_daredata.object(forKey: "like_count")!)"
        if "\(dic_daredata.object(forKey: "is_liked")!)" == "0"
        {
            str_likeStatus = "unlike"
            ic_like.image = UIImage(named: "follow.png")
        }
        else
        {
            str_likeStatus = "like"
            ic_like.image = UIImage(named: "ic_following.png")
        }
        
        lbl_contributors.text = "\(dic_daredata.object(forKey: "contributor_count")!) Contributors"
        
        let comment_count = "\(dic_daredata.object(forKey: "comment_count")!)"
        if comment_count == "1"
        {
            lbl_comments.text = "\(dic_daredata.object(forKey: "comment_count")!) Comment"
        }
        else
        {
            lbl_comments.text = "\(dic_daredata.object(forKey: "comment_count")!) Comments"
        }
        
        lbl_goalAmount.text = "$\(dic_daredata.object(forKey: "raised_amount")!)/$\(dic_daredata.object(forKey: "goal_amount")!)"
        let amount_raised = Float("\(dic_daredata.object(forKey: "raised_amount")!)")!
        let amount_goal = Float("\(dic_daredata.object(forKey: "goal_amount")!)")!
        goal_bar.progress = CGFloat(amount_raised/amount_goal)
        
        let str_description = "\(dic_daredata.object(forKey: "description")!)"
        if str_description.count > 150
        {
            let trimmed_str = String(str_description.prefix(150))
            txtvw_description.text = trimmed_str
            btn_ReadMore.isHidden = false
        }
        else
        {
            txtvw_description.text = str_description
            btn_ReadMore.isHidden = true
        }
        
        lbl_deadline.text = "Deadline \(dic_daredata.object(forKey: "deadline")!)"
        
        let dateString = "\(dic_daredata.object(forKey: "deadline")!)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let expDate = dateFormatter.date(from: dateString)
        
        let cur_str = "\(dic_daredata.object(forKey: "current_date")!)"
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let curDate = dateFormatter.date(from: cur_str)
        
        if expDate != nil
        {
            let remainingDays = Calendar.current.dateComponents([.day], from: curDate!, to: expDate!).day ?? 0
            if (remainingDays) < 0
            {
                lbl_deadline.text = "Deadline Expired"
                btn_contribute.isHidden = true
            }
            else if (remainingDays) > 0
            {
                lbl_deadline.text = "\(remainingDays + 1) days left"
            }
            else if (remainingDays) == 0
            {
                lbl_deadline.text = "Expiring Today"
            }
        }
            
        else
        {
            lbl_deadline.text = "Deadline N/A"
            btn_contribute.isHidden = true
        }
        
        if raised_amount >= goal_amount
        {
            if "\(dic_daredata.object(forKey: "response_video")!)" == ""
            {
                let remain_days = "\(dic_daredata.object(forKey: "video_uploading_remaining_days")!)"
                if remain_days == "0" || remain_days == ""
                {
                    lbl_deadline.text = "dare expired, response video not uploaded within 14 days"
                    
                    shouldUploadResponseVideo = false
                    lbl_responseVideo.text = "Response Video"
                }
                else
                {
                    lbl_deadline.text = "\(dic_daredata.object(forKey: "video_uploading_remaining_days")!) days left to upload response video"
                }
            }
            else
            {
                lbl_deadline.isHidden = true
            }
        }
        
        if "\(dic_daredata.object(forKey: "is_invite")!)" == "1"
        {
            var frame = vw_detail.frame
            frame.origin.y = vw_request.frame.origin.y + vw_request.frame.size.height
            vw_detail.frame = frame
            
            img_sender.imageForUrlWithImage(baseUrl: profile_image_url(), urlString: "\(dic_daredata.object(forKey: "creator_image")!)", placeHolderImage: "user_Profile.png")
            img_sender.layer.cornerRadius = img_sender.frame.size.width/2
            
            lbl_senderName.text = "\(dic_daredata.object(forKey: "creator_name")!)"
        }
    }
    
    func showFirstView()
    {
        let task_video = "\(dic_daredata.object(forKey: "video")!)"
        
        if task_video.trimmingCharacters(in: GDP.charSet).count > 0
        {
            vw_video.isHidden = false
            vw_image.isHidden = true
            vw_resvideo.isHidden = true
            
            lbl_taskVideo.textColor = UIColor.init(red: 35.0/255.0, green: 166.0/255.0, blue: 46.0/255.0, alpha: 1.0)
            lbl_taskVideoBottom.backgroundColor = UIColor.init(red: 35.0/255.0, green: 166.0/255.0, blue: 46.0/255.0, alpha: 1.0)
            
            lbl_taskImage.textColor = UIColor.black
            lbl_taskImageBottom.backgroundColor = UIColor.init(red: 141.0/255.0, green: 143.0/255.0, blue: 143.0/255.0, alpha: 1.0)
            
            lbl_responseVideo.textColor = UIColor.black
            lbl_responseVideoBottom.backgroundColor = UIColor.init(red: 141.0/255.0, green: 143.0/255.0, blue: 143.0/255.0, alpha: 1.0)
            
            let dare_video = "\(dare_video_url())\(dic_daredata.object(forKey: "video")!)"
            if dare_video == "\(dare_video_url())"
            {
                lbl_darevideo.isHidden = false
                if dare_videoPlayer != nil
                {
                    dare_videoPlayer.view.isHidden = true
                }
            }
            else
            {
                lbl_darevideo.isHidden = true
                
                if dare_videoPlayer != nil
                {
                    dare_videoPlayer.view.isHidden = false
                }
                
                let dare_url = URL(string: dare_video)
                
                dare_videoPlayer = MPMoviePlayerController(contentURL: dare_url)
                dare_videoPlayer.view.frame = CGRect(x: 0, y: 0, width: vw_video.frame.size.width, height: vw_video.frame.size.height)
                vw_video.addSubview(dare_videoPlayer.view)
                dare_videoPlayer.controlStyle = MPMovieControlStyle.embedded
                dare_videoPlayer.play()
            }
        }
            
        else
        {
            if dare_videoPlayer != nil
            {
                dare_videoPlayer.stop()
            }
            
            if response_videoPlayer != nil
            {
                response_videoPlayer.stop()
            }
            
            vw_video.isHidden = true
            vw_image.isHidden = false
            vw_resvideo.isHidden = true
            
            lbl_taskVideo.textColor = UIColor.black
            lbl_taskVideoBottom.backgroundColor = UIColor.init(red: 141.0/255.0, green: 143.0/255.0, blue: 143.0/255.0, alpha: 1.0)
            
            lbl_taskImage.textColor = UIColor.init(red: 35.0/255.0, green: 166.0/255.0, blue: 46.0/255.0, alpha: 1.0)
            lbl_taskImageBottom.backgroundColor = UIColor.init(red: 35.0/255.0, green: 166.0/255.0, blue: 46.0/255.0, alpha: 1.0)
            
            lbl_responseVideo.textColor = UIColor.black
            lbl_responseVideoBottom.backgroundColor = UIColor.init(red: 141.0/255.0, green: 143.0/255.0, blue: 143.0/255.0, alpha: 1.0)
        }
    }
    
    //MARK:- Alert View Methods
    func alertOkClick()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Picker View Methods
    func showPickerView()
    {
        self.view.endEditing(true)
        let arr_names = GDP.arr_reportCategory.value(forKey: "name") as? NSArray
        
        let picker = CZPickerView(headerTitle: "Report", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
        picker?.delegate = self
        picker?.dataSource = self
        picker?.needFooterView = true
        picker?.allowMultipleSelection = false
        picker?.headerBackgroundColor = app_color()
        picker?.confirmButtonBackgroundColor = app_color()
        if (arr_names?.contains("Abusive"))! && txtfld_category.text == ""
        {
            let arr_selected = NSMutableArray()
            let index = arr_names?.index(of: "Abusive")
            arr_selected.add(index!)
            picker?.setSelectedRows(arr_selected as! [Any])
        }
        
        picker?.show()
    }
    
    func numberOfRows(in pickerView: CZPickerView!) -> Int
    {
        return GDP.arr_reportCategory.count
    }
    
    func czpickerView(_ pickerView: CZPickerView!, titleForRow row: Int) -> String!
    {
        return (GDP.arr_reportCategory.object(at: row) as! NSDictionary).value(forKey: "name") as! String
    }
    
    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int)
    {
        str_selectedIds = "\((GDP.arr_reportCategory.object(at: row) as! NSDictionary).object(forKey: "id")!)"
        txtfld_category.text = "\((GDP.arr_reportCategory.object(at: row) as! NSDictionary).object(forKey: "name")!)"
        
        if txtfld_category.text!.contains("Other")
        {
            UIView.animate(withDuration: 0.2, animations: {
                var frame = self.vw_message.frame
                frame.origin.y = self.vw_subject.frame.origin.y + self.vw_subject.frame.size.height + 8
                self.vw_message.frame = frame
            })
        }
        else
        {
            UIView.animate(withDuration: 0.2, animations: {
                var frame = self.vw_message.frame
                frame.origin.y = self.vw_subject.frame.origin.y
                self.vw_message.frame = frame
            })
            
            txtfld_subject.text = ""
        }
    }
    
    func czpickerViewDidClickCancelButton(_ pickerView: CZPickerView!)
    {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
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
            } catch _ {
                data_dare_video = Data()
                return
            }
        }
        
        picker.dismiss(animated: true) {
            self.uploadMyReponseVideo()
        }
    }
    
    //MARK:- Text View Methods
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if textView == txtvw_msg
        {
            scrl_main.contentSize = CGSize(width: 0, height: scrl_main.frame.size.height)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if textView == txtvw_msg
        {
            scrl_main.contentSize = CGSize(width: 0, height: 0)
        }
    }
    
    public func textViewDidChange(_ textView: UITextView)
    {
        if textView == txtvw_msg
        {
            if txtvw_msg.text!.trimmingCharacters(in: GDP.charSet).count == 0
            {
                lbl_placeholder.isHidden = false
                btn_post.isEnabled = false
                ic_send.alpha = 0.3
            }
            else
            {
                lbl_placeholder.isHidden = true
                btn_post.isEnabled = true
                ic_send.alpha = 1.0
            }
        }
    }
    
    //MARK: - Table View Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arr_contributor.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let tmp_dic = arr_contributor.object(at: indexPath.row) as! NSDictionary
        let lbl_tmp = UILabel(frame: CGRect(x: 0, y: 0, width: tbl_contributor.frame.size.width - 100, height: 30.0))
        
        if UIDevice().userInterfaceIdiom == .pad
        {
            lbl_tmp.font = UIFont.systemFont(ofSize: 18.0)
        }
        else
        {
            lbl_tmp.font = UIFont.systemFont(ofSize: 12.0)
        }
        
        lbl_tmp.numberOfLines = 0
        lbl_tmp.text = "\(tmp_dic.object(forKey: "comment")!)"
        lbl_tmp.sizeToFit()
        lbl_tmp.layoutIfNeeded()
        
        if UIDevice().userInterfaceIdiom == .pad
        {
            if lbl_tmp.frame.size.height <= 30
            {
                return 90
            }
            else
            {
                return 120 + lbl_tmp.frame.size.height
            }
        }
        else
        {
            if lbl_tmp.frame.size.height <= 30
            {
                return 60
            }
            else
            {
                return 80 + lbl_tmp.frame.size.height
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell: Custom_Cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Custom_Cell
        
        let tmp_dic = arr_contributor.object(at: indexPath.row) as! NSDictionary
        
        cell.img_profile.imageForUrlWithImage(baseUrl: profile_image_url(), urlString: "\(tmp_dic.object(forKey: "profile_image")!)", placeHolderImage: "user_Profile.png")
        
        let width = cell.lbl_username.frame.origin.x - 8
        
        var height: CGFloat = 0
        if UIDevice().userInterfaceIdiom == .pad
        {
            height = 90 - 14
        }
        else
        {
            height = 60 - 14
        }
        
        let posX = 4.0
        let posY = 4.0
        
        if width > height
        {
            cell.img_profile.frame = CGRect(x: CGFloat(posX), y: CGFloat(posY), width: height, height: height)
            cell.img_profile.layer.cornerRadius = height/2
        }
        else
        {
            cell.img_profile.frame = CGRect(x: CGFloat(posX), y: CGFloat(posY), width: width, height: width)
            cell.img_profile.layer.cornerRadius = width/2
        }
        
        cell.lbl_username.text = "\(tmp_dic.object(forKey: "user_name")!)"
        var frame1 = cell.lbl_username.frame
        frame1.origin.x = cell.img_profile.frame.origin.x + cell.img_profile.frame.size.width + 8
        frame1.size.width = tbl_contributor.frame.size.width - (cell.img_profile.frame.size.width - 8 - cell.lbl_time.frame.size.width)
        cell.lbl_username.frame = frame1
        
        cell.lbl_title.text = "\(tmp_dic.object(forKey: "comment")!)"
        var frame2 = cell.lbl_title.frame
        cell.lbl_title.sizeToFit()
        cell.lbl_title.layoutIfNeeded()
        frame2.origin.x = cell.lbl_username.frame.origin.x
        frame2.origin.y = cell.lbl_username.frame.origin.y + cell.lbl_username.frame.size.height
        frame2.size.height = cell.lbl_title.frame.size.height
        cell.lbl_title.frame = frame2
        
        let dateString = "\(tmp_dic.object(forKey: "created")!)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateObj = dateFormatter.date(from: dateString)
        let currentDate = dateFormatter.date(from: "\(tmp_dic.object(forKey: "current_date")!)")!
        cell.lbl_time.text = "\(currentDate.offsetFrom(date: dateObj!)) ago"
        
        var frame3 = cell.lbl_time.frame
        frame3.origin.y = cell.lbl_username.frame.origin.y
        cell.lbl_time.frame = frame3
        
        cell.lbl_amount.text = "$\(tmp_dic.object(forKey: "amount")!)"
        
        var frame4 = cell.lbl_amount.frame
        frame4.origin.y = cell.lbl_time.frame.origin.y + cell.lbl_time.frame.size.height + 6
        cell.lbl_amount.frame = frame4
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let tmp_dic = arr_contributor.object(at: indexPath.row) as! NSDictionary
        if "\(tmp_dic.object(forKey: "user_name")!)" != "Anonymous"
        {
            let user_id = "\(tmp_dic.object(forKey: "user_id")!)"
            
            if GDP.userID == nil || GDP.userID == ""
            {
                appdel.showLoginAlert(controller: self)
            }
            else
            {
                self.viewUserProfile(tmp_id: user_id)
            }
        }
    }
    
    //MARK:- Button Action Methods
    @IBAction func on_btnBack_click(_ sender: UIButton)
    {
        if shouldBack == false
        {
            var isExists = false
            var frontView: UIViewController?
            for viObj in (appdel.appNav?.viewControllers)!
            {
                if viObj is HomePage
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
            else
            {
                let obj_view = HomePage(nibName: "HomePage", bundle: nil)
                appdel.appNav?.pushViewController(obj_view, animated: true)
            }
        }
        else
        {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func on_btnReport_click(_ sender: UIButton)
    {
        vw_reportMsg.frame = CGRect(x: 0, y: window_Height(), width: window_Width(), height: window_Height() - (self.GDP.topSafeArea + self.GDP.bottomSafeArea))
        self.view.addSubview(vw_reportMsg)
        
        var frame = self.vw_message.frame
        frame.origin.y = self.vw_subject.frame.origin.y
        self.vw_message.frame = frame
        
        UIView.animate(withDuration: 0.3)
        {
            self.vw_reportMsg.frame = CGRect(x: 0, y: 0, width: window_Width(), height: window_Height() - (self.GDP.topSafeArea + self.GDP.bottomSafeArea))
        }
    }
    
    @IBAction func on_btnTaskVideo_click(_ sender: UIButton)
    {
        vw_video.isHidden = false
        vw_image.isHidden = true
        vw_resvideo.isHidden = true
        
        if dare_videoPlayer != nil
        {
            dare_videoPlayer.stop()
        }
        
        if response_videoPlayer != nil
        {
            response_videoPlayer.stop()
        }
        
        let dare_video = "\(dare_video_url())\(dic_daredata.object(forKey: "video")!)"
        if dare_video == "\(dare_video_url())"
        {
            lbl_darevideo.isHidden = false
            if dare_videoPlayer != nil
            {
                dare_videoPlayer.view.isHidden = true
            }
        }
        else
        {
            lbl_darevideo.isHidden = true
            if dare_videoPlayer != nil
            {
                dare_videoPlayer.view.isHidden = false
            }
            
            dare_videoPlayer.play()
        }
        
        lbl_taskVideo.textColor = UIColor.init(red: 35.0/255.0, green: 166.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        lbl_taskVideoBottom.backgroundColor = UIColor.init(red: 35.0/255.0, green: 166.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        
        lbl_taskImage.textColor = UIColor.black
        lbl_taskImageBottom.backgroundColor = UIColor.init(red: 141.0/255.0, green: 143.0/255.0, blue: 143.0/255.0, alpha: 1.0)
        
        lbl_responseVideo.textColor = UIColor.black
        lbl_responseVideoBottom.backgroundColor = UIColor.init(red: 141.0/255.0, green: 143.0/255.0, blue: 143.0/255.0, alpha: 1.0)
    }
    
    @IBAction func on_btnTaskImage_click(_ sender: UIButton)
    {
        if dare_videoPlayer != nil
        {
            dare_videoPlayer.stop()
        }
        
        if response_videoPlayer != nil
        {
            response_videoPlayer.stop()
        }
        
        vw_video.isHidden = true
        vw_image.isHidden = false
        vw_resvideo.isHidden = true
        
        lbl_taskVideo.textColor = UIColor.black
        lbl_taskVideoBottom.backgroundColor = UIColor.init(red: 141.0/255.0, green: 143.0/255.0, blue: 143.0/255.0, alpha: 1.0)
        
        lbl_taskImage.textColor = UIColor.init(red: 35.0/255.0, green: 166.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        lbl_taskImageBottom.backgroundColor = UIColor.init(red: 35.0/255.0, green: 166.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        
        lbl_responseVideo.textColor = UIColor.black
        lbl_responseVideoBottom.backgroundColor = UIColor.init(red: 141.0/255.0, green: 143.0/255.0, blue: 143.0/255.0, alpha: 1.0)
    }
    
    @IBAction func on_btnResponseVideo_click(_ sender: UIButton)
    {
        if shouldUploadResponseVideo == true
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
                self.isCallApi = false
                imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
                self.present(imagePicker, animated: true, completion: nil)
            })
            
            let takephotoAction = UIAlertAction(title: NSLocalizedString("Record Video", comment: ""), style: .default, handler:
            {
                (alert: UIAlertAction!) -> Void in
                if UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
                {
                    self.isCallApi = false
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
            
            if let presenter = chooseMenu.popoverPresentationController
            {
                presenter.sourceView = button
                presenter.sourceRect = button.bounds
            }
            
            self.present(chooseMenu, animated: true, completion: nil)
        }
        else
        {
            if dare_videoPlayer != nil
            {
                dare_videoPlayer.stop()
            }
            
            if response_videoPlayer != nil
            {
                response_videoPlayer.stop()
            }
            
            vw_video.isHidden = true
            vw_image.isHidden = true
            vw_resvideo.isHidden = false
            
            let response_video = "\(dare_video_url())\(dic_daredata.object(forKey: "response_video")!)"
            if response_video == "\(dare_video_url())"
            {
                lbl_resvideo.isHidden = false
                
                if response_videoPlayer != nil
                {
                    response_videoPlayer.view.isHidden = true
                }
            }
            else
            {
                lbl_resvideo.isHidden = true
                if response_videoPlayer != nil
                {
                    response_videoPlayer.view.isHidden = false
                }
                
                let response_url = URL(string: response_video)
                
                if response_videoPlayer != nil
                {
                    response_videoPlayer.play()
                }
                else
                {
                    response_videoPlayer = MPMoviePlayerController(contentURL: response_url)
                    response_videoPlayer.view.frame = CGRect(x: 0, y: 0, width: vw_resvideo.frame.size.width, height: vw_resvideo.frame.size.height)
                    vw_resvideo.addSubview(response_videoPlayer.view)
                    response_videoPlayer.controlStyle = MPMovieControlStyle.embedded
                    response_videoPlayer.play()
                }
            }
            
            lbl_taskVideo.textColor = UIColor.black
            lbl_taskVideoBottom.backgroundColor = UIColor.init(red: 141.0/255.0, green: 143.0/255.0, blue: 143.0/255.0, alpha: 1.0)
            
            lbl_taskImage.textColor = UIColor.black
            lbl_taskImageBottom.backgroundColor = UIColor.init(red: 141.0/255.0, green: 143.0/255.0, blue: 143.0/255.0, alpha: 1.0)
            
            lbl_responseVideo.textColor = UIColor.init(red: 35.0/255.0, green: 166.0/255.0, blue: 46.0/255.0, alpha: 1.0)
            lbl_responseVideoBottom.backgroundColor = UIColor.init(red: 35.0/255.0, green: 166.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        }
    }
    
    @IBAction func on_btnImage_click(_ sender: UIButton)
    {
        let imageInfo = JTSImageInfo()
        imageInfo.image = img_dare.image
        imageInfo.referenceRect = img_dare.frame
        imageInfo.referenceView = img_dare.superview;
        imageInfo.referenceContentMode = img_dare.contentMode;
        imageInfo.referenceCornerRadius = img_dare.layer.cornerRadius;
        
        let imageViewer = JTSImageViewController.init(imageInfo: imageInfo, mode: .image, backgroundStyle: .scaled)
        imageViewer?.show(from: self, transition: .fromOriginalPosition)
    }
    
    @IBAction func on_btnLike_click(_ sender: UIButton)
    {
        if GDP.userID == nil || GDP.userID == ""
        {
            appdel.showLoginAlert(controller: self)
        }
        else
        {
            likeUnlikeDare()
        }
    }
    
    @IBAction func on_btnCreator_click(_ sender: UIButton)
    {
        let creator_id = "\(dic_daredata.object(forKey: "user_id")!)"
        if creator_id != ""
        {
            if GDP.userID == nil || GDP.userID == ""
            {
                appdel.showLoginAlert(controller: self)
            }
            else
            {
                self.viewUserProfile(tmp_id: creator_id)
            }
        }
    }
    
    @IBAction func on_btnAcceptor_click(_ sender: UIButton)
    {
        let acceptor_id = "\(dic_daredata.object(forKey: "acceptor_id")!)"
        if acceptor_id != ""
        {
            if GDP.userID == nil || GDP.userID == ""
            {
                appdel.showLoginAlert(controller: self)
            }
            else
            {
                self.viewUserProfile(tmp_id: acceptor_id)
            }
        }
    }
    
    @IBAction func on_btnContribute_click(_ sender: UIButton)
    {
        let goal_amount = Float("\(dic_daredata.object(forKey: "goal_amount")!)")!
        let raised_amount = Float("\(dic_daredata.object(forKey: "raised_amount")!)")!
        
        let obj_view = Contribute_View(nibName: "Contribute_View", bundle: nil)
        obj_view.str_dareId = "\(dic_daredata.object(forKey: "id")!)"
        obj_view.str_dareTitle = "\(dic_daredata.object(forKey: "title")!)"
        obj_view.str_credits = "\(dic_daredata.object(forKey: "darebux_credits")!)"
        obj_view.remaining_amount = goal_amount - raised_amount
        appdel.appNav?.pushViewController(obj_view, animated: true)
    }
    
    @IBAction func on_btnVerify_click(_ sender: UIButton)
    {
        let alert = UIAlertController(title: AppName(), message: "By clicking Verify, you confirm that this user has completed the dare. A false verification, may lead to penalties, and account termination.", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Verify", style: .default, handler: { action in
            switch action.style
            {
            case .default:
                print("default")
                self.verifyResponseVideo()
                
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
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func on_btnReadMore_click(_ sender: UIButton)
    {
        if isReadMore == false
        {
            isReadMore = true
            txtvw_description.text = "\(dic_daredata.object(forKey: "description")!)"
            btn_ReadMore.setTitle("Show Less", for: .normal)
        }
        else
        {
            let str_description = "\(dic_daredata.object(forKey: "description")!)"
            if str_description.count > 150
            {
                let trimmed_str = String(str_description.prefix(150))
                txtvw_description.text = trimmed_str
                
                isReadMore = false
                btn_ReadMore.setTitle("Read More", for: .normal)
            }
        }
    }
    
    @IBAction func on_btnContributorsList_click(_ sender: UIButton)
    {
        if "\(dic_daredata.object(forKey: "contributor_count")!)" == "0"
        {
            self.alertType(type: .okAlert, alertMSG: "No user has contributed yet on this dare.", delegate: self)
        }
        else
        {
            getcontributorList()
        }
    }
    
    @IBAction func on_btnComments_click(_ sender: UIButton)
    {
        let obj_view = Comments_View(nibName: "Comments_View", bundle: nil)
        obj_view.str_dareId = str_id
        appdel.appNav?.pushViewController(obj_view, animated: true)
    }
    
    @IBAction func on_btnPost_click(_ sender: UIButton)
    {
        if GDP.userID == nil || GDP.userID == ""
        {
            appdel.showLoginAlert(controller: self)
        }
        else
        {
            postMyComment()
        }
    }
    
    @IBAction func on_btnCloseKeyboard_click(_ sender: UIButton)
    {
        self.view.endEditing(true)
    }
    
    @IBAction func on_btnType_click(_ sender: UIButton)
    {
        self.view.endEditing(true)
        var arrType: NSArray!
        
        if is_video_reported == "1" || "\(dic_daredata.object(forKey: "response_video")!)" == ""
        {
            arrType = ["dare"]
        }
        else
        {
            arrType = ["dare", "video"]
        }
        
        var index = 0
        if (txtfld_conType.text?.isEmpty) == false
        {
            index = arrType.index(of: txtfld_conType.text!)
        }
        
        ActionSheetStringPicker.show(withTitle: "Select Report Type", rows: arrType as! [Any]?, initialSelection: index, doneBlock: {
            picker, indexes, values in
            
            self.txtfld_conType.text = values as? String
            
            return
            
        }, cancel: {ActionStringCancelBlock in
            return
        }, origin: sender)
    }
    
    @IBAction func on_btnCategory_click(_ sender: UIButton)
    {
        if GDP.arr_reportCategory == nil
        {
            getReportCategoryList()
        }
        else
        {
            showPickerView()
        }
    }
    
    @IBAction func on_btnCloseView_click(_ sender: UIButton)
    {
        txtfld_conType.text = ""
        txtfld_category.text = ""
        txtfld_subject.text = ""
        txtvw_comment.text = ""
        vw_reportMsg.removeFromSuperview()
    }
    
    @IBAction func on_btnSubmitReport_click(_ sender: UIButton)
    {
        if txtfld_category.text == ""
        {
            self.alertType(type: .okAlert, alertMSG: "Please select report category", delegate: self)
        }
        else if txtfld_category.text!.contains("Other") == true
        {
            if txtfld_subject.text!.trimmingCharacters(in: GDP.charSet).count == 0
            {
                self.alertType(type: .okAlert, alertMSG: "Please enter subject", delegate: self)
            }
            else
            {
                postReport(tmp_dareId: str_id, tmp_reportId: str_selectedIds, tmp_type: txtfld_conType.text!)
            }
        }
        else
        {
            postReport(tmp_dareId: str_id, tmp_reportId: str_selectedIds, tmp_type: txtfld_conType.text!)
        }
    }
    
    @IBAction func on_btnCloseList_click(_ sender: UIButton)
    {
        vw_contributors.removeFromSuperview()
    }
    
    @IBAction func on_btnRetry_click(_ sender: UIButton)
    {
        getDareDetail()
    }
    
    @IBAction func on_btnAcceptRequest_click(_ sender: UIButton)
    {
        str_status = "accept"
        accept_reject_request(tmp_status: "3")
    }
    
    @IBAction func on_btnRejectRequest_click(_ sender: UIButton)
    {
        str_status = "reject"
        accept_reject_request(tmp_status: "2")
    }
    
    //MARK:- Touch Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    //MARK:- Web Service Methods
    func getDareDetail()
    {
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self
            
            let tmp_dic: NSMutableDictionary = NSMutableDictionary()
            tmp_dic.setValue(str_id, forKey: "id")
            tmp_dic.setValue(GDP.getIPAddresses(), forKey: "ip_address")
            webclass.dareDetail(dic_data: tmp_dic)
        }
        else
        {
            vw_retry.isHidden = false
            btn_retry.isHidden = false
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }
    
    func accept_reject_request(tmp_status: String!)
    {
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self
            
            let tmp_dic: NSMutableDictionary = NSMutableDictionary()
            tmp_dic.setValue(str_id, forKey: "dare_id")
            tmp_dic.setValue(tmp_status, forKey: "status")
            webclass.acceptRejectRequest(dic_data: tmp_dic)
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }
    
    func likeUnlikeDare()
    {
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self
            
            let tmp_dic: NSMutableDictionary = NSMutableDictionary()
            tmp_dic.setValue(str_id, forKey: "dare_id")
            
            if str_likeStatus == "like"
            {
                str_likeStatus = "unlike"
            }
            else
            {
                str_likeStatus = "like"
            }
            
            tmp_dic.setValue(str_likeStatus, forKey: "status")
            webclass.likeUnlikeDare(dic_data: tmp_dic)
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }
    
    func getReportCategoryList()
    {
        self.view.endEditing(true)
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self
            webclass.reportCategoryList()
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }
    
    func postReport(tmp_dareId: String, tmp_reportId: String, tmp_type: String)
    {
        self.view.endEditing(true)
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self
            
            let tmp_dic: NSMutableDictionary = NSMutableDictionary()
            tmp_dic.setValue(tmp_dareId, forKey: "dare_id")
            tmp_dic.setValue(tmp_reportId, forKey: "category_id")
            tmp_dic.setValue(txtfld_subject.text!, forKey: "subject")
            tmp_dic.setValue(txtvw_comment.text!, forKey: "message")
            tmp_dic.setValue(tmp_type, forKey: "type")
            webclass.sendReport(dic_data: tmp_dic)
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }
    
    func uploadMyReponseVideo()
    {
        self.view.endEditing(true)
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self
            
            let tmp_dic: NSMutableDictionary = NSMutableDictionary()
            tmp_dic.setValue(str_id, forKey: "dare_id")
            webclass.uploadResponseVideo(dic_data: tmp_dic, videoData: data_dare_video)
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }
    
    func getcontributorList()
    {
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self
            
            let tmp_dic: NSMutableDictionary = NSMutableDictionary()
            tmp_dic.setValue(str_id, forKey: "dare_id")
            webclass.contributorList(dic_data: tmp_dic)
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }
    
    func postMyComment()
    {
        self.view.endEditing(true)
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self
            
            let str_comment = txtvw_msg.text!.trimmingCharacters(in: GDP.charSet)
            let encodedString = str_comment.encodeEmoji
            
            let tmp_dic: NSMutableDictionary = NSMutableDictionary()
            tmp_dic.setValue(str_id, forKey: "dare_id")
            tmp_dic.setValue(encodedString, forKey: "comment")
            webclass.postComment(dic_data: tmp_dic)
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
    
    func verifyResponseVideo()
    {
        self.view.endEditing(true)
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self
            
            let tmp_dic: NSMutableDictionary = NSMutableDictionary()
            tmp_dic.setValue(str_id, forKey: "dare_id")
            tmp_dic.setValue("3", forKey: "status")
            webclass.verifyVideo(dic_data: tmp_dic)
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
            
            if (kDareDetail().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg = JSONDict.object(forKey: "response_msg") as! String
                
                if responseStatus == "success"
                {
                    if let responseDic = JSONDict.object(forKey: "response_data") as? NSDictionary
                    {
                        vw_retry.isHidden = true
                        btn_retry.isHidden = true
                        
                        print(responseDic)
                        dic_daredata = responseDic
                        loadDareData()
                    }
                }
                else
                {
                    vw_retry.isHidden = false
                    btn_retry.isHidden = false
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }
                
            else if (kAcceptRejectRequest().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg = JSONDict.object(forKey: "response_msg") as! String
                
                if responseStatus == "success"
                {
                    if let responseDic = JSONDict.object(forKey: "response_data") as? NSDictionary
                    {
                        let msg = "\(responseDic.object(forKey: "message")!)"
                        self.alertType(type: .okAlert, alertMSG: msg, delegate: self)
                        
                        var frame = vw_detail.frame
                        frame.origin.y = 0
                        vw_detail.frame = frame
                        
                        if str_status == "accept"
                        {
                            lbl_acceptor.text = "\(responseDic.object(forKey: "username")!)"
                            lbl_status.text = "ACCEPTED"
                            lbl_status.backgroundColor = app_color()
                        }
                        else
                        {
                            lbl_acceptor.text = "\(responseDic.object(forKey: "username")!)"
                            lbl_status.text = "DECLINED"
                            lbl_status.backgroundColor = UIColor.red
                        }
                    }
                }
                else
                {
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }
                
            else if (kLikeUnlikeDare().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg = JSONDict.object(forKey: "response_msg") as! String
                
                if responseStatus == "success"
                {
                    if let responseDic = JSONDict.object(forKey: "response_data") as? NSDictionary
                    {
                        lbl_likes.text = "\(responseDic.object(forKey: "like_cnt")!)"
                        if "\(responseDic.object(forKey: "status")!)" == "0"
                        {
                            str_likeStatus = "unlike"
                            ic_like.image = UIImage(named: "follow.png")
                        }
                        else
                        {
                            str_likeStatus = "like"
                            ic_like.image = UIImage(named: "ic_following.png")
                        }
                    }
                }
                else
                {
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }
                
            else if (kReportCategoryList().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg    = JSONDict.object(forKey: "response_msg") as! String
                
                if responseStatus == "success"
                {
                    if let responseArr = JSONDict.object(forKey: "response_data") as? NSArray
                    {
                        GDP.arr_reportCategory = responseArr
                        showPickerView()
                    }
                }
                else
                {
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }
                
            else if (kReport().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg = JSONDict.object(forKey: "response_msg") as! String
                
                if responseStatus == "success"
                {
                    if txtfld_conType.text == "video"
                    {
                        is_video_reported = "1"
                    }
                    
                    txtfld_conType.text = ""
                    txtfld_category.text = ""
                    txtfld_subject.text = ""
                    txtvw_comment.text = ""
                    vw_reportMsg.removeFromSuperview()
                    
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
                else
                {
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }
                
            else if (kuploadResponseVideo().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg = JSONDict.object(forKey: "response_msg") as! String
                
                if responseStatus == "success"
                {
                    if let responseDic = JSONDict.object(forKey: "response_data") as? NSDictionary
                    {
                        shouldUploadResponseVideo = false
                        lbl_responseVideo.text = "Response Video"
                        lbl_resvideo.isHidden = true
                        lbl_deadline.isHidden = true
                        
                        vw_video.isHidden = true
                        vw_image.isHidden = true
                        vw_resvideo.isHidden = false
                        
                        lbl_taskVideo.textColor = UIColor.black
                        lbl_taskVideoBottom.backgroundColor = UIColor.init(red: 141.0/255.0, green: 143.0/255.0, blue: 143.0/255.0, alpha: 1.0)
                        
                        lbl_taskImage.textColor = UIColor.black
                        lbl_taskImageBottom.backgroundColor = UIColor.init(red: 141.0/255.0, green: 143.0/255.0, blue: 143.0/255.0, alpha: 1.0)
                        
                        lbl_responseVideo.textColor = UIColor.init(red: 35.0/255.0, green: 166.0/255.0, blue: 46.0/255.0, alpha: 1.0)
                        lbl_responseVideoBottom.backgroundColor = UIColor.init(red: 35.0/255.0, green: 166.0/255.0, blue: 46.0/255.0, alpha: 1.0)
                        
                        let response_video = "\(dare_video_url())\(responseDic.object(forKey: "response_video")!)"
                        let response_url = URL(string: response_video)
                        
                        response_videoPlayer = MPMoviePlayerController(contentURL: response_url)
                        response_videoPlayer.view.frame = CGRect(x: 0, y: 0, width: vw_resvideo.frame.size.width, height: vw_resvideo.frame.size.height)
                        vw_resvideo.addSubview(response_videoPlayer.view)
                        response_videoPlayer.controlStyle = MPMovieControlStyle.embedded
                        response_videoPlayer.play()
                    }
                }
                else
                {
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }
                
            else if (kVerifyVideo().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg    = JSONDict.object(forKey: "response_msg") as! String
                
                if responseStatus == "success"
                {
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                    
                    vw_verify.isHidden = false
                    ic_verify.image = UIImage(named: "btn_verified.png")
                    btn_verify.isEnabled = false
                    
                    lbl_status.text = "COMPLETED"
                    lbl_status.backgroundColor = app_color()
                    
                }
                else
                {
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }
                
            else if (kContributorList().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg = JSONDict.object(forKey: "response_msg") as! String
                
                if responseStatus == "success"
                {
                    if let responseDic = JSONDict.object(forKey: "response_data") as? NSDictionary
                    {
                        arr_contributor = (responseDic.object(forKey: "my_contributions") as! NSArray).arrayByReplacingNullsWithBlanks()
                        if arr_contributor.count > 0
                        {
                            vw_contributors.frame = CGRect(x: 0, y: window_Height(), width: window_Width(), height: window_Height() - (self.GDP.topSafeArea + self.GDP.bottomSafeArea))
                            self.view.addSubview(vw_contributors)
                            
                            UIView.animate(withDuration: 0.3, animations: {
                                self.vw_contributors.frame = CGRect(x: 0, y: 0, width: window_Width(), height: window_Height() - (self.GDP.topSafeArea + self.GDP.bottomSafeArea))
                            }, completion: { (finish) in
                                self.tbl_contributor.delegate = self
                                self.tbl_contributor.dataSource = self
                                self.tbl_contributor.reloadData()
                            })
                        }
                        else
                        {
                            self.alertType(type: .okAlert, alertMSG: "No user has contributed yet on this dare.", delegate: self)
                        }
                        
                        lbl_count.text = "\(responseDic.object(forKey: "contribution_count")!) Contributions"
                        lbl_amount.text = "Total: $\(responseDic.object(forKey: "total_contribution")!)"
                    }
                }
                else
                {
                    self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                }
            }
                
            else if (kpostComment().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg = JSONDict.object(forKey: "response_msg") as! String
                
                if responseStatus == "success"
                {
                    if let responseDic = JSONDict.object(forKey: "response_data") as? NSDictionary
                    {
                        let comment_count = "\(responseDic.object(forKey: "comment_count")!)"
                        if comment_count == "1"
                        {
                            lbl_comments.text = "\(responseDic.object(forKey: "comment_count")!) Comment"
                        }
                        else
                        {
                            lbl_comments.text = "\(responseDic.object(forKey: "comment_count")!) Comments"
                        }
                    }
                    
                    txtvw_msg.text = ""
                    
                    lbl_placeholder.isHidden = false
                    btn_post.isEnabled = false
                    ic_send.alpha = 0.3
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
            if (kDareDetail().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                vw_retry.isHidden = false
                btn_retry.isHidden = false
            }
            
            self.alertType(type: .okAlert, alertMSG: Invalid_ResMsg(), delegate: self)
            print("Error from backend \(error)")
        }
    }
    
    func dataDidFail (methodname : String , error : Error)
    {
        if (kDareDetail().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
        {
            vw_retry.isHidden = false
            btn_retry.isHidden = false
        }
        
        self.alertType(type: .okAlert, alertMSG: ServerErrorMsg(), delegate: self)
    }
}
