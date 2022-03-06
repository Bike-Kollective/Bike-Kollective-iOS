//
//  AccidentWaiverViewController.swift
//  Bike Kollective
//
//  Created by Kiwon Nam on 2/22/22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift
import GoogleSignIn

class AccidentWaiverViewController: UIViewController {

    var signedWaiver: Bool = false
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // connect to Firestore
        db = Firestore.firestore()
    }
    
    @IBAction func acceptTerms(_ sender: Any) {
        let firebaseUser = Auth.auth().currentUser
        guard
            let userId = firebaseUser?.uid,
            let email = firebaseUser?.email
        else { return }
        
        let newUser = User(
            email: email,
            signedWaiver: true,
            isBanned: false,
            hasBike: false,
            bikeId: nil)
        // add the user
        addUserToDatabase(userId: userId, newUser: newUser)
        // now go to the main page
        goToTabViewController()
    }
    
    // if the user decides to reject the accident waiver form
    // sign them out and send them back to login page
    @IBAction func rejectTerms(_ sender: Any) {
        // sign out of google
        GIDSignIn.sharedInstance.signOut()
        // sign out of firebase
        let firebaseSignOut = Auth.auth()
        do {
            try firebaseSignOut.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
        
        // to the log in screen
        goToLoginView()
        
    }
    // adds user to database
    private func addUserToDatabase(userId: String, newUser: User) -> Void {
        do {
            try db.collection("Users").document(userId).setData(from: newUser)
        } catch let error {
            print("ERROR WRITING NEW USER TO COLLECTION: \(error)")
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
