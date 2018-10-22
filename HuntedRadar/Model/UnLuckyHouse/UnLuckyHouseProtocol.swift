//
//  UnLuckyHouseProtocol.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/10/22.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import Foundation
import MapKit
protocol UnLuckyHouseProtocol: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {get}
    var houseId: Int {get}
    var lat: Double {get}
    var lng: Double {get}
    var title: String? {get}
    var subtitle: String? {get}
    init(title: String, subtitle: String, houseId: Int, lat: Double, lng: Double, coordinate: CLLocationCoordinate2D)
}
