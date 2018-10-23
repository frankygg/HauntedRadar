//
//  SwitchCollectionViewCell.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/8.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit

class SwitchCollectionViewCell: UICollectionViewCell {
    weak var delegate: TapSwitchCellDelegate?

    @IBOutlet weak var dangerousImage: UIImageView!
    @IBOutlet weak var dangerousLabel: UILabel!
    @IBOutlet weak var cellswitch: UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellswitch.addTarget(self, action: #selector(tappedMe(sender:)), for: UIControlEvents.valueChanged)
    }

    @objc func tappedMe(sender: UISwitch) {
        delegate?.tapSwitchCell(self)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // list
        if let result = cellswitch.hitTest(convert(point, to: cellswitch), with: event) {
            return result
        }
        if let result = dangerousLabel.hitTest(convert(point, to: dangerousLabel), with: event) {
            return result
        }
        if let result = dangerousImage.hitTest(convert(point, to: dangerousImage), with: event) {
            return result
        }
        return nil
    }
}
protocol TapSwitchCellDelegate: class {
    func tapSwitchCell(_ sender: SwitchCollectionViewCell)
}
