//
//  Hotel.swift
//  ToursDB
//
//  Created by Elena Nazarova on 04.12.2020.
//

import Foundation
import RealmSwift

class Hotel: Object  {
    @objc dynamic var name: String?
    @objc dynamic var stars: String?
    @objc dynamic var hotelcity: City?                                           // город этого отеля
    let hotelTours = List<Tour>()                                                // все туры в этом отеле
    
    override static func primaryKey() -> String? {
            return "name"
    }
}

