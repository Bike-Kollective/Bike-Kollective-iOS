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

struct Bike {
    let name: String
    let make: String
    let model: String
    let rating: [Int]
    let tags: [String]
    let location: CLLocation
}

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
     

    @IBOutlet weak var listView: UITableView!
    
    var db: Firestore!
    var bikes = [Bike]()
    var locationManager : CLLocationManager?
    var currentLocation : CLLocation?
    var storage : Storage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Connects Table View and Data Source to View Controller
        listView.delegate = self
        listView.dataSource = self
        // Do any additional setup after loading the view.
        db = Firestore.firestore()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        storage = Storage.storage()
        loadData()
    }

    private func loadData() {
        db.collection("Bikes").whereField("checked_out", isEqualTo: false).getDocuments() {
            (query, err) in
                            if let err = err {
                                print("Error getting documents: \(err)")
                            } else {
                                for doc in query!.documents {
                                    let data = doc.data()
                                    var locale = CLLocation()
                                    if let coords = data["location"] {
                                                    let point = coords as! GeoPoint
                                                    locale = CLLocation(latitude: point.latitude, longitude: point.longitude)
                                                }
                                    let bike = Bike(name: doc.documentID, make: data["make"] as! String, model: data["model"] as! String, rating: data["rating"] as! [Int], tags: data["tags"] as! [String], location: locale)
                                    self.bikes.append(bike)
                                }
                                self.listView.reloadData()
                            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            currentLocation = manager.location
        default:
            return
        }
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bikes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = listView.dequeueReusableCell(withIdentifier: "BikeCell") as! BikeCell
        let item = bikes[indexPath.row]
        cell.modelLabel.text = "\(item.make) \(item.model)"
        cell.tagsLabel.text = item.tags.joined(separator: ", ")
        var curAddress : String = ""
        let ceo : CLGeocoder = CLGeocoder()
        ceo.reverseGeocodeLocation(item.location, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]

                if pm.count > 0 {
                    let pm = placemarks![0]
                    let town = pm.locality!
                    curAddress = curAddress + town
                    cell.distanceLabel.text = curAddress
              }
        })
        storage!.reference(forURL: "gs://bike-kollective-cs467.appspot.com/bikes/aPt0uIVDdhcHQzJgnVLm.jpg").getData(maxSize: 1048576, completion: { (data, error) in

            guard let imageData = data, error == nil else {
                return
            }
            cell.picView.image = UIImage(data: imageData)

        })
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
