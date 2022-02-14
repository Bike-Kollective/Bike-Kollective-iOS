//
//  ListViewController.swift
//  Bike Kollective
//
//  Created by Born4Film on 1/18/22.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseStorage
import AlamofireImage
import MapKit

struct Bike {
    let name: String
    let make: String
    let model: String
    let rating: [Int]
    let tags: [String]
    let location: CLLocation
    let imageUrl: String
}

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UISearchBarDelegate {
     


    @IBOutlet weak var bikeSearchBar: UISearchBar!
    @IBOutlet weak var listView: UITableView!
    
    var db: Firestore!
    var bikes = [Bike]()
    var locationManager : CLLocationManager?
    var currentLocation : CLLocation?
    var storage : Storage?
    let refreshment = UIRefreshControl()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Connects Table View and Data Source to View Controller
        listView.delegate = self
        listView.dataSource = self
        // Connects Search Bar to View Controller
        bikeSearchBar.delegate = self
        // Ensures Table View Cells don't overlap with search bar
        listView.contentInset = UIEdgeInsets(top: 41, left: 0, bottom: 0, right: 0)
        // Connects to Firestore database
        db = Firestore.firestore()
        // Connects location services
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        // Gets authorization for user's location
        locationManager?.requestWhenInUseAuthorization()
        if locationManager?.authorizationStatus == .authorizedWhenInUse {
            locationManager?.startUpdatingLocation()
            currentLocation = locationManager?.location
            print("Coords: \(String(describing: currentLocation))")
        }
        else if locationManager?.authorizationStatus == .authorizedAlways {
            locationManager?.startUpdatingLocation()
            currentLocation = locationManager?.location
            print("Coords: \(String(describing: currentLocation))")
        } else {
            currentLocation = CLLocation(latitude: 41.8781, longitude: 87.6298)
        }
        // Connects to Firebase storage for images
        storage = Storage.storage()
        // Loads bike data
        loadData()
        // Sets up pull down to refresh ability
        refreshment.addTarget(self, action: #selector(refresher), for: .valueChanged)
        refreshment.attributedTitle = NSAttributedString(string: "Pull to refresh")
        listView.refreshControl = refreshment
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadData()
    }
    
    @objc func refresher() {
        self.bikeSearchBar.text = ""
        if locationManager?.authorizationStatus == .authorizedWhenInUse {
            locationManager?.startUpdatingLocation()
            currentLocation = locationManager?.location
            print("Coords: \(String(describing: currentLocation))")
        }
        else if locationManager?.authorizationStatus == .authorizedAlways {
            locationManager?.startUpdatingLocation()
            currentLocation = locationManager?.location
            print("Coords: \(String(describing: currentLocation))")
        } else {
            currentLocation = CLLocation(latitude: 41.8781, longitude: 87.6298)
        }
        loadData()
    }

    
    private func loadData() {
        db.collection("Bikes").whereField("checked_out", isEqualTo: false).getDocuments() {
            (query, err) in
                            if let err = err {
                                print("Error getting documents: \(err)")
                            } else {
                                self.bikes = [Bike]()
                                for doc in query!.documents {
                                    let data = doc.data()
                                    var locale = CLLocation()
                                    if let coords = data["location"] {
                                                    let point = coords as! GeoPoint
                                                    locale = CLLocation(latitude: point.latitude, longitude: point.longitude)
                                                }
                                    let bike = Bike(name: doc.documentID, make: data["make"] as! String, model: data["model"] as! String, rating: data["rating"] as! [Int], tags: data["tags"] as! [String], location: locale, imageUrl: data["imageURL"] as! String)
                                    self.bikes.append(bike)
                                }
                                self.listView.reloadData()
                                self.refreshment.endRefreshing()
                            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.bikeSearchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.bikeSearchBar.showsCancelButton = false
        self.bikeSearchBar.text = ""
        self.bikeSearchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let address = self.bikeSearchBar.text {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(address) { (placemarks, error) in
                if error != nil {
                    return
                }
                let placemarks = placemarks
                let location = placemarks?.first?.location
                self.currentLocation = location
                self.loadData()
                self.listView.reloadData()
            }
        }
        self.bikeSearchBar.showsCancelButton = false
        self.bikeSearchBar.resignFirstResponder()
    }
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bikes.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = listView.dequeueReusableCell(withIdentifier: "BikeCell") as! BikeCell
        let item = bikes[indexPath.row]
        cell.modelLabel.text = "\(item.make) \(item.model)"
        cell.tagsLabel.text = item.tags.joined(separator: ", ")
        let distance = currentLocation?.distance(from: item.location) ?? 160900
        let milesAway = round((distance / 1609) * 10) / 10.0
        cell.distanceLabel.text = "\(milesAway)mi. away"
        let url = URL(string: item.imageUrl)!
        cell.picView.af.setImage(withURL: url)
        let sumRating = item.rating.reduce(0, +)
        let avgRating : Double
        if sumRating == 0 {
           avgRating = 0
        } else {
            avgRating = Double(sumRating / item.rating.count)
        }
        switch avgRating {
        case 0..<0.5:
            cell.ratingView.image = UIImage(named: "regular_0")
        case 0.5..<1.25:
            cell.ratingView.image = UIImage(named: "regular_1")
        case 1.25..<1.75:
            cell.ratingView.image = UIImage(named: "regular_1_half")
        case 1.75..<2.25:
            cell.ratingView.image = UIImage(named: "regular_2")
        case 2.25..<2.75:
            cell.ratingView.image = UIImage(named: "regular_2_half")
        case 2.75..<3.25:
            cell.ratingView.image = UIImage(named: "regular_3")
        case 3.25..<3.75:
            cell.ratingView.image = UIImage(named: "regular_3_half")
        case 3.75..<4.2:
            cell.ratingView.image = UIImage(named: "regular_4")
        case 4.2..<4.6:
            cell.ratingView.image = UIImage(named: "regular_4_half")
        default:
            cell.ratingView.image = UIImage(named: "regular_5")
        }
        return cell
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
