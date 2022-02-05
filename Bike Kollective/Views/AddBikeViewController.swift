//
//  AddBikeViewController.swift
//  Bike Kollective
//
//  Created by Born4Film on 1/18/22.
//

import UIKit

class AddBikeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    // input fields
    @IBOutlet weak var addBikeImage: UIImageView!
    @IBOutlet weak var bikeMakeField: UITextField!
    @IBOutlet weak var bikeModelField: UITextField!
    @IBOutlet weak var bikeLocationField: UITextField!
    @IBOutlet weak var bikeCodeField: UITextField!
    
    //Error messages
    @IBOutlet weak var bikeMakeError: UILabel!
    @IBOutlet weak var bikeModelError: UILabel!
    @IBOutlet weak var bikeLockCodeError: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bikeMakeField.delegate = self
        bikeModelField.delegate = self
        bikeCodeField.delegate = self
        
        
        //Add an event listener for keyboard.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    // Stop listening to the keyboard.
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    // Function gets access to the camera to take a photo
    @IBAction func takePhotoTapped(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let bikeImagePicker = UIImagePickerController()
            bikeImagePicker.delegate = self
            bikeImagePicker.sourceType = UIImagePickerController.SourceType.camera
            bikeImagePicker.allowsEditing = false
            self.present(bikeImagePicker, animated: true, completion: nil)
        }
        
    }
    
    // Sets the photo that was taken to the image in layout and saves the photo.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let bikePickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            addBikeImage.contentMode = .scaleAspectFit
            addBikeImage.image = bikePickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Helps the keyboard move up the whole layout
    @objc func keyboardWillChange(notification: Notification) {
        
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        // Check for keyboard notifications 
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification{
            
            view.frame.origin.y = -keyboardSize.height
        } else {
            view.frame.origin.y = 0
        }
                
        print("Keyboard will show: \(notification.name.rawValue)")
    }
    
    // Makes the keyboard dissapear after the user hits return after input.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        bikeMakeField.resignFirstResponder()
        bikeModelField.resignFirstResponder()
        bikeCodeField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func bikeMakeChanged(_ sender: Any) {
        if let bikeMake = bikeMakeField.text {
            if let errorMessage = emptyBikeMake(bikeMake) {
                bikeMakeError.text = errorMessage
                bikeMakeError.isHidden = false
            }
            else {
                bikeMakeError.isHidden = true
            }
        }
    }
    
    func emptyBikeMake(_ value: String) -> String? {
        if value.count == 0 {
            return "Bike make is a required field."
        }
        return nil
    }
    
    @IBAction func bikeModelChanged(_ sender: Any) {
        if let bikeModel = bikeModelField.text {
            if let errorMessage = emptyBikeModel(bikeModel) {
                bikeModelError.text = errorMessage
                bikeModelError.isHidden = false
            }
            else {
                bikeModelError.isHidden = true
            }
        }
    }
        
    func emptyBikeModel(_ value: String) -> String? {
        if value.count == 0 {
            return "Bike model is a required field."
        }
        return nil
    }
    
    @IBAction func bikeLockCodeChanged(_ sender: Any) {
        if let bikeLockCode = bikeCodeField.text {
            if let errorMessage = emptyBikeLockCode(bikeLockCode) {
                bikeLockCodeError.text = errorMessage
                bikeLockCodeError.isHidden = false
            }
            else {
                bikeLockCodeError.isHidden = true
            }
        }
    }
    
    func emptyBikeLockCode(_ value: String) -> String? {
        if value.count == 0 {
            return "Bike lock code is a required field"
        }
        return nil
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
