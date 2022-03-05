//
//  ProfileViewController.swift
//  Bike Kollective
//
//  Created by Born4Film on 1/18/22.
//

import UIKit
import Alamofire
import AlamofireImage
import FirebaseAuth
import FirebaseFirestore
import Foundation
import MapKit
import CoreLocation

class ProfileViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var memberSince: UILabel!
    @IBOutlet weak var userLocation: MKMapView!
    @IBOutlet weak var borrowedBike: UIStackView!
    @IBOutlet weak var bikePhoto: UIImageView!
    
    var db: Firestore!
    var hasBike: Bool = false
    var bikeId: String = ""
    var userId: String = ""
    var locationManager = CLLocationManager()
    // set default location to Chicago... but as we know, this app needs location services to work properly
    var currentLatitude: Double = 41.8789
    var currentLongitude: Double = 87.6359
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // connect to firebase
        let db = Firestore.firestore()
        
        // get the user information - set name, memberSince and profile photo
        let firebaseUser = Auth.auth().currentUser
        guard
            let userId = firebaseUser?.uid,
            let name = firebaseUser?.displayName,
            let dateJoined = firebaseUser?.metadata.creationDate,
            let profilePicURL = firebaseUser?.photoURL
        else { return }
        
        // MARK: Show profile information
        self.displayUserInfo(userId: userId, name: name, dateJoined: dateJoined, profilePicUrl: profilePicURL)
        // Set up location services
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // MARK: SHOW ANY BORROW BIKE INFOMRATION - BASED ON IF THEY HAVE A BIKE BORROWED OR NOT
        let userRef = db.collection("Users").document(userId)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.hasBike = document.get("hasBike") as! Bool
                // MARK: Show bike info - if user has a bike
                if self.hasBike {
                    // TODO: - show bike information
                    // display bike data
                    self.bikeId = document.get("checked_out_bike") as! String
                    print(self.bikeId)
                    self.userId = userId
                    self.displayBikeData(bikeId: self.bikeId, db: db)
                    self.borrowedBike.arrangedSubviews[1].isHidden = true  // go to bikes reminder
                    self.borrowedBike.arrangedSubviews[2].isHidden = false // Bike Picture
                    self.borrowedBike.arrangedSubviews[3].isHidden = false // Time Due
                    self.borrowedBike.arrangedSubviews[4].isHidden = false // Park Bike button
                    
                } else {
                    // TODO: - show something that tell's user to go to list view for bikes
                    self.borrowedBike.arrangedSubviews[1].isHidden = false
                    self.borrowedBike.arrangedSubviews[2].isHidden = true
                    self.borrowedBike.arrangedSubviews[3].isHidden = true
                    self.borrowedBike.arrangedSubviews[4].isHidden = true
                }
            }
        }
        
        
    }
    
    // using CLLocationManagerDelegate method to get user's current lcoation and coordiate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            print("no location")
            return 
        }
        
        self.currentLatitude = location.coordinate.latitude
        self.currentLongitude = location.coordinate.longitude
        
        displayUserLocation(latitude: self.currentLatitude, longitude: self.currentLongitude)
    }
    
    // gets the user location to display on the map
    private func displayUserLocation(latitude: Double, longitude: Double) -> Void{
        let locationMarker = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let mapAnnotation = MKPointAnnotation()
        mapAnnotation.coordinate = locationMarker
        userLocation.addAnnotation(mapAnnotation)
        
        let center = CLLocation(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: center.coordinate,  latitudinalMeters: 500, longitudinalMeters: 500)
        userLocation.setRegion(region, animated: false)
        
    }
    
    private func displayBikeData(bikeId: String, db: Firestore) -> Void {
        print("bikeid: \(bikeId)")
        let bikeRef = db.collection("Bikes").document(bikeId)
        
    
    }
    
    
    
    private func displayUserInfo(userId: String, name: String, dateJoined: Date, profilePicUrl: URL) {
        // format the firebase date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YYYY"
        // display the user's name, membership date and photo
        fullName.text = name
        memberSince.text = dateFormatter.string(from: dateJoined)
        profilePhoto.af.setImage(withURL: profilePicUrl, filter: RoundedCornersFilter(radius: 15.0))
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let currentBikeId = self.bikeId
        let currentUserId = self.userId
        
        let parkBikeVC = segue.destination as! ParkBikeViewController
        parkBikeVC.bikeId = currentBikeId
        parkBikeVC.userId = currentUserId
    }
    
}
