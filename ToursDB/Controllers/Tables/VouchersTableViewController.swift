//
//  VouchersTableViewController.swift
//  ToursDB
//
//  Created by Elena Nazarova on 13.12.2020.
//

import UIKit
import RealmSwift

class VouchersTableViewController: SwipeTableViewController {
    let realm = try! Realm()
    var vouchers: Results<Voucher>?
    var tours: Results<Tour>?
    var clients: Results<Client>?
    var chosenTour: Tour?
    var chosenClient: Client?
    
    @IBOutlet weak var vouchersSearchBar: UISearchBar!
    var tourPicker = UIPickerView()
    var clientPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        vouchersSearchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.estimatedRowHeight = 175
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.reloadData()
    }
    
    // MARK: - Table methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vouchers?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VouchersCell", for: indexPath) as! VouchersTableViewCell
        cell.numberLabel?.text = addSharp(string: vouchers?[indexPath.row].number ?? "no number")
        cell.dateOffLabel?.text = vouchers?[indexPath.row].dateOff ?? "no dateOff"
        cell.dateReturnLabel?.text = vouchers?[indexPath.row].dateReturn ?? "no returnDate"
        cell.priceLabel?.text = makePrice(price: vouchers?[indexPath.row].price ?? "no price")
        cell.tourLabel?.text = vouchers?[indexPath.row].vouchertour?.name ?? "no tour"
        cell.clientLabel?.text = vouchers?[indexPath.row].voucherclient?.name ?? "no client"
        
        cell.delegate = self
        return cell
    }
    
    // MARK: - add new voucher
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add a voucher", message: "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        alert.isModalInPresentation = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        //textfield voucher number
        var textFieldVoucher = UITextField()
        //datepicker dateoff
        let descriptionLabel1 = UILabel(frame: CGRect(x: 12, y: 55, width: 100, height: 30))
        descriptionLabel1.text = "Set dateOff"
        let dateoffPicker = UIDatePicker(frame: CGRect(x: 133, y: 53, width: 100, height: 30))
        dateoffPicker.datePickerMode = .date
        dateoffPicker.preferredDatePickerStyle = .compact
        //datepicker datereturn
        let descriptionLabel2 = UILabel(frame: CGRect(x: 12, y: 95, width: 130, height: 30))
        descriptionLabel2.text = "Set dateReturn"
        let datereturnPicker = UIDatePicker(frame: CGRect(x: 133, y: 95, width: 100, height: 30))
        datereturnPicker.datePickerMode = .date
        datereturnPicker.preferredDatePickerStyle = .compact
        //textfield voucher price
        var textFieldPrice = UITextField()
        //tourpicker
        tourPicker = UIPickerView(frame: CGRect(x: 5, y: 115, width: 250, height: 130))
        tourPicker.delegate = self
        tourPicker.dataSource = self
        //clientpicker
        clientPicker = UIPickerView(frame: CGRect(x: 5, y: 185, width: 250, height: 130))
        clientPicker.delegate = self
        clientPicker.dataSource = self
        let action = UIAlertAction(title: "Add", style: .default) {(action) in
            if let tourofvoucher = self.chosenTour, let clientofvoucher = self.chosenClient {
                let newVoucher = Voucher()
                //textfield number
                newVoucher.number = textFieldVoucher.text!
                //dateOff and datereturn
                
                newVoucher.dateOff = dateFormatter.string(from: dateoffPicker.date)
                newVoucher.dateReturn = dateFormatter.string(from: datereturnPicker.date)
                //textfild price
                newVoucher.price = textFieldPrice.text!
                //tourpicker
                newVoucher.vouchertour = tourofvoucher
                newVoucher.voucherclient = clientofvoucher
                //check
                if !self.check(primaryKey: newVoucher.number!), self.checkEmpty(primaryKey: newVoucher.number!) {
                    self.save(voucher: newVoucher, tour: tourofvoucher, client: clientofvoucher)
                }
                else {
                    let alert = UIAlertController(title: "This voucher already exists or the name is empty. Try a new name or edit this one.", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else {
                let alert = UIAlertController(title: "Vouchers can't be set without a client and a hotel", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alert, animated: true, completion: nil)
            }
            self.chosenTour = nil
            self.chosenClient = nil
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Write the number of the voucher"
            alertTextField.keyboardType = .numberPad
            textFieldVoucher = alertTextField
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Write the price of the voucher"
            alertTextField.keyboardType = .numberPad
            textFieldPrice = alertTextField
        }
        alert.view.addSubview(descriptionLabel1)
        alert.view.addSubview(dateoffPicker)
        alert.view.addSubview(descriptionLabel2)
        alert.view.addSubview(datereturnPicker)
        alert.view.addSubview(clientPicker)
        alert.view.addSubview(tourPicker)
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true, completion: nil)
        tourPicker.reloadAllComponents()
        clientPicker.reloadAllComponents()
    }
    
    //update
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Edit the voucher", message: "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        alert.isModalInPresentation = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        // label
        let voucherPrimaryKey = UILabel(frame: CGRect(x: 12, y: 35, width: 250, height: 50))
        voucherPrimaryKey.font = UIFont.boldSystemFont(ofSize: 22)
        alert.view.addSubview(voucherPrimaryKey)
        voucherPrimaryKey.text = vouchers?[indexPath.row].number ?? "no voucher"
        //datepicker dateoff
        let descriptionLabel1 = UILabel(frame: CGRect(x: 12, y: 75, width: 100, height: 30))
        descriptionLabel1.text = "Set dateOff"
        let dateoffPicker = UIDatePicker(frame: CGRect(x: 133, y: 73, width: 100, height: 30))
        dateoffPicker.datePickerMode = .date
        dateoffPicker.preferredDatePickerStyle = .compact
        //datepicker datereturn
        let descriptionLabel2 = UILabel(frame: CGRect(x: 12, y: 115, width: 130, height: 30))
        descriptionLabel2.text = "Set dateReturn"
        let datereturnPicker = UIDatePicker(frame: CGRect(x: 133, y: 115, width: 100, height: 30))
        datereturnPicker.datePickerMode = .date
        datereturnPicker.preferredDatePickerStyle = .compact
        //textfield voucher price
        var textFieldPrice = UITextField()
        //tourpicker
        tourPicker = UIPickerView(frame: CGRect(x: 5, y: 135, width: 250, height: 130))
        tourPicker.delegate = self
        tourPicker.dataSource = self
        //clientpicker
        clientPicker = UIPickerView(frame: CGRect(x: 5, y: 205, width: 250, height: 130))
        clientPicker.delegate = self
        clientPicker.dataSource = self
        let action = UIAlertAction(title: "Edit", style: .default) {(action) in
            if let tourofvoucher = self.chosenTour, let clientofvoucher = self.chosenClient {
                let voucher = Voucher()
                //label number
                voucher.number = voucherPrimaryKey.text!
                    
                //dateOff and datereturn
                voucher.dateOff = dateFormatter.string(from: dateoffPicker.date)
                voucher.dateReturn = dateFormatter.string(from: datereturnPicker.date)
                //textfild price
                voucher.price = textFieldPrice.text!
                //tourpicker
                voucher.vouchertour = tourofvoucher
                voucher.voucherclient = clientofvoucher
                self.update(voucher: voucher, tour: tourofvoucher, client: clientofvoucher)
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Write the price of the voucher"
            alertTextField.text = self.vouchers?[indexPath.row].price
            alertTextField.keyboardType = .numberPad
            textFieldPrice = alertTextField
        }
        
        alert.view.addSubview(voucherPrimaryKey)
        alert.view.addSubview(descriptionLabel1)
        dateoffPicker.date = dateFormatter.date(from: (vouchers?[indexPath.row].dateOff)!)!
        alert.view.addSubview(dateoffPicker)
        alert.view.addSubview(descriptionLabel2)
        datereturnPicker.date = dateFormatter.date(from: (vouchers?[indexPath.row].dateReturn)!)!
        alert.view.addSubview(datereturnPicker)
        alert.view.addSubview(clientPicker)
        alert.view.addSubview(tourPicker)
        
        for i in 0..<tourPicker.numberOfRows(inComponent: 0) {
            let pickerTitle = (pickerView(tourPicker, titleForRow: i, forComponent: 0))?.stringBefore(",")
            if self.vouchers?[indexPath.row].vouchertour?.name == pickerTitle {
                tourPicker.selectRow(i, inComponent: 0, animated: true)
                self.chosenTour = realm.objects(Tour.self).filter("name = %@", pickerTitle).first
            }
        }
        
        for i in 0..<clientPicker.numberOfRows(inComponent: 0) {
            let pickerTitle = pickerView(clientPicker, titleForRow: i, forComponent: 0)
            if self.vouchers?[indexPath.row].voucherclient?.name == pickerTitle {
                clientPicker.selectRow(i, inComponent: 0, animated: true)
                self.chosenClient = realm.objects(Client.self).filter("name = %@", pickerTitle).first
            }
        }
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func makePrice(price: String) -> String { price != "" ? "\(price) RUB" : "" }
    
    func addSharp(string: String) -> String { string != "" ? "#\(string)" : "" }

    
    // MARK: - database methods
    
    //save
    func save(voucher: Voucher, tour: Tour, client: Client) {
        do {
            try realm.write {
                tour.tourVouchers.append(voucher)
                client.clientVouchers.append(voucher)
            }
        }
        catch {
            print("error saving")
        }
        tableView.reloadData()
    }
    
    //update
    func update(voucher: Voucher, tour: Tour, client: Client) {
        do {
            try realm.write {
                if let obj = realm.objects(Voucher.self).filter("number = %@", voucher.number).first {
                    realm.delete(obj)
                    realm.add(voucher, update: .modified)
                    tour.tourVouchers.append(voucher)
                    client.clientVouchers.append(voucher)
                }
            }
        }
        catch {
            print("error saving")
        }
        tableView.reloadData()
    }
    
    //load
    func loadItems() {
        vouchers = realm.objects(Voucher.self)
        tableView.reloadData()
    }
    
    //check
    func check(primaryKey: String) -> Bool {
        if let obj = realm.objects(Voucher.self).filter("number = %@", primaryKey).first {
            return true
        }
        return false
    }
    
    //delete
    override func updateModel(at indexPath: IndexPath) {
        if let voucherForDeletion = self.vouchers?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(voucherForDeletion)
                }
            }
            catch {
                print("Error deleting hotel, \(error)")
            }
        }
    }
    
}



