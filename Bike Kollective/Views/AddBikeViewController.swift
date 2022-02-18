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
    
    //Error message
    @IBOutlet weak var emptyError: UILabel!
    
    var userReleaseOfInterest: Bool?
    
    let manager = CLLocationManager()
    var currentLatitude: Double?
    var currentLongitude: Double?

    override func viewDidLoad() {
        super.viewDidLoad()

        bikeMakeField.delegate = self
        bikeModelField.delegate = self
        bikeCodeField.delegate = self
        
        //Hide the empty error message.
        emptyError.isHidden = true
        
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
    
    func emptyBikeMakeFieldCheck() -> Bool{
        
        // Check the Bike Make Field
        if bikeMakeField.text?.count == 0 {
            emptyError.text = "Bike make is a required field."
            emptyError.isHidden = false
            return false
        }
        else {
            emptyError.isHidden = true
            return true
        }
    }
    
    func emptyBikeModelFieldCheck() -> Bool{
        // Check the Bike Model Field
        if bikeModelField.text?.count == 0 {
            emptyError.text = "Bike model is a required field."
            emptyError.isHidden = false
            return false
        }
        else {
            emptyError.isHidden = true
            return true
        }
    }
    
    func emptyBikeLockCodeFieldCheck() -> Bool{
        
        // Check the Bike Lock Code Field
        if bikeCodeField.text?.count == 0 {
            emptyError.text = "Bike lock code is a required field."
            emptyError.isHidden = false
            return false
        }
        else {
            emptyError.isHidden = true
            return true
        }
    
    }
    
    func bikeImageCheck() -> Bool{
        
        print("In Image check FALSE")
        
        if addBikeImage.image == nil {
            emptyError.isHidden = false
            return false
        }
        else {
            emptyError.isHidden = true
            return true
        }
    }
    
    @IBAction func releaseOfInterestTapped(_ sender: Any) {

        let newViewController = storyboard?.instantiateViewController(withIdentifier: "releaseOfInterest") as! ReleaseOfInterestViewController
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.releaseOfInterestCheck = { Bool in
            self.userReleaseOfInterest = Bool
        }
        present(newViewController, animated: true)
        
        print("RELEASE OF INTEREST FUNCTION")
        print(userReleaseOfInterest)
        
    }
    
    
    @IBAction func addBikeTapped(_ sender: Any) {
        
        // Check to see if their is the proper inputs in the required fields
        
        if emptyBikeMakeFieldCheck() == false {
            print("ERROR: Bike make field is empty")
            return
        }
        
        if emptyBikeModelFieldCheck() == false {
            print("ERROR: Bike model field is empty")
            return
        }
        
        if emptyBikeLockCodeFieldCheck() == false {
            print("ERROR: Bike lock code field is empty")
            return
        }

//        print("BIKE IMAGE")
//        print(addBikeImage)
        
        // Check to see if there was a photo taken.
        let isImage = bikeImageCheck()
        if isImage == false {
            print("ERROR: No bike image input")
            return
        }
        

        print("RELEASE OF INTEREST IN ADD BIKE TAPPED")
        print(userReleaseOfInterest!)
        
        
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

    
//    // Checks to see if the value input is empty or not.
//    func checkValidInput(_ value: String) -> Bool {
//
//        if value.count == 0 {
//            return false
//        } else {
//            return true
//        }
//    }

    
//    func getReleaseOfInterest() -> Bool {
//
//        var tempReleaseValue = false
//
//        let newViewController = storyboard?.instantiateViewController(withIdentifier: "releaseOfInterest") as! ReleaseOfInterestViewController
//        newViewController.modalPresentationStyle = .fullScreen
//        newViewController.releaseOfInterestCheck = { Bool in
//            tempReleaseValue = Bool
//        }
//        present(newViewController, animated: true)
//
//        print("RELEASE OF INTEREST FUNCTION")
//        print(tempReleaseValue)
//
//        return tempReleaseValue
//
//    }
    
    
    
    
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
