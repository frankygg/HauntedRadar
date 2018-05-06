//
//  DangerousLocationDetailMapView.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/4.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit
protocol DangerousLocationDetailMapViewDelegate: class {
    func detailsRequestedForDangerousLocation(locations: [String])
}

class DangerousLocationDetailMapView: UIView, UITableViewDelegate, UITableViewDataSource {
    //data
    var locations: [String]!
    weak var delegate: DangerousLocationDetailMapViewDelegate?

    @IBOutlet weak var backGroundButten: UIButton!

    @IBOutlet weak var detailTableView: UITableView!

    override func awakeFromNib() {
        super.awakeFromNib()

        //setup list
        detailTableView.register(UINib(nibName: "DangerousLocationTableViewCell", bundle: nil), forCellReuseIdentifier: "DangerousLocationTableViewCell")
        detailTableView.delegate = self
        detailTableView.dataSource = self

        // appearance
        backGroundButten.applyArrowDialogAppearanceWithOrientation(arrowOrientation: .down)

    }

    func configureWithLocation(location: [String]) { // 5
        delegate?.detailsRequestedForDangerousLocation(locations: locations)
        self.locations = location
        detailTableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DangerousLocationTableViewCell", for: indexPath) as? DangerousLocationTableViewCell {
        if let item = locations?[indexPath.row] {
            cell.configureWithItem(item: item)
        }
        return cell
        } else {
            return UITableViewCell()
        }
    }

    // MARK: - Hit test. We need to override this to detect hits in our custom callout.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Check if it hit our annotation detail view components.

        // list
        if let result = detailTableView.hitTest(convert(point, to: detailTableView), with: event) {
            return result
        }
        // fallback to our background content view
        return backGroundButten.hitTest(convert(point, to: backGroundButten), with: event)
    }

}
