//
//  User.swift
//  Bike Kollective
//
//  Created by Kiwon Nam on 2/22/22.
//

import Foundation

public struct User: Codable {
    let email: String?
    let signedWaiver: Bool
    var isBanned: Bool
    var hasBike: Bool
    var bikeId: String?

    enum CodingKeys: String, CodingKey {
        case email
        case signedWaiver
        case isBanned = "banned"
        case hasBike
        case bikeId
    }
}
