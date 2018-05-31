//
//  AddQuestionViewController.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/14.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit
import FirebaseAuth
import SDWebImage
import SVProgressHUD
import Photos
class AddQuestionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    var passedValue: Any?
    var articleObject: Article?
    @IBOutlet weak var reasonTextView: UITextView!
    @IBOutlet weak var addQuestionButton: UIButton!
//    @IBOutlet weak var reasonTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldDelegate()
        setButtonUI()
        setTextFieldPlaceholder()
        setNavigation()
        imageView.isUserInteractionEnabled = true
        let touch = UITapGestureRecognizer(target: self, action: #selector(bottomAlert))
        imageView.addGestureRecognizer(touch)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setTextFieldDelegate() {
//        reasonTextField.delegate = self
        addressTextField.delegate = self
        titleTextField.delegate = self
        reasonTextView.delegate = self
    }

    func setButtonUI() {
        addQuestionButton.layer.cornerRadius = 5
        addQuestionButton.layer.borderWidth = 1
        addQuestionButton.layer.borderColor = UIColor.lightGray.cgColor
        addQuestionButton.clipsToBounds = true
    }
    func setTextFieldPlaceholder() {
        titleTextField.placeholder = "標題"
//        reasonTextField.placeholder = "內容"
        addressTextField.placeholder = "地址"
        titleTextField.layer.borderColor = UIColor.red.cgColor
        addressTextField.layer.borderColor = UIColor.red.cgColor

        reasonTextView.text = "內容"
        reasonTextView.textColor = UIColor(displayP3Red: 199 / 255, green: 199 / 255, blue: 205 / 255, alpha: 1)
        reasonTextView.layer.cornerRadius = 5
        reasonTextView.layer.masksToBounds = true
        reasonTextView.layer.borderWidth = 1
        reasonTextView.layer.borderColor = UIColor.lightGray.cgColor
        guard let passedValue = passedValue as? Article else {
        return
        }
        titleTextField.text = passedValue.title
//        reasonTextField.text = passedValue.reason
        addressTextField.text = passedValue.address
        reasonTextView.text = passedValue.reason
        reasonTextView.textColor = UIColor.black
        imageView.sd_setImage(with: URL(string: passedValue.imageUrl), placeholderImage: UIImage(named: "picture_3"))
        addQuestionButton.setTitle("編輯", for: .normal)

    }
    func setArticleObject() {
        guard let title = titleTextField.text, let reason = reasonTextView.text, let address = addressTextField.text else {
            return
        }
        guard title.trimmingCharacters(in: .whitespaces) != "" &&  address.trimmingCharacters(in: .whitespaces) != "" && reason.trimmingCharacters(in: .whitespaces) != "" else {
            alertAction(title: "輸入錯誤", message: "欄位不得為空白！")
            return
        }
        if let passedValue = passedValue as? Article {
            articleObject = passedValue
            articleObject?.address = address
            articleObject?.title = title
            articleObject?.reason = reason
            articleObject?.createdTime = Int(NSDate().timeIntervalSince1970)
        } else {
        articleObject = Article(uid: "", userName: "", imageUrl: "", address: address, reason: reason, title: title, createdTime: Int(NSDate().timeIntervalSince1970), articleKey: "", imageName: "")
        }
    }

    func setNavigation() {
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "exit"), style: .done, target: self, action: #selector(logout))
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    func alertAction(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    let picker = UIImagePickerController()
                    picker.delegate = self
                    picker.sourceType = .photoLibrary
                    self.present(picker, animated: true, completion: nil)
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted, .denied:
            alertAction(title: "未開啟存取本機相冊權限", message: "請在手機設定中開啟本機相冊存取權限，相冊將用於編輯及新增發問時所需的照片。")
            print("User do not have access to photo album.")
       
        }
    }
    
    @objc func bottomAlert() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let photoAction = UIAlertAction(title: "相片", style: .default) { _ in
            self.checkPermission()
        }
        let cameraAction = UIAlertAction(title: "相機", style: .default) { _ in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            self.present(picker, animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(photoAction)
        alertController.addAction(cameraAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        if picker.sourceType == .camera {
            UIImageWriteToSavedPhotosAlbum(image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        imageView.image = image
        dismiss(animated: true, completion: nil)
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let alertController = UIAlertController(title: "儲存發生錯誤", message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "確定", style: .default))
            present(alertController, animated: true)
        } else {
            let alertController = UIAlertController(title: "存擋", message: "資料已成功上傳", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "確定", style: .default))
            present(alertController, animated: true)
        }
    }

    @IBAction func addQuestionAction(_ sender: UIButton) {
        setArticleObject()
        guard let articleObject = articleObject else {
            return
        }
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.setDefaultStyle(.light)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.show(withStatus: "上傳中")
        if articleObject.articleKey != "" {
            FirebaseManager.shared.editArticle(uploadimage: imageView.image, article: articleObject, handler: {
                SVProgressHUD.dismiss()
                self.navigationController?.popViewController(animated: true)
            })
        } else {
        FirebaseManager.shared.addArticleQuestion(uploadimage: imageView.image, uploadArticle: articleObject, handler: {
            SVProgressHUD.dismiss()
            self.navigationController?.popViewController(animated: true)
        })
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "內容"{
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if(textView.text.count < 1 || textView.text == ""){
            textView.text = "內容"
            textView.textColor = UIColor(displayP3Red: 175 / 255, green: 174 / 255, blue: 174 / 255, alpha: 1)
        }
    }
    
}

extension UITextField
{
    open override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.masksToBounds = true
    }
}
