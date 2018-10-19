//
//  DangerousAddress.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/10/19.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import Foundation

class DangerousAddress {
    var title: [String]
    var address: String
    var crimeWithDate: [String]
    
    init(address: String, title: [String], crimeWithDate: [String]) {
        self.address = address
        self.title = title
        self.crimeWithDate = crimeWithDate
    }
}
