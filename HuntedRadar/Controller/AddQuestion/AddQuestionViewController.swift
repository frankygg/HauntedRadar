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
class AddQuestionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    var passedValue: Any?
    var articleObject: Article?
    @IBOutlet weak var addQuestionButton: UIButton!
    @IBOutlet weak var reasonTextField: UITextField!
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
        reasonTextField.delegate = self
        addressTextField.delegate = self
        titleTextField.delegate = self
    }

    func setButtonUI() {
        addQuestionButton.layer.cornerRadius = addQuestionButton.frame.height / 2
        addQuestionButton.clipsToBounds = true
    }
    func setTextFieldPlaceholder() {
        titleTextField.placeholder = "標題"
        reasonTextField.placeholder = "內容"
        addressTextField.placeholder = "地址"
        guard let passedValue = passedValue as? Article else {
        return
        }
        titleTextField.text = passedValue.title
        reasonTextField.text = passedValue.reason
        addressTextField.text = passedValue.address
        imageView.sd_setImage(with: URL(string: passedValue.imageUrl), placeholderImage: nil)
        addQuestionButton.setTitle("編輯", for: .normal)

    }
    func setArticleObject() {
        guard let title = titleTextField.text, let reason = reasonTextField.text, let address = addressTextField.text else {
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

    @objc func bottomAlert() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let photoAction = UIAlertAction(title: "相片", style: .default) { _ in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
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
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "存擋", message: "資料已成功上傳", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }

    @IBAction func addQuestionAction(_ sender: UIButton) {
        setArticleObject()
        guard let articleObject = articleObject else {
            return
        }
        if articleObject.articleKey != "" {
            FirebaseManager.shared.editArticle(uploadimage: imageView.image, article: articleObject, handler: {
                self.navigationController?.popViewController(animated: true)
            })
        } else {
        FirebaseManager.shared.addArticleQuestion(uploadimage: imageView.image, uploadArticle: articleObject, handler: {
            self.navigationController?.popViewController(animated: true)
        })
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
