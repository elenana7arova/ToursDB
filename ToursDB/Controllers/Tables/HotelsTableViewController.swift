//
//  HotelsTableViewController.swift
//  ToursDB
//
//  Created by Elena Nazarova on 04.12.2020.
//

import UIKit
import RealmSwift

class HotelsTableViewController: SwipeTableViewController {
    let realm = try! Realm()
    var hotels: Results<Hotel>?
    var cities: Results<City>?
    var chosenCity: City?
    
    @IBOutlet weak var hotelsSearchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        hotelsSearchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.estimatedRowHeight = 135
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hotels?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HotelsCell", for: indexPath) as! HotelsTableViewCell
        cell.hotelNameLabel?.text = hotels?[indexPath.row].name ?? "no hotel"

        let starsQuantity = Int(hotels?[indexPath.row].stars ?? "")
        cell.starsLabel?.text = starsMaker(quantity: starsQuantity ?? 0)
        cell.citynameLabel?.text = hotels?[indexPath.row].hotelcity?.name ?? "no city"

        if let numberOfTours = hotels?[indexPath.row].hotelTours.count {
            var arrayOfTours: [String] = []
            for i in 0..<numberOfTours {
                arrayOfTours.append(hotels?[indexPath.row].hotelTours[i].name ?? "")
            }
            let stringArray = arrayOfTours.joined(separator: ", ")
            cell.toursLabel?.text = stringArray
        }
        
