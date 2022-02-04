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
    
    @IBAction func handleGoogleLogin(_ sender: Any) {
        let googleClientId = FirebaseApp.app()?.options.clientID ?? ""
        let config = GIDConfiguration.init(clientID: googleClientId)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { user, error in
            guard error == nil else { return }
            guard let user = user else { return }
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
