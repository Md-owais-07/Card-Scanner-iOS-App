//
//  CardDataModel.swift
//  Card Scanner
//
//  Created by Owais on 05/08/24.
//

import Foundation

//struct CardDataModel: Codable {
//    var fields: [String: String] = [:]  // Dictionary to hold dynamic fields
//}

//struct CardDataModel: Codable {
//    var fields: [String] = []
//}

struct CardDataModel: Codable {
    var name: String?
    var jobProfile: String?
    var company: String?
    var email: String?
    var phoneNumber: String?
    var website: String?
    var address: String?
    var other: String?
    var fields: [String] = []
}
