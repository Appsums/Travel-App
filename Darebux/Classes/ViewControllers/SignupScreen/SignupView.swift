//
//  SignupView.swift
//  Darebux
//
//  Created by LogicSpice on 25/01/18.
//  Copyright © 2018 logicspice. All rights reserved.
//

import UIKit
import ActiveLabel
import MapKit
import FBSDKCoreKit
import FBSDKLoginKit

class SignupView: UIViewController, WebCommunicationClassDelegate, UITextFieldDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet var contentView:UIView!
    @IBOutlet var btnBackView:UIView!
    @IBOutlet var vw_whiteView:UIView!
    @IBOutlet var btnSignup:UIButton!
    @IBOutlet var btnFacebook: UIButton!
    @IBOutlet var lblLogin:UILabel!
    @IBOutlet var imgEye:UIImageView!
    @IBOutlet var txtFName:UITextField!
    @IBOutlet var txtLName:UITextField!
    @IBOutlet var txtEmail:UITextField!
    @IBOutlet var txtPassword:UITextField!
    @IBOutlet var txtDOB:UITextField!
    @IBOutlet var txtGender:UITextField!
    @IBOutlet var txtAddress:UITextField!
    @IBOutlet var vw_addressView:UIView!
    @IBOutlet weak var lbl_terms: ActiveLabel!
    let GDP = GDP_Obj()
    let appdel = App_Delegate()
    let arrGender = ["Male", "Female", "Other"]
    
    var placesTable:UITableView!
    var searchResultPlaces = NSArray()
    var searchQuery:SPGooglePlacesAutocompleteQuery!
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var selectedLocation: CLLocation?
    var isFromeHome = false

    var selected_dob: Date!
    var str_city: String!
    var str_country: String!

    var social_id : String = ""
    var login_type: String = ""
    var socialEmail: String = ""
    var socialFirstName: String = ""
    var socialLastName: String = ""

    var str_quickbloxId: String = ""
    var str_username: String = ""
    var isregistered_on_quickblox: Bool = false

    //MARK:- View Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        vw_whiteView.layer.cornerRadius = 4
        vw_whiteView.dropShadow()

        if isFromeHome
        {
            btnBackView.isHidden = false
        }

        str_city = ""
        str_country = ""
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        self.locationManager = CLLocationManager()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.distanceFilter = 50
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        self.locationManager.startUpdatingHeading()
        
        searchQuery = SPGooglePlacesAutocompleteQuery()
        searchQuery.radius = 100.0
    }
    
    override func viewDidLayoutSubviews()
    {
        GDP.adjustView(tmp_view: self.view)

        GDP.setColorAttributedText(colorStr1: "Already Sign Up? ", color1: UIColor.black, colorStr2: "Login Here", color2: UIColor(red: 35/255.0, green: 166/255.0, blue: 46/255.0, alpha: 1), lblObj: lblLogin, fontSize: lblLogin.font.pointSize)

        btnSignup.layer.cornerRadius = btnSignup.bounds.size.height/2
        btnFacebook.layer.cornerRadius = btnFacebook.bounds.size.height/2
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- CLLocationManagerDelegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location: CLLocation = locations.last!
        currentLocation = location
        self.reverseGeocodeCoordinate()
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
            str_city = arr![0]
            str_country = arr![0]
        }
        else if (arr?.count)! == 2
        {
            str_city = arr![0]
            str_country = arr![1]
        }
        else if (arr?.count)! == 3
        {
            str_city = arr![0]
            str_country = arr![2]
        }
        else
        {
            str_city = arr![(arr?.count)! - 3]
            str_country = arr![(arr?.count)! - 1]
        }

        print(str_city)
        print(str_country)
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

    func reverseGeocodeCoordinate()
    {
        CLGeocoder().reverseGeocodeLocation(currentLocation!, completionHandler: {(placemarks, error)-> Void in
            if (error != nil)
            {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }

            if placemarks?.count != 0
            {
                let place = placemarks![0] as CLPlacemark
                let lines = place.addressDictionary?["FormattedAddressLines"] as? [String]
                let my_address = lines?.joined(separator: ",")
                self.txtAddress.text = lines?.joined(separator: ",")

                self.parsePlacemarks(placemark: place, address: my_address)
            }
            else
            {
                print("Problem with the data received from geocoder")
            }
        })
    }

    func parsePlacemarks(placemark: CLPlacemark, address: String!)
    {
        if let city = placemark.locality, !city.isEmpty
        {
            self.str_city = city
        }
        // the same story optionalllls also they are not empty
        if let country = placemark.country, !country.isEmpty
        {
            self.str_country = country
        }

        if self.str_city == "" || self.str_country == ""
        {
            getCityCountry(address: address)
        }

        print(self.str_city)
        print(self.str_country)
    }

    func getCityCountry(address: String!)
    {
        let arr = address.components(separatedBy: ",")
        if (arr.count) == 1
        {
            self.str_city = arr[0]
            self.str_country = arr[0]
        }
        else if (arr.count) == 2
        {
            self.str_city = arr[0]
            self.str_country = arr[1]
        }
        else if (arr.count) == 3
        {
            self.str_city = arr[0]
            self.str_country = arr[2]
        }
        else
        {
            self.str_city = arr[(arr.count) - 3]
            self.str_country = arr[(arr.count) - 1]
        }

        print(self.str_city)
        print(self.str_country)
    }

    //MARK:- Button Click Method
    @IBAction func btn_Back_Click(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_SignUp_Click(_ sender: UIButton)
    {
        self.view.endEditing(true)
        if Reachability.isConnectedToNetwork()
        {
            if(checkValidation())
            {
                if isregistered_on_quickblox == false
                {
                    self.registerWithQuickblox()
                }
                else
                {
                    self.userregisteronServer()
                }
            }
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }

    @IBAction func btn_Facebook_Click(_ sender: UIButton)
    {
        if Reachability.isConnectedToNetwork()
        {
            login_type = "facebook"

            let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
            fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
                if (error == nil)
                {
                    let fbloginresult : FBSDKLoginManagerLoginResult = result!
                    if fbloginresult.grantedPermissions != nil
                    {
                        if(fbloginresult.grantedPermissions.contains("email"))
                        {
                            SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
                            self.getFacebookUserData()
                            fbLoginManager.logOut()
                        }
                    }
                }
            }
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }

    func getFacebookUserData()
    {
        if((FBSDKAccessToken.current()) != nil)
        {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil)
                {
                    SVProgressHUD .dismiss()
                    let JSONDict = result as! NSDictionary
                    print(JSONDict)

                    self.social_id = JSONDict.object(forKey: "id") as! String!
                    self.socialEmail = JSONDict.object(forKey: "email") as! String!
                    self.socialFirstName = JSONDict.object(forKey: "first_name") as! String!
                    self.socialLastName = JSONDict.object(forKey: "last_name") as! String!

                    self.txtFName.text = self.socialFirstName
                    self.txtLName.text = self.socialLastName
                    self.txtEmail.text = self.socialEmail

                    if self.isregistered_on_quickblox == false
                    {
                        self.registerWithQuickblox()
                    }
                    else
                    {
                        self.postSocialLoginData()
                    }
                }
            })
        }
    }
    
    @IBAction func btn_HideShowPWD_Click(_ sender: UIButton)
    {
        imgEye.isHighlighted = !imgEye.isHighlighted
        txtPassword.isSecureTextEntry = !imgEye.isHighlighted
    }
    
    @IBAction func btnDOB_Click(_ sender: UIButton)
    {
        self.view.endEditing(true)
        var sel_date: Date!
        
        if txtDOB.text == ""
        {
            sel_date = Date()
            selected_dob = Date()
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
            self.selected_dob = value as! Date
            
            return
        }, cancel: { ActionStringCancelBlock in return }, origin: sender)
        
        //datePicker?.maximumDate = Date()
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
    
    @IBAction func btn_SignIn_Click(_ sender: UIButton) {
        var isExists = false
        var frontView:UIViewController?
        
        for viObj in (appdel.appNav?.viewControllers)!
        {
            if viObj is LoginView
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
            let obj_view = LoginView(nibName: "LoginView", bundle: nil)
            appdel.appNav?.pushViewController(obj_view, animated: true)
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
        let charSet = NSCharacterSet.whitespacesAndNewlines
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
        else if ((txtEmail.text?.trimmingCharacters(in: charSet))?.count == 0)
        {
            self.alertType(type: .okAlert, alertMSG: "Please enter email", delegate: self)
            return false
        }
        else if ((isValidEmail(testStr: txtEmail.text!) == false))
        {
            self.alertType(type: .okAlert, alertMSG: "Please enter valid email address", delegate: self)
            return false
        }
        else if ((txtPassword.text?.trimmingCharacters(in: charSet))?.count == 0)
        {
            self.alertType(type: .okAlert, alertMSG: "Please enter password", delegate: self)
            return false
        }
        else if (((txtPassword.text?.trimmingCharacters(in: charSet))?.count)! < 8)
        {
            self.alertType(type: .okAlert, alertMSG: "Password must contain atleast 8 characters", delegate: self)
            return false
        }
        else if ((txtDOB.text?.trimmingCharacters(in: charSet))?.count == 0)
        {
            self.alertType(type: .okAlert, alertMSG: "Please select date of birth", delegate: self)
            return false
        }
        else if (selected_dob > Date())
        {
            self.alertType(type: .okAlert, alertMSG: "Date of birth cannot be in future", delegate: self)
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
//        else if (selectedLocation == nil)
//        {
//            self.alertType(type: .okAlert, alertMSG: "Please enter correct address", delegate: self)
//            return false
//        }

        return true
    }
    
    func formatTermsLabel()
    {
        let customType1 = ActiveType.custom(pattern: "\\sterms\\b") //Looks for "terms"
        let customType2 = ActiveType.custom(pattern: "\\sprivacy\\b") //Looks for "privacy policy"
        let customType3 = ActiveType.custom(pattern: "\\sdisclaimer\\b") //Looks for "disclaimer"
        
        lbl_terms.enabledTypes.append(customType1)
        lbl_terms.enabledTypes.append(customType2)
        lbl_terms.enabledTypes.append(customType3)
        
        lbl_terms.customize { label in
            label.text = "By Signing Up, you agree to our terms, privacy and disclaimer"
            label.numberOfLines = 2
            label.lineSpacing = 4
            label.textColor = UIColor.black
            
            //Custom types
            label.customColor[customType1] = UIColor.blue
            label.customSelectedColor[customType1] = UIColor.gray
            label.customColor[customType2] = UIColor.blue
            label.customSelectedColor[customType2] = UIColor.gray
            label.customColor[customType3] = UIColor.blue
            label.customSelectedColor[customType3] = UIColor.gray
            
            label.handleCustomTap(for: customType1, handler: { (str) in
                let obj_view = Web_View(nibName: "Web_View", bundle: nil)
                obj_view.str_title = "Terms & Conditions"
                obj_view.str_url = "http://darebux.logicspice.com/terms-and-conditions"
                self.appdel.appNav?.pushViewController(obj_view, animated: true)
            })
            
            label.handleCustomTap(for: customType2, handler: { (str) in
                let obj_view = Web_View(nibName: "Web_View", bundle: nil)
                obj_view.str_title = "Privacy Policy"
                obj_view.str_url = "http://darebux.logicspice.com/privacy-policy"
                self.appdel.appNav?.pushViewController(obj_view, animated: true)
            })
            
            label.handleCustomTap(for: customType3, handler: { (str) in
                let obj_view = Web_View(nibName: "Web_View", bundle: nil)
                obj_view.str_title = "Disclaimer"
                obj_view.str_url = "http://darebux.logicspice.com/disclaimer"
                self.appdel.appNav?.pushViewController(obj_view, animated: true)
            })
        }
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
            
            placesTableFrame = CGRect(x: 0, y:vw_addressView.frame.origin.y-140, width: vw_addressView.frame.size.width, height: 140)
            
            if (string == "" && newString.count == 0)
            {
                placesTable.isHidden = true;
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
                        placesTable.isHidden = true;
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
                
                self.placesTable.delegate = self;
                self.placesTable.dataSource = self;
                self.placesTable.backgroundColor = UIColor.clear
                self.placesTable.reloadData()
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
    
    //MARK:- Web Services delegate methods
    func registerWithQuickblox()
    {
        if Reachability.isConnectedToNetwork()
        {
            SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
            let newUser = QBUUser()
            newUser.fullName = "\(txtFName.text!) \(txtLName.text!)"
            newUser.email = "\(txtEmail.text!)"
            newUser.password = "darebux@123"

            QBRequest.signUp(newUser, successBlock: { (response, user) in
                print("successfull")
                self.isregistered_on_quickblox = true
                self.str_quickbloxId = "\(user.id)"
                SVProgressHUD.dismiss()

                if self.login_type == "facebook"
                {
                    self.postSocialLoginData()
                }
                else
                {
                    self.userregisteronServer()
                }

            }, errorBlock: { (response) in
                self.isregistered_on_quickblox = false
                let str_error = response.error?.reasons?.description
                let char_set = (NSCharacterSet.alphanumerics).inverted
                if str_error != nil
                {
                    let str_result = (str_error?.components(separatedBy: char_set) as! NSArray).componentsJoined(by: "")
                    print(str_result)

                    if str_result == "errorsemailhasalreadybeentaken"
                    {
                        QBRequest.user(withEmail: self.txtEmail.text!, successBlock: { (response, user) in
                            self.str_quickbloxId = "\(user.id)"
                            SVProgressHUD.dismiss()

                            if self.login_type == "facebook"
                            {
                                self.postSocialLoginData()
                            }
                            else
                            {
                                self.userregisteronServer()
                            }

                        }, errorBlock: { (response) in
                            SVProgressHUD.dismiss()
                            self.alertType(type: .okAlert, alertMSG: "Unable to register, please contact to admin.", delegate: self)
                        })
                    }
                    else
                    {
                        SVProgressHUD.dismiss()
                        self.alertType(type: .okAlert, alertMSG: "Unable to register, please contact to admin.", delegate: self)
                    }
                }
                else
                {
                    SVProgressHUD.dismiss()
                    self.alertType(type: .okAlert, alertMSG: "Unable to register, please contact to admin.", delegate: self)
                }
            })
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }

    func userregisteronServer()
    {
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self

            login_type = "normal"

            let tmp_dic:NSMutableDictionary = NSMutableDictionary()
            tmp_dic.setValue(txtFName.text!, forKey: "first_name")
            tmp_dic.setValue(txtLName.text, forKey: "last_name")
            tmp_dic.setValue(txtEmail.text!, forKey: "email")
            tmp_dic.setValue(txtPassword.text, forKey: "password")
            tmp_dic.setValue(txtDOB.text!, forKey: "dob")
            tmp_dic.setValue(txtGender.text, forKey: "gender")
            tmp_dic.setValue("", forKey: "address")
            tmp_dic.setValue(currentLocation?.coordinate.latitude, forKey: "latitude")
            tmp_dic.setValue(currentLocation?.coordinate.longitude, forKey: "longitude")
            tmp_dic.setValue("", forKey: "contact")
            tmp_dic.setValue(str_city, forKey: "city")
            tmp_dic.setValue(str_country, forKey: "country")
            tmp_dic.setValue(login_type, forKey: "type")
            tmp_dic.setValue(str_quickbloxId, forKey: "quickblox_id")
            tmp_dic.setValue(kDeviceType(), forKey: "device_type")
            tmp_dic.setValue(self.GDP.device_ID, forKey: "device_id")
            webclass.userRegister(dic_register: tmp_dic)
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }

    func loginWithQuickblox(tmp_email: String)
    {
        if Reachability.isConnectedToNetwork()
        {
            SVProgressHUD.show(with: SVProgressHUDMaskType.gradient)
            QBRequest.logIn(withUserEmail: tmp_email, password: "darebux@123", successBlock: { (response, user) in

                let device_uuid = UIDevice.current.identifierForVendor?.uuidString
                let subscription = QBMSubscription()
                subscription.notificationChannel = .APNS
                subscription.deviceUDID = device_uuid
                subscription.deviceToken = self.GDP.device_token

                QBRequest.subscriptions(successBlock: { (response, arrSubscription:[QBMSubscription]?) in

                    for value:QBMSubscription in arrSubscription!
                    {
                        QBRequest.deleteSubscription(withID:value.id , successBlock: { (response) in
                        }, errorBlock: { (response) in
                            print(response)
                        })
                    }

                    QBRequest.createSubscription(subscription, successBlock: { (response, objects: [QBMSubscription]?) in
                        print("This is an Success")
                    }, errorBlock: { (response) in
                        print("This is an error")
                    })

                }, errorBlock: { (errResponse) in

                    QBRequest.createSubscription(subscription, successBlock: { (response, objects: [QBMSubscription]?) in
                        print("This is an Success")
                    }, errorBlock: { (response) in
                        print("This is an error")
                    })

                    print(errResponse)
                })

            }, errorBlock: { (response) in

            })

            let updateParameters = QBUpdateUserParameters()
            updateParameters.fullName = "\(str_username)"
            updateParameters.login = "\(str_username)"
            QBRequest.updateCurrentUser(updateParameters, successBlock: { (response, user) in

            }) { (response) in
                SVProgressHUD.dismiss()
                self.alertType(type: .okAlert, alertMSG: ServerErrorMsg(), delegate: self)
            }

            let mainView = HomePage(nibName: "HomePage", bundle: nil)

            GDP.leftView = LeftViewController(nibName: "LeftViewController", bundle: nil)
            appdel.appNav = UINavigationController(rootViewController: mainView)
            appdel.appNav?.isNavigationBarHidden = true;
            appdel.window!.rootViewController = appdel.appNav
            appdel.window!.makeKeyAndVisible()
        }
        else
        {
            self.alertType(type: .okAlert, alertMSG: kNo_Internet(), delegate: self)
        }
    }

    func postSocialLoginData()
    {
        if Reachability.isConnectedToNetwork()
        {
            let webclass = WebCommunicationClass()
            webclass.aCaller = self

            let tmp_dic:NSMutableDictionary = NSMutableDictionary()

            tmp_dic.setValue(str_quickbloxId, forKey: "quickblox_id")
            tmp_dic.setValue(login_type, forKey: "type")
            tmp_dic.setValue(socialFirstName, forKey: "first_name")
            tmp_dic.setValue(socialLastName, forKey: "last_name")
            tmp_dic.setValue(socialEmail, forKey: "email")
            tmp_dic.setValue("", forKey: "password")
            tmp_dic.setValue("", forKey: "address")
            tmp_dic.setValue("", forKey: "latitude")
            tmp_dic.setValue("", forKey: "longitude")
            tmp_dic.setValue("", forKey: "gender")
            tmp_dic.setValue("", forKey: "dob")
            tmp_dic.setValue("", forKey: "contact")
            tmp_dic.setValue(str_city, forKey: "city")
            tmp_dic.setValue(str_country, forKey: "country")
            tmp_dic.setValue(kDeviceType(), forKey: "device_type")
            tmp_dic.setValue(self.GDP.device_ID, forKey: "device_id")
            webclass.userRegister(dic_register: tmp_dic)
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
            
            if (kUserSignUp().caseInsensitiveCompare(methodname) == ComparisonResult.orderedSame)
            {
                let responseStatus = JSONDict.object(forKey: "response_status") as! String
                let responseMsg    = JSONDict.object(forKey: "response_msg") as! String
                
                if responseStatus == "success"
                {
                    if login_type == "facebook"
                    {
                        if let responseDict = JSONDict.object(forKey: "response_data") as? NSDictionary
                        {
                            UserDefaults.standard.set("\(responseDict.object(forKey: "token")!)", forKey: "token")
                            UserDefaults.standard.set("\(responseDict.object(forKey: "quickblox_id")!)", forKey: "quickblox_id")
                            UserDefaults.standard.set(responseDict.object(forKey: "email_address"), forKey: "email")
                            UserDefaults.standard.set(responseDict.object(forKey: "first_name"), forKey: "first_name")
                            UserDefaults.standard.set(responseDict.object(forKey: "last_name"), forKey: "last_name")
                            UserDefaults.standard.set(responseDict.object(forKey: "profile_image"), forKey: "profile_image")
                            UserDefaults.standard.set(responseDict.object(forKey: "user_id"), forKey: "user_id")

                            GDP.isBeforeLogin = false
                            GDP.qb_id = "\(responseDict.object(forKey: "quickblox_id")!)"
                            GDP.userEmail = "\(responseDict.object(forKey: "email_address")!)"
                            GDP.userID = "\(responseDict.object(forKey: "user_id")!)"
                            GDP.userFirstName = "\(responseDict.object(forKey: "first_name")!)"
                            GDP.jsonToken = "\(responseDict.object(forKey: "token")!)"

                            str_username = "\(responseDict.object(forKey: "username")!)"
                            self.loginWithQuickblox(tmp_email: GDP.userEmail)
                        }
                    }
                    else
                    {
                        GDP.isBeforeLogin = true
                        self.alertType(type: .okAlert, alertMSG: responseMsg, delegate: self)
                        let mainView = LoginView(nibName: "LoginView", bundle: nil)
                        appdel.appNav = UINavigationController(rootViewController: mainView)
                        appdel.appNav?.isNavigationBarHidden = true;
                        appdel.window!.rootViewController = appdel.appNav
                        appdel.window!.makeKeyAndVisible()
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
