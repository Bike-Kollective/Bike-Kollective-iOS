//
//  goToLogInView.swift
//  Bike Kollective
//
//  Created by Kiwon Nam on 2/16/22.
//

import UIKit

// function that sets the login screen
public func goToLoginView() -> Void {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavigationController")
    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
}
