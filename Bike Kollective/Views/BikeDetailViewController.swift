//
//  BikeDetailViewController.swift
//  Bike Kollective
//
//  Created by Born4Film on 1/18/22.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseFirestore
import UserNotifications

class BikeDetailViewController: UIViewController {

    var bike: Bike!
    let notificationCenter = UNUserNotificationCenter.current()
    
    @IBOutlet weak var bikeImage: BikeImageView!
    @IBOutlet weak var bikeMake: UILabel!
    @IBOutlet weak var bikeModel: UILabel!
    @IBOutlet weak var bikeRating: UIImageView!
    @IBOutlet weak var bikeTags: UILabel!
    @IBOutlet weak var bikeMapLocation: MKMapView!
    @IBOutlet weak var bikeCommentTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Dislpay the bikes image.
        if let imageURL = URL(string: bike.imageUrl) {
            bikeImage.loadImage(from: imageURL)
        }
        
        // Display the bike make and model.
        bikeMake.text = bike.make
        bikeModel.text = bike.model
        
        // Display the bikes rating.
        bikeRating.image = getBikeRating()
     
        // Display the bikes tags.
        bikeTags.text = getBikeTags()
        
        // Display the bikes location
        getMapLocation()
        
        // Set up the comment table view
        bikeCommentTableView.dataSource = self
        
    }
    
    // Get the bike average bike rating and return the corrisponding image
    func getBikeRating() -> UIImage {

        let avgRating : Double
        var sum = 0
        
        // Sum up the total ratings for bikes in the rating array.
        for bikes in bike.rating {
            sum += bikes
        }
        
        // Get the average rating of the bikes.
        if bike.rating.count != 0 {
            avgRating = Double(sum / bike.rating.count)
        }
        else {
            avgRating = 0
        }
        
        // Find and return the correct image.
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
    
    func getBikeTags() -> String {
        
        // Display the bike tags.  Only display 5
        if bike.tags.count > 5 {
            var count = 0
            var bikeTagString = ""
            for tag in bike.tags {
                print(tag)
                if count < 5 {
                    if count < 4 {
                        bikeTagString += "\(tag), "
                    }
                    else {
                        bikeTagString += "\(tag)"
                    }
                }
                count += 1
            }
            return bikeTagString
        }
        else {
            return bike.tags.joined(separator: ", ")
        }
    }
    
    func getMapLocation() {
        
        // set up the location of the bike and display it on the map.
        let displayLocation = MKPointAnnotation()
        displayLocation.coordinate = CLLocationCoordinate2D(latitude: bike.location.coordinate.latitude, longitude: bike.location.coordinate.longitude)
        bikeMapLocation.addAnnotation(displayLocation)
        
        // Zoom in closer on the map.
        let bikeLocationLatLong = CLLocation(latitude: bike.location.coordinate.latitude, longitude: bike.location.coordinate.longitude)
        let mapZoom = MKCoordinateRegion(center: bikeLocationLatLong.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        bikeMapLocation.setRegion(mapZoom, animated: true)

    }
    
    
    @IBAction func borrowTapped(_ sender: Any) {
        
        // get the current user.
        let firebaseUser = Auth.auth().currentUser
        
        // Connect to firestore database
        let database = Firestore.firestore()

        let userReference = database.collection("Users").document(firebaseUser!.uid)

        userReference.getDocument { (document, error) in
            if let document = document, document.exists {

                // Check to see if the user already has checked out a bike
                if (document.get("checked_out_bike") != nil) {

                    self.userAlreadyHasBikeCheckedOutAlert()
                }
                else {
                    // get the current time and date to save in firestore.
                    let currentTimeStamp = NSDate().timeIntervalSince1970
                    let timeInterval = TimeInterval(currentTimeStamp)
                    let time = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                    
                    // Mark bike as checked out.
                    database.collection("Bikes").document(self.bike.name).updateData([
                        "checked_out": true]) {
                        error in if let error = error {
                            print("ERROR: \(error)")
                        } else {
                            print("Bike successfuly checked out")
                        }
                    }
                    
                    // Save bike ID and check out time to user
                    database.collection("Users").document(firebaseUser!.uid).updateData([
                        "checked_out_bike": self.bike.name,
                        "hasBike": true,
                        "time_checked_out": time]) {
                                error in if let error = error {
                                    print("ERROR: \(error)")
                                } else {
                                    print("Bike added to the user collection")
                                    // give the user the bike lock code
                                    self.bikeCheckOutSuccessAlert(bikeLockCode: self.bike.bike_lock_code)
                                    
                                }
                            }
                }
            }
        }
    }
    
    func bikeCheckOutSuccessAlert(bikeLockCode: String) {
        //Create the success alert message to pop up.
        let successAlert = UIAlertController(title: "Success", message: "Bike Lock Code: \(bikeLockCode) ", preferredStyle: UIAlertController.Style.alert)
        
        //Create the button to get rid of the alert.
        successAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        //Present the alert to the user.
        self.present(successAlert, animated: true, completion: nil)
    }
    
    func userAlreadyHasBikeCheckedOutAlert() {
        //Create the success alert message to pop up.
        let failureAlert = UIAlertController(title: "Failure", message: "You cannot check out another bike until you return the last one.", preferredStyle: UIAlertController.Style.alert)
        
        //Create the button to get rid of the alert.
        failureAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        //Present the alert to the user.
        self.present(failureAlert, animated: true, completion: nil)
    }
    
    
}

extension BikeDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Check to see if there are comments.  If there are display that many cells.  If not
        // display one cell.
        if bike.comments.count > 0 {
            return bike.comments.count
        }
        else {
            return 1
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Check to see if there are any comments and if yes display them.  If not display no comments.
        if bike.comments.count > 0 {
            let commentCell = tableView.dequeueReusableCell(withIdentifier: "Comment_Cell", for: indexPath)
            commentCell.textLabel?.text = bike.comments[indexPath.row]
            return commentCell
        }
        else {
            let commentCell = tableView.dequeueReusableCell(withIdentifier: "Comment_Cell", for: indexPath)
            commentCell.textLabel?.text = "No Comments"
            return commentCell
        }
    }
}
