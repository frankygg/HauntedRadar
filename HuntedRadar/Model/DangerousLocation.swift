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

    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: title!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        return mapItem
    }
}

class DangerousAddress {
    var title: [String]
    var address: String

    init(address: String, title: [String]) {
        self.address = address
        self.title = title
    }

}

struct DLManager {

    func requestArticles(completion: @escaping ([String: [String]]) -> Void) {

            //alamofire
            Alamofire.request("https://od.moi.gov.tw/api/v1/rest/datastore/A01010000C-000499-073").responseJSON { response in

                do {
                    guard let data = response.data else {return}
                    if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String: Any] {

                        if let jsonData = json["result"] as? [String: Any], let records = jsonData["records"] as? [NSDictionary] {
                            DispatchQueue.global().async {
                                var dangerousAddressWithTitles = [String: [String]]()
                        for obj in records {
                            if let address = obj.object(forKey: "oc_p1") as? String, let title = obj.object(forKey: "type") as? String {

                                let oneaddress = title.trimmingCharacters(in: .whitespaces)
                                let annotationAtAddress = dangerousAddressWithTitles[address] ?? [String]()
                                dangerousAddressWithTitles[address] = annotationAtAddress + [oneaddress]

                            }

                        }
                                completion(dangerousAddressWithTitles)
                            }

                    }
                        if (json["error"] as? String) != nil {
                    }
                }
                } catch {
                    fatalError()
                }
            }
        }

    func convertAddressToLocation(_ address: String, callback: @escaping (CLLocationCoordinate2D) -> Void) {
        //        let address = "1 Infinite Loop, Cupertino, CA 95014"
        //        let address2 = "台北市萬華區"
        var coordinate: CLLocationCoordinate2D? = nil
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, _) in
                if let placemarks = placemarks, let location = placemarks.first?.location {
                        coordinate = location.coordinate
                        callback(coordinate!)
                } else {

//            // handle no location found
            callback(CLLocationCoordinate2D(latitude: 25.0, longitude: 119.5))
            }
                // Use your location
        }
    }

}
