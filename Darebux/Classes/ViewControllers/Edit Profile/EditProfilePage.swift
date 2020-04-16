//
//  EditProfilePage.swift
//  Darebux
//
//  Created by LogicSpice on 02/02/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit

class EditProfilePage: UIViewController, WebCommunicationClassDelegate, UITextFieldDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, alertClassDelegate
{
    @IBOutlet var lblHeaderText:UILabel!
    @IBOutlet var lblMiddleLine: UILabel!
    @IBOutlet var imgBackView:UIView!
    @IBOutlet var imgUser:UIImageView!
    @IBOutlet var lblEmail:UILabel!
    
    @IBOutlet var contentView:UIView!
    @IBOutlet var txtFName:UITextField!
    @IBOutlet var txtLName:UITextField!
    @IBOutlet var txtUsername:UITextField!
    @IBOutlet var txtEmail:UITextField!
    @IBOutlet var txtDOB:UITextField!
    @IBOutlet var txtGender:UITextField!
    @IBOutlet var txtAddress:UITextField!
    @IBOutlet var txtCity:UITextField!
    @IBOutlet var txtCountry:UITextField!
    @IBOutlet var vw_addressView:UIView!
    @IBOutlet var tvAboutMe:UITextView!
    
    let GDP = GDP_Obj()
    let appdel = App_Delegate()
    let arrGender = ["Male", "Female", "Other"]
    
    var placesTable:UITableView!
    var searchResultPlaces = NSArray()
    var searchQuery:SPGooglePlacesAutocompleteQuery!
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var selectedLocation:CLLocation?
    
    var dictUserData:NSDictionary!
    var imgData = Data()
    let charSet = NSCharacterSet.whitespacesAndNewlines

    //MARK:- View Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.locationManager = CLLocationManager()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.distanceFilter = 50
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        self.locationManager.startUpdatingHeading()
        
        searchQuery = SPGooglePlacesAutocompleteQuery()
        searchQuery.radius = 100.0

