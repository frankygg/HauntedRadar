//
//  TabBarViewController.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/12.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit
enum TabBar {
    case map
    case article
    case profile

    func controller() -> UIViewController {
        switch self {
        case .map: return UIStoryboard.mapStoryboard().instantiateInitialViewController()!
        case .article: return UIStoryboard.articleStoryboard().instantiateInitialViewController()!
        case .profile: return UIStoryboard.profileStoryboard().instantiateInitialViewController()!
        }
    }

    func image() -> UIImage {
        switch self {
        case .map: return #imageLiteral(resourceName: "define_location")
        case .article: return #imageLiteral(resourceName: "user_group_man_man")
        case .profile: return #imageLiteral(resourceName: "user")
        }
    }

    func selectedImage() -> UIImage {
        switch self {
        case .map: return #imageLiteral(resourceName: "define_location").withRenderingMode(.alwaysTemplate)
        case .article: return #imageLiteral(resourceName: "user_group_man_man").withRenderingMode(.alwaysTemplate)
        case .profile: return #imageLiteral(resourceName: "user").withRenderingMode(.alwaysTemplate)
        }
    }

    func titles() -> String {
        switch self {
        case .map: return "雷達"
        case .article: return "論壇"
        case .profile: return "設定"
        }
    }
}
class TabBarViewController: UITabBarController {

    let tabs: [TabBar] = [.map, .article, .profile]
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTab()
    }

    private func setupTab() {
        tabBar.tintColor = UIColor(red: 255/255, green: 61/255, blue: 59/255, alpha: 1)

        var controllers = [UIViewController]()

        for tab in tabs {
            let controller = tab.controller()

            let item = UITabBarItem(
                title: tab.titles(),
                image: tab.image(),
                selectedImage: tab.selectedImage()
            )

            item.imageInsets = UIEdgeInsets(top: 3, left: 0, bottom: -3, right: 0)

            controller.tabBarItem = item

            controllers.append(controller)
        }
        setViewControllers(controllers, animated: false)
    }

}
