//
//  ViewController.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/2.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, SwitchViewDelegate{
    
    
    let dangerous = ["凶宅", "毒品", "強制性交", "強盜", "搶奪", "住宅竊盜", "汽車竊盜", "機車竊盜"]

    var boolArray = ["凶宅": false, "毒品": false, "強制性交": false, "強盜": false, "搶奪": false, "住宅竊盜": false, "汽車竊盜": false, "機車竊盜": false]
    
    func deliverSwitchState(_ sender: SwitchCollectionViewCell, _ rowAt: Int) {
        if let state = boolArray[dangerous[rowAt]] {
        boolArray[dangerous[rowAt]] = !state
        }
        handleUnluckyHouse()
        handleDangerousLocation()
    }

    var resultSearchController: UISearchController?
    var hasUnluckyhouse = false

    @IBOutlet weak var fullscreenExitButton: UIButton!
    var dangerousLocation = [DangerousLocation]()
    var addressWithMultiAnnotation = [String: [DangerousLocation]]()

    var dangerousAddress = [DangerousAddress]()
    var dangerousCrimeDate: [String]?

    @IBOutlet var mapViewEqualHeightConstraint: NSLayoutConstraint!

    @IBOutlet var mapViewHeightConstraint: NSLayoutConstraint!
    var isFullScreen = false
    @IBOutlet weak var controlPanelView: UIView!
    var userLocation: CLLocation?
    var originalLocation: CLLocationCoordinate2D?
    @objc func centerBackOnLocation(_ sender: UIBarButtonItem) {
        mapView.removeAnnotations(mapView.annotations)

        if let originalLocation = originalLocation {
            userLocation = CLLocation(latitude: originalLocation.latitude, longitude: originalLocation.longitude)
            centerLocation(originalLocation, with: 0)
        }
        handleUnluckyHouse()
        handleDangerousLocation()
    }
    @IBOutlet weak var searchButton: UIButton!
    @IBAction func visible(_ sender: UIButton) {
        handleUnluckyHouse()
        print("================dangerousAddress============== \(dangerousAddress.count)")
        handleDangerousLocation()
    }

    func handleUnluckyHouse() {
        hasUnluckyhouse = false
        for annotation in mapView.annotations {
            if annotation.isKind(of: DangerousLocation.self) || annotation.isKind(of: UnLuckyHouse.self) || annotation.isKind(of: SafeLocation.self) {
                mapView.removeAnnotation(annotation)
            }
        }
        if boolArray["凶宅"] == true {
            for unluckyhouse in unluckyhouseList {

                let latitude = unluckyhouse.coordinate.latitude
                let longitude = unluckyhouse.coordinate.longitude
                let annotationLocation = CLLocation(latitude: latitude, longitude: longitude)
                if let userLocation = userLocation {
                    if userLocation.distance(from: annotationLocation) < 1604 {
                        hasUnluckyhouse = true
                        mapView.addAnnotation(unluckyhouse)
                    }
                }
            }
    }
    }

    func handleDangerousLocation() {
        dangerousCrimeDate = [String]()
        if let userLocation = userLocation, dangerousAddress.count > 0 {
            getAddressFromLatLon(pdblLatitude: userLocation.coordinate.latitude, withLongitude: userLocation.coordinate.longitude) { useraddress in
                DispatchQueue.main.async {
                    for item in self.dangerousAddress where item.address == useraddress {
                        self.convertAddressToLocationAtCotro(item.address, callback: { [weak self] coordinate in
                            var crimes = [String]()
                            var crimeDates = [String]()
                            for value in item.title where self?.boolArray[value] == true {
                                crimes.append(value)
                            }
                            for value in item.crimeWithDate where self?.boolArray[String(value[value.index(value.startIndex, offsetBy: 5)...])] == true {
                                crimeDates.append(value)
                            }
                            
                            if crimes.count > 0 {
                                let location = DangerousLocation(coordinate: coordinate, title: "", subtitle: item.address, crimes: crimes)
                                self?.dangerousCrimeDate = crimeDates
                                self?.mapView.addAnnotation(location)
                                self?.mapView.selectAnnotation(location, animated: true)
                                self?.centerLocation(location.coordinate, with: 0.014)
                            } else if self?.hasUnluckyhouse == false {
                                let location = SafeLocation(title: "沒有犯罪危險呢！", subtitle: item.address, coordinate: coordinate)
                                self?.mapView.addAnnotation(location)
                                self?.mapView.selectAnnotation(location, animated: true)

                            } else {
                                let location = SafeLocation(title: "有凶宅！", subtitle: item.address, coordinate: coordinate)
                                self?.mapView.addAnnotation(location)
                                self?.mapView.selectAnnotation(location, animated: true)
                            }
                        })
                    }
                }
            }
        }
    }
    var tapGesture = UITapGestureRecognizer()
    @IBOutlet weak var mapView: MKMapView!
    let unLuckyHouseIdentifier = "unluckyhouse"
    let dangerouseLocationIdentifier = "dangerouse"
    let safeLocationIdentifier = "safe"

    var unluckyhouseList = [UnLuckyHouse]()

    let locationManager = CLLocationManager()

    var dlManager = DLManager()

    override func viewDidLoad() {

        super.viewDidLoad()

        //set searchbutton
        let transform = CGAffineTransform(scaleX: 2, y: 2)
        searchButton.transform = transform
        //set search bar
        let storyBoard = UIStoryboard(name: "LocationSearchTable", bundle: nil)
        let locationSearchTable = storyBoard.instantiateViewController(withIdentifier: "LocationSearchTable") as? LocationSearchTable
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

        // TAP Gesture
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapviewTapped))
        mapView.addGestureRecognizer(tapGesture)
        mapView.isUserInteractionEnabled = true

        //json api dangerous location
        DispatchQueue.main.async {

        self.dlManager.requestDLinJson(completion: { [weak self] locations in

            for (key, values) in locations {
                var title = [String]()
                for crime in values {
                    title.append(String(crime[crime.index(crime.startIndex, offsetBy: 5)...]))
                }
                let addressObj = DangerousAddress(address: key, title: title, crimeWithDate: values)
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

                UIView.animate(withDuration: 1.0, animations: {
                    self.mapViewHeightConstraint.isActive = false
                    self.mapViewEqualHeightConstraint.isActive = true
                    self.view.layoutIfNeeded()
                })
                isFullScreen = !isFullScreen
                controlPanelView.isHidden = isFullScreen            }
        }
    }
    //Container segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "qq" {
            if let nextVC = segue.destination as? SwitchViewController {
                nextVC.delegate = self
            }
        } else if segue.identifier == "deliverCrime" {
            
                
                // initialize new view controller and cast it as your view controller
                let viewController = segue.destination as? BarChartViewController
                // your new view controller should have property that will store passed value
            viewController?.passedValue = dangerousCrimeDate
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func exitFullscreen(_ sender: UIButton) {
        if isFullScreen {
            sender.isHidden = true
            UIView.animate(withDuration: 1.0, animations: {
                self.mapViewEqualHeightConstraint.isActive = false
                self.mapViewHeightConstraint.isActive = true
                self.view.layoutIfNeeded()
            })
            isFullScreen = !isFullScreen
            controlPanelView.isHidden = isFullScreen
        }
    }

    func convertAddressToLocationAtCotro(_ address: String, callback: @escaping (CLLocationCoordinate2D) -> Void) {
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
//                    print(pm.country) print(pm.locality)print(pm.subLocality)print(pm.thoroughfare)print(pm.postalCode)
//                    print(pm.subThoroughfare)
                    var addressString: String = ""
                    if let subAdministrativeArea = placemark.subAdministrativeArea {
                        if subAdministrativeArea == "桃園縣" {
                            addressString += "桃園市"                        } else {
                    addressString += subAdministrativeArea
                        }
                    }
                    if let locality = placemark.locality, addressString.range(of: locality[..<locality.index(locality.startIndex, offsetBy: 2)]) == nil {
                        addressString += locality
                    }
                        if let sublocality = placemark.subLocality, addressString != sublocality {
        addressString += sublocality
    }
                    print(addressString)
                    callback(addressString)
                }
        })
    }

    func centerLocation(_ coordinate: CLLocationCoordinate2D, with offset: CLLocationDegrees) {
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let xylocation = CLLocationCoordinate2D(latitude: coordinate.latitude + offset, longitude: coordinate.longitude)
        let region = MKCoordinateRegionMake(xylocation, span)
        mapView.setRegion(region, animated: true)
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
            centerLocation(location.coordinate, with: 0)
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        var view: MKAnnotationView
        if let annotation = annotation as? UnLuckyHouse {
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: unLuckyHouseIdentifier) {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: unLuckyHouseIdentifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.image = UIImage(named: "ghost")
        }
            return view } else if let annotation = annotation as? DangerousLocation {

                if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: dangerouseLocationIdentifier) {
                    dequeuedView.annotation = annotation
                    view = dequeuedView
                } else {
                    view = DangerousLocationAnnotationView(annotation: annotation, reuseIdentifier: dangerouseLocationIdentifier)
                }
            return view
        } else if let annotation = annotation as? SafeLocation {

            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: safeLocationIdentifier) {
                dequeuedView.annotation = annotation
                view = dequeuedView
                if annotation.title == "有凶宅！" {
                    view.image = UIImage(named: "exclamation")
                } else {
                    view.image = UIImage(named: "safe")
                }
            } else {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: safeLocationIdentifier)
                                    view.canShowCallout = true
                                    view.calloutOffset = CGPoint(x: -5, y: 5)
                if annotation.title == "有凶宅！" {
                    view.image = UIImage(named: "exclamation")
                } else {
                    view.image = UIImage(named: "safe")
                }
            }
            return view
        } else {
            let reuseId = "pin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.image = UIImage(named: "scanner")
            return pinView
        }
    }

//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
//                 calloutAccessoryControlTapped control: UIControl) {
//        if let location = view.annotation as? UnLuckyHouse {
//        location.mapItem().openInMaps()
//        }
//        if let location = view.annotation as? DangerousLocation {
//            location.mapItem().openInMaps()
//        }
//    }
}

extension MapViewController: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark) {
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)

        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        userLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        centerLocation(placemark.coordinate, with: 0)
        handleUnluckyHouse()
        handleDangerousLocation()
    }
}
