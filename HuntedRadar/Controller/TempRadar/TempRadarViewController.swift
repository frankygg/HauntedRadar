//
//  TempRadarViewController.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/6/8.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth

class TempRadarViewController: UIViewController {

        //IBOutlet var
        @IBOutlet weak var originalMapTopConstraint: NSLayoutConstraint!
        @IBOutlet weak var fullScreenMapTopConstraint: NSLayoutConstraint!
        @IBOutlet weak var controlPanelView: UIView!
        @IBOutlet weak var mapPanelView: UIView!
        //local var
        var mapViewController: MapViewController!
        var resultSearchController: UISearchController?

        @objc func centerBackOnLocation(_ sender: UIBarButtonItem) {
            sender.tintColor = UIColor(red: 255/255, green: 61/255, blue: 59/255, alpha: 1)
            mapViewController.centerBackOnLocation()
        }

        override func viewDidLoad() {

            super.viewDidLoad()
            setSearchBar()
            setNavigationItem()
        }

        func setSearchBar() {
            let storyBoard = UIStoryboard(name: "LocationSearchTable", bundle: nil)
            let locationSearchTable = storyBoard.instantiateViewController(withIdentifier: "LocationSearchTable") as? LocationSearchUITableViewController
            resultSearchController = UISearchController(searchResultsController: locationSearchTable)
            resultSearchController?.searchResultsUpdater = locationSearchTable
            resultSearchController?.setUpCustomButton()
            let searchBar = resultSearchController!.searchBar
            if #available(iOS 11.0, *) {
                let searchBarContainer = SearchBarContainerView(customSearchBar: searchBar)
                searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
                navigationItem.titleView = searchBarContainer
            } else {

                navigationItem.titleView = searchBar
            }
            locationSearchTable?.mapView = mapViewController.mapView
            locationSearchTable?.delegate = mapViewController
            resultSearchController?.hidesNavigationBarDuringPresentation = false
            resultSearchController?.dimsBackgroundDuringPresentation = true
            definesPresentationContext = true
        }

        func setNavigationItem() {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "center_back"), style: .done, target: self, action: #selector(centerBackOnLocation(_:)))
            navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 255/255, green: 61/255, blue: 59/255, alpha: 1)

        }
        //Container segue
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "switchView" {
                if let nextVC = segue.destination as? SwitchViewController {
                    nextVC.delegate = self
                }
            } else if segue.identifier == "mapView" {
                if let nextVC = segue.destination as? MapViewController {
                    mapViewController = nextVC
                    nextVC.delegate = self
                }
            }
        }

        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }

    }

    extension TempRadarViewController: SwitchViewDelegate {

        func deliverSwitchState(_ sender: SwitchCollectionViewCell, _ rowAt: Int) {
            if let state = MapViewConstants.boolArray[MapViewConstants.dangerous[rowAt]] {
                MapViewConstants.boolArray[MapViewConstants.dangerous[rowAt]] = !state
            }
            mapViewController.handleUnluckyHouse()
            mapViewController.handleDangerousLocation()
        }
}

    extension TempRadarViewController: MapViewDelegate {
    func mapChangedFromUserInteraction(_ sender: MapViewController) {
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }

    func didFullScreen(_ sender: MapViewController, isHidden: Bool) {
        UIView.animate(withDuration: 0.5, animations: {
                                self.originalMapTopConstraint.isActive = false
                                self.fullScreenMapTopConstraint.isActive = true
            self.view.layoutIfNeeded()
        })
      controlPanelView.isHidden = isHidden
    }

    func exitFullScreen(_ sender: MapViewController, isHidden: Bool) {
        UIView.animate(withDuration: 0.5, animations: {
                            self.fullScreenMapTopConstraint.isActive = false
                            self.originalMapTopConstraint.isActive = true
            self.view.layoutIfNeeded()
        })
                    controlPanelView.isHidden = isHidden
        }
}
