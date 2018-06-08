//
//  GhostMKAnnotationView.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/6/7.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit
import MapKit

class UnLuckyHouseMKAnnotationView: MKAnnotationView {

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        self.canShowCallout = true
        self.calloutOffset = CGPoint(x: -5, y: 5)
        self.image = UIImage(named: "ghost")
    }
}
