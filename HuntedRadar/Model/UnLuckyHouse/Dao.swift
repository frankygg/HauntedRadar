//
//  Dao.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/2.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import Foundation
import FMDB
import MapKit

class Dao: NSObject {

    static let shared = Dao()

    var fileName: String = "unluckyhouse.sqlite" // sqlite name
    var filePath: String = "" // sqlite path
    var database: FMDatabase! // FMDBConnection
    private override init() {
        super.init()
        let dbPath = Bundle.main.path(forResource: "unluckyhouse", ofType: "sqlite")
        // 取得sqlite在documents下的路徑(開啟連線用)
        guard let filepath = dbPath else { return}
        self.filePath = filepath
        print("filePath: \(self.filePath)")
    }

    deinit {
        print("deinit: \(self)")
    }

    // 取得 .sqlite 連線
    func openConnection() -> Bool {
        var isOpen: Bool = false
        self.database = FMDatabase(path: self.filePath)
        if self.database != nil {
            if self.database.open() {
                isOpen = true
            } else {
                print("Could not get the connection.")
            }
        }

        return isOpen
    }

    func queryData() -> [UnLuckyHouseProtocol] {
        var departmentDatas: [UnLuckyHouse] = [UnLuckyHouse]()
        if self.openConnection() {
            let querySQL: String = "SELECT * FROM unluckyhouse where lat != 25.0 and lng != 119.5"
            do {
                let dataLists: FMResultSet = try database.executeQuery(querySQL, values: nil)
                while dataLists.next() {
                    let title = (dataLists.string(forColumn: "approach") ?? "No reason")
                    let subtitle = (dataLists.string(forColumn: "address") ?? "")
                    let lat = Double(dataLists.double(forColumn: "lat"))
                    let lng = Double(dataLists.double(forColumn: "lng"))
                    let latitude = Double(dataLists.double(forColumn: "lat"))
                    let longitude = Double(dataLists.double(forColumn: "lng"))
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    let houseId =  Int(dataLists.int(forColumn: "id"))
                    let department: UnLuckyHouse = UnLuckyHouse(title: title, subtitle: subtitle, houseId: houseId, lat: lat, lng: lng, coordinate: coordinate)
                    departmentDatas.append(department)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return departmentDatas
    }
}
