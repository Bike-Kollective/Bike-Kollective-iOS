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
    
    @IBOutlet weak var acceptanceSwitch: UISwitch!
    
    
    public var releaseOfInterestCheck: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        acceptanceSwitch.isOn = false
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func confirmButtonTapped(_ sender: Any) {
        
        
        releaseOfInterestCheck!(acceptanceSwitch.isOn)
        
        print("IN CONFIRM BUTTON TAPPED")
        print(acceptanceSwitch.isOn)
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
}
