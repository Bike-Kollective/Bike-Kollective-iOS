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
import Foundation
import MapKit
import CoreLocation

class ProfileViewController: UIViewController {

    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var memberSince: UILabel!
    @IBOutlet weak var userLocation: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the user information - set name, memberSince and profile photo
        let firebaseUser = Auth.auth().currentUser
        
        guard
            let userId = firebaseUser?.uid,
            let name = firebaseUser?.displayName,
            let dateJoined = firebaseUser?.metadata.creationDate,
            let profilePicURL = firebaseUser?.photoURL
        else { return }
        // Do any additional setup after loading the view.
        displayUserInfo(userId: userId, name: name, dateJoined: dateJoined, profilePicUrl: profilePicURL)
        
        
    }
    @IBAction func parkBike(_ sender: Any) {
        
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
