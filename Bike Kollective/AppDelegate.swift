//
//  AppDelegate.swift
//  Bike Kollective
//
//  Created by Born4Film on 1/11/22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import GoogleMaps

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // GMSServices.provideAPIKey("")
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        let db = Firestore.firestore()
        
        // attempts to restore any previous log in so that user does not have to sign in each time they open app
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
            // Show the app's signed-out state.
                goToLoginView()
            } else {
                let firebaseUser = Auth.auth().currentUser
                guard let userId = firebaseUser?.uid else {return}
                let userRef = db.collection("Users").document(userId)
                userRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        print("User ID: \(userId)")
                        // check if user is banned
                        if document.get("banned") as! Bool {
                            goToBannedUserView()
                        } else {
                            if document.get("hasBike") as! Bool {
                                // check if the bike is overdue!
                                self.checkIfOverdue(userReference: userRef, userDocument: document)
                            } else {
                                goToTabViewController()
                            }
                        }
                    }
                }
            }
        }
        
        // ask user for permission to send notifications
        let notificationCenter = UNUserNotificationCenter.current()
        
        // this asks the user for permission to send notifications
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            // permission not granted
            if !granted {
                print("Error - permission not granted!\(String(describing: error?.localizedDescription))")
            }
        }
        
        if #available(iOS 15.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            //Configure additional customizations here
            UINavigationBar.appearance().standardAppearance = navBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled: Bool

          handled = GIDSignIn.sharedInstance.handle(url)
          if handled {
            return true
          }

          // Handle other custom URL types.

          // If not handled by this app, return false.
          return false
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

