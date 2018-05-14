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
        case .profile: return #imageLiteral(resourceName: "user_male")
        }
    }

    func selectedImage() -> UIImage {
        switch self {
            case .map: return #imageLiteral(resourceName: "define_location").withRenderingMode(.alwaysTemplate)
            case .article: return #imageLiteral(resourceName: "user_group_man_man").withRenderingMode(.alwaysTemplate)
            case .profile: return #imageLiteral(resourceName: "user_male").withRenderingMode(.alwaysTemplate)
        }
    }
}
class TabBarViewController: UITabBarController {

    let tabs: [TabBar] = [.map, .article, .profile]
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTab()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func setupTab() {
        tabBar.tintColor = UIColor(red: 255/255, green: 61/255, blue: 59/255, alpha: 1)

        var controllers = [UIViewController]()

        for tab in tabs {
            let controller = tab.controller()

            let item = UITabBarItem(
                title: nil,
                image: tab.image(),
                selectedImage: tab.selectedImage()
            )

            item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)

            controller.tabBarItem = item

            controllers.append(controller)
        }
        setViewControllers(controllers, animated: false)
    }

}
