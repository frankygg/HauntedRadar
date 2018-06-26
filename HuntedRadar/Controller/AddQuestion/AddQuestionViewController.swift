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
class AddQuestionViewController: UIViewController {
    var passedValue: Any?
    var pageControl = UIPageControl()
    let fullSize = UIScreen.main.bounds.size
    var icount = 0
    var myTag = 0
    var imageArray = [UIImage]()

    var articleObject: Article?
    @IBOutlet weak var bottomScrollView: UIScrollView!
    @IBOutlet weak var reasonTextView: UITextView!
    @IBOutlet weak var addQuestionButton: UIButton!
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefaultScrollView()
        setTextFieldDelegate()
        setButtonUI()
        setTextFieldPlaceholderAndImageHolder()
        setNavigation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setTextFieldDelegate() {
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

    func setTextFieldPlaceholderAndImageHolder() {
        setDefaultProperty()
        DispatchQueue.main.async {
            self.setScrollView(numberOfPhotos: 1)
        }
        setImageProperty()
        guard let passedValue = passedValue as? Article else {
        return
        }
        titleTextField.text = passedValue.title
        addressTextField.text = passedValue.address
        reasonTextView.text = passedValue.reason
        reasonTextView.textColor = UIColor.black
        //編輯圖片 初始
        icount = 0
        imageArray = []
        DispatchQueue.main.async {
            self.setScrollView(numberOfPhotos: passedValue.imageUrl.count)
        }
        for imageSubView in self.myScrollView.subviews {

            imageSubView.removeFromSuperview()
        }
        for asset in passedValue.imageUrl {
            let image = UIImageView()
            image.tag = self.icount
            image.contentMode = UIViewContentMode.scaleAspectFill
            image.layer.masksToBounds = true
            image.sd_setImage(with: URL(string: asset), placeholderImage: UIImage(named: "adjust_picture"))
            guard let appendImage = image.image else {
                return
            }
            imageArray.append(appendImage)
            image.frame = CGRect(x: 0, y: 0, width: self.fullSize.width, height: self.myScrollView.frame.height)
            image.center = CGPoint(x: self.fullSize.width * (0.5 + CGFloat(self.icount)), y: self.myScrollView.frame.height / 2 )
            self.myScrollView.addSubview(image)
            image.isUserInteractionEnabled = true
            let touch = UITapGestureRecognizer(target: self, action: #selector(self.bottomAlert))
            image.addGestureRecognizer(touch)
            icount += 1

        }

        addQuestionButton.setTitle("編輯", for: .normal)

    }

    func setDefaultProperty() {
        titleTextField.placeholder = "標題"
        addressTextField.placeholder = "地址"
        titleTextField.layer.borderColor = UIColor.red.cgColor
        addressTextField.layer.borderColor = UIColor.red.cgColor

        reasonTextView.text = "內容"
        reasonTextView.textColor = UIColor(displayP3Red: 199 / 255, green: 199 / 255, blue: 205 / 255, alpha: 1)
        reasonTextView.layer.cornerRadius = 5
        reasonTextView.layer.masksToBounds = true
        reasonTextView.layer.borderWidth = 1
        reasonTextView.layer.borderColor = UIColor.lightGray.cgColor
    }

    func setImageProperty() {
        let image = UIImageView()
        image.contentMode = UIViewContentMode.scaleAspectFill
        image.layer.masksToBounds = true
        image.image = UIImage(named: "adjust_picture")

        image.frame = CGRect(x: 0, y: 0, width: self.fullSize.width, height: self.myScrollView.frame.height)
        image.center = CGPoint(x: self.fullSize.width * (0.5 + CGFloat(self.icount)), y: self.myScrollView.frame.height / 2 )
        self.myScrollView.addSubview(image)
        image.isUserInteractionEnabled = true
        let touch = UITapGestureRecognizer(target: self, action: #selector(self.buttonAction(_:)))
        image.addGestureRecognizer(touch)

    }

    func setArticleObject() {
        guard let title = titleTextField.text, let reason = reasonTextView.text, let address = addressTextField.text else {
            return
        }
        guard title.trimmingCharacters(in: .whitespaces) != "" &&  address.trimmingCharacters(in: .whitespaces) != "" && reason.trimmingCharacters(in: .whitespaces) != "" else {
            alertAction(title: "輸入錯誤", message: "欄位不得為空白！")
            return
        }
        guard imageArray.count > 0 else {
            alertAction(title: "輸入錯誤", message: "至少放入一張照片！")
            return
        }
        if let passedValue = passedValue as? Article {
            articleObject = passedValue
            articleObject?.address = address
            articleObject?.title = title
            articleObject?.reason = reason
            articleObject?.createdTime = Int(NSDate().timeIntervalSince1970)
        } else {
        articleObject = Article(uid: "", userName: "", imageUrl: [""], address: address, reason: reason, title: title, createdTime: Int(NSDate().timeIntervalSince1970), articleKey: "", imageName: [""])
        }
    }

    func setNavigation() {
        navigationItem.rightBarButtonItem?.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Medium", size: 20)!]
        guard (passedValue as? Article) != nil else {
            navigationItem.title = "發問"
            return
        }
        navigationItem.title = "編輯"
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
            PHPhotoLibrary.requestAuthorization({ newStatus in
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

    @objc func bottomAlert(recognizer: UITapGestureRecognizer) {
            myTag = recognizer.view!.tag

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

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let alertController = UIAlertController(title: "儲存發生錯誤", message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "確定", style: .default))
            present(alertController, animated: true)
        }
    }

    @IBAction func addQuestionAction(_ sender: UIButton) {
        setArticleObject()
        guard let articleObject = articleObject else {
            return
        }
        guard  Auth.auth().currentUser != nil else {
            self.alertAction(title: "您尚未登入", message: "請先登入再進行此操作")

            return
        }
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.setDefaultStyle(.light)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.show(withStatus: "上傳中")
        if articleObject.articleKey != "" {
            FirebaseManager.shared.editArticle(uploadimage: imageArray, article: articleObject, handler: {
                SVProgressHUD.dismiss()
                self.navigationController?.popViewController(animated: true)
            })
        } else {
        FirebaseManager.shared.addArticleQuestion(uploadimage: imageArray, uploadArticle: articleObject, handler: {
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
        if textView.text.count < 1 || textView.text == "" {
            textView.text = "內容"
            textView.textColor = UIColor(displayP3Red: 175 / 255, green: 174 / 255, blue: 174 / 255, alpha: 1)
        }
    }

    func setScrollView(numberOfPhotos: Int) {

        // 實際視圖範圍
        myScrollView.contentSize = CGSize(
            width: fullSize.width * CGFloat(numberOfPhotos), height: fullSize.height / 5)
    }

    func setDefaultScrollView() {
        //設置尺寸 也就是可見視圖範圍
        myScrollView.frame = CGRect(
            x: 0, y: 0,
            width: fullSize.width, height: myScrollView.frame.height)

        // 是否顯示滑動條
        myScrollView.showsHorizontalScrollIndicator = false
        myScrollView.showsVerticalScrollIndicator = false

        // 滑動超過範圍時是否使用彈回效果
        myScrollView.alwaysBounceVertical = false
        myScrollView.alwaysBounceHorizontal = true

        // 設置委任對象
        myScrollView.delegate = self

        // 以一頁為單位滑動
        myScrollView.isPagingEnabled = true
    }

    // 點擊點點換頁
    @objc func pageChanged(sender: UIPageControl) {
        // 依照目前圓點在的頁數算出位置
        var frame = self.myScrollView.frame
        frame.origin.x = frame.size.width * CGFloat(sender.currentPage)
        frame.origin.y = 0

        // 再將 UIScrollView 滑動到該點
        myScrollView.scrollRectToVisible(frame, animated: true)
    }

    func multiPhoto() {

        let alert = UIAlertController(style: .actionSheet)
        alert.addPhotoLibraryPicker(flow: .vertical, paging: false, selection: .multiple(action: { assets in
                                        self.icount = 0
                                        DispatchQueue.main.async {
                                            self.setScrollView(numberOfPhotos: assets.count)
                                        }
                                        //remove subview
            for imageSubView in self.myScrollView.subviews {
                imageSubView.removeFromSuperview()
                                        }
        self.imageArray = []
        for asset in assets {
            let image = UIImageView()
            image.tag = self.icount
            image.contentMode = UIViewContentMode.scaleAspectFill
            image.layer.masksToBounds = true
            image.image = self.getAssetThumbnail(asset: asset)
            self.imageArray.append(self.getAssetThumbnail(asset: asset))
            image.frame = CGRect(x: 0, y: 0, width: self.fullSize.width, height: self.myScrollView.frame.height)
            image.center = CGPoint(x: self.fullSize.width * (0.5 + CGFloat(self.icount)), y: self.myScrollView.frame.height / 2 )
            self.myScrollView.addSubview(image)
            image.isUserInteractionEnabled = true
            let touch = UITapGestureRecognizer(target: self, action: #selector(self.bottomAlert))
            image.addGestureRecognizer(touch)
            self.icount += 1
            }

        }))
        alert.addAction(title: "取消", style: .cancel)
        alert.show()
    }

    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: fullSize.width, height: myScrollView.frame.height), contentMode: .aspectFill, options: option, resultHandler: {(result, _) -> Void in
            thumbnail = result!
        })
        return thumbnail
    }

    @IBAction func buttonAction(_ sender: Any) {
        multiPhoto()
    }

}

extension UITextField {
    open override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.masksToBounds = true
    }
}

extension AddQuestionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        if picker.sourceType == .camera {
            UIImageWriteToSavedPhotosAlbum(image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        for subview in myScrollView.subviews {
            if  let subview = subview as? UIImageView, subview.tag == myTag, let image = image {
                subview.image = image
                imageArray[myTag] = image
            }
        }
        dismiss(animated: true, completion: nil)
    }
}

extension AddQuestionViewController: UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate {
    //UIScrollViewDelegate方法，每次滚动结束后调用
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 左右滑動到新頁時 更新 UIPageControl 顯示的頁數
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = page
    }
}
