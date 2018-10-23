//
//  SwitchViewDelegate.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/10/23.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import Foundation
protocol SwitchViewDelegate: class {
    func deliverSwitchState(_ sender: SwitchCollectionViewCell, _ rowAt: Int)
}
