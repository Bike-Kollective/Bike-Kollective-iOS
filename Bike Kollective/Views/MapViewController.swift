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
    
    private func setLocation() {
        currentLocation = CLLocation(latitude: 41.8781, longitude: 87.6298)
        if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
            currentLocation = locationManager.location ?? CLLocation(latitude: 41.8781, longitude: 87.6298)
            print("Coords: \(String(describing: currentLocation))")
        }
        let region = MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 1609 * 20, longitudinalMeters: 1609 * 20)
        bikeMap.setRegion(region, animated: true)
    }

    
    private func loadData() {
        db.collection("Bikes").whereField("checked_out", isEqualTo: false).getDocuments() {
            (query, err) in
                            if let err = err {
                                print("Error getting documents: \(err)")
                            } else {
                                self.bikes = [MKbike]()
                                for doc in query!.documents {
                                    let data = doc.data()
                                    var locale = CLLocation()
                                    if let coords = data["location"] {
                                                    let point = coords as! GeoPoint
                                                    locale = CLLocation(latitude: point.latitude, longitude: point.longitude)
                                                    let distance: Double = self.currentLocation.distance(from: locale)
                                                    let milesAway: Double = round((distance / 1609.3) * 10) / 10.0
                                                    if milesAway <= 25.0 {
                                                        let bike = Bike(name: doc.documentID, make: data["make"] as! String, model: data["model"] as! String, rating: data["rating"] as! [Int], tags: data["tags"] as! [String], comments: data["comments"] as! [String], location: locale, distance: milesAway, imageUrl: data["imageURL"] as! String, bike_lock_code: data["bike_lock_code"] as! String)
                                                        let bikeMK = MKbike(bike: bike, coordinate: locale.coordinate)
                                                        self.bikes.append(bikeMK)
                                                    }
                                                }
                                }
                                self.bikeMap.addAnnotations(self.bikes)
                            }
        }
    }
    
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
                let region = MKCoordinateRegion(center: self.currentLocation.coordinate, latitudinalMeters: 1609 * 16, longitudinalMeters: 1609 * 16)
                self.bikeMap.setRegion(region, animated: true)
                self.loadData()
            }
        }
        self.mapSearchBar.showsCancelButton = false
        self.mapSearchBar.resignFirstResponder()
    }
    
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
