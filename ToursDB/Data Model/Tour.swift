//
//  Tour.swift
//  ToursDB
//
//  Created by Elena Nazarova on 04.12.2020.
//

import Foundation
import RealmSwift

class Tour: Object {
    @objc dynamic var name: String?
    @objc dynamic var agencyName: String?
    @objc dynamic var meal: Bool = false
    @objc dynamic var transfer: Bool = false
    @objc dynamic var tourcity: City?                                                       // город этого тура
    @objc dynamic var tourhotel: Hotel?                                                     // отель этого тура
    let tourVouchers = List<Voucher>()    
    
    override static func primaryKey() -> String? {
            return "name"
    }
}
