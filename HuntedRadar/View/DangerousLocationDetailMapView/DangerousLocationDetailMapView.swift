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
    
    // local variables
    var locations: [String]!
    var twoDimensionArray = [ExpandableLocations]()
    let dangerous = ["毒品", "強制性交", "強盜", "搶奪", "住宅竊盜", "汽車竊盜", "機車竊盜"]
    let dangerousimage: [String: String] = ["毒品": "needle", "強制性交": "sexual_abuse", "強盜": "rob", "搶奪": "steal", "住宅竊盜": "homesteal", "汽車竊盜": "carsteal", "機車竊盜": "motorcycle_steal"]
    weak var delegate: DangerousLocationDetailMapViewDelegate?

    // IBOutlet variables
    @IBOutlet weak var titleLabel: UILabel!
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

    func configureWithLocation(location: DangerousLocation) {
        delegate?.detailsRequestedForDangerousLocation(locations: locations)
        self.locations = location.crimes
        for item in dangerous {
            var group = [String]()
            for location in locations where item == location.trimmingCharacters(in: .whitespaces) {
                group.append(location)
            }
            if group.count > 0 {
                twoDimensionArray.append(ExpandableLocations(isExpandable: true, locations: group))
            }
        }
        titleLabel.text = location.subtitle
        detailTableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return twoDimensionArray.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return twoDimensionArray[section].locations[0]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DangerousLocationTableViewCell", for: indexPath) as? DangerousLocationTableViewCell {
            let item = twoDimensionArray[indexPath.section].locations[indexPath.row]
            cell.configureWithItem(item: item)
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let button = UIButton(type: .system)
        let numberOfDangerous = twoDimensionArray[section].locations.count
        button.setTitle("\(twoDimensionArray[section].locations[0]) X\(numberOfDangerous)", for: .normal)
        if let imageName = dangerousimage[twoDimensionArray[section].locations[0]] {
            let image = UIImageView(image: UIImage(named: imageName))
            button.addSubview(image)
            image.translatesAutoresizingMaskIntoConstraints = false
            let horizontalConstraint = NSLayoutConstraint(item: image, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: button, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 10)
            let verticalConstraint = NSLayoutConstraint(item: image, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: button, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 25)
            let widthConstraint = NSLayoutConstraint(item: image, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 20)
            let heightConstraint = NSLayoutConstraint(item: image, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 20)
            button.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        }
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.tag = section
        button.layer.borderColor = UIColor.black.cgColor
        button.clipsToBounds = true
        button.layer.borderWidth = 4
        button.layer.cornerRadius = 2
        button.layer.borderColor = UIColor.white.cgColor
        return button
    }

    @objc func handleExpandClose(_ sender: UIButton) {
        let section = sender.tag
        var indexPaths = [IndexPath]()
        for row in twoDimensionArray[section].locations.indices {
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        let isExpanded = twoDimensionArray[section].isExpandable
        twoDimensionArray[section].isExpandable = !isExpanded
        if isExpanded {
            detailTableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            detailTableView.insertRows(at: indexPaths, with: .fade)
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }

    // MARK: - Hit test. We need to override this to detect hits in our custom callout.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // list
        if let result = detailTableView.hitTest(convert(point, to: detailTableView), with: event) {
            return result
        }
        // fallback to our background content view
        return backGroundButten.hitTest(convert(point, to: backGroundButten), with: event)
    }

}
