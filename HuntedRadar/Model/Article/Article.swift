//
//  Article.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/17.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import Foundation
class Article {
    var uid: String
    var userName: String
    var imageUrl: String
    var address: String
    var reason: String
    var memo: String
    init(uid: String, userName: String, imageUrl: String, address: String, reason: String, memo: String) {
        self.imageUrl = imageUrl
        self.uid = uid
        self.userName = userName
        self.address = address
        self.memo = memo
        self.reason = reason
    }
}
