//
//  DLManagerProtocol.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/10/19.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import Foundation

protocol DLManagerProtocol {
    func requestDLinJson(completion: @escaping ([String: [String]]) -> Void)
}
