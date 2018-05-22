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

class LoginViewController: UIViewController {
    weak var delegate: DismissView?
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var confirmPasswordStackView: UIStackView!
    @IBOutlet weak var userNameStackView: UIStackView!
    var isSignIn: Bool = true
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var signinLabel: UILabel!
    @IBOutlet weak var signinSelector: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameStackView.isHidden = true
        confirmPasswordStackView.isHidden = true
        dismissButton.setImage(dismissButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        dismissButton.tintColor = UIColor.white

    }

    @IBAction func signInSelectorChanged(_ sender: UISegmentedControl) {
        isSignIn = !isSignIn
        if isSignIn {
            signinLabel.text = "Sign In"
            signInButton.setTitle("Sign In", for: .normal)
            userNameStackView.isHidden = true
            confirmPasswordStackView.isHidden = true
        } else {
            signinLabel.text = "Register"
            signInButton.setTitle("Register", for: .normal)
            userNameStackView.isHidden = false
            confirmPasswordStackView.isHidden = false
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func signInButtonTapped(_ sender: UIButton) {

        //some validation on email and password
        if let email = emailTextField.text, let password = passwordTextField.text {

            //check if it's sign in or register
            if isSignIn {
                //Sign in the userwith Firebase
                Auth.auth().signIn(withEmail: email, password: password, completion: loginCompletionCallback)
            } else {
                if let confirm = confirmTextField.text, let username = userNameTextField.text {
                    if confirm != password {
                        alertAction(title: "Regiter failed", message: "Confirm Password Not Match")
                    } else {
                   let ref = Database.database().reference()
                    ref.child("users").queryOrdered(byChild: "username").queryEqual(toValue: "\(username)")
                        .observe(.value, with: { [weak self] snapshot in
                            if snapshot.value is NSNull {
                                print("not found)")
                                //Register the user with Firebase
                                Auth.auth().createUser(withEmail: email, password: password, completion: self?.registerCompletionCallback)

                            } else {
                                    self?.alertAction(title: "Regiter failed", message: "The UserName has been used")
                            }
                        })
                    }} else {

                }
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }

    func loginCompletionCallback(user: User?, error: Error?) {
        if error == nil {
//            self.performSegue(withIdentifier: "loginToAddQuestion", sender: self)
            self.delegate?.dismissView(true)
            setUserDefaultUserName()
            dismiss(animated: true, completion: nil)
        } else {
            guard let error = error else {
                return
            }
            alertAction(title: "Login failed", message: error.localizedDescription)
        }
    }

    func registerCompletionCallback(user: User?, error: Error?) {
        if error == nil {
            let ref = Database.database().reference()
            ref.child("users").child(user!.uid).child("email").setValue(user!.email)
            ref.child("users").child(user!.uid).child("username").setValue(userNameTextField.text!)
            self.delegate?.dismissView(true)
            setUserDefaultUserName()
            dismiss(animated: true, completion: nil)
        } else {
            guard let error = error else {
                return
            }
            alertAction(title: "Register failed", message: error.localizedDescription)
        }
    }

    @IBAction func dismissAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    func alertAction(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func setUserDefaultUserName() {
        FirebaseManager.shared.getUserName(completion: {name in
            let userdefault = UserDefaults.standard
            userdefault.set(name, forKey: "userName")
        })
        FirebaseManager.shared.loadForbidUsers(completion: {_ in })
    }
}

protocol DismissView: class {
    func dismissView(_ bool: Bool)
}
