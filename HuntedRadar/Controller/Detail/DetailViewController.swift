//
//  DetailViewController.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/21.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit
import FirebaseAuth
class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    
    //local variable
    var passedValue: Any?
    var passedKey: String!
    var fullSize: CGSize!
    var comment = [Comment]()
    
    
    //IBOutlet variable
    @IBOutlet weak var commetTextField: UITextField!
    @IBOutlet weak var detailTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        fullSize = UIScreen.main.bounds.size
        setNib()
        setDetailData()
        setTextFieldButton()
        loadCommentFromFirebase()
        

    }
    func loadCommentFromFirebase() {
        FirebaseManager.shared.loadComment(articleId: passedKey, completion: {comments in
            self.comment = comments
            self.comment.sort(by:  { $0.createdTime < $1.createdTime})
            self.detailTableView.reloadData()
            
        })
    }
    
    func setTextFieldButton() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "plus"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsetsMake(0, -16, 0, 0)
        button.frame = CGRect(x: CGFloat(fullSize.width - 16 - 30), y: CGFloat(10), width: CGFloat(30), height: CGFloat(30))
        button.addTarget(self, action: #selector(self.sendComment), for: .touchUpInside)
        commetTextField.rightView = button
        commetTextField.rightViewMode = .always
//        textField.rightView = btnColor
//        textField.rightViewMode = .unlessEditing
    }
    
    @objc func sendComment() {
//        let showLoginScreen = Auth.auth().currentUser == nil
        guard  Auth.auth().currentUser != nil else {
            alertAction(title: "您尚未登入", message: "請先登入再進行此操作")
            return
        }
        guard let text = commetTextField.text else {
            return
        }
        FirebaseManager.shared.addComment(comment: text, articleId: passedKey)
        self.view.endEditing(true)
        commetTextField.text = ""

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
    }

    func setDetailData() {
        if let article = passedValue as? Article {
//            contentLabel.text = article.address + "/r/n" + article.reason + "/r/n" + article.memo + "key  = \(passedKey)"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + comment.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 && indexPath.section == 0{
            return UITableViewCell()
        
    } else {
            guard let cell = self.detailTableView.dequeueReusableCell(withIdentifier: String(describing: CommentTableViewCell.self), for: indexPath) as? CommentTableViewCell else {
                 return UITableViewCell()
            }
            
            let cellIndex = indexPath.row - 1
            
            cell.commentLabel.text = comment[cellIndex].comment
            
            cell.userNameLabel.text = comment[cellIndex].userName
            
            return cell
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
}
