//
//  VouchersTableViewCell.swift
//  ToursDB
//
//  Created by Elena Nazarova on 04.12.2020.
//

import UIKit
import SwipeCellKit

class VouchersTableViewCell: SwipeTableViewCell {
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var dateOffLabel: UILabel!
    @IBOutlet weak var dateReturnLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var tourLabel: UILabel!
    @IBOutlet weak var clientLabel: UILabel!
}
