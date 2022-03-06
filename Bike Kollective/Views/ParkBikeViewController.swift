//
//  ParkBikeViewController.swift
//  Bike Kollective
//
//  Created by Kiwon Nam on 20223/3/.
//

import UIKit
import Firebase
import FirebaseFirestore
import Cosmos
import UserNotifications

class ParkBikeViewController: UIViewController {

    @IBOutlet weak var ratingStars: CosmosView!
    @IBOutlet weak var comments: UITextView!
    
    var db:Firestore!
    var bikeId: String = ""
    var userId: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var comment: String = ""
    var bikeRating: Double!
    let notificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("bikeId \(bikeId)")
        print("userId \(userId)")
        // connect to firebase
        db = Firestore.firestore()
        
        comments.layer.borderWidth = 0.5
        comments.layer.borderColor = UIColor.black.cgColor
        
        // gets the rating value when the user
        ratingStars.didFinishTouchingCosmos = { rating in
            self.bikeRating = rating
            print(self.bikeRating!)
        }
        
        
    }
    
    @IBAction func returnBike(_ sender: Any) {
        // dimiss the view controller, thus going back profile view controller
        self.dismiss(animated: true, completion: nil)
        
        self.comment = comments.text ?? ""
        // remove any scheduled local notification reminders about parking the bike
        notificationCenter.removeAllPendingNotificationRequests()
        // make sure to update the bike's fields
        updateBikeDetails(bikeId: self.bikeId, comment: self.comment, bikeRating: self.bikeRating, lat: self.latitude, lon: self.longitude)
        // make sure to update the user's bike related fields
        updateUserBikeFields(userId: self.userId)
        // now go back to provfile view
        goToTabViewController()
        
    }
    
    // function that will update the user's bike related fields, such hasBike to false, and deleting the checked_out_bike and time_checked_out fields
    private func updateUserBikeFields(userId: String) -> Void {
        let userRef = db.collection("Users").document(userId)
        userRef.updateData(["checked_out_bike": FieldValue.delete(), "time_checked_out": FieldValue.delete(), "hasBike": false])
    }
    
    // function that will update bike
    private func updateBikeDetails(bikeId: String, comment: String, bikeRating: Double, lat: Double, lon: Double) -> Void {
        let bikeRef = db.collection("Bikes").document(bikeId)
        var commentArray = [String]()
        var ratingArray = [Double]()
        let loc = GeoPoint(latitude: lat, longitude: lon)
        
        bikeRef.getDocument { (document, error) in
            if let document = document, document.exists {
                ratingArray = document.get("rating") as! Array
                commentArray = document.get("comments") as! Array
                // If the user actually adds a comment
                if comment != "" {
                    commentArray.append(comment)
                }
                ratingArray.append(bikeRating)
                bikeRef.updateData(["checked_out": false, "rating": ratingArray, "comments": commentArray, "location": loc])
            } else {
                print("error in getting bike document! \(String(describing: error))")
            }
        }
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
