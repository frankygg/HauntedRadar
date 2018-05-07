//
//  ViewController.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/2.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    var resultSearchController: UISearchController?

    @IBOutlet weak var fullscreenExitButton: UIButton!
    var dangerousLocation = [DangerousLocation]()
    var addressWithMultiAnnotation = [String: [DangerousLocation]]()

    var dangerousAddress = [DangerousAddress]()

    @IBOutlet var mapViewEqualHeightConstraint: NSLayoutConstraint!

    @IBOutlet var mapViewHeightConstraint: NSLayoutConstraint!
    var isFullScreen = false
    @IBOutlet weak var controlPanelView: UIView!
    var userLocation: CLLocation?
    var originalLocation: CLLocationCoordinate2D?
    @objc func centerBackOnLocation(_ sender: UIBarButtonItem) {
        if let originalLocation = originalLocation {
            userLocation = CLLocation(latitude: originalLocation.latitude, longitude: originalLocation.longitude)
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: originalLocation, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    @IBAction func changeDangerousLocationVisibility(_ sender: UISwitch) {
        let annotationVisible = sender.isOn
        print("================dangerousAddress============== \(dangerousAddress.count)")
        if annotationVisible, let userLocation = userLocation, dangerousAddress.count > 0 {
        getAddressFromLatLon(pdblLatitude: userLocation.coordinate.latitude, withLongitude: userLocation.coordinate.longitude) { useraddress in

            DispatchQueue.main.async {

                    for item in self.dangerousAddress where item.address.range(of: useraddress) != nil {
                                            self.convertAddressToLocationAtCotro(item.address, callback: { [weak self] coordinate in
                                                var crimes = ""
                                                for value in item.title {
                                                    crimes += " " + value
                                                }
                                                let location = DangerousLocation(coordinate: coordinate, title: crimes, subtitle: item.address, crimes: item.title)
                                                self?.mapView.addAnnotation(location)
})
                        }

            }

        }
        } else {
            for annotation in self.mapView.annotations {
                if let dangerousLocation = annotation as? DangerousLocation {
                    mapView.view(for: dangerousLocation)?.isHidden = true
                }
            }
        }

    }
    @IBAction func changeAnnotationsVisibility(_ sender: UISwitch) {

        let annotationVisible = sender.isOn
        for annotation in mapView.annotations {
            if let unluckyAnnotation = annotation as? UnLuckyHouse, let userLocation = userLocation {
            let latitude = unluckyAnnotation.coordinate.latitude
            let longitude = unluckyAnnotation.coordinate.longitude
            let annotationLocation = CLLocation(latitude: latitude, longitude: longitude)
            if annotationVisible {
//                mapView.view(for: unluckyAnnotation)?.isHidden = false
                mapView.view(for: unluckyAnnotation)?.isHidden = (userLocation.distance(from: annotationLocation) > 1604)
            } else {

                mapView.view(for: unluckyAnnotation)?.isHidden = annotation.isKind(of: UnLuckyHouse.self)
            }
            }
        }
    }
    var tapGesture = UITapGestureRecognizer()
    @IBOutlet weak var mapView: MKMapView!
    let unLuckyHouseIdentifier = "unluckyhouse"
    let dangerouseLocationIdentifier = "dangerouse"

    var unluckyhouseList = [UnLuckyHouse]()

    let locationManager = CLLocationManager()

    var dlManager = DLManager()

    override func viewDidLoad() {

        super.viewDidLoad()
        //set search bar
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as? LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "center_back"), style: .done, target: self, action: #selector(centerBackOnLocation))
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable?.mapView = mapView
        locationSearchTable?.delegate = self

        locationManager.delegate = self
        fullscreenExitButton.isHidden = true
        //kCLLocationAccuracyHundredMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()

        mapView.delegate = self

        unluckyhouseList = Dao.shared.queryData()

//        print("number house = \(unluckyhouseList.count)")
        //        for house in unluckyhouseList {
        //            print("\(house.id) = lng: \(house.lng), lat: \(house.lat)")
        //        }
        mapView.addAnnotations(unluckyhouseList)
//        mapView.addAnnotations(dangerousLocation)
        //        let overlays = unluckyhouseList.map { MKCircle(center: $0.coordinate, radius: 100) }
        //        mapView.addOverlays(overlays)
        //
        //
        //        // TAP Gesture
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapviewTapped))
        mapView.addGestureRecognizer(tapGesture)
        mapView.isUserInteractionEnabled = true

        //json api dangerous location
        DispatchQueue.main.async {

        self.dlManager.requestDLinJson(completion: { [weak self] locations in

            for (key, values) in locations {
                let addressObj = DangerousAddress(address: key, title: values)
                self?.dangerousAddress.append(addressObj)
            }
        })
              }

    }

    @objc func mapviewTapped(_ sender: UITapGestureRecognizer) {

        let tapPoint = sender.location(in: self.mapView)

        let hitAnnotationView: UIView? = mapView.hitTest(tapPoint, with: nil)
        if let annotationView = hitAnnotationView {
            if !annotationView.isKind(of: MKAnnotationView.self) && !isFullScreen {
                fullscreenExitButton.isHidden = false
                UIView.animate(withDuration: 0.7, animations: {

                    self.mapViewHeightConstraint.isActive = false
                    self.mapViewEqualHeightConstraint.isActive = true

                })
                isFullScreen = !isFullScreen
                controlPanelView.isHidden = isFullScreen            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func testAction(_ sender: UIButton) {
        if isFullScreen {
            sender.isHidden = true
            UIView.animate(withDuration: 0.7, animations: {
                self.mapViewEqualHeightConstraint.isActive = false
                self.mapViewHeightConstraint.isActive = true

            })
            isFullScreen = !isFullScreen
            controlPanelView.isHidden = isFullScreen
        }
    }

    func convertAddressToLocationAtCotro(_ address: String, callback: @escaping (CLLocationCoordinate2D) -> Void) {
        //        let address = "1 Infinite Loop, Cupertino, CA 95014"
        //        let address2 = "台北市萬華區"
        var coordinate: CLLocationCoordinate2D? = nil
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            if let placemarks = placemarks {
                let location = placemarks.first?.location
                coordinate = location?.coordinate
                callback(coordinate!)
            } else {
                print(error?.localizedDescription ?? "ERROR")
            }
        }
    }

    func getAddressFromLatLon(pdblLatitude: Double, withLongitude pdblLongitude: Double, callback: @escaping (String) -> Void) {
        var center: CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = pdblLatitude
        //21.228124
        let lon: Double = pdblLongitude
        //72.833770
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon

        let loc: CLLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)

        ceo.reverseGeocodeLocation(loc, completionHandler: {(placemarks, error) in
                if error != nil {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let placeMark = placemarks! as [CLPlacemark]

                if placeMark.count > 0 {
                    let placemark = placeMark[0]
//                    print(pm.country)
//                    print(pm.locality)
//                    print(pm.subLocality)
//                    print(pm.thoroughfare)
//                    print(pm.postalCode)
//                    print(pm.subThoroughfare)

                    var addressString: String = ""
                    if let locality = placemark.locality {
                    addressString += locality
                    }
                        if let sublocality = placemark.subLocality {
        addressString += sublocality
    }
                    callback(addressString)
//                    if pm.subLocality != nil {
//                        addressString += pm.subLocality! + ", "
//                    }
//                    if pm.thoroughfare != nil {
//                        addressString += pm.thoroughfare! + ", "
//                    }
//                    if pm.locality != nil {
//                        addressString += pm.locality! + ", "
//                    }
//                    if pm.country != nil {
//                        addressString += pm.country! + ", "
//                    }
//                    if pm.postalCode != nil {
//                        addressString += pm.postalCode! + " "
//                    }
//
//                    print(addressString)
                }
        })

    }
}

extension MapViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //simulator模擬目前位置
        if let location = locations.first {
            userLocation = location
            originalLocation = location.coordinate
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)        }
        //
    }
}

