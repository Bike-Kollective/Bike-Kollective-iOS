//
//  goToTabViewController.swift
//  Bike Kollective
//
//  Created by Kiwon Nam on 2/16/22.
//

import UIKit

func goToTabViewController() {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
        
    // This is to get the SceneDelegate object from your view controller
    // then call the change root view controller function to change to main tab bar
    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
}
