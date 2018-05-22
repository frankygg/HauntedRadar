//
//  CommentTableViewCell.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/21.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit
import SwipeCellKit
class CommentTableViewCell: SwipeTableViewCell {

    //delegate variable
//    weak var delegate: SwipeTableViewCellDelegate?

    //IBOutlet var
    @IBOutlet weak var createdTimeLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
