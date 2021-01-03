//
//  ToursTableViewController.swift
//  ToursDB
//
//  Created by Elena Nazarova on 13.12.2020.
//

import UIKit
import RealmSwift

class ToursTableViewController: SwipeTableViewController {
    let realm = try! Realm()
    var tours: Results<Tour>?
    var hotels: Results<Hotel>?
    var chosenHotel: Hotel?
    
    @IBOutlet weak var toursSearchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        toursSearchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.estimatedRowHeight = 200 // for example. Set your average height
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.reloadData()
    }
    
    // MARK: - Table methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tours?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToursCell", for: indexPath) as! ToursTableViewCell
        cell.tournameLabel?.text = tours?[indexPath.row].name ?? "no tour"
        cell.agencyLabel?.text = tours?[indexPath.row].agencyName ?? "no agency"
        cell.mealLabel?.text = checkmarkMaker(isChecked: (tours?[indexPath.row].meal ?? false))
        cell.transferLabel?.text = checkmarkMaker(isChecked: (tours?[indexPath.row].transfer ?? false))
        cell.cityLabel?.text = tours?[indexPath.row].tourhotel?.hotelcity?.name ?? "no city"
        cell.hotelLabel?.text = tours?[indexPath.row].tourhotel?.name ?? "no hotel"
        
        //array of vouchers of the tour
        if let numberOfVouchers = tours?[indexPath.row].tourVouchers.count {
            var arrayOfVouchers: [String] = []
            for i in 0..<numberOfVouchers {
                arrayOfVouchers.append(tours?[indexPath.row].tourVouchers[i].number ?? "")
            }
            let stringOfArray = arrayOfVouchers.joined(separator: ", ")
            cell.vouchersLabel.text = stringOfArray
        }
        
        cell.delegate = self
        return cell
    }
    
    // MARK: - Data manipulating methods
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add a tour", message: "\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        alert.isModalInPresentation = true
        //textfields
        var textFieldTour = UITextField()
        var textFieldAgency = UITextField()
        //label and meal
        let mealDescriptionLabel = UILabel(frame: CGRect(x: 18, y: 60, width: 100, height: 30))
        mealDescriptionLabel.text = "meal?"
        let hasMeal = UISwitch(frame: CGRect(x: 189, y: 55, width: 50, height: 20))
        //label and transfer
        let transferDescriptionLabel = UILabel(frame: CGRect(x: 18, y: 90, width: 100, height: 30))
        transferDescriptionLabel.text = "transfer?"
        let hasTransfer = UISwitch(frame: CGRect(x: 189, y: 95, width: 50, height: 20))
        //hotelpicker
        let hotelPicker = UIPickerView(frame: CGRect(x: 5, y: 100, width: 250, height: 130))
        hotelPicker.delegate = self
        hotelPicker.dataSource = self
        alert.view.addSubview(hotelPicker)
        //vouchers
        
        let action = UIAlertAction(title: "Add", style: .default) {(action) in
            if let hoteloftour = self.chosenHotel {
                let newTour = Tour()
                //textfields
                newTour.name = textFieldTour.text!.capitalizingFirstLetter()
                newTour.agencyName = textFieldAgency.text!.capitalizingFirstLetter()
                //switch meal and transfer
                newTour.meal = hasMeal.isOn ? true : false
                newTour.transfer = hasTransfer.isOn ? true : false
                //hotelpicker and the city of the hotel
                newTour.tourhotel = hoteloftour
                newTour.tourcity = hoteloftour.hotelcity
                //check
                if !self.check(primaryKey: newTour.name!), self.checkEmpty(primaryKey: newTour.name!) {
                    self.save(tour: newTour, hotel: hoteloftour)
                }
                else {
                    let alert = UIAlertController(title: "This tour already exists or the name is empty. Try a new name or edit this one.", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    self.present(alert, animated: true, completion: nil)
                    
                }
            }
            else {
                let alert = UIAlertController(title: "Tours can't be set without a hotel", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alert, animated: true, completion: nil)
            }
            self.chosenHotel = nil
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Write the name of the tour"
            textFieldTour = alertTextField
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Write the agency of the tour"
            textFieldAgency = alertTextField
        }
        alert.view.addSubview(hasMeal)
        alert.view.addSubview(mealDescriptionLabel)
        alert.view.addSubview(hasTransfer)
        alert.view.addSubview(transferDescriptionLabel)
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true, completion: nil)
        hotelPicker.reloadAllComponents()
    }
    
    // MARK: - Update selecting
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Edit the tour", message: "\n\n\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        alert.isModalInPresentation = true
        //textfield
        var textFieldAgency = UITextField()
        //label and meal
        let mealDescriptionLabel = UILabel(frame: CGRect(x: 18, y: 85, width: 100, height: 30))
        mealDescriptionLabel.text = "meal?"
        let hasMeal = UISwitch(frame: CGRect(x: 189, y: 80, width: 50, height: 20))
        //label and transfer
        let transferDescriptionLabel = UILabel(frame: CGRect(x: 18, y: 115, width: 100, height: 30))
        transferDescriptionLabel.text = "transfer?"
        let hasTransfer = UISwitch(frame: CGRect(x: 189, y: 120, width: 50, height: 20))
        //hotelpicker
        let hotelPicker = UIPickerView(frame: CGRect(x: 5, y: 125, width: 250, height: 130))
        hotelPicker.delegate = self
        hotelPicker.dataSource = self
        alert.view.addSubview(hotelPicker)
        
        // label
        let tourPrimaryKey = UILabel(frame: CGRect(x: 17, y: 40, width: 250, height: 50))
        tourPrimaryKey.font = UIFont.boldSystemFont(ofSize: 22)
        alert.view.addSubview(tourPrimaryKey)
        tourPrimaryKey.text = tours?[indexPath.row].name ?? "no tour"
        
        let action = UIAlertAction(title: "Edit", style: .default) {(action) in
            if let hoteloftour = self.chosenHotel {
                let tour = Tour()
                tour.name = tourPrimaryKey.text
                tour.agencyName = textFieldAgency.text!.capitalizingFirstLetter()
                //switch meal and transfer
                
                tour.meal = hasMeal.isOn ? true : false
                tour.transfer = hasTransfer.isOn ? true : false
                
                //hotelpicker and the city of the hotel
                tour.tourhotel = hoteloftour
                tour.tourcity = hoteloftour.hotelcity
                
                self.update(tour: tour, hotel: hoteloftour)
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Write the agency of the tour"
            alertTextField.text = self.tours?[indexPath.row].agencyName
            textFieldAgency = alertTextField
        }
        alert.view.addSubview(hasMeal)
        hasMeal.setOn((self.tours?[indexPath.row].meal)!, animated: true)
        alert.view.addSubview(mealDescriptionLabel)
        alert.view.addSubview(hasTransfer)
        hasTransfer.setOn((self.tours?[indexPath.row].transfer)!, animated: true)
        alert.view.addSubview(transferDescriptionLabel)
        
        for i in 0..<hotelPicker.numberOfRows(inComponent: 0) {
            let pickerTitle = (pickerView(hotelPicker, titleForRow: i, forComponent: 0))?.stringBefore(",")
            if self.tours?[indexPath.row].tourhotel?.name == pickerTitle {
                hotelPicker.selectRow(i, inComponent: 0, animated: true)
                self.chosenHotel = realm.objects(Hotel.self).filter("name = %@", pickerTitle).first
            }
        }
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true, completion: nil)
        hotelPicker.reloadAllComponents()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func checkmarkMaker(isChecked: Bool) -> String {
        isChecked ? "✅" : "❌"
    }
    
    // MARK: - database methods
    
    //save
    func save(tour: Tour, hotel: Hotel) {
        do {
            try realm.write {
                hotel.hotelTours.append(tour)
                hotel.hotelcity?.cityTours.append(tour)
            }
        }
        catch {
            print("error saving")
        }
        tableView.reloadData()
    }
    
    //update
    func update(tour: Tour, hotel: Hotel) {
        do {
            try realm.write {
                if let obj = realm.objects(Tour.self).filter("name = %@", tour.name).first {
                    if !obj.tourVouchers.isEmpty {
                        var existingVouchers = [Voucher]()
                        for i in 0..<obj.tourVouchers.count {
                            existingVouchers.append(obj.tourVouchers[i])
                        }
                        realm.delete(obj)
                        realm.add(tour, update: .modified)
                        for existingVoucher in existingVouchers {
                            existingVoucher.vouchertour = tour
                            tour.tourVouchers.append(existingVoucher)
                        }
                        hotel.hotelTours.append(tour)
                        hotel.hotelcity?.cityTours.append(tour)
                    }
                    else {
                        realm.delete(obj)
                        realm.add(tour, update: .modified)
                        hotel.hotelTours.append(tour)
                        hotel.hotelcity?.cityTours.append(tour)
                    }
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
        tours = realm.objects(Tour.self)
        tableView.reloadData()
    }
    
    //check
    func check(primaryKey: String) -> Bool {
        if let obj = realm.objects(Tour.self).filter("name = %@", primaryKey).first {
            return true
        }
        return false
    }

    
    //delete
    override func updateModel(at indexPath: IndexPath) {
        if let tourForDeletion = self.tours?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(tourForDeletion)
                }
            }
            catch {
                print("Error deleting hotel, \(error)")
            }
        }
    }
    
}

// MARK: - Extension UIPickerView
extension ToursTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return realm.objects(Hotel.self).count+1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "Choose the hotel"
        }
        else {
            hotels = realm.objects(Hotel.self)
            let titleRow = "\(hotels?[row-1].name ?? ""), \(hotels?[row-1].hotelcity?.name ?? "")"
            return titleRow
        }
    }
        
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row != 0 {
            chosenHotel = hotels?[row-1]
        }
        else {
            chosenHotel = nil
        }
    }

}

// MARK: - UISEARCHBAR
extension ToursTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ toursSearchBar: UISearchBar) {
        tours = tours?.filter("name CONTAINS[cd] %@", toursSearchBar.text as Any).sorted(byKeyPath: "name", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ toursSearchBar: UISearchBar, textDidChange searchText: String) {
        if toursSearchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                toursSearchBar.resignFirstResponder()
            }
        }
    }
}
