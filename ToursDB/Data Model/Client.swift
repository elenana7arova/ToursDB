//
//  Client.swift
//  ToursDB
//
//  Created by Elena Nazarova on 04.12.2020.
//

import UIKit
import RealmSwift

class Client: Object {
    @objc dynamic var name: String?
    @objc dynamic var birthday: String?
    @objc dynamic var telephone: String?
    @objc dynamic var passport: String?
    let clientVouchers = List<Voucher>()                      // ваучеры этого клиента
    
    override static func primaryKey() -> String? {
        return "name"
    }
}
