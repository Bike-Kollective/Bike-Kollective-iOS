//
//  Bike.swift
//  Bike Kollective
//
//  Created by Born4Film on 2/19/22.
//

import Foundation
import CoreLocation

struct Bike {
    let name: String
    let make: String
    let model: String
    let rating: [Int]
    let tags: [String]
    let comments: [String]
    let location: CLLocation
    let distance: Double
    let imageUrl: String
    let bike_lock_code: String
}
