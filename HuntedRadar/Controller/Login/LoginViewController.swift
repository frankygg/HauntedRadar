//
//  LoginViewController.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/14.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController, UITextFieldDelegate {
    //local var
    weak var delegate: DismissView?
    var isSignIn: Bool = true
    var isFromAppFlag: Bool = false

    //IBOutlet var
    @IBOutlet weak var visitButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var confirmPasswordStackView: UIStackView!
    @IBOutlet weak var userNameStackView: UIStackView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var signinLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameStackView.isHidden = true
        confirmPasswordStackView.isHidden = true
        dismissButton.setImage(dismissButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        setSignInAndVisitButton()
        setTextFieldDelegateAndStyle()
    }

    @IBAction func signInSelectorChanged(_ sender: UIButton) {
        isSignIn = !isSignIn
        if isSignIn {
            sender.setTitle("註冊", for: .normal)
            signinLabel.text = "沒有帳號嗎？"
            signInButton.setTitle("登入", for: .normal)
            userNameStackView.isHidden = true
            confirmPasswordStackView.isHidden = true
        } else {
            sender.setTitle("登入", for: .normal)
            signinLabel.text = "已有帳號嗎？"
            signInButton.setTitle("註冊", for: .normal)
            userNameStackView.isHidden = false
            confirmPasswordStackView.isHidden = false
        }
    }

    @IBAction func signInButtonTapped(_ sender: UIButton) {
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.show(withStatus: "登入中")
        //some validation on email and password
        if let email = emailTextField.text, let password = passwordTextField.text {

            //check if it's sign in or register
            if isSignIn {
                guard email.trimmingCharacters(in: .whitespaces) != "" && password.trimmingCharacters(in: .whitespaces) != ""  else {
                    SVProgressHUD.dismiss()
                    popUpAlert(title: "登入失敗", message: "有欄位空白", shouldHaveCancelButton: false, confirmCompletion: nil)
                    return
                }
                //Sign in the userwith Firebase
                Auth.auth().signIn(withEmail: email, password: password, completion: loginCompletionCallback)
            } else {
                if let confirm = confirmTextField.text, let username = userNameTextField.text, username.trimmingCharacters(in: .whitespaces) != "" {
                    if confirm != password {
                        SVProgressHUD.dismiss()
                        popUpAlert(title: "註冊失敗", message: "確認密碼不一致", shouldHaveCancelButton: false, confirmCompletion: nil)
                    } else {
                   let ref = Database.database().reference()
                    ref.child("users").queryOrdered(byChild: "username").queryEqual(toValue: "\(username)")
                        .observeSingleEvent(of: .value, with: { [weak self] snapshot in
                            if snapshot.value is NSNull {
                                print("not found)")
                                //Register the user with Firebase
                                Auth.auth().createUser(withEmail: email, password: password, completion: self?.registerCompletionCallback)

                            } else {
                                SVProgressHUD.dismiss()
                                    self?.popUpAlert(title: "註冊失敗", message: "暱稱已被使用！", shouldHaveCancelButton: false, confirmCompletion: nil)
                            }
                        })
                    }} else {
                    SVProgressHUD.dismiss()

                    popUpAlert(title: "註冊失敗", message: "有欄位空白", shouldHaveCancelButton: false, confirmCompletion: nil)

                }
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }

    func setTextFieldDelegateAndStyle() {
        passwordTextField.delegate = self
     emailTextField.delegate = self
        userNameTextField.delegate = self
        confirmTextField.delegate = self
    }

    func loginCompletionCallback(user: User?, error: Error?) {
        if error == nil {
            self.delegate?.dismissView(true)
            setUserDefaultUserName()
        } else {
            SVProgressHUD.dismiss()

            guard let error = error, let errorCode = AuthErrorCode(rawValue: error._code)
            else {
                return
            }

            popUpAlert(title: "登入失敗", message: errorCode.errorMessage, shouldHaveCancelButton: false, confirmCompletion: nil)
        }
    }

    func registerCompletionCallback(user: User?, error: Error?) {
        if error == nil {
            let ref = Database.database().reference()
            ref.child("users").child(user!.uid).child("email").setValue(user!.email)
            ref.child("users").child(user!.uid).child("username").setValue(userNameTextField.text!)
            self.delegate?.dismissView(true)
            setUserDefaultUserName()
        } else {
            SVProgressHUD.dismiss()

            guard let error = error, let errorCode = AuthErrorCode(rawValue: error._code)
                else {
                return
            }
            print("\(error._code)  \(error.localizedDescription)")
            popUpAlert(title: "註冊失敗", message: errorCode.errorMessage, shouldHaveCancelButton: false, confirmCompletion: nil)
        }
    }

    @IBAction func dismissAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func visitAction(_ sender: Any) {
        if self.isFromAppFlag {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }

            let tabBarController = UIStoryboard.customTabBarStoryboard().instantiateInitialViewController()!

            appDelegate.window?.rootViewController = tabBarController
        } else {
        dismiss(animated: true, completion: nil)
        }
    }

    func setUserDefaultUserName() {
        FirebaseManager.shared.getUserName(completion: {name in
            let userdefault = UserDefaults.standard
            userdefault.set(name, forKey: "userName")
        })
        FirebaseManager.shared.loadForbidUsers(completion: {_ in
            SVProgressHUD.dismiss()
            if self.isFromAppFlag {
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    return
                }

                let tabBarController = UIStoryboard.customTabBarStoryboard().instantiateInitialViewController()!

                appDelegate.window?.rootViewController = tabBarController
            } else {
            self.dismiss(animated: true, completion: nil)
            }
        })
    }

    func setSignInAndVisitButton() {
        signInButton.layer.cornerRadius = 5
        signInButton.clipsToBounds = true

        visitButton.layer.cornerRadius = 5
        visitButton.clipsToBounds = true

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

protocol DismissView: class {
    func dismissView(_ bool: Bool)
}
