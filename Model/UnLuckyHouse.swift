//
//  UnLuckyHouse.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/2.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import Foundation
import MapKit
import Contacts

class UnLuckyHouse: NSObject , MKAnnotation{
    
    var coordinate: CLLocationCoordinate2D
    var id: Int
    var lat: Double
    var lng: Double
    var title: String?
    var subtitle: String?
    
    init(title: String,subtitle: String,  id: Int, lat: Double, lng: Double, coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.lat = lat
        self.lng = lng
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        super.init()
    }
    
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: title!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        //        mapItem.name = title
        
        
        return mapItem
    }
}