        cell.delegate = self
        return cell
    }
    
    // MARK: - Data manipulating methods
    // update
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Edit the hotel", message: "\n\n\n\n\n\n", preferredStyle: .alert)
        alert.isModalInPresentation = true
        
        // cityPicker
        let cityPicker = UIPickerView(frame: CGRect(x: 5, y: 40, width: 250, height: 130))
        alert.view.addSubview(cityPicker)
        cityPicker.delegate = self
        cityPicker.dataSource = self

        // label
        let hotelPrimaryKey = UILabel(frame: CGRect(x: 17, y: 40, width: 250, height: 50))
        hotelPrimaryKey.font = UIFont.boldSystemFont(ofSize: 22)
        alert.view.addSubview(hotelPrimaryKey)
        hotelPrimaryKey.text = hotels?[indexPath.row].name ?? "no hotel"
        
        // stars
        var textFieldStars = UITextField()
        
        let action = UIAlertAction(title: "Edit", style: .default) {(action) in
            if let cityofhotel = self.chosenCity {
                let hotel = Hotel()
                hotel.name = hotelPrimaryKey.text
                hotel.stars = textFieldStars.text!
                hotel.hotelcity = cityofhotel
                self.update(hotel: hotel, city: cityofhotel)
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Write the amount of stars"
            alertTextField.text = self.hotels?[indexPath.row].stars
            textFieldStars = alertTextField
        }
        
        for i in 0..<cityPicker.numberOfRows(inComponent: 0) {
            if self.hotels?[indexPath.row].hotelcity?.name == pickerView(cityPicker, titleForRow: i, forComponent: 0) {
                cityPicker.selectRow(i, inComponent: 0, animated: true)
                self.chosenCity = realm.objects(City.self).filter("name = %@", pickerView(cityPicker, titleForRow: i, forComponent: 0)).first
            }
        }
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true, completion: nil)
        cityPicker.reloadAllComponents()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // add
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add a hotel", message: "\n\n\n\n\n\n", preferredStyle: .alert)
        alert.isModalInPresentation = true
        
        var textFieldHotel = UITextField()
        var textFieldStars = UITextField()
        let cityPicker = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
        
        alert.view.addSubview(cityPicker)
        cityPicker.delegate = self
        cityPicker.dataSource = self
        
        let action = UIAlertAction(title: "Add", style: .default) {(action) in
            if let cityofhotel = self.chosenCity {
                let newHotel = Hotel()
                newHotel.name = textFieldHotel.text!.capitalizingFirstLetter()
                newHotel.stars = textFieldStars.text!

                newHotel.hotelcity = cityofhotel
                //check
                if self.check(primaryKey: newHotel.name!), self.checkEmpty(primaryKey: newHotel.name!) {
                    self.save(hotel: newHotel, city: cityofhotel)
                }
                else {
                    let alert = UIAlertController(title: "This hotel already exists or the name is empty. Try a new name or edit this one.", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else {
                let alert = UIAlertController(title: "Hotels can't be set without a city", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alert, animated: true, completion: nil)
            }
            self.chosenCity = nil
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Write the name of the hotel"
            textFieldHotel = alertTextField
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Write the amount of stars"
            textFieldStars = alertTextField
        }
        
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true, completion: nil)
    }

    func starsMaker(quantity: Int) -> String {
        var starsString: String = ""
        switch quantity {
        case 1:
            starsString = "⭐️"
        case 2:
            starsString = "⭐️ ⭐️"
        case 3:
            starsString = "⭐️ ⭐️ ⭐️"
        case 4:
            starsString = "⭐️ ⭐️ ⭐️ ⭐️"
        case 5:
            starsString = "⭐️ ⭐️ ⭐️ ⭐️ ⭐️"
        default:
            starsString = ""
        }
        return starsString
    }
    
    // MARK: - Database Methods
    
    // save
    func save(hotel: Hotel, city: City) {
        do {
            try realm.write {
                city.cityHotels.append(hotel)
            }
        }
        catch {
            print("error saving")
        }
        tableView.reloadData()
    }
    
    //update
    func update(hotel: Hotel, city: City) {
        do {
            try realm.write {
                if let obj = realm.objects(Hotel.self).filter("name = %@", hotel.name).first {
                    if !obj.hotelTours.isEmpty {
                        var existingTours = [Tour]()
                        for i in 0..<obj.hotelTours.count {
                            existingTours.append(obj.hotelTours[i])
                            //print(obj.hotelTours[i].name)   2
                        }
                        realm.delete(obj)
                        realm.add(hotel, update: .modified)
                        for existingTour in existingTours {
                            //print(existingTour.name)        3
                            existingTour.tourhotel = hotel
                            hotel.hotelTours.append(existingTour)
                        }
                        city.cityHotels.append(hotel)
                    }
                    else {
                        realm.delete(obj)
                        realm.add(hotel, update: .modified)
                        city.cityHotels.append(hotel)
                    }
                }
            }
            
        }
        catch {
            print("Error saving \(error)")
        }
        tableView.reloadData()
    }
    

    //load
    func loadItems() {
        hotels = realm.objects(Hotel.self)
        tableView.reloadData()
    }
    
    //check
    func check(primaryKey: String) -> Bool { realm.objects(Hotel.self).filter("name = %@", primaryKey).first != nil ? false : true}
    
    
    //delete
    override func updateModel(at indexPath: IndexPath) {
        if let hotelForDeletion = self.hotels?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(hotelForDeletion)
                }
            }
            catch {
                print("Error deleting hotel, \(error)")
            }
        }
    }
    
    
}
// MARK: - Extension UIPickerView
extension HotelsTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return realm.objects(City.self).count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "Choose the city"
        }
        else {
            cities = realm.objects(City.self)
            let titleRow = cities?[row-1].name
            return titleRow
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row != 0 {
            chosenCity = cities?[row-1]
        }
        else {
            chosenCity = nil
        }
    }
    
}

// MARK: - UISEARCHBAR
extension HotelsTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ hotelsSearchBar: UISearchBar) {
        hotels = hotels?.filter("name CONTAINS[cd] %@", hotelsSearchBar.text as Any).sorted(byKeyPath: "name", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ hotelsSearchBar: UISearchBar, textDidChange searchText: String) {
        if hotelsSearchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                hotelsSearchBar.resignFirstResponder()
            }
        }
    }
}
