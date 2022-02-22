//
//  GoToWaiverView.swift
//  Bike Kollective
//
//  Created by Kiwon Nam on 2/22/22.
//

import UIKit

// function that takes the user to the accident waiver
public func goToWaiver() -> Void {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let waiverView = storyboard.instantiateViewController(identifier: "WaiverView")

    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(waiverView)
}
