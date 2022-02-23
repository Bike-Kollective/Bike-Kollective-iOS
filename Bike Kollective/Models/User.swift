//
//  User.swift
//  Bike Kollective
//
//  Created by Kiwon Nam on 2/22/22.
//

import Foundation

public struct User: Codable {
//    let userId: String?
//    let firstName: String?
//    let lastName: String?
//    let email: String?
    let signedWaiver: Bool
    var isBanned: Bool
    var bikeId: String?

    enum CodingKeys: String, CodingKey {
//        case userId
//        case firstName
//        case lastName
//        case email
        case signedWaiver
        case isBanned = "banned"
        case bikeId
    }
}
