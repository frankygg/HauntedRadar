//
//  SearchBarContainerView.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/18.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit

class SearchBarContainerView: UIView {

    let searchBar: UISearchBar

    init(customSearchBar: UISearchBar) {
        searchBar = customSearchBar
        super.init(frame: CGRect.zero)

//        searchBar.barTintColor = UIColor.white
//        searchBar.searchBarStyle = .minimal
//        searchBar.returnKeyType = .done
        addSubview(searchBar)
    }
    override convenience init(frame: CGRect) {
        self.init(customSearchBar: UISearchBar())
        self.frame = frame
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        searchBar.frame = bounds
    }
}
