//
//  LoginViewController.swift
//  Bike Kollective
//
//  Created by Born4Film on 1/18/22.
//

import UIKit
import GoogleSignIn
import Firebase
import FirebaseCore
import FirebaseAuth

class LoginViewController: UIViewController {

    // button for google sign in - need to set button class as GIDSignInButton
    // @IBOutlet weak var signInButton: GIDSignInButton!
    
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // connect to Firestore
        db = Firestore.firestore()
    }
    
    // function to handle Google Sign in on tap of googlesigninbutton
    @IBAction func handleGoogleLogin(_ sender: Any) {
        let googleClientId = FirebaseApp.app()?.options.clientID ?? ""
        let config = GIDConfiguration.init(clientID: googleClientId)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            // guard error == nil else { return }
            // guard let user = user else { return }
            
            if let error = error {
                print("Sign In error: \(error)")
                return
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {return}
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                             accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print("Authentication Error: \(error.localizedDescription)")
                    // return
                } else {
                    // after authentication is complete
                    // get the userId from firebase auth
                    let firebaseUser = Auth.auth().currentUser
                    guard let userId = firebaseUser?.uid else {return}
                    checkIfUserExists(userId: userId)
                    
                }
                
            }
            
            
            
        }
        
        
    }
    
    // function that check is user that signed in with Google Sign In currently has been added to Firestore collection already
    // if not, go to the accident waiver form to sign it and creat new user, else go to the main page
    private func checkIfUserExists(userId: String) -> Void {
        // obtain document with userId
        let userRef = db.collection("Users").document(userId)
        
        // check if the document exists - async!
        userRef.getDocument { (document, error) in
            // user exists - has signed waiver form
            if let document = document, document.exists {
                
                // if the banned field is true, go to banned account
                if document.get("banned") as! Bool {
                    goToBannedUserView()
                } else {
                    goToTabViewController()
                }
               
            } else {
                // they don't exist in database, haven't signed waiver so take them to waiver form to sign
                goToWaiver()
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


