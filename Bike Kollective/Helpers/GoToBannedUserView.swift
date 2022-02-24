//
//  GoToBannedUserView.swift
//  Bike Kollective
//
//  Created by Kiwon Nam on 2/24/22.
//

import UIKit

// goes to a screen that show the user that they are banned
public func goToBannedUserView() -> Void {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let bannedUserView = storyboard.instantiateViewController(identifier: "BannedUserView")
    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(bannedUserView)
    
}
