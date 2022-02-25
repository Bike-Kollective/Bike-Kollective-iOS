//
//  BannedUserViewController.swift
//  Bike Kollective
//
//  Created by Kiwon Nam on 2/24/22.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class BannedUserViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func returnToLoginScreen(_ sender: Any) {
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
