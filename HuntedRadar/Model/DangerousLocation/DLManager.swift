//
//  DLManager.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/10/19.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import Foundation

struct DLManager: DLManagerProtocol {
    func requestDLinJson(completion: @escaping ([String: [String]]) -> Void) {
        let url = Bundle.main.url(forResource: "crimes10701_10703", withExtension: "json")
        let data = try? Data(contentsOf: url!)
        do {
            guard let jsonData = data else {return}
            let responseStrInmacOSRoman = String(data: jsonData, encoding: String.Encoding.macOSRoman)
            guard let modifiedDataInUTF8Format = responseStrInmacOSRoman?.data(using: String.Encoding.utf16) else {
                print("could not convert data to UTF-8 format")
                return
            }
            if let records = try JSONSerialization.jsonObject(with: modifiedDataInUTF8Format, options: JSONSerialization.ReadingOptions()) as? [NSDictionary] {
                DispatchQueue.global().async {
                    var dangerousAddressWithTitles = [String: [String]]()
                    for obj in records {
                        if let address = obj.object(forKey: "oc_p1") as? String, let title = obj.object(forKey: "type") as? String, var crimeDate =  obj.object(forKey: "oc_dt") as? String, crimeDate.count > 4 {
                            crimeDate = String(crimeDate[..<crimeDate.index(crimeDate.startIndex, offsetBy: 5)])
                            let oneaddress = crimeDate + title.trimmingCharacters(in: .whitespaces)
                            let annotationAtAddress = dangerousAddressWithTitles[address] ?? [String]()
                            dangerousAddressWithTitles[address] = annotationAtAddress + [oneaddress]
                        }
                    }
                    completion(dangerousAddressWithTitles)
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
