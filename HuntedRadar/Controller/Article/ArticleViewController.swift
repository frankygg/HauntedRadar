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
import SDWebImage

class ArticleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DismissView {

    //local variables
    var articles = [Article]()
    var passArticle: Article!
    var ref: DatabaseReference?

    //IBOutlet variables
    @IBOutlet weak var myTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        //xib的名稱
        let nib = UINib(nibName: "ArticleTableViewCell", bundle: nil)
        //註冊，forCellReuseIdentifier是你的TableView裡面設定的Cell名稱
        myTableView.register(nib, forCellReuseIdentifier: "ArticleTableViewCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        ref = Database.database().reference()
//        ref?.child("Articles").childByAutoId().setValue("test")

        setNavigationItem()

            loadArticleFromeFirebase()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadArticleFromeFirebase()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard  let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleTableViewCell") as? ArticleTableViewCell else {
            return UITableViewCell()
        }
        cell.userNameLabel.text = articles[indexPath.row].userName
        cell.imageUrlView.sd_setImage(with: URL(string: articles[indexPath.row].imageUrl), placeholderImage: nil)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        passArticle = articles[indexPath.row]
        performSegue(withIdentifier: "articleDetail", sender: self)

    }

    func setNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "plus"), style: .done, target: self, action: #selector(addQuestion))
        navigationItem.rightBarButtonItem?.tintColor = .white
    }

    @objc func addQuestion(_ sender: UIButton) {

        let showLoginScreen = Auth.auth().currentUser == nil
        if showLoginScreen {
            performSegue(withIdentifier: "login", sender: self)
//            let controller =
        } else {
            performSegue(withIdentifier: "addQuestion", sender: self)
        }

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? LoginViewController {
            controller.delegate = self
        } else if let controller = segue.destination as? DetailViewController {
            controller.passedValue = passArticle
            controller.passedKey = passArticle.articleKey
        }
    }

    func dismissView(_ bool: Bool) {
        if bool {
            performSegue(withIdentifier: "addQuestion", sender: self)

        }
    }

    func loadArticleFromeFirebase() {
        FirebaseManager.shared.loadArticle(completion: {articles in
            self.articles = articles
            self.articles.sort(by: {$0.createdTime > $1.createdTime})
            self.myTableView.reloadData()

        })

    }

}
