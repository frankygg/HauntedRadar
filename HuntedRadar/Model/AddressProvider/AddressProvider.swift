//
//  AddressProvider.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/6/6.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import Foundation
import MapKit

class AddressProvider {

    static let shared = AddressProvider()

    func getAddressFromLocation(pdblLatitude: Double, withLongitude pdblLongitude: Double, callback: @escaping (String) -> Void) {
        var center: CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = pdblLatitude
        //21.228124
        let lon: Double = pdblLongitude
        //72.833770
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon

        let loc: CLLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)

        ceo.reverseGeocodeLocation(loc, completionHandler: {(placemarks, error) in
            if error != nil {
                print("reverse geodcode fail: \(error!.localizedDescription)")
                callback("")
            }
            guard let placeMark = placemarks else {
                return
            }

            if placeMark.count > 0 {
                let placemark = placeMark[0]
                var addressString: String = ""
                if let subAdministrativeArea = placemark.subAdministrativeArea {
                    if subAdministrativeArea == "桃園縣" {
                        addressString += "桃園市"
                    } else {
                        addressString += subAdministrativeArea
                    }
                }
                if let locality = placemark.locality, addressString.range(of: locality[..<locality.index(locality.startIndex, offsetBy: 2)]) == nil {
                    addressString += locality
                }
                if let sublocality = placemark.subLocality, addressString != sublocality {
                    addressString += sublocality
                }
                print(addressString)
                callback(addressString)
            }
        })
    }

    func getLocationFromAddress(_ address: String, callback: @escaping (CLLocationCoordinate2D) -> Void) {
        var coordinate: CLLocationCoordinate2D? = nil
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            if let placemarks = placemarks {
                let location = placemarks.first?.location
                coordinate = location?.coordinate
                callback(coordinate!)
            } else {
                print(error?.localizedDescription ?? "ERROR")
            }
        }
    }

}
