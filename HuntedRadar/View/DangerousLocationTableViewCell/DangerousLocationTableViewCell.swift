//
//  DangerousLocationTableViewCell.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/4.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit

class DangerousLocationTableViewCell: UITableViewCell {

    @IBOutlet weak var itemLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configureWithItem(item: String) {
        self.itemLabel.text = item
    }

}