        GDP.shouldReloadData = true
        setUserData()
    }
    
    override func viewDidLayoutSubviews()
    {
        GDP.adjustView(tmp_view: self.view)

        let xorigin = lblMiddleLine.frame.origin.x
        let imageHeight = lblEmail.frame.origin.y - (lblHeaderText.frame.origin.y+lblHeaderText.frame.size.height) - 20 - 5
        
        var viFrame = imgBackView.frame
        viFrame.origin.x = xorigin - imageHeight/2
        viFrame.origin.y = lblHeaderText.frame.origin.y + lblHeaderText.frame.size.height + 20
        viFrame.size.height = imageHeight
        viFrame.size.width = imageHeight
        imgBackView.frame = viFrame
        
        imgBackView.layer.cornerRadius = imgBackView.bounds.size.width/2
        imgBackView.layer.borderWidth =  5
        imgBackView.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    func setUserData()
    {
        if let str_img = dictUserData.object(forKey: "profile_image") as? String
        {
            imgUser.imageForUrl(profile_image_url(), urlString: str_img, placeHolderImage: "user_Profile.png", completionHandler: { (data) in

                self.imgData = data! as Data
            })
        }

        txtFName.text = "\(dictUserData.object(forKey: "first_name")!)"
        txtLName.text = "\(dictUserData.object(forKey: "last_name")!)"
        txtUsername.text = "\(dictUserData.object(forKey: "username")!)"
        txtEmail.text = "\(dictUserData.object(forKey: "email_address")!)"
        txtGender.text = "\(dictUserData.object(forKey: "gender")!)"
        txtAddress.text = "\(dictUserData.object(forKey: "address")!)"
        txtCity.text = "\(dictUserData.object(forKey: "city")!)"
        txtCountry.text = "\(dictUserData.object(forKey: "country")!)"
        tvAboutMe.text = "\(dictUserData.object(forKey: "about_me")!)"

        if "\(dictUserData.object(forKey: "dob")!)" != ""
        {
            let strDOB = "\(dictUserData.object(forKey: "dob")!)"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let tmp_date = dateFormatter.date(from: strDOB)
            if tmp_date == nil
            {
                txtDOB.text = "\(dictUserData.object(forKey: "dob")!)"
            }
            else
            {
                txtDOB.text = NSDate.string(from: tmp_date!, withFormat: "dd MMM yyyy")
            }
        }
    }
    
    //MARK:- CLLocationManagerDelegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location: CLLocation = locations.last!
        currentLocation = location
        locationManager.stopUpdatingLocation()
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        switch status
        {
        case .restricted:
            print("Location access was restricted.")
            
        case .denied:
            print("User denied access to location.")
            
        case .notDetermined:
            print("Location status not determined.")
            
        case .authorizedAlways: fallthrough
            
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }

    //MARK:- Alert View Methods
    func alertOkClick()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- UITableView delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return searchResultPlaces.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 32
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        cell.textLabel?.text = placeAtIndexPath(indexpath: indexPath).name
        cell.textLabel?.textColor = UIColor(red: 117/255.0, green: 117/255.0, blue: 117/255.0, alpha: 1)
        cell.textLabel?.textAlignment = .center;
        
        return cell
    }
    
    func placeAtIndexPath(indexpath:IndexPath)->SPGooglePlacesAutocompletePlace
    {
        return searchResultPlaces.object(at: indexpath.row) as! SPGooglePlacesAutocompletePlace
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.view.endEditing(true)
        
        let resultplace = placeAtIndexPath(indexpath: indexPath)
        
        placesTable.delegate = nil
        placesTable.dataSource = nil
        placesTable.isHidden = true
        
        txtAddress.text = resultplace.name
        let arr = txtAddress.text?.components(separatedBy: ",")

        if (arr?.count)! == 1
        {
            txtCity.text = arr![0]
            txtCountry.text = arr![0]
        }
        else if (arr?.count)! == 2
        {
            txtCity.text = arr![0]
            txtCountry.text = arr![1]
        }
        else if (arr?.count)! == 3
        {
            txtCity.text = arr![0]
            txtCountry.text = arr![2]
        }
        else
        {
            txtCity.text = arr![(arr?.count)! - 3]
            txtCountry.text = arr![(arr?.count)! - 1]
        }

        getReverseGeocoder(strAddress: txtAddress.text!)
    }
    
    func getReverseGeocoder(strAddress:String)
    {
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.getLocationFromAddress(address: strAddress, completionHandler: { (location, error) in
                if error == nil
                {
                    self.selectedLocation = CLLocation(latitude: (location?.latitude)!, longitude: (location?.longitude)!)
                }
            })
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }
    
    //MARK:- Validation Methods
    func isValidEmail(testStr:String) -> Bool
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

    func checkValidation() -> Bool
    {
        if ((txtFName.text?.trimmingCharacters(in: charSet))?.count == 0)
        {
            self.alertType(type: .okAlert, alertMSG: "Please enter first name", delegate: self)
            return false
        }
        else if ((txtLName.text?.trimmingCharacters(in: charSet))?.count == 0)
        {
            self.alertType(type: .okAlert, alertMSG: "Please enter last name", delegate: self)
            return false
        }
        else if ((txtUsername.text?.trimmingCharacters(in: charSet))?.count == 0)
        {
            self.alertType(type: .okAlert, alertMSG: "Please enter username", delegate: self)
            return false
        }
        else if (((txtUsername.text?.trimmingCharacters(in: charSet))?.count)! < 3)
        {
            self.alertType(type: .okAlert, alertMSG: "Username must contain atleast 3 characters", delegate: self)
            return false
        }
        else if (((txtUsername.text?.trimmingCharacters(in: charSet))?.count)! > 20)
        {
            self.alertType(type: .okAlert, alertMSG: "Username can contain maximum 20 characters", delegate: self)
            return false
        }
        else if ((txtEmail.text?.trimmingCharacters(in: charSet))?.count == 0)
        {
            self.alertType(type: .okAlert, alertMSG: "Please enter email address", delegate: self)
            return false
        }
        else if ((isValidEmail(testStr: txtEmail.text!) == false))
        {
            self.alertType(type: .okAlert, alertMSG: "Please enter valid email address", delegate: self)
            return false
        }
        else if ((txtDOB.text?.trimmingCharacters(in: charSet))?.count == 0)
        {
            self.alertType(type: .okAlert, alertMSG: "Please select date of birth", delegate: self)
            return false
        }
        else if ((txtGender.text?.trimmingCharacters(in: charSet))?.count == 0)
        {
            self.alertType(type: .okAlert, alertMSG: "Please select gender", delegate: self)
            return false
        }
//        else if ((txtAddress.text?.trimmingCharacters(in: charSet))?.characters.count == 0)
//        {
//            self.alertType(type: .okAlert, alertMSG: "Please enter address", delegate: self)
//            return false
//        }
        else if ((txtCity.text?.trimmingCharacters(in: charSet))?.count == 0)
        {
            self.alertType(type: .okAlert, alertMSG: "Please enter city", delegate: self)
            return false
        }
        else if ((txtCountry.text?.trimmingCharacters(in: charSet))?.count == 0)
        {
            self.alertType(type: .okAlert, alertMSG: "Please enter country", delegate: self)
            return false
        }
        
        return true
    }
    
    //MARK:- Button Click Method
    @IBAction func btn_Back_Click(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDOB_Click(_ sender: UIButton)
    {
        self.view.endEditing(true)
        var sel_date:Date!
        
        if txtDOB.text == ""
        {
            sel_date = Date()
        }
        else
        {
            let dateString = txtDOB.text!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            sel_date = dateFormatter.date(from: dateString)
        }
        
        let datePicker = ActionSheetDatePicker(title: "Date of birth", datePickerMode: UIDatePickerMode.date, selectedDate: sel_date, doneBlock: {
            picker, value, index in
            
            self.txtDOB.text = NSDate.string(from: value as!Date, withFormat: "dd MMM yyyy")
            
            return
        }, cancel: { ActionStringCancelBlock in return }, origin: sender)
        
        datePicker?.maximumDate = Date()
        datePicker?.show()
    }
    
    @IBAction func btnGender_Click(_ sender: UIButton)
    {
        self.view.endEditing(true)
        if arrGender.count > 0
        {
            var index = 0
            
            if (txtGender.text?.isEmpty) == false
            {
                index = arrGender.index(of: txtGender.text!)!
            }
            
            ActionSheetStringPicker.show(withTitle: "Select Gender", rows: arrGender, initialSelection: index, doneBlock: {
                picker, indexes, values in
                
                self.txtGender.text = values as? String
                
                return
                
            }, cancel: {ActionStringCancelBlock in
                return
            }, origin: sender)
        }
    }
    
    @IBAction func btn_UpdateProfile_Click(_ sender: UIButton)
    {
        if Reachability.isConnectedToNetwork()
        {
            if checkValidation()
            {
                self.editProfile()

//                let webclass = WebCommunicationClass()
//                webclass.getLocationFromAddress(address: txtAddress.text!, completionHandler: { (location, error) in
//                    if error == nil
//                    {
//                        self.selectedLocation = CLLocation(latitude: (location?.latitude)!, longitude: (location?.longitude)!)
//                        self.editProfile()
//                    }
//                })
            }
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }
    
    @IBAction func btn_ChangePic_click(_ sender: UIButton)
    {
        guard let button = sender as? UIView else {
            return
        }
        self.view.endEditing(true)
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        let chooseMenu = UIAlertController(title: nil, message: NSLocalizedString("Choose Image", comment: ""), preferredStyle: .actionSheet)
        chooseMenu.modalPresentationStyle = .popover
        
        let libraryAction = UIAlertAction(title: NSLocalizedString("Photo Library", comment: ""), style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
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
    
    //MARK:- UIImagePickerView Methods
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if UIDevice().userInterfaceIdiom == .pad
        {
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            {
                imgUser.image = pickedImage
                imgData = UIImageJPEGRepresentation(pickedImage, 0.5)!
            }
        }
        else
        {
            if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage
            {
                imgUser.image = pickedImage
                imgData = UIImageJPEGRepresentation(pickedImage, 0.5)!
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Touch Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField == txtFName || textField == txtLName
        {
            let range = GDP.regex.rangeOfFirstMatch(in: string, options: [], range: NSRange(location: 0, length: string.count))
            return range.length == string.count
        }
        else if textField == txtAddress
        {
            var searchStr = ""
            var newString = ""
            var placesTableFrame:CGRect!
            
            searchStr = textField.text!
            newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
            
            placesTableFrame = CGRect(x: vw_addressView.frame.origin.x, y:vw_addressView.frame.origin.y-140, width: vw_addressView.frame.size.width, height: 140)
            
            if (string == "" && newString.count == 0)
            {
                if placesTable != nil
                {
                    placesTable.isHidden = true;
                }
                
                searchStr = searchStr.substring(to: searchStr.index(before: searchStr.endIndex))
            }
            else
            {
                searchStr = searchStr.appending(string)
                if (searchStr.count == 1 && string != "")
                {
                    placesTable = UITableView(frame: placesTableFrame)
                    placesTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
                    placesTable.isHidden = true;
                    contentView.addSubview(placesTable)
                }
                
                handleSearchForSearchString(searchString: searchStr)
                
                if (searchStr == "" && newString.count == 0)
                {
                    placesTable.isHidden = true;
                    placesTable.removeFromSuperview()
                }
                    
                else
                {
                    if (searchResultPlaces.count > 0)
                    {
                        placesTable.isHidden = false;
                        placesTable.reloadData()
                    }
                    else
                    {
                        if (placesTable != nil)
                        {
                            placesTable.isHidden = true;
                        }
                    }
                }
            }
        }
        return true
    }
    
    func handleSearchForSearchString(searchString:String)
    {
        searchQuery.location = (locationManager.location?.coordinate)!;
        searchQuery.input = searchString;
        
        searchQuery.fetchPlaces { (places, error) in
            if error == nil
            {
                self.searchResultPlaces = places! as NSArray;

                if self.placesTable != nil
                {
                    self.placesTable.delegate = self;
                    self.placesTable.dataSource = self;
                    self.placesTable.backgroundColor = UIColor.clear
                    self.placesTable.reloadData()
                }
            }
            else
            {
                SPPresentAlertViewWithErrorAndTitle(error, "Could not fetch Places. Try Again!");
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if (placesTable != nil)
        {
            placesTable.delegate = nil
            placesTable.dataSource = nil
            placesTable.isHidden = true
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool
    {
        if (placesTable != nil)
        {
            placesTable.delegate = nil
            placesTable.dataSource = nil
            placesTable.removeFromSuperview()
        }
        
        return true
    }
    
    //MARK:- UITextView Delegate Methods
    public func textViewDidChange(_ textView: UITextView)
    {
        if tvAboutMe.text!.trimmingCharacters(in: charSet).count == 0
        {
            //lblPlacehoder.isHidden = false
        }
        else
        {
            //lblPlacehoder.isHidden = true
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView)
    {
        if tvAboutMe.text!.trimmingCharacters(in: charSet).count == 0
        {
            //lblPlacehoder.isHidden = false
        }
        else
        {
            //lblPlacehoder.isHidden = true
        }
    }
    
    //MARK:- Web Services methods
    func editProfile()
    {
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self
            
            let tmp_dic:NSMutableDictionary = NSMutableDictionary()
            tmp_dic.setValue(txtFName.text!, forKey: "first_name")
            tmp_dic.setValue(txtLName.text, forKey: "last_name")
            tmp_dic.setValue(txtUsername.text, forKey: "username")
            tmp_dic.setValue(txtEmail.text, forKey: "email")
            tmp_dic.setValue(txtDOB.text!, forKey: "dob")
            tmp_dic.setValue(txtGender.text, forKey: "gender")
            tmp_dic.setValue(tvAboutMe.text, forKey: "about_me")
            tmp_dic.setValue(txtAddress.text, forKey: "address")
            tmp_dic.setValue(txtCity.text, forKey: "city")
            tmp_dic.setValue(txtCountry.text, forKey: "country")
            tmp_dic.setValue(selectedLocation?.coordinate.latitude, forKey: "latitude")
            tmp_dic.setValue(selectedLocation?.coordinate.longitude, forKey: "longitude")
            tmp_dic.setValue("", forKey: "contact")
            webclass.editUserProfile(dic_editprofile: tmp_dic,imgData:imgData)
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }

    func updateProfileonQuickblox()
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)

        let updateParameters = QBUpdateUserParameters()
        updateParameters.fullName = "\(txtUsername.text!)"
        updateParameters.email = "\(txtEmail.text!)"
        updateParameters.login = "\(txtUsername.text!)"

        QBRequest.updateCurrentUser(updateParameters, successBlock: { (response, user) in

            SVProgressHUD.dismiss()
            if self.imgData.count > 0
            {
                self.updateProfileImageonQuickblox()
            }

        }) { (response) in
            SVProgressHUD.dismiss()
            self.alertType(type: .okAlert, alertMSG: ServerErrorMsg(), delegate: self)
        }
    }

    func updateProfileImageonQuickblox()
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)

        QBRequest.tUploadFile(imgData, fileName: "UserProfileImage", contentType: "image/jpeg", isPublic: true, successBlock: { (response : QBResponse!, uploadedBlob :QBCBlob!) -> Void in

            let param = QBUpdateUserParameters()
            param.blobID = Int(uploadedBlob.id)
            param.customData = "https://qbprod.s3.amazonaws.com/\(uploadedBlob.uid!)"

            QBRequest.updateCurrentUser(param, successBlock: { (response, user) in

                SVProgressHUD.dismiss()
                self.alertType(type: .okAlertwithDelegate, alertMSG: "Your profile updated successfully.", delegate: self)

            }, errorBlock: { (response) in
                self.alertType(type: .okAlert, alertMSG: ServerErrorMsg(), delegate: self)
            })

        }, statusBlock: { (request : QBRequest?, status : QBRequestStatus?) -> Void in

        }) { (response : QBResponse!) -> Void in

            SVProgressHUD.dismiss()
            self.alertType(type: .okAlert, alertMSG: ServerErrorMsg(), delegate: self)
        }
    }
    
    //MARK:- Web Services delegate methods
    func dataDidFinishDowloading(aResponse: AnyObject?, methodname: String)
    {
        do {
            let JSONDict = try JSONSerialization.jsonObject(with: aResponse as! Data, options: []) as! NSDictionary
            print("Server Response: \(JSONDict)")
            
            if (kUserEditProfile().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg    = JSONDict.object(forKey: "response_msg") as! String
                
                if responseStatus == "success"
                {
                    if let responseDict    = JSONDict.object(forKey: "response_data") as? NSDictionary
                    {
                        UserDefaults.standard.set(responseDict.object(forKey: "first_name"), forKey: "first_name")
                        UserDefaults.standard.set(responseDict.object(forKey: "last_name"), forKey: "last_name")
                        UserDefaults.standard.set(responseDict.object(forKey: "profile_image"), forKey: "profile_image")
                        
                        GDP.userFirstName = "\(responseDict.object(forKey: "first_name")!)"
                        updateProfileonQuickblox()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
