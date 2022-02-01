//
//  AddBikeViewController.swift
//  Bike Kollective
//
//  Created by Born4Film on 1/18/22.
//

import UIKit

class AddBikeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var addBikeImage: UIImageView!
    @IBOutlet weak var bikeMakeField: UITextField!
    @IBOutlet weak var bikeModelField: UITextField!
    @IBOutlet weak var bikeLocationField: UITextField!
    @IBOutlet weak var bikeCodeField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func takePhotoTapped(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let bikeImagePicker = UIImagePickerController()
            bikeImagePicker.delegate = self
            bikeImagePicker.sourceType = UIImagePickerController.SourceType.camera
            bikeImagePicker.allowsEditing = false
            self.present(bikeImagePicker, animated: true, completion: nil)
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let bikePickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            addBikeImage.contentMode = .scaleToFill
            addBikeImage.image = bikePickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addBikeTapped(_ sender: Any) {
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
