//
//  UIStoryBoardExtension.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/12.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit
extension UIStoryboard {
    static func mapStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }

    static func articleStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Article", bundle: nil)
    }

    static func profileStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Profile", bundle: nil)
    }

    static func customTabBarStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "TabBar", bundle: nil)
    }

    static func loginStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Login", bundle: nil)
    }

    static func addQuestionStoryboar() -> UIStoryboard {
        return UIStoryboard(name: "AddQuestion", bundle: nil)
    }
}
