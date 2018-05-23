//
//  ProfileViewController.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/24.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigation()

    }
    func setNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "exit"), style: .done, target: self, action: #selector(logout))
        navigationItem.rightBarButtonItem?.tintColor = .white
    }

    @objc func logout() {
        do {
            try Auth.auth().signOut()
            let userdefault = UserDefaults.standard
            userdefault.set(nil, forKey: "userName")
            userdefault.set(nil, forKey: "Forbidden")
            navigationController?.popViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}
