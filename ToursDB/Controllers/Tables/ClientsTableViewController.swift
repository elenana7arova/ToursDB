//
//  ClientsTableViewController.swift
//  ToursDB
//
//  Created by Elena Nazarova on 04.12.2020.
//

import UIKit
import RealmSwift
import TLCustomMask

class ClientsTableViewController: SwipeTableViewController {
    let realm = try! Realm()
    var clients: Results<Client>?
    
    @IBOutlet weak var clientsSearchBar: UISearchBar!
    
    var textFieldTel = UITextField()
    var textFieldPassport = UITextField()
    let telMask = TLCustomMask(formattingPattern: "+$ ($$$) $$$-$$-$$")
    let passportMask = TLCustomMask(formattingPattern: "$$$$ $$$$$$")

    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        clientsSearchBar.delegate = self
//        printResults()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.estimatedRowHeight = 160
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clients?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClientsCell", for: indexPath) as! ClientsTableViewCell
        
        cell.nameLabel?.text = clients?[indexPath.row].name ?? "no name"
        cell.bdayLabel?.text = clients?[indexPath.row].birthday ?? "no bday"
        cell.telLabel?.text = clients?[indexPath.row].telephone ?? "no telephone"
        cell.passportLabel?.text = clients?[indexPath.row].passport ?? "no passport"
        //array of vouchers of the client
        
        if let numberOfVouchers = clients?[indexPath.row].clientVouchers.count {
            var arrayOfVouchers: [String] = []
            for i in 0..<numberOfVouchers {
                arrayOfVouchers.append(clients?[indexPath.row].clientVouchers[i].number ?? "")
            }
            let stringOfArray = arrayOfVouchers.joined(separator: ", ")
            cell.vouchersLabel.text = stringOfArray
        }
        
