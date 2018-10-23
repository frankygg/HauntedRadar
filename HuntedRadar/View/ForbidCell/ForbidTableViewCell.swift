//
//  ForbidTableViewCell.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/24.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit
import SwipeCellKit
class ForbidTableViewCell: SwipeTableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
