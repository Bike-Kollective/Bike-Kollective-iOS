//
//  goToTabViewController.swift
//  Bike Kollective
//
//  Created by Kiwon Nam on 2/16/22.
//

import UIKit

// function that takes user to the main bike list screen
public func goToTabViewController() -> Void {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
}
