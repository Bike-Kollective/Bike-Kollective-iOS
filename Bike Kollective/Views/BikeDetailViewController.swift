//
//  BikeDetailViewController.swift
//  Bike Kollective
//
//  Created by Born4Film on 1/18/22.
//

import UIKit
import MapKit

class BikeDetailViewController: UIViewController {

    var bike: Bike!
    
    @IBOutlet weak var bikeImage: UIImageView!
    @IBOutlet weak var bikeMake: UILabel!
    @IBOutlet weak var bikeModel: UILabel!
    @IBOutlet weak var bikeRating: UIImageView!
    @IBOutlet weak var bikeTags: UILabel!
    @IBOutlet weak var bikeMapLocation: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("IN BIKE DETAIL VIEW CONTROLLER")
        print(bike)
        print("BIKE MAKE")
        print(bike.make)
        
        bikeMake.text = bike.make
        bikeModel.text = bike.model
//        bikeRating.text = bike.rating
        
        bikeRating.image = getBikeRating()
     
        print("TAGS")
        print(bike.tags)
        bikeTags.text = bike.tags.joined(separator: ", ")
        
        getMapLocation()
        
//        bikeMapLocation.centerCoordinate.latitude = bike.location.coordinate.latitude
//        bikeMapLocation.centerCoordinate.longitude = bike.location.coordinate.longitude
        
    }
    
    // Get the bike average bike rating and return the corrisponding image
    func getBikeRating() -> UIImage {
        print("BIKE RATING")
        print(bike.rating)
        
        let avgRating : Double
        var sum = 0
        
        // Sum up the total ratings for bikes in the rating array.
        for bikes in bike.rating {
            sum += bikes
        }
        
        // Get the average rating of the bikes.
        avgRating = Double(sum / bike.rating.count)
        
        // Find and return the correct image.
        switch avgRating {
        case 0..<0.5:
            return UIImage(named: "regular_0")!
        case 0.5..<1.25:
            return UIImage(named: "regular_1")!
        case 1.25..<1.75:
            return UIImage(named: "regular_1_half")!
        case 1.75..<2.25:
            return UIImage(named: "regular_2")!
        case 2.25..<2.75:
            return UIImage(named: "regular_2_half")!
        case 2.75..<3.25:
            return UIImage(named: "regular_3")!
        case 3.25..<3.75:
            return UIImage(named: "regular_3_half")!
        case 3.75..<4.2:
            return UIImage(named: "regular_4")!
        case 4.2..<4.6:
            return UIImage(named: "regular_4_half")!
        default:
            return UIImage(named: "regular_5")!
        }
        
    }
    
    func getMapLocation() {
        
        let displayLocation = MKPointAnnotation()
        displayLocation.coordinate = CLLocationCoordinate2D(latitude: bike.location.coordinate.latitude, longitude: bike.location.coordinate.longitude)
        bikeMapLocation.addAnnotation(displayLocation)
        
        let bikeLocationLatLong = CLLocation(latitude: bike.location.coordinate.latitude, longitude: bike.location.coordinate.longitude)
        let mapZoom = MKCoordinateRegion(center: bikeLocationLatLong.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        bikeMapLocation.setRegion(mapZoom, animated: true)

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
