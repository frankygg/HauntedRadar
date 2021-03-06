//
//  DangerousLocationAnnotationView.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/4.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit
import MapKit

class DangerousLocationAnnotationView: MKAnnotationView {

    weak var customCalloutView: DangerousLocationDetailMapView?
    override var annotation: MKAnnotation? {
        willSet { customCalloutView?.removeFromSuperview() }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.canShowCallout = false
        self.image = UIImage(named: "evileye")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.canShowCallout = false
        self.image = UIImage(named: "evileye")
    }

    // MARK: - callout showing and hiding
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            // remove old custom callout (if any)
            self.customCalloutView?.removeFromSuperview()
            if let newCustomCalloutView = loadDangerousDetailMapView() {
                // fix location from top-left to its right place.
                newCustomCalloutView.frame.origin.x -= newCustomCalloutView.frame.width / 2.0 - (self.frame.width / 2.0)
                newCustomCalloutView.frame.origin.y -= newCustomCalloutView.frame.height
                // set custom callout view
                self.addSubview(newCustomCalloutView)
                self.customCalloutView = newCustomCalloutView
                // animate presentation
                if animated {
                    self.customCalloutView!.alpha = 0.0
                    UIView.animate(withDuration: 0.7, animations: {
                        self.customCalloutView!.alpha = 1.0
                    })
                }
            }
        } else {
            if customCalloutView != nil {
                if animated {
                    // fade out animation, then remove it.
                    UIView.animate(withDuration: 0.7, animations: {
                        self.customCalloutView!.alpha = 0.0
                    }, completion: nil)
                } else { self.customCalloutView!.removeFromSuperview() } // just remove it.
            }
        }
    }

    func loadDangerousDetailMapView() -> DangerousLocationDetailMapView? {
        if let views = Bundle.main.loadNibNamed("DangerousLocationDetailMapView", owner: self, options: nil) as? [DangerousLocationDetailMapView], views.count > 0 {
            let detailMapView = views.first!
            detailMapView.delegate = self as? DangerousLocationDetailMapViewDelegate
            if let dangerousAnnotation = annotation as? DangerousLocation {
                let locations = dangerousAnnotation
                detailMapView.configureWithLocation(location: locations)
            }
            return detailMapView
        }
        return nil

    }

    override func prepareForReuse() { // 5
        super.prepareForReuse()
        self.customCalloutView?.removeFromSuperview()
    }
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // if super passed hit test, return the result
        if let parentHitView = super.hitTest(point, with: event) { return parentHitView } else { // test in our custom callout.
            if customCalloutView != nil {
                return customCalloutView!.hitTest(convert(point, to: customCalloutView!), with: event)
            } else { return nil }
        }
    }

}