        cell.delegate = self
        return cell
    }
    // MARK: - Data Manipulation Methods
    
    //add
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        //textfield name
        var textFieldName = UITextField()
        //datepicker bday
        let descriptionLabel = UILabel(frame: CGRect(x: 15, y: 65, width: 100, height: 30))
        descriptionLabel.text = "Set b-day"
        let bdayPicker = UIDatePicker(frame: CGRect(x: 130, y: 65, width: 100, height: 30))
        bdayPicker.datePickerMode = .date
        bdayPicker.preferredDatePickerStyle = .compact
        //textfield telephone up

        //textfield passport up
        
        let alert = UIAlertController(title: "Add a client", message: "\n\n\n", preferredStyle: .alert)
        alert.isModalInPresentation = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newClient = Client()
            //set date as bday
            newClient.birthday = dateFormatter.string(from: bdayPicker.date)
            //set other fields
            newClient.name = textFieldName.text!.capitalizingFirstLetter()
            newClient.telephone = self.textFieldTel.text!
            newClient.passport = self.textFieldPassport.text!
            
            if !self.check(primaryKey: newClient.name!), self.checkEmpty(primaryKey: newClient.name!) {
                self.save(client: newClient)
            }
            else {
                let alert = UIAlertController(title: "This client already exists or the name is empty. Try a new name or edit this one.", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        alert.view.addSubview(bdayPicker)
        alert.view.addSubview(descriptionLabel)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Write the name"
            textFieldName = alertTextField
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.delegate = self
            alertTextField.placeholder = "Write the telephone"
            alertTextField.keyboardType = .phonePad
            self.textFieldTel = alertTextField

        }
        alert.addTextField { (alertTextField) in
            alertTextField.delegate = self
            alertTextField.placeholder = "Write the passport"
            alertTextField.keyboardType = .numberPad
            self.textFieldPassport = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true, completion: nil)
    }
    
    //update
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // label of client name
        let clientPrimaryKey = UILabel(frame: CGRect(x: 15, y: 40, width: 250, height: 50))
        clientPrimaryKey.font = UIFont.boldSystemFont(ofSize: 22)
        clientPrimaryKey.text = clients?[indexPath.row].name ?? "no client"
        // description label
        let descriptionLabel = UILabel(frame: CGRect(x: 15, y: 80, width: 100, height: 30))
        descriptionLabel.text = "Set b-day"
        //bday picker
        let bdayPicker = UIDatePicker(frame: CGRect(x: 130, y: 80, width: 100, height: 30))
        bdayPicker.datePickerMode = .date
        bdayPicker.preferredDatePickerStyle = .compact
        
        //textfield telephone up
        //textfield passport up
        
        let alert = UIAlertController(title: "Edit the client", message: "\n\n\n\n", preferredStyle: .alert)
        alert.isModalInPresentation = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        let action = UIAlertAction(title: "Edit", style: .default) { (action) in
            let client = Client()
            //label
            client.name = clientPrimaryKey.text
            //set date as bday
            
            client.birthday = dateFormatter.string(from: bdayPicker.date)
            //set other fields
            client.telephone = self.textFieldTel.text!
            client.passport = self.textFieldPassport.text!
            self.update(client: client)
        }
        alert.view.addSubview(clientPrimaryKey)
        alert.view.addSubview(bdayPicker)
        alert.view.addSubview(descriptionLabel)

        bdayPicker.date = dateFormatter.date(from: (self.clients?[indexPath.row].birthday)!)!
        
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "Write the telephone"
            alertTextField.text = self.clients?[indexPath.row].telephone
            alertTextField.keyboardType = .phonePad
            alertTextField.delegate = self
            self.textFieldTel = alertTextField
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Write the passport"
            alertTextField.text = self.clients?[indexPath.row].passport
            alertTextField.keyboardType = .numberPad
            alertTextField.delegate = self
            self.textFieldPassport = alertTextField
        }
    
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - DATABASE METHODS
    
    //save
    func save(client: Client) {
        do {
            try realm.write {
                realm.add(client)
            }
        }
        catch {
            print("Error saving category \(error)")
        }
        tableView.reloadData()
    }
    
    //update
    func update(client: Client) {
        do {
            try realm.write {
                realm.add(client, update: .modified)
                client.clientVouchers.append(objectsIn: realm.objects(Voucher.self).filter("voucherclient.name = %@", client.name))
            }
        }
        catch {
            print("Error")
        }
        tableView.reloadData()
    }
    
    //load
    func loadItems() {
        clients = realm.objects(Client.self)
        tableView.reloadData()
    }
    
    //delete
    override func updateModel(at indexPath: IndexPath) {
        if let clientForDeletion = self.clients?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(clientForDeletion)
                }
            }
            catch {
                print("Error deleting hotel, \(error)")
            }
        }
    }
    
    //check
    func check(primaryKey: String) -> Bool {
        if let obj = realm.objects(Client.self).filter("name = %@", primaryKey).first {
            return true
        }
        return false
    }

    
    
    
//    func printResults() {
//        let filteredObjects = realm.objects(Client.self).filter("name.count > name.@avg.count")
//        for filteredObject in filteredObjects {
//            print(filteredObject.name)
//        }
//    }
}
// MARK: - MASKS OF TEXTFIELDS
extension ClientsTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        if (textField == textFieldTel) {
            textFieldTel.text = telMask.formatStringWithRange(range: range, string: string)
        }
        else if (textField == textFieldPassport) {
            textFieldPassport.text = passportMask.formatStringWithRange(range: range, string: string)
        }
        return false
    }
}

// MARK: - UISEARCHBAR
extension ClientsTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ clientsSearchBar: UISearchBar) {
        clients = clients?.filter("name CONTAINS[cd] %@", clientsSearchBar.text as Any).sorted(byKeyPath: "name", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ clientsSearchBar: UISearchBar, textDidChange searchText: String) {
        if clientsSearchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                clientsSearchBar.resignFirstResponder()
            }
        }
    }
}
