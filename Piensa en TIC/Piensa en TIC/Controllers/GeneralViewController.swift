import UIKit
import ImageIO
import Photos

protocol AlertInfoViewDelegate {
    func dismissAlert()
}

class GeneralViewController: UIViewController {
    
    var index:Int!
    var info:[String:String]!
    var colorText:String!
    var colorSelected:UIColor!
    let imagePicker = UIImagePickerController()
    var imageSaved:UIImage!
    var metadata:AnyObject!
    var activityName:String!
    let storage = Storage.shared
    var delegate:CompleteChapterDelegate!
    var delegateSwipe:DataSourceEnableSwipe!
    var delegateTransition: SwipeDelegate!
    
    let dictionaries = [["key":kCGImagePropertyExifDictionary,
                         "values":[kCGImagePropertyExifDateTimeOriginal,kCGImagePropertyExifFlash, kCGImagePropertyExifWhiteBalance],
                         "textValues":["Fecha y hora: ", "Flash: ", "Balance de blancos: "]],
                        ["key":kCGImagePropertyTIFFDictionary,
                         "values":[kCGImagePropertyTIFFModel],
                         "textValues":["Modelo: "]],
                        ["key":kCGImagePropertyPixelWidth,
                         "textValues": "Ancho: "],
                        ["key":kCGImagePropertyPixelHeight,
                         "textValues": "Altura: "],
                        ["key":kCGImagePropertyOrientation,
                         "textValues": "Orientación: "],
                        ["key":kCGImagePropertyGPSDictionary,
                         "values":[kCGImagePropertyGPSAltitude, kCGImagePropertyGPSLongitude, kCGImagePropertyGPSLatitude],
                         "textValues":["Altitud: ","Longitud: ", "Latitud: "]]]
    
    var alertViewInfo:AlertInfoViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if colorText != nil {
            colorSelected = UIColor(hexString: colorText)!
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getUserNameFromUserDefaults() -> String {
        let userDefaults = UserDefaults.standard
        guard let name:String = userDefaults.object(forKey: "userName") as! String? else {return ""}
     
        return name
    }
    
    func matchRegex(pattern: String, value:String) -> Bool{
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: value, options: [], range: NSRange(location: 0, length: value.characters.count))
        return matches.count > 0
    }
    
    func showAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Ok", style: .cancel) {(_) in
            alert.dismiss(animated: false, completion: nil)
        }
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
}

extension GeneralViewController {
    func processExample(_ example:String) -> NSAttributedString {
        let shouldBeBold = example.contains("Mshtscnell") || example.contains("M5ht5cne11")
        let array = example.split(by: "|")
        guard let arrayResult = array else { return NSAttributedString()}
        let words = (arrayResult[0] as! String).split(by: ",")
        let fonts = (arrayResult[1] as! String).split(by: ",")
        guard let wordsResult = words else {return NSAttributedString()}
        guard let fontsResult = fonts else {return NSAttributedString()}
        var wordsResponse = [AnyObject]()
        for i in 0..<wordsResult.count {
            let word = wordsResult[i] as! String
            let newText = word.replacingOccurrences(of: "u015", with: "\n")
            
            wordsResponse.append(newText as AnyObject)
        }
        
        var fontsResponse = [AnyObject]()
        for i in 0..<fontsResult.count {
            let fontSize = fontsResult[i] as! String
            let cast = Int(fontSize)
            if shouldBeBold {
                if i == fontsResult.count - 1 {
                    fontsResponse.append(UIFont.boldSystemFont(ofSize: CGFloat(cast!)))
                    continue
                }
            }
            fontsResponse.append(UIFont.systemFont(ofSize: CGFloat(cast!)))
        }
        
        
        
        let result = NSAttributedString().stringWithWords(words: wordsResponse as! [String], fonts: fontsResponse as! [UIFont], color:UIColor(hexString: colorText)!)
        return result
    }
    
    func processNickname(_ format:String) -> NSAttributedString {
        guard let user = getUser() else {
            return NSAttributedString(string: String.init(format: format, ""))
        }
        
        let formatted = format.replacingOccurrences(of: "\\n", with: "u015").replacingOccurrences(of: "u015", with: "\n").replacingOccurrences(of: "%@", with: "")
        let words = [user.nickName.uppercased(), formatted]
        let fonts = [UIFont.boldSystemFont(ofSize: 20), UIFont.systemFont(ofSize: 20)]
        
        
        let result = NSAttributedString().stringWithWords(words: words, fonts: fonts, color: UIColor(hexString: colorText)!)
        return result
    }
    
