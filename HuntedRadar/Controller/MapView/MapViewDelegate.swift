//
//  MapViewDelegate.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/10/23.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import Foundation
protocol MapViewDelegate: class {
    func didFullScreen(_ sender: MapViewController, isHidden: Bool)
    
    func exitFullScreen(_ sender: MapViewController, isHidden: Bool)
    
    func mapChangedFromUserInteraction(_ sender: MapViewController)
}
