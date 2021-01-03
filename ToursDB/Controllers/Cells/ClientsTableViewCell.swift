//
//  ClientsTableViewCell.swift
//  ToursDB
//
//  Created by Elena Nazarova on 04.12.2020.
//

import UIKit
import SwipeCellKit

class ClientsTableViewCell: /*UITableViewCell,*/ SwipeTableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bdayLabel: UILabel!
    @IBOutlet weak var telLabel: UILabel!
    @IBOutlet weak var passportLabel: UILabel!
    @IBOutlet weak var vouchersLabel: UILabel!
}
