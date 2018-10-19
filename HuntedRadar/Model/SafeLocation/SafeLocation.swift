//
//  SafeLocation.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/8.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import Foundation
import MapKit
class SafeLocation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
