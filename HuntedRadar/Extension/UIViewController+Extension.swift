//
//  UIViewController+Extension.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/10/22.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func popUpAlert(title: String, message: String, shouldHaveCancelButton: Bool, confirmCompletion:(() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default, handler: { _ in
            guard let completion = confirmCompletion else {
                return
            }
            completion()
            })
        alertController.addAction(okAction)
        if shouldHaveCancelButton {
            let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
            alertController.addAction(cancelAction)
        }
        self.present(alertController, animated: true, completion: nil)
    }
}
