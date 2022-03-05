//
//  FilterViewController.swift
//  Bike Kollective
//
//  Created by Born4Film on 3/4/22.
//

import UIKit

class FilterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var distanceField: UITextField!
    @IBOutlet weak var measureSelect: UISegmentedControl!
    @IBOutlet weak var tagField: UITextField!
    
    let defaults = UserDefaults.standard
    let tags = ["Choose...", "broken", "new", "clean", "fast", "easy to ride", "road", "mountain", "touring", "electric", "cargo", "folding", "bmx", "recumbent", "kids", "womens", "tandem"]
    var pickerView = UIPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // sets up pickerview
        pickerView.delegate = self
        pickerView.dataSource = self
        tagField.inputView = pickerView
        // sets up tagfield initial text
        if let curTag = defaults.string(forKey: "tag") {
            let index = tags.firstIndex(of: curTag)
            tagField.text = tags[index!]
        } else {
            tagField.text = tags[0]
        }
        tagField.textAlignment = .center
        // sets distancefield initial text and keyboard
        distanceField.keyboardType = .numberPad
        distanceField.text = "\(defaults.integer(forKey: "distance") == 0 ? 15 : defaults.integer(forKey: "distance"))"
        distanceField.textAlignment = .right
        // sets measureselect initial selection
        measureSelect.selectedSegmentIndex = defaults.integer(forKey: "measure")
    }
    
    
    func getDistance() -> Int {
        var distance : Int
        if distanceField.text == "" {
            distance = 15
        } else {
            distance = Int(distanceField.text!)!
        }
        switch distance {
        case ..<2:
            return 1
        case 2...25:
            return distance
        default:
            return 25
        }
    }
    
    @IBAction func applyFilter(_ sender: Any) {
        defaults.set(getDistance(), forKey: "distance")
        defaults.set(tagField.text, forKey: "tag")
        defaults.set(measureSelect.selectedSegmentIndex, forKey: "measure")
        defaults.synchronize()
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @IBAction func resetFilters(_ sender: Any) {
        defaults.set(15, forKey: "distance")
        defaults.set(tags[0], forKey: "tag")
        defaults.set(0, forKey: "measure")
        distanceField.text = "15"
        tagField.text = tags[0]
        measureSelect.selectedSegmentIndex = 0
        dismiss(animated: true, completion: nil)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tags.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return tags[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tagField.text = tags[row]
        tagField.resignFirstResponder()
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
