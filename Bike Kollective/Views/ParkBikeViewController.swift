//
//  ParkBikeViewController.swift
//  Bike Kollective
//
//  Created by Kiwon Nam on 20223/3/.
//

import UIKit
import Firebase
import FirebaseFirestore

class ParkBikeViewController: UIViewController {

    var bikeId: String = ""
    var userId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("bikeId \(self.bikeId)")
        print("userId \(self.userId)")
        // Do any additional setup after loading the view.
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
