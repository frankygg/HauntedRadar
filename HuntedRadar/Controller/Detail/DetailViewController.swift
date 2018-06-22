//
//  DetailViewController.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/21.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit
import FirebaseAuth
import SDWebImage
import SwipeCellKit
var imagePhotoUrls = [String]()
class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {

    //local variable
    var passedValue: Any?
    var passedKey: String!
    var fullSize: CGSize!
    var comment = [Comment]()
    var article: Article!
    var isScrollToBottomAfterComment = false
    let button = UIButton(type: .custom)

    //IBOutlet variable
    @IBOutlet weak var commetTextField: UITextField!
    @IBOutlet weak var detailTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationItem()
        fullSize = UIScreen.main.bounds.size
        setNib()
        setDetailData()
        setTextFieldButton()
        loadCommentFromFirebase()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCommentFromFirebase()
        detailTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)

    }
    func loadCommentFromFirebase() {
        FirebaseManager.shared.loadComment(articleId: passedKey, completion: {[weak self] comments in
            self?.comment = comments
                self?.detailTableView.reloadData()
            guard let flag = self?.isScrollToBottomAfterComment else {
                return
            }
            if flag {
                self?.detailTableView.scrollToRow(at: IndexPath(row: (self?.comment.count)!, section: 0), at: .bottom, animated: true)
                self?.isScrollToBottomAfterComment = false
            }
        })
    }

    func setTextFieldButton() {
        
        button.setImage(UIImage(named: "paper_plane")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.lightGray
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        button.frame = CGRect(x: CGFloat(fullSize.width - 16 - 30), y: CGFloat(10), width: CGFloat(30), height: CGFloat(30))
        button.addTarget(self, action: #selector(self.sendComment), for: .touchUpInside)
        button.isEnabled = false
        commetTextField.rightView = button
        commetTextField.rightViewMode = .always
        commetTextField.placeholder = "留言"
        commetTextField.delegate = self
        let accountLeftView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        commetTextField.leftViewMode = .always
        commetTextField.leftView = accountLeftView
        commetTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ sender: UITextField) {
        if sender.text?.trimmingCharacters(in: .whitespaces) == "" {
            button.isEnabled = false
        } else {
            button.isEnabled = true
        }
    }

    @objc func sendComment() {
        guard  Auth.auth().currentUser != nil else {
            alertAction(title: "您尚未登入", message: "請先登入再進行此操作") {[weak self] in
                self?.performSegue(withIdentifier: "login", sender: self)
            }
            return
        }
        guard let text = commetTextField.text else {
            return
        }
        FirebaseManager.shared.addComment(comment: text, articleId: passedKey)
        self.view.endEditing(true)
        commetTextField.text = ""
        isScrollToBottomAfterComment = true
        button.isEnabled = false
    }
    

    func setNavigationItem() {
        navigationItem.title = "深入瞭解"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Medium", size: 20)!]
    }
    func setNib() {
        //xib的名稱
        let nib = UINib(nibName: String(describing: ImageTableViewCell.self), bundle: nil)
        //註冊
        detailTableView.register(nib, forCellReuseIdentifier: String(describing: ImageTableViewCell.self))

        let nib2 = UINib(nibName: String(describing: CommentTableViewCell.self), bundle: nil)
        detailTableView.register(nib2, forCellReuseIdentifier: String(describing: CommentTableViewCell.self))

        detailTableView.dataSource = self
        detailTableView.delegate = self
        detailTableView.allowsSelection = false
    }

    func setDetailData() {
        guard let article = passedValue as? Article else {
            return
        }
        self.article = article
        imagePhotoUrls = article.imageUrl
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
                return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + comment.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 && indexPath.section == 0 {
            guard let cell = self.detailTableView.dequeueReusableCell(withIdentifier: String(describing: ImageTableViewCell.self), for: indexPath) as? ImageTableViewCell else {
                return UITableViewCell()
            }

            cell.addressLabel.text = "地址： \(article.address)"

            cell.titleLabel.text = article.title

            cell.reasonLabel.text = "內容： \(article.reason)"

            //處理時間
            let date = Date(timeIntervalSince1970: TimeInterval(article.createdTime))

            let now = Date()

            let timeOffset = now.offset(from: date)

            cell.createdTimeLabel.text = timeOffset

            cell.userNameLabel.text = article.userName

            cell.separatorInset = .zero

            return cell

    } else {
            guard let cell = self.detailTableView.dequeueReusableCell(withIdentifier: String(describing: CommentTableViewCell.self), for: indexPath) as? CommentTableViewCell else {
                 return UITableViewCell()
            }

            let cellIndex = indexPath.row - 1

            cell.delegate = self
            cell.commentLabel.text = comment[cellIndex].comment

            cell.userNameLabel.text = comment[cellIndex].userName

            //處理時間
            let date = Date(timeIntervalSince1970: TimeInterval(comment[cellIndex].createdTime))

            let now = Date()

            let timeOffset = now.offset(from: date)

            cell.createdTimeLabel.text = timeOffset

            //無下邊界
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)

            return cell
    }
}

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        if indexPath.row != 0 && indexPath.section != 0 {
//            return true
//        } else {
//            return false
//        }
        return true
    }

    func multiAction(at indexPath: IndexPath) -> SwipeAction {

        let userdefault = UserDefaults.standard
        let userName = userdefault.string(forKey: "userName")
        if comment[indexPath.row - 1].userName == userName {
            //users can delete their message
            let action = SwipeAction(style: .default, title: "刪除", handler: { (_, indexpath) in
                guard  Auth.auth().currentUser != nil else {
                    self.alertAction(title: "您尚未登入", message: "請先登入再進行此操作") { [weak self] in
                        self?.performSegue(withIdentifier: "login", sender: self)

                    }
                    return
                }
                self.alertAction(title: "", message: "您確定要刪除嗎？", completion: { [weak self] in
                    let commentKey = self?.comment[indexpath.row - 1].commentKey
                    FirebaseManager.shared.deleteComment(articleKey: (self?.passedKey)!, commentKey: commentKey!)
                    //
                    self?.comment.remove(at: indexPath.row - 1)
                    self?.detailTableView.deleteRows(at: [indexPath], with: .fade)
                    self?.detailTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                })
            })

            action.backgroundColor = UIColor.red

            action.image = UIImage(named: "delete-button")

            return action

        } else {
            //users can forbid other accounts' activities
            let action = SwipeAction(style: .default, title: "封鎖用戶", handler: { (_, indexpath) in
                guard  Auth.auth().currentUser != nil else {
                    self.alertAction(title: "您尚未登入", message: "請先登入再進行此操作") {[weak self] in
                        self?.performSegue(withIdentifier: "login", sender: self)

                    }
                    return
                }
                let commentUser = self.comment[indexpath.row - 1].userName
                FirebaseManager.shared.forbid(userName: commentUser)
                FirebaseManager.shared.loadForbidUsers { _ in
                    FirebaseManager.shared.loadComment(articleId: self.passedKey, completion: { comments in
                        self.comment = comments
                        self.detailTableView.reloadData()
                    })
                }

            })

            action.backgroundColor = UIColor.orange

            action.image = UIImage(named: "forbid")

            return action
        }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {

        guard orientation == .right else { return nil }

        let action = multiAction(at: indexPath)

        return [action]
    }

    func alertAction(title: String, message: String, completion: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default, handler: { _ in
            completion()
        })
        let cancelAction = UIAlertAction(title: "取消", style: .default, handler: { _ in

        })
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

extension DetailViewController: UITextFieldDelegate {
    
}
