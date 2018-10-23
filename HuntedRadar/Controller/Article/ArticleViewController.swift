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
import SwipeCellKit
import SVProgressHUD
class ArticleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DismissView, SwipeTableViewCellDelegate {

    //local variables
    var articles = [Article]()
    var passArticle: Article!
    var editArticle: Article!

    //IBOutlet variables
    @IBOutlet weak var myTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setTableView()

        setNavigationItem()

        loadArticleFromeFirebase()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadArticleFromeFirebase()
    }

    func setTableView() {
        //xib的名稱
        let nib = UINib(nibName: "ArticleTableViewCell", bundle: nil)
        //註冊，forCellReuseIdentifier是你的TableView裡面設定的Cell名稱
        myTableView.register(nib, forCellReuseIdentifier: "ArticleTableViewCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
//        self.automaticallyAdjustsScrollViewInsets = false
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard  let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleTableViewCell") as? ArticleTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.userNameLabel.text = articles[indexPath.row].userName
        cell.imageUrlView.sd_setImage(with: URL(string: articles[indexPath.row].imageUrl[0]), placeholderImage: UIImage(named: "adjust_picture"))
        cell.titleLabel.text = articles[indexPath.row].title
        //處理時間
        let date = Date(timeIntervalSince1970: TimeInterval(articles[indexPath.row].createdTime))

        let now = Date()

        let timeOffset = now.offset(from: date)

        cell.createdTimeLabel.text = timeOffset

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        passArticle = articles[indexPath.row]
        performSegue(withIdentifier: "articleDetail", sender: self)

    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let action = multiAction(at: indexPath)

        return action
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        return true
    }

    func setNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "plus"), style: .done, target: self, action: #selector(addQuestion))
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationController?.navigationBar.topItem?.title = "論壇"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Medium", size: 20)!]
    }

    func multiAction(at indexPath: IndexPath) -> [SwipeAction] {

        let userdefault = UserDefaults.standard
        let userName = userdefault.string(forKey: "userName")
        if articles[indexPath.row].userName == userName {
            //users can delete their message
            let action = SwipeAction(style: .default, title: "刪除", handler: { (_, indexpath) in
                guard  Auth.auth().currentUser != nil else {
                    self.popUpAlert(title: "您尚未登入", message: "請先登入再進行此操作", shouldHaveCancelButton: true) {[weak self] in
                        self?.performSegue(withIdentifier: "loginWithOutAddQuestion", sender: self)

                    }
                    return
                }
                self.popUpAlert(title: "", message: "您確定要刪除嗎？", shouldHaveCancelButton: true) { [weak self] in
                    //delete realtime database & storage image file
                    FirebaseManager.shared.deleteArticle(article: (self?.articles[indexpath.row])!)
                    self?.articles.remove(at: indexPath.row)
                    self?.myTableView.deleteRows(at: [indexPath], with: .fade)

                    }
            })

            action.backgroundColor = UIColor.red

            action.image = UIImage(named: "delete-button")

            let edit = editAction(at: indexPath)

            return [edit, action]

        } else {
            //users can forbid other accounts' activities
            let action = SwipeAction(style: .default, title: "封鎖用戶", handler: { (_, indexpath) in
                guard  Auth.auth().currentUser != nil else {
                    self.popUpAlert(title: "您尚未登入", message: "請先登入再進行此操作", shouldHaveCancelButton: true) {[weak self] in
                        self?.performSegue(withIdentifier: "loginWithOutAddQuestion", sender: self)
                    }
                    return
                }
                let articleUser = self.articles[indexpath.row].userName
                FirebaseManager.shared.forbid(userName: articleUser)
                FirebaseManager.shared.loadForbidUsers { _ in
                    FirebaseManager.shared.loadArticle(completion: { article in
                        self.articles = article
                        self.myTableView.reloadData()
                    })             }
            })

            action.backgroundColor = UIColor.orange

            action.image = UIImage(named: "forbid")

            return [action]
        }
    }

    func editAction(at indexPath: IndexPath) -> SwipeAction {
        let action = SwipeAction(style: .default, title: "編輯", handler: { (_, indexpath) in
            guard  Auth.auth().currentUser != nil else {
                self.popUpAlert(title: "您尚未登入", message: "請先登入再進行此操作", shouldHaveCancelButton: true) { [weak self]
in                    self?.performSegue(withIdentifier: "loginWithOutAddQuestion", sender: self)

                }
                return
            }
            self.editArticle = self.articles[indexpath.row]
            self.performSegue(withIdentifier: "editQuestion", sender: self)
        })

        action.backgroundColor = UIColor(red: 255/255, green: 229/255, blue: 59/255, alpha: 1)

        action.image = UIImage(named: "edit")

        return action
    }

    @objc func addQuestion(_ sender: UIButton) {

        let showLoginScreen = Auth.auth().currentUser == nil
        if showLoginScreen {
            performSegue(withIdentifier: "login", sender: self)
        } else {
            performSegue(withIdentifier: "addQuestion", sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? LoginViewController {
            if segue.identifier == "login" {
            controller.delegate = self
            }
        } else if let controller = segue.destination as? DetailViewController {
            controller.passedValue = passArticle
            controller.passedKey = passArticle.articleKey
        } else if let controller = segue.destination as? AddQuestionViewController {
            if segue.identifier == "editQuestion" {
                controller.passedValue = editArticle
            }
        }
    }

    func dismissView(_ bool: Bool) {
        if bool {
            performSegue(withIdentifier: "addQuestion", sender: self)

        }
    }

    func loadArticleFromeFirebase() {
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.setDefaultStyle(.light)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        SVProgressHUD.show(withStatus: "載入中")
        FirebaseManager.shared.loadArticle(completion: {articles in
            self.articles = articles
            self.myTableView.reloadData()
            SVProgressHUD.dismiss()
        })
    }

}