    func processDescriptionWithLinks(_ description:String, links:[String]) -> NSAttributedString {
        let words = description.split(by: ",")
        guard let wordsResult = words else {return NSAttributedString()}
        var wordsResponse = [AnyObject]()
        for i in 0..<wordsResult.count {
            
            let word = wordsResult[i] as! String
            
            let newText1 = word.replacingOccurrences(of: "\\n", with: "u015").replacingOccurrences(of: "u015", with: "\n")
            let newText = newText1.replacingOccurrences(of: "u2022", with: "• ")
            
            wordsResponse.append(newText as AnyObject)
        }
        
        let result = NSAttributedString().stringWithWords(words: wordsResponse as! [String], links: links, color:UIColor(hexString: colorText)!)
        return result
    }
    
    func processDescriptionWithLinks(_ description:String, links:[String], font:UIFont!, linkColor:UIColor? = UIColor.white) -> NSAttributedString {
        let words = description.split(by: ",")
        guard let wordsResult = words else {return NSAttributedString()}
        var wordsResponse = [AnyObject]()
        for i in 0..<wordsResult.count {
            
            let word = wordsResult[i] as! String
            
            let newText1 = word.replacingOccurrences(of: "\\n", with: "u015").replacingOccurrences(of: "u015", with: "\n")
            let newText = newText1.replacingOccurrences(of: "u2022", with: "• ")
            
            wordsResponse.append(newText as AnyObject)
        }
        
        let result = NSAttributedString().stringWithWords(words: wordsResponse as! [String], links: links, color:UIColor(hexString: colorText)!, font: font, linkColor: linkColor!)
        return result
    }
}


extension GeneralViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate{
    @IBAction func loadImageButtonTapped(sender: UIButton) {
        let actionSheet = UIActionSheet(title: "Choose Option", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Camera", "Photo Library")
        actionSheet.show(in: self.view)
    }
    
    //MARK: delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print(info)
        
        if let metadata = info[UIImagePickerControllerMediaMetadata] as! [String: AnyObject]! {
            
            let value = searchIn(metadata)
            storage.setMetadata(metadata: value as AnyObject)
            
        } else if let url  = info[UIImagePickerControllerReferenceURL] as! NSURL!{
            let asset = PHAsset.fetchAssets(withALAssetURLs: [url as URL], options: nil)
            guard let result = asset.firstObject, result is PHAsset else {
                return
            }
            let imageManager = PHImageManager.default()
            imageManager.requestImageData(for: result , options: nil, resultHandler:{
                (data, responseString, imageOriet, info) -> Void in
                let imageData: NSData = data! as NSData
                if let imageSource = CGImageSourceCreateWithData(imageData, nil) {
                    let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)! as NSDictionary
                    print(imageProperties)
                    let valuesFromUrl = self.searchIn(imageProperties as! [String : AnyObject])
                    self.storage.setMetadata(metadata: valuesFromUrl as AnyObject!)
                    //now you have got meta data in imageProperties, you can display PixelHeight, PixelWidth, etc.
                }
            })
        }

        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            self.imageView.contentMode = UIViewContentMode.scaleAspectFit
//            self.imageView.image = pickedImage
//            let value = getMetadata(image: pickedImage)
//            storage.setMetadata(metadata: value as AnyObject)
            storage.setImage(image: pickedImage)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: UIActionSheet delegate Methods
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        var shouldStop = false
        switch (buttonIndex){
            
        case 0:
            shouldStop = true
            break
        case 1:
            imagePicker.sourceType = .camera
            break
        case 2:
            imagePicker.sourceType = .photoLibrary
            break
        default:break
            
        }
        
        if shouldStop {
            return
        }
        storage.saveParameter(key: .latestChapter, value: "chapter1" as AnyObject)
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func formattedText(_ word:String) -> String{
        return word.replacingOccurrences(of: "u015", with: "\n")
    }

}

extension GeneralViewController {
    func getUser() -> User! {
        guard let data = storage.getParameterFromKey(key: .user) as! Data! else { return nil}
        guard let dic = User.unarchive(data: data) else { return nil}
        let user = User.initUser(fromDic: dic)
        return user
    }
}

