//
//  MapViewController.swift
//  parkingMap
//
//  Created by Xie Liwei on 2016/11/5.
//  Copyright © 2016年 Xie Liwei. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate {
    @IBOutlet weak var parkingMap: MKMapView! {
        didSet {
            parkingMap.mapType = .standard
            parkingMap.isPitchEnabled = false
            parkingMap.delegate = self
            
        }
    }
    @IBOutlet weak var detailView: UIView!
    
    var jsonData : [String:Any]?
    var center : CLLocationCoordinate2D?
    var servicePrice : String = "0.00"
    var locationManager : CLLocationManager!
    var parkingPlace : [MKPolygon]?
    var currentZone : String?
    var currentZoneName : String?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var allowedOrNotLabel: UILabel!
    @IBOutlet weak var maxDurationLabel: UILabel!
    @IBOutlet weak var servicePriceLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var providerLabel: UILabel!
    @IBOutlet weak var startParking: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readJson()
        self.locationManager = CLLocationManager()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        self.locationManager.requestWhenInUseAuthorization()
        self.startParking.backgroundColor = UIColor.gray
        self.startParking.layer.cornerRadius = 5
        initTheMap()
        getThePolygonInfo()
        drawTheZonePolygon(polygon: self.parkingPlace!)
    }
    // MARK: - Read the json file
    func readJson() {
        do {
            if let file = Bundle.main.url(forResource: "response", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: Any] {
                    self.jsonData = object
                } else {
                    print("JSON is invalid")
                }
            } else {
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    // MARK: - Load the mapview
    func initTheMap() {
        let myLocation = (self.jsonData?["current_location"] as! String).components(separatedBy: ", ")
        let latitude = Double(myLocation[0])
        let longitude = Double(myLocation[1])
        let myLocationCoordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        self.parkingMap.setCenter(myLocationCoordinate, animated: true)
        let bounds = (self.jsonData?["location_data"] as! NSDictionary).value(forKey: "bounds") as! NSDictionary
        let east = bounds.value(forKey: "east") as! Double
        let west = bounds.value(forKey: "west") as! Double
        let north = bounds.value(forKey: "north") as! Double
        let south = bounds.value(forKey: "south") as! Double
        let region = MKCoordinateRegionMakeWithDistance(myLocationCoordinate, east - west, north - south)
        self.parkingMap.setRegion(region, animated: true)

    }
    // MARK: - Check the permission
    //In case it needs in the furture
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied || status == .restricted {
            let alert = UIAlertController(title: "No Permission" , message: "Cannot get the location", preferredStyle: .alert)
            let openSettings = UIAlertAction(title: "Open settings", style: .default, handler: {
                (action) -> Void in
                let URL = Foundation.URL(string: UIApplicationOpenSettingsURLString)
                UIApplication.shared.open(URL!)
                self.dismiss(animated: true, completion: nil)
            })
            alert.addAction(openSettings)
            alert.view.tintColor = UIColor.black
            present(alert, animated: true, completion: nil)
        } else {
            self.locationManager.startUpdatingLocation()
        }
    }
    // MARK: - Draw the polygons
    func getThePolygonInfo() {
        let zone = (self.jsonData?["location_data"] as! NSDictionary).value(forKey: "zones") as! NSArray
        for i in 0...zone.count-1 {
            let polygonData = (zone[i] as! NSDictionary).value(forKey: "polygon")! as! String
            let polygonPoints = polygonData.components(separatedBy: ", ")
            var polygonPointsCoord : [CLLocationCoordinate2D]?
            for j in 0...polygonPoints.count-1 {
                let point = polygonPoints[j].components(separatedBy: " ") as NSArray
                let latitude = Double(point[0] as! String)
                let longitude = Double(point[1] as! String)
                if polygonPointsCoord == nil {
                    polygonPointsCoord = [CLLocationCoordinate2DMake(latitude!, longitude!)]
                } else {
                    polygonPointsCoord?.append(CLLocationCoordinate2DMake(latitude!, longitude!))
                }
            }
            let polygon = MKPolygon(coordinates: polygonPointsCoord!, count: (polygonPointsCoord?.count)!)
            if self.parkingPlace == nil {
                self.parkingPlace = [polygon]
            } else {
                self.parkingPlace?.append(polygon)
            }
        }
    }
    
    func drawTheZonePolygon(polygon:[MKPolygon]) {
        let zone = (self.jsonData?["location_data"] as! NSDictionary).value(forKey: "zones") as! NSArray
        for i in 0...zone.count-1 {
            let title = (zone[i] as! NSDictionary).value(forKey: "payment_is_allowed")! as! String
            let polygon = self.parkingPlace![i]
            if title == "0" {
                polygon.title = "allowed"
            } else {
                polygon.title = "not allowed"
            }
            parkingMap.add(polygon)
        }
    }
    
    // MARK: - Map pin functions
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polygonView = MKPolygonRenderer(overlay: overlay)
        polygonView.lineWidth = 1
        if overlay.title! == "allowed" {
            polygonView.fillColor = UIColor(red: 217.0 / 255.0, green: 241.0 / 255.0, blue: 165.0 / 255.0, alpha: 0.4)
            polygonView.strokeColor = UIColor(red: 61.0 / 255.0, green: 145.0 / 255.0, blue: 29.0 / 255.0, alpha: 0.7)
        } else if overlay.title! == "not allowed"{
            polygonView.fillColor = UIColor(red: 227.0 / 255.0, green: 105.0 / 255.0, blue: 106.0 / 255.0, alpha: 0.4)
            polygonView.strokeColor = UIColor(red: 227.0 / 255.0, green: 105.0 / 255.0, blue: 106.0 / 255.0, alpha: 0.7)
        } else {
            polygonView.fillColor = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.4)
            polygonView.fillColor = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.7)
        }
        return polygonView
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        parkingMap.removeAnnotations(parkingMap.annotations)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.center = parkingMap.centerCoordinate
        self.detailView.isHidden = true
        self.currentZone = nil
        if self.parkingPlace == nil {
            getThePolygonInfo()
        }
        let zone = (self.jsonData?["location_data"] as! NSDictionary).value(forKey: "zones") as! NSArray
        for i in 0...zone.count-1 {
            let servicePrice = (zone[i] as! NSDictionary).value(forKey: "service_price")! as! String
            let polygon = self.parkingPlace?[i]
            drawTheZonePolygon(polygon: [polygon!])
            if zoneIsSelected(polygon: polygon!) == true {
                self.servicePrice = "The service price here is " + servicePrice
                polygon?.title = "I am here"
                let id = (zone[i] as! NSDictionary).value(forKey: "id") as! String
                let name = (zone[i] as! NSDictionary).value(forKey: "name") as! String
                let isAllowedOrNot = (zone[i] as! NSDictionary).value(forKey: "payment_is_allowed") as! String
                let duration = (zone[i] as! NSDictionary).value(forKey: "max_duration") as! String
                let email = (zone[i] as! NSDictionary).value(forKey: "contact_email") as! String
                let provider = (zone[i] as! NSDictionary).value(forKey: "provider_name") as! String
                self.nameLabel.text = name
                if isAllowedOrNot == "0" {
                self.allowedOrNotLabel.text = "Available"
                } else {
                    self.allowedOrNotLabel.text = "Not Available"
                }
                self.maxDurationLabel.text = "max: " + duration + " mins"
                self.servicePriceLabel.text = servicePrice + " euros / min"
                self.emailLabel.text = email
                self.providerLabel.text = provider
                self.detailView.isHidden = false
                self.detailView.backgroundColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.6)
                self.currentZone = id
                parkingMap.add(polygon!)
                break
            } else {
                self.servicePrice = "Not in the parking place"
            }
        }
        let centerAnnotation = MapPin(title: self.servicePrice, coordinate: self.center!)
        parkingMap.addAnnotation(centerAnnotation)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        view.canShowCallout = true
    }
    
    func zoneIsSelected (polygon: MKPolygon) -> Bool {
        let polygonView = MKPolygonRenderer(polygon: polygon)
        let pinPoint = MKMapPointForCoordinate(self.center!)
        let mapPoint = polygonView.point(for: pinPoint)
        let path = polygonView.path
        let pinIsInTheParkingPlace : Bool = (path?.contains(mapPoint))!
        return pinIsInTheParkingPlace
    }

    // MARK: - Start parking button
    @IBAction func StartParking(_ sender: AnyObject) {
        let zone = (self.jsonData?["location_data"] as! NSDictionary).value(forKey: "zones") as! NSArray
        for i in zone {
            if (i as! NSDictionary).value(forKey: "id") as? String == self.currentZone {
                let isAllowed = (i as! NSDictionary).value(forKey: "payment_is_allowed") as? String
                if self.startParking.currentTitle == "Start" {
                    if isAllowed == "0" {
                        self.currentZoneName = self.nameLabel.text!
                        let alert = UIAlertController(title: "Start parking", message: "Start parking at " + self.currentZoneName! + " ?", preferredStyle: .alert)
                        let cancle = UIAlertAction(title: "Cancle", style: .cancel)
                        let yes = UIAlertAction(title: "Yes", style: .default) {
                            (UIAlertAction) -> Void in
                            self.startParking.setTitle("Stop", for: .normal)
                        }
                        alert.addAction(cancle)
                        alert.addAction(yes)
                        self.present(alert, animated: true, completion: nil)
                    } else if isAllowed == "1" {
                        let alert = UIAlertController(title: "Oops", message: "Sorry! This zone is not available, please choose another one!", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .cancel)
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } else if self.currentZone == nil {
                if self.startParking.currentTitle == "Start" {
                    let alert = UIAlertController(title: "Oops", message: "Please select a zone", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .cancel)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        if self.startParking.currentTitle == "Stop" {
            let alert = UIAlertController(title: "Stop parking", message: "You are parking at " + self.currentZoneName! + " ! Do you want to stop parking?", preferredStyle: .alert)
            let cancle = UIAlertAction(title: "Cancle", style: .cancel)
            let ok = UIAlertAction(title: "OK", style: .default) {
                (UIAlertAction) -> Void in
                self.startParking.setTitle("Start", for: .normal)
            }
            alert.addAction(ok)
            alert.addAction(cancle)
            self.present(alert, animated: true, completion: nil)
        }

    }
    
}




