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
    var deq = 0
    var ghost = 0
    @IBOutlet weak var mapViewEqualHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapViewHeightConstraint: NSLayoutConstraint!
    var isFullScreen = false
    var originalMapFrame:[NSLayoutConstraint]!
    @IBOutlet weak var controlPanelView: UIView!
    var userLocation: CLLocation!
    @IBAction func changeAnnotationsVisibility(_ sender: UISwitch) {
        
        let annotationVisible = sender.isOn
        
        for annotation in mapView.annotations {
            let annotationLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            if annotationVisible {
                mapView.view(for: annotation)?.isHidden = (userLocation.distance(from: annotationLocation) > 1604)
            }else {
                
                mapView.view(for: annotation)?.isHidden = annotation.isKind(of: UnLuckyHouse.self)
            }
            //            mapView.view(for: annotation)?.isHidden = !annotationVisible && !(userLocation.distance(from: annotationLocation) > 1604)
            //            print("distance \(userLocation.distance(from: annotationLocation))")
            
        }
    }
    var tapGesture = UITapGestureRecognizer()
    
    
    @IBOutlet weak var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 1000
    let identifier = "unluckyhouse"
    
    var unluckyhouseList = [UnLuckyHouse]()
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        originalMapFrame = mapView.constraints
        locationManager.delegate = self
        //kCLLocationAccuracyHundredMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        mapView.delegate = self
        
        unluckyhouseList = Dao.shared.queryData()
        
        //        for house in unluckyhouseList {
        //            print("\(house.id) = lng: \(house.lng), lat: \(house.lat)")
        //        }
        mapView.addAnnotations(unluckyhouseList)
        //        let overlays = unluckyhouseList.map { MKCircle(center: $0.coordinate, radius: 100) }
        //        mapView.addOverlays(overlays)
        //
        //
        //        // TAP Gesture
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapviewTapped))
        mapView.addGestureRecognizer(tapGesture)
        mapView.isUserInteractionEnabled = true
        //
    }
    
    @objc func mapviewTapped(_ sender: UITapGestureRecognizer) {
        
        let tapPoint = sender.location(in: self.mapView)
        
        let v: UIView? = mapView.hitTest(tapPoint, with: nil)
        if let annotationView = v {
            if !annotationView.isKind(of: MKAnnotationView.self) && !isFullScreen{
                UIView.animate(withDuration: 0.7, animations: {
                    //                    self.mapView.translatesAutoresizingMaskIntoConstraints = false
                    self.mapViewHeightConstraint.isActive = false
                    self.mapViewEqualHeightConstraint.isActive = true
                    
                })
                isFullScreen = !isFullScreen
                controlPanelView.isHidden = isFullScreen            }
        }
        //
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    @IBAction func testAction(_ sender: Any) {
        if isFullScreen {
            
            UIView.animate(withDuration: 2.0, animations: {
                //                self.mapView.translatesAutoresizingMaskIntoConstraints = false
                self.mapViewEqualHeightConstraint.isActive = false
                self.mapViewHeightConstraint.isActive = true
                
            })
            isFullScreen = !isFullScreen
            controlPanelView.isHidden = isFullScreen
        }
        //        else {
        //            UIView.animate(withDuration: 1.0, animations: {
        //                self.mapView.translatesAutoresizingMaskIntoConstraints = false
        //             self.mapViewHeightConstraint.isActive = false
        //                self.mapViewEqualHeightConstraint.isActive = true
        //            })
        //        }
        
    }
    
}

extension MapViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //        let address = "台北市萬華區"
        //        var coordinate: CLLocationCoordinate2D?
        //        let geoCoder = CLGeocoder()
        //        DispatchQueue.main.async {
        //
        //            geoCoder.geocodeAddressString(address) { (placemarks, error) in
        //                guard
        //                    let placemarks = placemarks,
        //                    let location = placemarks.first?.location
        //                    else {
        //                        // handle no location found
        //                        return
        //                }
        //                coordinate = location.coordinate
        //                self.userLocation = location
        //
        //                let span = MKCoordinateSpanMake(0.05, 0.05)
        //                let region = MKCoordinateRegion(center: self.userLocation.coordinate, span: span)
        //                self.mapView.setRegion(region, animated: true)
        //            }
        //        }
        //simulator模擬目前位置
        if let location = locations.first {
            userLocation = location
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)        }
        //
    }
}

extension MapViewController: MKMapViewDelegate {
    // 1
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        mapView.frame = self.mapView.frame
        
        // 2
        guard let annotation = annotation as? UnLuckyHouse else { return nil }
        // 3
        var view: MKAnnotationView
        // 4
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            dequeuedView.annotation = annotation
            view = dequeuedView
            view.isHidden = true
            deq += 1
        } else {
            // 5
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.image = UIImage(named: "ghost")
            view.isHidden = true
            //            let transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            //            view.transform = transform
            
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! UnLuckyHouse
        //        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps()
    }
    
    //    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    //        let renderer = MKCircleRenderer(overlay: overlay)
    //        renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
    //        renderer.strokeColor = UIColor.blue
    //        renderer.lineWidth = 2
    //        return renderer
    //    }
    
    
}

