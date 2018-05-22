//
//  HuntedNavigationController.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/14.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit

class HuntedNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        arrangeShadowLayer()
        arrangeGradientLayer()
        arrangeNavigationItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func arrangeGradientLayer() {

        let layer = CAGradientLayer()

        layer.colors = [
            UIColor(red: 255/255, green: 61/255, blue: 59/255, alpha: 1).cgColor,
            UIColor(red: 255/255, green: 229/255, blue: 59/255, alpha: 1).cgColor
        ]

        layer.startPoint = CGPoint(x: 0.0, y: 0.5)

        layer.endPoint = CGPoint(x: 1.0, y: 0.5)

        layer.frame = CGRect(
            x: 0,
            y: 0,
            width: self.navigationBar.bounds.width,
            height: self.navigationBar.bounds.height + navigationBar.frame.origin.y
        )

        let image = UIImage.imageFromLayer(layer: layer)

        self.navigationBar.setBackgroundImage(image, for: .topAttached, barMetrics: .default)
    }

    private func arrangeShadowLayer() {
        //shadow
        //阴影颜色
        self.navigationBar.layer.shadowColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.24).cgColor
        //阴影偏移,x向右偏移4，y向下偏移4
        self.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        //阴影半径，默认3
        //        navigationController?.navigationBar.layer.shadowRadius = 4
        //阴影透明度，默认0
        self.navigationBar.layer.shadowOpacity = 4.0

        self.navigationBar.barTintColor = UIColor(red: 255/255, green: 61/255, blue: 59/255, alpha: 1)
    }

    private func arrangeNavigationItem() {
        self.navigationBar.tintColor = UIColor.white
    }

}

extension UIImage {

    static func imageFromLayer(layer: CALayer) -> UIImage? {

        UIGraphicsBeginImageContext(layer.frame.size)

        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        layer.render(in: context)

        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return image
    }
}
