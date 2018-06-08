//
//  UISearchController+Extension.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/6/8.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import Foundation
import UIKit

extension UISearchController {
    func setUpCustomButton() {
        let searchBar = self.searchBar
        searchBar.sizeToFit()
        searchBar.setValue("取消", forKey: "_cancelButtonText")
        searchBar.placeholder = "找尋你要的位置"
    }
}

