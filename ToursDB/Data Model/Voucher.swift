//
//  Voucher.swift
//  ToursDB
//
//  Created by Elena Nazarova on 04.12.2020.
//

import Foundation
import RealmSwift

class Voucher: Object {
    @objc dynamic var number: String?
    @objc dynamic var dateOff: String?
    @objc dynamic var dateReturn: String?
    @objc dynamic var price: String?
    @objc dynamic var vouchertour: Tour?                  // тур этого ваучера
    @objc dynamic var voucherclient: Client?              // клиент этого ваучера
    
    override static func primaryKey() -> String {
        return "number"
    }
}
