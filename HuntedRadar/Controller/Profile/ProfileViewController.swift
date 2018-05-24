//
//  ProfileViewController.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/24.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwipeCellKit
class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {

    var forbidUser = [Forbid]()
    var isExpand = true

    @IBOutlet weak var forbidUserTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigation()
        setNib()
        loadForbidUserFromFireBase()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadForbidUserFromFireBase()

    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let button = UIButton(type: .system)
        button.setTitle("已封鎖用戶", for: .normal)

        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .lightGray
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleExpandClose), for: .touchUpInside)
        button.tag = section
        button.layer.borderColor = UIColor.black.cgColor

        button.clipsToBounds = true
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 2
        button.layer.borderColor = UIColor.lightGray.cgColor
        return button

    }

    @objc func handleExpandClose(_ sender: UIButton) {
        let section = sender.tag
        var indexPaths = [IndexPath]()
        for row in 0..<forbidUser.count {
            let indexPath = IndexPath(row: row, section: 0)
            indexPaths.append(indexPath)
        }
        let isExpanded = isExpand
        isExpand = !isExpanded
        if isExpanded {

            forbidUserTableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            forbidUserTableView.insertRows(at: indexPaths, with: .fade)
        }
        //
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isExpand {
        return forbidUser.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.forbidUserTableView.dequeueReusableCell(withIdentifier: String(describing: ForbidTableViewCell.self), for: indexPath) as? ForbidTableViewCell else {
            return UITableViewCell()
        }

        cell.delegate = self

        cell.userNameLabel.text = forbidUser[indexPath.row].userName

        return cell
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {

        guard orientation == .right else { return nil }

        let action = recoverAction(at: indexPath)

        return [action]
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func recoverAction(at indexPath: IndexPath) -> SwipeAction {
        //users can delete their message
        let action = SwipeAction(style: .destructive, title: "解除封鎖", handler: { (_, indexpath) in
            guard  Auth.auth().currentUser != nil else {
                self.alertAction(title: "您尚未登入", message: "請先登入再進行此操作")
                return
            }
            FirebaseManager.shared.deleteForbidUser(forbidUser: self.forbidUser[indexpath.row])

            self.forbidUser.remove(at: indexPath.row)
            self.forbidUserTableView.deleteRows(at: [indexPath], with: .fade)
        })
        action.backgroundColor = UIColor.green

        action.image = UIImage(named: "unlock")

        return action
    }

    func setNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "exit"), style: .done, target: self, action: #selector(logout))
        navigationItem.rightBarButtonItem?.tintColor = .white
    }

    func setNib() {
        //xib的名稱
        let nib = UINib(nibName: String(describing: ForbidTableViewCell.self), bundle: nil)
        //註冊
        forbidUserTableView.register(nib, forCellReuseIdentifier: String(describing: ForbidTableViewCell.self))

        forbidUserTableView.delegate = self

        forbidUserTableView.dataSource = self

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

    func loadForbidUserFromFireBase() {
        FirebaseManager.shared.loadForbidUsers(completion: { forbidUser in

            self.forbidUser = forbidUser
            self.forbidUserTableView.reloadData()

        })
    }

    func alertAction(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: { _ in
            self.performSegue(withIdentifier: "login", sender: self)

        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
