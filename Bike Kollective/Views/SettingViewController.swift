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
    
    // function that sets the login screen
    func goToLogin() {
        // go back to login screen
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavigationController")
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
    }
    
    
    // signs out the user from the app and takes them back to the login page
    @IBAction func signOut(_ sender: Any) {
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
        goToLogin()
        
    }
    
    // 'disconnects' the users google account from the app - all user data will be deleted
    @IBAction func disconnectGoogleAccount(_ sender: Any) {
        // call the disconnect method for google sign in
        GIDSignIn.sharedInstance.disconnect { error in
            guard error == nil else { return }
            
            // TODO: Add popup window to confirm user wants to delete their account!
            
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
        goToLogin()
        
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
