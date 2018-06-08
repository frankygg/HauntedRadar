//
//  MapViewConstants.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/6/7.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import Foundation

struct MapViewConstants {
    static let dangerous = ["凶宅", "毒品", "強制性交", "強盜", "搶奪", "住宅竊盜", "汽車竊盜", "機車竊盜"]
    static let unLuckyHouseIdentifier = "unluckyhouse"
    static let dangerouseLocationIdentifier = "dangerouse"
    static let pinViewIdentifier = "pin"
    static let safeLocationIdentifier = "safe"
    static var boolArray = ["凶宅": false, "毒品": false, "強制性交": false, "強盜": false, "搶奪": false, "住宅竊盜": false, "汽車竊盜": false, "機車竊盜": false]
    static let dangerousimage: [String: String] = ["凶宅": "ghost", "毒品": "needle", "強制性交": "sexual_abuse", "強盜": "rob", "搶奪": "steal", "住宅竊盜": "homesteal", "汽車竊盜": "carsteal", "機車竊盜": "motorcycle_steal"]
    static let dangerousWithUnluckyHouse = ["毒品", "強制性交", "強盜", "搶奪", "住宅竊盜", "汽車竊盜", "機車竊盜"]
    
    static let countMonth = ["10701", "10702", "10703"]

}
