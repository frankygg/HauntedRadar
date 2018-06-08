//
//  CustomResultSearchController.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/6/7.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit

class CustomResultSearchController: UISearchController {
    
    override init(searchResultsController: UIViewController?) {
        super.init(searchResultsController: searchResultsController)
        setup()
        guard let updater = searchResultsController as? UISearchResultsUpdating else {
            return
        }
        self.searchResultsUpdater = updater
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    func setup() {
        
//        let searchBar = self.searchBar
//        searchBar.sizeToFit()
//        searchBar.setValue("取消", forKey: "_cancelButtonText")
//        searchBar.placeholder = "找尋你要的位置"
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
