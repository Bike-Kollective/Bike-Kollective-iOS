//
//  ReleaseOfInterestViewController.swift
//  Bike Kollective
//
//  Created by Anthony Nice on 2/15/22.
//

import UIKit

class ReleaseOfInterestViewController: UIViewController {

    @IBOutlet weak var releaseStatement: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func confirmButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
}
