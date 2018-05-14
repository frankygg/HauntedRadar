//
//  LoginViewController.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/14.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    var isSignIn: Bool = true
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var signinLabel: UILabel!
    @IBOutlet weak var signinSelector: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func signInSelectorChanged(_ sender: UISegmentedControl) {
        isSignIn = !isSignIn
        if isSignIn {
            signinLabel.text = "Sign In"
            signInButton.setTitle("Sign In", for: .normal)
        } else {
            signinLabel.text = "Register"
            signInButton.setTitle("Register", for: .normal)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func signInButtonTapped(_ sender: UIButton) {
        
        // TODO: some validation on email and password
        if let email = emailTextField.text, let password = passwordTextField.text {
            
            //check if it's sign in or register
            if isSignIn {
                //Sign in the userwith Firebase
                Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                    // ...
                    if error == nil && user != nil {
                        self.performSegue(withIdentifier: "addQuestion", sender: self)
                    }else {
                        
                    }
                }
            } else {
                //Register the user with Firebase
                Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                    // ...
                    if error == nil && user != nil {
                        self.performSegue(withIdentifier: "addQuestion", sender: self)
                    }else {
                        
                    }
                }
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }

}
