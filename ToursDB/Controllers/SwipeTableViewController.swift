//
//  SwipeTableViewController.swift
//  ToursDB
//
//  Created by Elena Nazarova on 10.12.2020.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.updateModel(at: indexPath)
        }
        deleteAction.image = UIImage(named: "delete-icon")
        return [deleteAction]
    }
    
    func updateModel(at indexPath: IndexPath) {
        //update
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
    
    // MARK: - CHECK IF THE STRING IS EMPTY
    func checkEmpty(primaryKey: String) -> Bool { !primaryKey.isEmpty ? true : false }
}

// MARK: - AUTOCAPITALIZING FIRST LETTER
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func stringBefore(_ delimiter: Character) -> String {
        if let index = firstIndex(of: delimiter) {
            return String(prefix(upTo: index))
        } else {
            return ""
        }
    }
        
    func stringAfter(_ delimiter: Character) -> String {
        if let index = firstIndex(of: delimiter) {
                return String(suffix(from: index).dropFirst())
        } else {
                return ""
        }
    }
}

