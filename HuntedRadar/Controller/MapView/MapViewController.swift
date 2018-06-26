//
//  MapViewController.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/6/8.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class MapViewController: UIViewController {

    //local var
    weak var delegate: MapViewDelegate?

    //IBOutlet var
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var fullscreenExitButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!

    //IBOutlet Action
    @IBAction func exitFullscreen(_ sender: UIButton) {
        if isFullScreen {
            sender.isHidden = true
            isFullScreen = !isFullScreen
            delegate?.exitFullScreen(self, isHidden: isFullScreen)
        }
    }

    //local var
    var tapGesture = UITapGestureRecognizer()
    var unluckyhouseList = [UnLuckyHouse]()
    let locationManager = CLLocationManager()
    var dlManager = DLManager()
    private var mapChangedFromUserInteraction = false
    var hasUnluckyhouse = false
    var dangerousLocation = [DangerousLocation]()
    var addressWithMultiAnnotation = [String: [DangerousLocation]]()
    var dangerousAddress = [DangerousAddress]()
    var dangerousCrimeDate: [String]?
    var isFullScreen = false
    var userLocation: CLLocation?
    var originalLocation: CLLocationCoordinate2D?

    func centerBackOnLocation() {
        mapView.removeAnnotations(mapView.annotations)

        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("No access")
                userLocation = nil
                alertAction(title: "未開啟定位權限", message: "請在手機設定中開啟定位權限以取得您的位置，您的目前位置會顯示於地圖，並用於計算附近範圍是否曾發生凶宅或犯罪行為。")
                return
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
            }
        } else {
            print("Location services are not enabled")
        }
        if let originalLocation = originalLocation {
            userLocation = CLLocation(latitude: originalLocation.latitude, longitude: originalLocation.longitude)
            centerLocation(originalLocation, with: 0)
        }
        handleUnluckyHouse()
        handleDangerousLocation()
    }

    func handleUnluckyHouse() {
        hasUnluckyhouse = false
        for annotation in mapView.annotations {
            if annotation.isKind(of: DangerousLocation.self) || annotation.isKind(of: UnLuckyHouse.self) || annotation.isKind(of: SafeLocation.self) {
                mapView.removeAnnotation(annotation)
            }
        }
        if MapViewConstants.boolArray["凶宅"] == true {
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
        guard let userLocation = userLocation else {
            alertAction(title: "定位設定處理中", message: "如未開啟定位權限，請在手機設定中開啟定位權限以取得您的位置。")
            return
        }
        if dangerousAddress.count > 0 {
            AddressProvider.shared.getAddressFromLocation(pdblLatitude: userLocation.coordinate.latitude, withLongitude: userLocation.coordinate.longitude) { useraddress in
                if useraddress == "" {
                    self.alertAction(title: "系統過載", message: "系統過載請稍待片刻謝謝！")
                    return
                }

                DispatchQueue.main.async {
                    var hasAnnotation = false
                    for item in self.dangerousAddress where item.address == useraddress {
                        hasAnnotation = true
                        AddressProvider.shared.getLocationFromAddress(item.address, callback: { [weak self] coordinate in
                            var crimes = [String]()
                            var crimeDates = [String]()
                            for value in item.title where MapViewConstants.boolArray[value] == true {
                                crimes.append(value)
                            }
                            for value in item.crimeWithDate where MapViewConstants.boolArray[String(value[value.index(value.startIndex, offsetBy: 5)...])] == true {
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
                    if !hasAnnotation {
                        let location = SafeLocation(title: "無資料", subtitle: useraddress, coordinate: userLocation.coordinate)
                        self.mapView.addAnnotation(location)
                        self.mapView.selectAnnotation(location, animated: true)
                        self.alertAction(title: "找無資料", message: "請切換至繁體中文語系並僅限搜尋台灣地區！")
                    }
                }
            }
        }
    }

    override func viewDidLoad() {

        super.viewDidLoad()
        //set searchbutton
        setSearchButton()
        setFullScfeenExitButton()

        locationManager.delegate = self
        //kCLLocationAccuracyHundredMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        mapView.delegate = self
        mapView.showsUserLocation = true
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

    func setSearchButton() {
        let transform = CGAffineTransform(scaleX: 2, y: 2)
        searchButton.transform = transform
        searchButton.setImage(searchButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        searchButton.tintColor = UIColor(red: 255/255, green: 61/255, blue: 59/255, alpha: 1)

    }

    func setFullScfeenExitButton() {
        fullscreenExitButton.setImage(fullscreenExitButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        fullscreenExitButton.tintColor = UIColor(red: 255/255, green: 61/255, blue: 59/255, alpha: 1)
        fullscreenExitButton.isHidden = true

    }

    @objc func mapviewTapped(_ sender: UITapGestureRecognizer) {
        let tapPoint = sender.location(in: self.mapView)
        let hitAnnotationView: UIView? = mapView.hitTest(tapPoint, with: nil)
        if let annotationView = hitAnnotationView {
            if !annotationView.isKind(of: MKAnnotationView.self) && !isFullScreen {
                fullscreenExitButton.isHidden = false
                isFullScreen = !isFullScreen
                delegate?.didFullScreen(self, isHidden: isFullScreen)
            }
        }
    }

    //Container segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "deliverCrime" {
            // initialize new view controller and cast it as your view controller
            let viewController = segue.destination as? BarChartViewController
            // new view controller should have property that will store passed value
            viewController?.passedValue = dangerousCrimeDate
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func centerLocation(_ coordinate: CLLocationCoordinate2D, with offset: CLLocationDegrees) {
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let xylocation = CLLocationCoordinate2D(latitude: coordinate.latitude + offset, longitude: coordinate.longitude)
        let region = MKCoordinateRegionMake(xylocation, span)
        mapView.setRegion(region, animated: true)
    }

    func alertAction(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
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
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: MapViewConstants.unLuckyHouseIdentifier) {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = UnLuckyHouseMKAnnotationView(annotation: annotation, reuseIdentifier: MapViewConstants.unLuckyHouseIdentifier)
            }
            return view

        } else if let annotation = annotation as? DangerousLocation {
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: MapViewConstants.dangerouseLocationIdentifier) {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = DangerousLocationAnnotationView(annotation: annotation, reuseIdentifier: MapViewConstants.dangerouseLocationIdentifier)
            }
            return view
        } else if let annotation = annotation as? SafeLocation {
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: MapViewConstants.safeLocationIdentifier) {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = SafeLocationMKAnnotationView(annotation: annotation, reuseIdentifier: MapViewConstants.safeLocationIdentifier)
            }
            return view
        } else {
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: MapViewConstants.pinViewIdentifier) {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = PinViewMKAnnotationView(annotation: annotation, reuseIdentifier: MapViewConstants.pinViewIdentifier)
            }
            return view
        }
    }

    private func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = self.mapView.subviews[0]
        //  Look through gesture recognizers to determine whether this region change is from user interaction
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if recognizer.state == UIGestureRecognizerState.began || recognizer.state == UIGestureRecognizerState.ended {
                    return true
                }
            }
        }
        return false
    }

    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        mapChangedFromUserInteraction = mapViewRegionDidChangeFromUserInteraction()
        if mapChangedFromUserInteraction {
            // user changed map region
            delegate?.mapChangedFromUserInteraction(self)
        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if mapChangedFromUserInteraction {
            // user changed map region
            delegate?.mapChangedFromUserInteraction(self)
        }
    }
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
        delegate?.mapChangedFromUserInteraction(self)
    }
}

protocol MapViewDelegate: class {
    func didFullScreen(_ sender: MapViewController, isHidden: Bool)

    func exitFullScreen(_ sender: MapViewController, isHidden: Bool)

    func mapChangedFromUserInteraction(_ sender: MapViewController)
}
