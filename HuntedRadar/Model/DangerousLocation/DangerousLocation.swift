//
//  DamgerousLocation.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/2.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import Foundation
import MapKit
import Contacts
import Alamofire

class DangerousLocation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var crimes: [String]

    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, crimes: [String]) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.crimes = crimes
    }
}
