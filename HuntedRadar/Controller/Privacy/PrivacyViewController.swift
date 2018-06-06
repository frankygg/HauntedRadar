//
//  PrivacyViewController.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/30.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //IBOutlet var
    @IBOutlet weak var privacyTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setNib()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setNib() {
        //xib的名稱
        let nib = UINib(nibName: String(describing: PrivacyViewCell.self), bundle: nil)
        //註冊
        privacyTableView.register(nib, forCellReuseIdentifier: String(describing: PrivacyViewCell.self))

        privacyTableView.delegate = self

        privacyTableView.dataSource = self

        privacyTableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.privacyTableView.dequeueReusableCell(withIdentifier: String(describing: PrivacyViewCell.self), for: indexPath) as? PrivacyViewCell else {
            return UITableViewCell()
        }

        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        //不可被點選
        cell.selectionStyle = .none

        return cell
    }

    @IBAction func understandAction(_ sender: Any) {

        dismiss(animated: true, completion: nil)
    }

}
