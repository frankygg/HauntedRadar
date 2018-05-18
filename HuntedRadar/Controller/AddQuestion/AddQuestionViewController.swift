//
//  AddQuestionViewController.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/14.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit
import FirebaseAuth
class AddQuestionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var artileObject: Article?
    @IBOutlet weak var memoTextField: UITextField!
    @IBOutlet weak var reasonTextView: UITextView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigation()
        setArticleObject()
        imageView.isUserInteractionEnabled = true
        let touch = UITapGestureRecognizer(target: self, action: #selector(bottomAlert))
        imageView.addGestureRecognizer(touch)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setArticleObject() {
        guard let address = addressTextField.text, let reason = reasonTextView.text, let memo = memoTextField.text else {
            return
        }
        artileObject = Article(uid: "", userName: "", imageUrl: "", address: address, reason: reason, memo: memo)
    }

    func setNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "exit"), style: .done, target: self, action: #selector(logout))
        navigationItem.rightBarButtonItem?.tintColor = .white
    }

    @objc func logout() {
        do {
            try Auth.auth().signOut()
            navigationController?.popViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    @objc func bottomAlert() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let photoAction = UIAlertAction(title: "Photo", style: .default) { _ in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
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
        guard let articleObject = artileObject else {
            return
        }
        FirebaseManager.shared.addArticleQuestion(uploadimage: imageView.image, uploadArticle: articleObject)

    }
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        reasonTextView.resignFirstResponder()
//        addressTextField.resignFirstResponder()
//        memoTextField.resignFirstResponder()
//    }
//    
}
