//
//  MKbike.swift
//  Bike Kollective
//
//  Created by Born4Film on 3/1/22.
//

import MapKit
import CoreLocation

class MKbike: NSObject, MKAnnotation {
    let bike: Bike?
    let coordinate: CLLocationCoordinate2D
    
    init(
        bike: Bike?,
        coordinate: CLLocationCoordinate2D
    ) {
        self.bike = bike
        self.coordinate = coordinate
        
        super.init()
    }
    
    var title: String? {
        return "\(bike?.make ?? "") \(bike?.model ?? "Bike")"
    }
    
    var subtitle: String? {
        let subs = bike?.tags.joined(separator: ", ")
        return subs
    }
    
    var avgRate: Int? {
        let sum = bike?.rating.reduce(0, +) ?? 0
        let avg = sum / (bike?.rating.count)!
        return avg
    }
    
}

