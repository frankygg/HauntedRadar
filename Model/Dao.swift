//
//  Dao.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/2.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import Foundation
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
        let dbPath = Bundle.main.path(forResource: "unluckyhouse", ofType:"sqlite")
        //        // 取得sqlite在documents下的路徑(開啟連線用)
        //        self.filePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/" + self.fileName
        guard let filepath = dbPath else { return}
        
        self.filePath = filepath
        
        
        print("filePath: \(self.filePath)")
    }
    
    deinit {
        print("deinit: \(self)")
    }
    
    /// 生成 .sqlite 檔案並創建表格，只有在 .sqlite 不存在時才會建立
    func createTable() {
        let fileManager: FileManager = FileManager.default
        
        // 判斷documents是否已存在該檔案
        if !fileManager.fileExists(atPath: self.filePath) {
            
            // 開啟連線
            if self.openConnection() {
                let createTableSQL = """
                    CREATE TABLE "unluckyhouse" (
                `id`    INTEGER,
                `age`    INTEGER,
                `age_unit`    CHAR(1) DEFAULT 'Y',
                `gender`    CHAR(1) DEFAULT 'F',
                `initative`    CHAR(1) DEFAULT 'S',
                `approach`    VARCHAR(20),
                `news`    TEXT,
                `area`    VARCHAR(10),
                `address`    VARCHAR(255),
                `datetime`    DATETIME,
                `state`    INTEGER DEFAULT 0,
                `lat`    REAL DEFAULT 25.0,
                `lng`    REAL DEFAULT 119.5,
                `vlat`    REAL DEFAULT 25.0,
                `vlng`    REAL DEFAULT 119.5,
                `vazu`    INTEGER DEFAULT 0,
                `mtime`    DATETIME DEFAULT (datetime('now',
                'localtime')),
                PRIMARY KEY(id)
                )
                """
                self.database.executeStatements(createTableSQL)
                print("file copy to: \(self.filePath)")
            }
        } else {
            print("DID-NOT copy db file, file allready exists at path:\(self.filePath)")
        }
    }
    
    /// 取得 .sqlite 連線
    ///
    /// - Returns: Bool
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
    
    func queryData() -> [UnLuckyHouse] {
        var departmentDatas: [UnLuckyHouse] = [UnLuckyHouse]()
        
        if self.openConnection() {
            let querySQL: String = "SELECT * FROM unluckyhouse"
            
            do {
                let dataLists: FMResultSet = try database.executeQuery(querySQL, values: nil)
                
                while dataLists.next() {
                    if(Double(dataLists.double(forColumn: "lat")) == 25.0 && Double(dataLists.double(forColumn: "lng")) == 119.5) {
                        continue
                    }
                    let department: UnLuckyHouse = UnLuckyHouse(title: (dataLists.string(forColumn: "approach") ?? "No reason") , subtitle: (dataLists.string(forColumn: "address") ?? "") ,id: Int(dataLists.int(forColumn: "id")), lat: Double(dataLists.double(forColumn: "lat")), lng: Double(dataLists.double(forColumn: "lng")), coordinate: CLLocationCoordinate2D(latitude: Double(dataLists.double(forColumn: "lat")), longitude: Double(dataLists.double(forColumn: "lng"))))
                    departmentDatas.append(department)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return departmentDatas
    }
}
