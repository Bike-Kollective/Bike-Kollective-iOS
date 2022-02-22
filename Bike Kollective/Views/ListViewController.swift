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
import MapKit


class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UISearchBarDelegate {
    

    @IBOutlet weak var bikeSearchBar: UISearchBar!
    @IBOutlet weak var listView: UITableView!
    
    var db: Firestore!
    var bikes = [Bike]()
    var locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var storage : Storage?
    let refreshment = UIRefreshControl()
    let defaults = UserDefaults.standard
    var matchingDocs = [QueryDocumentSnapshot]()
    
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
        locationManager.delegate = self
        // Gets authorization for user's location
        locationManager.requestWhenInUseAuthorization()
        setLocation()
        // Connects to Firebase storage for images
        storage = Storage.storage()
        // Loads bike data
        loadData()
        // Sets up pull down to refresh ability
        refreshment.addTarget(self, action: #selector(refresher), for: .valueChanged)
        refreshment.attributedTitle = NSAttributedString(string: "Pull to refresh")
        listView.refreshControl = refreshment
    }

    // MARK: Data Handling
    
    @objc func refresher() {
        self.bikeSearchBar.text = ""
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
                                                    let distance: Double = self.currentLocation.distance(from: locale)
                                                    let milesAway: Double = round((distance / 1609.3) * 10) / 10.0
                                                    if milesAway <= 25.0 {
                                                        let bike = Bike(name: doc.documentID, make: data["make"] as! String, model: data["model"] as! String, rating: data["rating"] as! [Int], tags: data["tags"] as! [String], location: locale, distance: milesAway, imageUrl: data["imageURL"] as! String)
                                                        self.bikes.append(bike)
                                                    }
                                                }
                                }
                                self.listView.reloadData()
                                self.refreshment.endRefreshing()
                            }
        }
    }
    

    
    // MARK: SearchBar
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.bikeSearchBar.becomeFirstResponder()
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
                self.currentLocation = location ?? self.currentLocation
                self.loadData()
                self.listView.reloadData()
            }
        }
        self.bikeSearchBar.showsCancelButton = false
        self.bikeSearchBar.resignFirstResponder()
    }
    
    // MARK: TableView

    private func getAvgRating(sum: Int, length: Int) -> UIImage {
        let avgRating : Double
        if sum == 0 {
           avgRating = 0
        } else {
            avgRating = Double(sum / length)
        }
        switch avgRating {
        case 0..<0.5:
            return UIImage(named: "regular_0")!
        case 0.5..<1.25:
            return UIImage(named: "regular_1")!
        case 1.25..<1.75:
            return UIImage(named: "regular_1_half")!
        case 1.75..<2.25:
            return UIImage(named: "regular_2")!
        case 2.25..<2.75:
            return UIImage(named: "regular_2_half")!
        case 2.75..<3.25:
            return UIImage(named: "regular_3")!
        case 3.25..<3.75:
            return UIImage(named: "regular_3_half")!
        case 3.75..<4.2:
            return UIImage(named: "regular_4")!
        case 4.2..<4.6:
            return UIImage(named: "regular_4_half")!
        default:
            return UIImage(named: "regular_5")!
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch bikes.count == 0 {
        case true:
            return 1
        case false:
            return bikes.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch bikes.count == 0 {
        case true:
            let cell = listView.dequeueReusableCell(withIdentifier: "emptyCell")!
            return cell
        case false:
            let cell = listView.dequeueReusableCell(withIdentifier: "BikeCell") as! BikeCell
            let item = bikes[indexPath.row]
            cell.modelLabel.text = "\(item.make) \(item.model)"
            cell.tagsLabel.text = item.tags.joined(separator: ", ")
            cell.distanceLabel.text = "\(item.distance)mi. away"
            if let imgUrl = URL(string: item.imageUrl) {
                cell.picView.loadImage(from: imgUrl)
            }
            let sumRating = item.rating.reduce(0, +)
            let rateLength : Int = item.rating.count
            cell.ratingView.image = getAvgRating(sum: sumRating, length: rateLength)
            return cell
        }
        
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if let cell = sender as? UITableViewCell {
            let indexPath = listView.indexPath(for: cell)!
            let bike = bikes[indexPath.row]
            // Pass to Bike Detail View Controller
            let detailView = segue.destination as! BikeDetailViewController

            detailView.bike = bike

            listView.deselectRow(at: indexPath, animated: true)
        }
    }


    

   

}
