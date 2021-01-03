//
//  City.swift
//  ToursDB
//
//  Created by Elena Nazarova on 04.12.2020.
//

import Foundation
import RealmSwift

class City: Object {
    @objc dynamic var name: String?
    @objc dynamic var countryName: String?
    let cityHotels = List<Hotel>()                   // все отели этого города
    let cityTours = List<Tour>()                     // все туры этого города
    
    override static func primaryKey() -> String? {
            return "name"
    }
    
}
