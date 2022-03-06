//
//  SettingViewController.swift
//  Bike Kollective
//
//  Created by Kiwon Nam on 2/6/22.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

class SettingViewController: UIViewController {

    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // connect to Firestore
        db = Firestore.firestore()
    }
    
    // signs out the user from the app and takes them back to the login page
    @IBAction func signOut(_ sender: Any) {
        // create action buttons for alert
        let signOutAction = UIAlertAction(title: "Sign Out", style: .default) { (action) in
            // sign out of google account
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
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("Cancel")
        }
        
        let signOutAlert = UIAlertController(title: "Confirm Sign Out", message: "Would you like to sign out of the app?", preferredStyle: .actionSheet)
        // add the sign out and cancel actions to the alert
        signOutAlert.addAction(cancelAction)
        signOutAlert.addAction(signOutAction)
        
        self.present(signOutAlert, animated: true)
    }
    
    // 'disconnects' the users google account from the app - all user data will be deleted
    @IBAction func disconnectGoogleAccount(_ sender: Any) {
        // check if the user has a bike checked out - if so they need to return the bike first - give them an alert
        let user = Auth.auth().currentUser
        guard let userId = user?.uid else { return }
        let userRef = db.collection("Users").document(userId)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {

                // Check to see if the user already has checked out a bike
                if (document.get("hasBike") as! Bool) {
                    let understoodAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
                        print("Pressed Understood")
                    }
                    let bikeStillCheckoutAlert = UIAlertController(title: "Cannot Delete Account", message: "Must return borrowed bike prior to account deletion", preferredStyle: .alert)
                    bikeStillCheckoutAlert.addAction(understoodAction)
                    
                    self.present(bikeStillCheckoutAlert, animated: true)
                } else {
                    // create actionsheet
                    let deleteAction = UIAlertAction(title: "Confirm Delete", style: .destructive) { (action) in
                        GIDSignIn.sharedInstance.disconnect { error in
                            guard error == nil else { return }
                            // account disconnect - do backend cleanup i.e. deleting user data
                            

                            
                            user?.delete { error in
                                if let error = error {
                                    print("error with account deletion: \(error)")
                                } else {
                                    // account deleted
                                    print("account deleted succesfully")
                                    // delete rest of user data from firestore
                                    self.deleteFirestoreAccountData(userId: userId)
                                    // to the log in screen
                                    goToLoginView()
                                }
                            }
                        }
                    }
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                        print("Cancelled Delete")
                    }
                    
                    // create the actionsheet and add the actions
                    let deleteAlert = UIAlertController(title: "Confirm Account Deletion", message: "WARNING: THIS ACTION CANNOT BE UNDONE!", preferredStyle: .actionSheet)
                    deleteAlert.addAction(deleteAction)
                    deleteAlert.addAction(cancelAction)
                    
                    self.present(deleteAlert, animated: true)
                }
            }
        }
    }
    
    // deletes user data from the Users collection
    private func deleteFirestoreAccountData(userId: String) -> Void {
        let userRef = db.collection("Users").document(userId)
        
        userRef.delete() { error in
            if let error = error {
                print("Error deleting user account: \(error)")
            } else {
                print("DELETED PROPERLY")
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
