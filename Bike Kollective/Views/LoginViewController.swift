//
//  LoginViewController.swift
//  Bike Kollective
//
//  Created by Born4Film on 1/18/22.
//

import UIKit
import GoogleSignIn
import FirebaseCore
import FirebaseAuth


class LoginViewController: UIViewController {

    // button for google sign in - need to set button class as GIDSignInButton
    // @IBOutlet weak var signInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // function to handle Google Sign in on tap of googlesigninbutton
    @IBAction func handleGoogleLogin(_ sender: Any) {
        let googleClientId = FirebaseApp.app()?.options.clientID ?? ""
        let config = GIDConfiguration.init(clientID: googleClientId)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            // guard error == nil else { return }
            // guard let user = user else { return }
            
            if let error = error {
                print("error")
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
                }
                
            }
            // let emailAddress = user.profile?.email
            
            // let firstName = user.profile?.givenName
            // let lastName = user.profile?.familyName
            
            // let prof
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
                
            // This is to get the SceneDelegate object from your view controller
            // then call the change root view controller function to change to main tab bar
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
            
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