extension VouchersTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == tourPicker {
            return realm.objects(Tour.self).count+1
        }
        else /* pickerView == clientPicker */ {
            return realm.objects(Client.self).count+1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == tourPicker {
            if row == 0 {
                return "Choose the tour"
            }
            else {
                tours = realm.objects(Tour.self)
                let titleRow = "\(tours?[row-1].name ?? ""), \(tours?[row-1].tourcity?.name ?? "")"
                return titleRow
            }
        }
        else /* pickerView == clientPicker */ {
            if row == 0 {
                return "Choose the client"
            }
            else {
                clients = realm.objects(Client.self)
                let titleRow = clients?[row-1].name
                return titleRow
            }
        }
        
    }
        
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == tourPicker {
            if row != 0 {
                chosenTour = tours?[row-1]
            }
            else {
                chosenTour = nil
            }
        }
        else /* pickerView == clientPicker */ {
            if row != 0 {
                chosenClient = clients?[row-1]
            }
            else {
                chosenClient = nil
            }
        }
        tourPicker.reloadAllComponents()
        clientPicker.reloadAllComponents()
    }
}

extension VouchersTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ vouchersSearchBar: UISearchBar) {
        vouchers = vouchers?.filter("number CONTAINS[cd] %@", vouchersSearchBar.text as Any).sorted(byKeyPath: "number", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ vouchersSearchBar: UISearchBar, textDidChange searchText: String) {
        if vouchersSearchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                vouchersSearchBar.resignFirstResponder()
            }
        }
    }
}
