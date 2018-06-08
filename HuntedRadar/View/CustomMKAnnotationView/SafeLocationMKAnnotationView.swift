//
//  SafeLocationMKAnnotationView.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/6/7.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit
import MapKit

class SafeLocationMKAnnotationView: MKAnnotationView {

    private var annotationTitle: String?

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        guard let annotation = annotation as? SafeLocation else {
            return
        }
        annotationTitle = annotation.title
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        self.canShowCallout = true
        self.calloutOffset = CGPoint(x: -5, y: 5)
        if annotationTitle == "有凶宅！" {
            self.image = UIImage(named: "exclamation")
        } else {
            self.image = UIImage(named: "safe")
        }
    }

}
