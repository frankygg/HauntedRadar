//
//  ArticleViewController.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/14.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit
import FirebaseCore
import Firebase
import FirebaseAuth

class ArticleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var ref: DatabaseReference?
    @IBOutlet weak var myTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //xib的名稱
        let nib = UINib(nibName: "ArticleTableViewCell", bundle: nil)
        //註冊，forCellReuseIdentifier是你的TableView裡面設定的Cell名稱
        myTableView.register(nib, forCellReuseIdentifier: "ArticleTableViewCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        ref = Database.database().reference()
//        ref?.child("Articles").childByAutoId().setValue("test")
        
        setNavigationItem()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard  let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleTableViewCell") as? ArticleTableViewCell else {
            return UITableViewCell()
        }
        return cell
    }
    
    func setNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "plus"), style: .done, target: self, action: #selector(addQuestion))
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    @objc func addQuestion(_ sender: UIButton) {
        
        let showLoginScreen = Auth.auth().currentUser == nil
        if showLoginScreen {
            performSegue(withIdentifier: "login", sender: self)
        } else {
            performSegue(withIdentifier: "addQuestion", sender: self)
        }
    
    }
   
}
