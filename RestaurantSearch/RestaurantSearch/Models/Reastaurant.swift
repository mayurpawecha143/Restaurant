//
//  Reastaurant.swift
//  RestaurantSearch
//
//  Created by Mayur Pawecha on 12/7/22.
//

import Foundation

struct Restaurant: Decodable {
    let id: String
    let name: String
    let imageUrl: String
    let price: String
    let alias: String
    let displayPhone: String
    let distance: Double?
    let isClosed: Bool
    let phone: String
    let rating: Float
    let reviewCount: Int64
    let url: String
    let location: Address
    let categories: [Category]
    let coordinates: Coordinate
    var hours: [Hours]?
    var specialHours: [SpecialHours]?
}

struct Address: Decodable {
    let address1: String
    let address2: String?
    let address3: String?
    let city: String
    let country: String
    let state: String
    let zipCode: String
    let displayAddress: [String]
}

struct Category: Decodable {
    let alias: String
    let title: String
}

struct Coordinate: Decodable {
    let latitude: Double
    let longitude: Double
}

struct Hours: Decodable {
    let hoursType: String
    let isOpenNow: Bool
    let open: [OpenHours]
}

struct OpenHours: Decodable {
    let isOvernight: Bool
    let end: String
    let day: Int64
    let start: String
}

struct SpecialHours: Decodable {
    let start: String?
    let end: String?
    let isOvernight: Bool?
    let isClosed: Bool?
    let date: String
}

extension Restaurant {
    mutating func merge(with: Restaurant) {
        hours = hours ?? with.hours
        specialHours = specialHours ?? with.specialHours
    }
}

