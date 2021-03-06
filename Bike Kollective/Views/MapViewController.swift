//
//  MapViewController.swift
//  Bike Kollective
//
//  Created by Born4Film on 1/18/22.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import AlamofireImage

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var mapSearchBar: UISearchBar!
    @IBOutlet weak var bikeMap: MKMapView!
    
    var db: Firestore!
    var bikes = [MKbike]()
    var locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var storage : Storage?
    let refreshment = UIRefreshControl()
    let defaults = UserDefaults.standard
    var matchingDocs = [QueryDocumentSnapshot]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bikeMap.delegate = self
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        mapSearchBar.delegate = self
        db = Firestore.firestore()
        locationManager.requestWhenInUseAuthorization()
        storage = Storage.storage()
        setLocation()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    // MARK: Data Handling
    
    private func setLocation() {
        let radius = defaults.integer(forKey: "distance") == 0 ? 15.0 : Double(defaults.integer(forKey: "distance"))
        let measure = defaults.integer(forKey: "measure") == 0 ? 1609.3 : 1000.0
        currentLocation = CLLocation(latitude: 41.8781, longitude: 87.6298)
        if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
            currentLocation = locationManager.location ?? CLLocation(latitude: 41.8781, longitude: 87.6298)
            print("Coords: \(String(describing: currentLocation))")
        }
        let region = MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: measure * radius * 2, longitudinalMeters: measure * radius * 2)
        bikeMap.setRegion(region, animated: true)
        let cameraRegion = MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: measure * radius * 5, longitudinalMeters: measure * radius * 6)
        bikeMap.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: cameraRegion), animated: true)
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: measure * radius * 10)
        bikeMap.setCameraZoomRange(zoomRange, animated: true)
    }

    
    private func loadData() {
        var tag: String
        if (defaults.string(forKey: "tag") != nil) && defaults.string(forKey:"tag") != "Choose..." {
            tag = defaults.string(forKey: "tag")!
        } else {
            tag = ""
        }
        let radius = defaults.integer(forKey: "distance") == 0 ? 15.0 : Double(defaults.integer(forKey: "distance"))
        let measure = defaults.integer(forKey: "measure") == 0 ? 1609.3 : 1000.0
        self.bikeMap.removeAnnotations(bikeMap.annotations)
        db.collection("Bikes").whereField("checked_out", isEqualTo: false).getDocuments() {
            (query, err) in
                            if let err = err {
                                print("Error getting documents: \(err)")
                            } else {
                                self.bikes = [MKbike]()
                                if tag == "" {
                                    for doc in query!.documents {
                                        let data = doc.data()
                                        var locale = CLLocation()
                                        if let coords = data["location"] {
                                            let point = coords as! GeoPoint
                                            locale = CLLocation(latitude: point.latitude, longitude: point.longitude)
                                            let distance: Double = self.currentLocation.distance(from: locale)
                                            let milesAway: Double = round((distance / measure) * 10) / 10.0
                                            if milesAway <= radius {
                                                let bike = Bike(name: doc.documentID, make: data["make"] as! String, model: data["model"] as! String, rating: data["rating"] as! [Int], tags: data["tags"] as! [String], comments: data["comments"] as! [String], location: locale, distance: milesAway, imageUrl: data["imageURL"] as! String, bike_lock_code: data["bike_lock_code"] as! String)
                                                let bikeMK = MKbike(bike: bike, coordinate: locale.coordinate)
                                                self.bikes.append(bikeMK)
                                            }
                                        }
                                    }
                                } else {
                                    for doc in query!.documents {
                                        let data = doc.data()
                                        var locale = CLLocation()
                                        if let coords = data["location"] {
                                            let point = coords as! GeoPoint
                                            locale = CLLocation(latitude: point.latitude, longitude: point.longitude)
                                            let distance: Double = self.currentLocation.distance(from: locale)
                                            let milesAway: Double = round((distance / measure) * 10) / 10.0
                                            let tags = data["tags"] as! [String]
                                            if milesAway <= radius && tags.contains(tag) {
                                                let bike = Bike(name: doc.documentID, make: data["make"] as! String, model: data["model"] as! String, rating: data["rating"] as! [Int], tags: data["tags"] as! [String], comments: data["comments"] as! [String], location: locale, distance: milesAway, imageUrl: data["imageURL"] as! String, bike_lock_code: data["bike_lock_code"] as! String)
                                                let bikeMK = MKbike(bike: bike, coordinate: locale.coordinate)
                                                self.bikes.append(bikeMK)
                                            }
                                        }
                                    }
                                }
                                self.bikeMap.addAnnotations(self.bikes)
                            }
        }
    }
    
    // MARK: Search Bar
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.mapSearchBar.becomeFirstResponder()
        self.mapSearchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.mapSearchBar.showsCancelButton = false
        self.mapSearchBar.text = ""
        self.mapSearchBar.resignFirstResponder()
        self.setLocation()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let radius = defaults.integer(forKey: "distance") == 0 ? 15.0 : Double(defaults.integer(forKey: "distance"))
        let measure = defaults.integer(forKey: "measure") == 0 ? 1609.3 : 1000.0
        if let address = self.mapSearchBar.text {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(address) {(placemarks, error) in
                if error != nil {
                    return
                }
                let placemarks = placemarks
                let location = placemarks?.first?.location
                self.currentLocation = location ?? self.currentLocation
                self.bikeMap.delegate = self
                let region = MKCoordinateRegion(center: self.currentLocation.coordinate, latitudinalMeters: measure * radius * 2, longitudinalMeters: measure * radius * 2)
                let cameraRegion = MKCoordinateRegion(center: self.currentLocation.coordinate, latitudinalMeters: measure * radius * 5, longitudinalMeters: measure * radius * 6)
                let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: measure * radius * 10)
                self.bikeMap.setCameraZoomRange(zoomRange, animated: true)
                self.bikeMap.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: cameraRegion), animated: true)
                self.bikeMap.setRegion(region, animated: true)
                self.loadData()
            }
        }
        self.mapSearchBar.showsCancelButton = false
        self.mapSearchBar.resignFirstResponder()
    }
    
    // MARK: Map
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MKbike else { return nil }
        
        let identifier = "mkbike"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            
        } else {
            annotationView?.annotation = annotation
        }
        
        let btn = UIButton(type: .detailDisclosure)
        annotationView?.rightCalloutAccessoryView = btn
        annotationView?.glyphImage = UIImage(systemName: "bicycle")
        annotationView?.displayPriority = .required
        
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let mkbike = view.annotation as? MKbike else { return }
        let bike = mkbike.bike
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "BikeDetailViewController") as! BikeDetailViewController
        detailVC.bike = bike
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    @IBAction func refreshMap(_ sender: Any) {
        bikeMap.delegate = self
        setLocation()
        loadData()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
