//
//  SettingViewController.swift
//  Bike Kollective
//
//  Created by Kiwon Nam on 2/6/22.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class SettingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        // create actionsheet
        let deleteAction = UIAlertAction(title: "Confirm Delete", style: .destructive) { (action) in
            GIDSignIn.sharedInstance.disconnect { error in
                guard error == nil else { return }
                // account disconnect - do backend cleanup i.e. deleting user data
                
                // get the current user and delete with the deleteWithCompletion method?
                let user = Auth.auth().currentUser
                
                user?.delete { error in
                    if let error = error {
                        print("error with account deletion")
                    } else {
                        // account deleted
                        print("account deleted succesfully")
                    }
                }
            }
            // to the log in screen
            goToLoginView()
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
