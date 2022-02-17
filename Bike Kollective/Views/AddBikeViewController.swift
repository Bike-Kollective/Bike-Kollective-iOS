//
//  AddBikeViewController.swift
//  Bike Kollective
//
//  Created by Born4Film on 1/18/22.
//

import UIKit
import Firebase
import FirebaseStorage
import CoreLocation
import FirebaseFirestore


class AddBikeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate {

    // input fields
    @IBOutlet weak var addBikeImage: UIImageView!
    @IBOutlet weak var bikeMakeField: UITextField!
    @IBOutlet weak var bikeModelField: UITextField!
    @IBOutlet weak var bikeCodeField: UITextField!
    
    //Error messages
    @IBOutlet weak var bikeMakeError: UILabel!
    @IBOutlet weak var bikeModelError: UILabel!
    @IBOutlet weak var bikeLockCodeError: UILabel!
    @IBOutlet weak var bikeImageEmptyError: UILabel!
    
    let manager = CLLocationManager()
    var currentLatitude: Double?
    var currentLongitude: Double?

    override func viewDidLoad() {
        super.viewDidLoad()

        bikeMakeField.delegate = self
        bikeModelField.delegate = self
        bikeCodeField.delegate = self
        
        //Hide the image is empty error message.
        bikeImageEmptyError.isHidden = true
        
        //Add an event listener for keyboard.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        //Set up location enabling
//        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
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
    
    func bikeImageCheck() -> Bool{
        
        print("In Image check FALSE")
        
        if addBikeImage.image == nil {
            bikeImageEmptyError.isHidden = false
            return false
        }
        else {
            bikeImageEmptyError.isHidden = true
            return true
        }
    }
    
    @IBAction func addBikeTapped(_ sender: Any) {
        
        // Check to see if their is the proper inputs in the required fields
        let makeEmpty = checkValidInput(self.bikeMakeField.text!)
        let modelEmpty = checkValidInput(self.bikeModelField.text!)
        let bikeCodeEmpty = checkValidInput(self.bikeCodeField.text!)
        
        if(makeEmpty == false || modelEmpty == false || bikeCodeEmpty == false) {
            print("ERROR: Not all needed valid inputs")
            return
        }
        
        
//        print("BIKE IMAGE")
//        print(addBikeImage)
        
        // Check to see if there was a photo taken.
//        let isImage = bikeImageCheck()
//        if isImage == false {
//            print("ERROR: No bike image input")
//            return
//        }
        
        //Go to the release of interest screen.
        let newViewController = storyboard?.instantiateViewController(withIdentifier: "releaseOfInterest") as! ReleaseOfInterestViewController
        newViewController.modalPresentationStyle = .fullScreen
        present(newViewController, animated: true)
        
        
        // create Firestore and Firestore Storage
        let database = Firestore.firestore()
        let imageStorage = Storage.storage()
                
        guard let photoInfo = self.addBikeImage.image?.jpegData(compressionQuality: 0.5) else {
            print("ERROR: Image couldn't be converted")
            return
        }

        // create metatdate of the file
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"

        // Create a new file name
        let documentID = UUID().uuidString

        // Create a storage reference to upload the image.
        let imageStorageRef = imageStorage.reference()
        let newImageStorageRef = imageStorageRef.child("bikes/").child(documentID)

        // Upload the image to Firebase Storage
        let uploadTask = newImageStorageRef.putData(photoInfo, metadata: metaData) { (metadata, error) in if let error = error {
                print("ERROR: Putting data in storage")
                print(error)
                return
            }
        }

        // observe the upload and print out success or failure
        uploadTask.observe(.success) { (snapshot) in
            print("Upload Success")

            var uploadImageURL = ""
                
            newImageStorageRef.downloadURL(completion: { url, error in
                guard let url = url, error == nil else {
                    print("ERROR: Couldn't get image URL")
                    print(error!)
                    return
                }
                
                let urlString = url.absoluteString
                print("Download URL: \(urlString)")
                uploadImageURL = urlString
                
                // Create the array for ratings and tags
                let ratingArray = [Int]()
                let tagsArray = [String]()
                
                // Get the current location
                let currentLocation = GeoPoint(latitude: self.currentLatitude!, longitude: self.currentLongitude!)
                
                // Send the rest of the information on the bile
                database.collection("Bikes").document(documentID).setData([
                    "checked_out": false,
                    "location": currentLocation,
                    "make": self.bikeMakeField.text!,
                    "model": self.bikeModelField.text!,
                    "bike_lock_code": self.bikeCodeField.text!,
                    "missing": false, "rating": ratingArray,
                    "tags": tagsArray,
                    "imageURL": uploadImageURL]) {
                    error in if let error = error {
                        print("ERROR: \(error)")
                    } else {
                        print("Document successfuly sent")
                    }
                }
                
            })
            
            // display success message to the user.
            self.bikeUploadSuccessAlert()
            
        }

        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print("ERROR: Upload Failure \(error)")
            }
        }
    }

    
    // Checks to see if the value input is empty or not.
    func checkValidInput(_ value: String) -> Bool {
        
        if value.count == 0 {
            return false
        } else {
            return true
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let first = locations.first else {
            print("ERROR: No Locations")
            return
        }
//
//        print("COORDINATES TEST")
//        print("\(first.coordinate.longitude) | \(first.coordinate.latitude)")
        
        currentLatitude = first.coordinate.latitude
        currentLongitude = first.coordinate.longitude
        
    }
    
    func bikeUploadSuccessAlert() {
        //Create the success alert message to pop up.
        let successAlert = UIAlertController(title: "Success", message: "Bike successfuly uploaded to the Kollective", preferredStyle: UIAlertController.Style.alert)
        
        //Create the button to get rid of the alert.
        successAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        //Present the alert to the user.
        self.present(successAlert, animated: true, completion: nil)
    }

}
