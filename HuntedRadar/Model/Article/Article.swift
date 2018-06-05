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
    var imageUrl: [String]
    var address: String
    var reason: String
    var title: String
    var createdTime: Int
    var articleKey: String
    var imageName: [String]
    init(uid: String, userName: String, imageUrl: [String], address: String, reason: String, title: String, createdTime: Int, articleKey: String, imageName: [String]) {
        self.imageUrl = imageUrl
        self.uid = uid
        self.userName = userName
        self.address = address
        self.title = title
        self.reason = reason
        self.createdTime = createdTime
        self.articleKey = articleKey
        self.imageName = imageName
    }
}