extension MapViewController: MKMapViewDelegate {
    // 1
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        mapView.frame = self.mapView.frame

        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        var view: MKAnnotationView
        // 2
        if let annotation = annotation as? UnLuckyHouse {
        // 3
        // 4
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: unLuckyHouseIdentifier) {
            dequeuedView.annotation = annotation
            view = dequeuedView
            view.isHidden = true
        } else {
            // 5
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: unLuckyHouseIdentifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.image = UIImage(named: "ghost")
            view.isHidden = true
        }
            return view } else if let annotation = annotation as? DangerousLocation {

                if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: dangerouseLocationIdentifier) {
                    dequeuedView.annotation = annotation
                    view = dequeuedView
//                    view.isHidden = true
                } else {
                    // 5
                    view = DangerousLocationAnnotationView(annotation: annotation, reuseIdentifier: dangerouseLocationIdentifier)
//                    view.canShowCallout = true
//                    view.calloutOffset = CGPoint(x: -5, y: 5)
//                    view.image = UIImage(named: "banana")
//                    view.isHidden = true
                }
            return view
        } else {
            let reuseId = "pin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.image = UIImage(named: "scanner")
            let transform = CGAffineTransform(scaleX: 2, y: 2)
                        pinView?.transform = transform
            return pinView
        }
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        if let location = view.annotation as? UnLuckyHouse {
        //        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps()
        }
        if let location = view.annotation as? DangerousLocation {
            //        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            location.mapItem().openInMaps()
        }
    }
}

extension MapViewController: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark) {
        // cache the pin
//        selectedPin = placemark
        // clear existing pins
        for annotation in mapView.annotations {
            if !annotation.isKind(of: UnLuckyHouse.self ) {
            mapView.removeAnnotation(annotation)
            }
        }
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        userLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}