extension GeneralViewController {
    func shareFunctionality() {
        let staticText = "Encriptando con Piensa En TIC"
        let activityViewController = UIActivityViewController(activityItems: [staticText], applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler  = { activity, success, items, error in
            print("Activitycontroller ",activity ?? "")
            print("items ",items ?? "")
        }
        self.present(activityViewController, animated: true, completion: {})

    }
}

extension GeneralViewController:AlertInfoViewDelegate {
    func showAlertInfoView(_ message: String! = "") {
        
        UIView.animate(withDuration: 0, delay: 1, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                guard self.alertViewInfo == nil else {return}
                
                self.alertViewInfo = self.storyboard?.instantiateViewController(withIdentifier: StoryboardIdentifier.alertViewInfo) as! AlertInfoViewController
                
                self.alertViewInfo.message = message
                self.alertViewInfo.delegate = self
                self.navigationController?.view.addSubview(self.alertViewInfo.view)
            }, completion: {_ in
                
            }
        )
        
        
        
    }
    
    func dismissAlert() {
        guard alertViewInfo != nil else {return}
        
        alertViewInfo.removeFromParentViewController()
        alertViewInfo.view.removeFromSuperview()
        alertViewInfo = nil
    }
}

extension GeneralViewController {
    func getMetadata(image: UIImage) -> [String]{
        var metaData = [String]()
//        guard let jpgData: Data = UIImageJPEGRepresentation(image, 1.0) else {
//            return metaData
//        }
//        metaData.append(readMetadata(jpgData))
        guard let pngData: Data = UIImagePNGRepresentation(image) else {
            return metaData
        }
    
        
        metaData.append(readMetadata(pngData))
        return metaData
    }
    
    func readMetadata(_ data: Data) -> String {
        var metaData = String()
        
        guard let sourceRef = CGImageSourceCreateWithData(data as CFData, nil) else {
            return metaData
        }
        
//        let options = [kCGImageSourceShouldCache as String : NSNumber(value: false)]
        guard let imagesProperties = CGImageSourceCopyPropertiesAtIndex(sourceRef, 0, nil) else {
            return metaData
        }
        
        for dictionary in dictionaries {
            guard let arrayValues = dictionary["values"] as! [CFString]! else {
                guard let value = dictionaryGetValue(dictionary: imagesProperties, key: dictionary["key"] as! CFString) else {
                    continue
                }
                metaData.append(String(format:"\n%@ %@", dictionary["textValues"] as! String, value as! CVarArg))
                
                continue
            }
            
            let textTitles = dictionary["textValues"] as! [String]
            guard let secondaryProperties = dictionaryGetValue(dictionary: imagesProperties, key: dictionary["key"] as! CFString) as! CFDictionary!  else {
                continue
            }
            
            for i in 0 ..< arrayValues.count {
                let property = arrayValues[i]
                let title = textTitles[i]
                guard let value = dictionaryGetValue(dictionary: secondaryProperties, key: property) as! String! else {
                    continue
                }
                metaData.append(String(format:"\n%@ %@", title, value))
            }
        }
        
        return metaData

    }
    
    func keyIsInExcludeList(list: [CFString], key:CFString) -> Bool {
        let isInList = list.contains {
            $0 === key
        }
        return isInList
    }
    
    func dictionaryGetValue(dictionary: CFDictionary, key: CFString) -> Any! {
        guard let ref = CFDictionaryGetValue(dictionary, unsafeBitCast(key, to: UnsafeRawPointer.self)) else {return nil}
        let value = unsafeBitCast(ref, to: AnyObject.self)

        return value
    }
    
    func searchIn(_ mainDictionary: [String: AnyObject]) -> String {
        var metaData = String()
        
        for dictionary in dictionaries {
            let key = dictionary["key"] as! String
            guard let arrayValues = dictionary["values"] as! [String]! else {
                guard let value = mainDictionary[key] else {
                    continue
                }
                
                if value is String {
                    metaData.append(String(format:"\n%@ %@", dictionary["textValues"] as! String, value as! String))
                } else if value is NSNumber {
                    metaData.append(String(format:"\n%@ %@", dictionary["textValues"] as! String, value as! NSNumber))
                }
                
                
                continue
            }
            
            let textTitles = dictionary["textValues"] as! [String]
            
            guard let secondaryDictionary = mainDictionary[key] as! [String:AnyObject]! else {
                continue
            }
            
            for i in 0 ..< arrayValues.count {
                let property = arrayValues[i]
                let title = textTitles[i]
                guard let value = secondaryDictionary[property] else {
                    continue
                }
                
                
                if value is String {
                    metaData.append(String(format:"\n%@ %@", title, value as! String))
                } else if value is NSNumber {
                    metaData.append(String(format:"\n%@ %@", title, value as! NSNumber))
                }
            }
        }
        
        return metaData
    }
}
