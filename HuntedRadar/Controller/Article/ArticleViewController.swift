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
class ArticleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DismissView, SwipeTableViewCellDelegate {
    
    

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
        cell.imageUrlView.sd_setImage(with: URL(string: articles[indexPath.row].imageUrl), placeholderImage: nil)
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
        
        return [action]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
       
        return true
    }

    func setNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "plus"), style: .done, target: self, action: #selector(addQuestion))
        navigationItem.rightBarButtonItem?.tintColor = .white
    }

    func multiAction(at indexPath: IndexPath) -> SwipeAction {
        
        let userdefault = UserDefaults.standard
        let userName = userdefault.string(forKey: "userName")
        if articles[indexPath.row].userName == userName {
            //users can delete their message
            let action = SwipeAction(style: .default, title: "刪除", handler: { (_, indexpath) in
                guard  Auth.auth().currentUser != nil else {
                    self.alertAction(title: "您尚未登入", message: "請先登入再進行此操作")
                    return
                }
                let articleKey = self.articles[indexpath.row].articleKey
                // ToDo
//                FirebaseManager.shared.deleteComment(articleKey: self.passedKey, commentKey: commentKey)
                
                self.articles.remove(at: indexPath.row)
                self.myTableView.deleteRows(at: [indexPath], with: .fade)
            })
            
            action.backgroundColor = UIColor.red
            
            action.image = UIImage(named: "delete-button")
            
            return action
            
        }
        else {
            //users can forbid other accounts' activities
            let action = SwipeAction(style: .default, title: "封鎖", handler: { (_, indexpath) in
                guard  Auth.auth().currentUser != nil else {
                    self.alertAction(title: "您尚未登入", message: "請先登入再進行此操作")
                    return
                }
                let articleUser = self.articles[indexpath.row].userName
                FirebaseManager.shared.forbid(userName: articleUser)
                FirebaseManager.shared.loadForbidUsers { _ in
                    FirebaseManager.shared.loadArticle(completion:{ articles in
                        self.articles = articles
                        self.myTableView.reloadData()
                    })
                }
                
            })
            
            action.backgroundColor = UIColor.orange
            
            action.image = UIImage(named: "forbid")
            
            return action
        }
    }
    
    func alertAction(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: { _ in
            self.performSegue(withIdentifier: "login", sender: self)
            
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
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
