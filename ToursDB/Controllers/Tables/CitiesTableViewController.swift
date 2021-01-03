//
//  CitiesTableViewController.swift
//  ToursDB
//
//  Created by Elena Nazarova on 04.12.2020.
//

import UIKit
import RealmSwift

class CitiesTableViewController: SwipeTableViewController {
    let realm = try! Realm()
    var cities: Results<City>?
    
    @IBOutlet weak var citiesSearchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        citiesSearchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.estimatedRowHeight = 150
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CitiesCell", for: indexPath) as! CitiesTableViewCell
        cell.citynameLabel?.text = cities?[indexPath.row].name ?? "no city"
        cell.countrynameLabel?.text = cities?[indexPath.row].countryName ?? "no country"
        
        //array of hotels in the city
        if let numberOfHotels = cities?[indexPath.row].cityHotels.count {
            var arrayOfHotels: [String] = []
            for i in 0..<numberOfHotels {
                arrayOfHotels.append(cities?[indexPath.row].cityHotels[i].name ?? "")
            }
            let stringOfArray = arrayOfHotels.joined(separator: ", ")
            cell.hotelsLabel?.text = stringOfArray
        }
        //array of tours in the city
        if let numberOfTours = cities?[indexPath.row].cityTours.count {
            var arrayOfTours: [String] = []
            for i in 0..<numberOfTours {
                arrayOfTours.append(cities?[indexPath.row].cityTours[i].name ?? "")
            }
            let stringOfArray = arrayOfTours.joined(separator: ", ")
            cell.toursLabel?.text = stringOfArray
        }
        cell.delegate = self
        return cell
    }
    
    // MARK: - Data manipulating methods
    // update
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Edit the city", message: "\n\n", preferredStyle: .alert)
        alert.isModalInPresentation = true
        
        // label of city name
        let cityPrimaryKey = UILabel(frame: CGRect(x: 17, y: 40, width: 250, height: 50))
        cityPrimaryKey.font = UIFont.boldSystemFont(ofSize: 22)
        alert.view.addSubview(cityPrimaryKey)
        cityPrimaryKey.text = cities?[indexPath.row].name ?? "no city"
        
        // country
        var textFieldCountry = UITextField()
        
        let action = UIAlertAction(title: "Edit", style: .default) {(action) in
            let city = City()
            city.name = cityPrimaryKey.text
            city.countryName = textFieldCountry.text!.capitalizingFirstLetter()
                
            self.update(city: city)
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Write the countryname"
            alertTextField.text = self.cities?[indexPath.row].countryName
            textFieldCountry = alertTextField
        }
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // add
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textFieldName = UITextField()
        var textFieldCountry = UITextField()
        
        let alert = UIAlertController(title: "Add a city", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newCity = City()
           
            newCity.name = textFieldName.text!.capitalizingFirstLetter()
            newCity.countryName = textFieldCountry.text!.capitalizingFirstLetter()
            
            //check
            if !self.check(primaryKey: newCity.name!), self.checkEmpty(primaryKey: newCity.name!) {
                self.save(city: newCity)
            }
            else {
                let alert = UIAlertController(title: "This city already exists or the name is empty. Try a new name or edit this one.", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Write the name of the city"
            textFieldName = alertTextField
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Write the country"
            textFieldCountry = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Database Methods

    // save
    func save(city: City) {
        do {
            try realm.write {
                realm.add(city)
                //city.cityHotels.append(objectsIn: realm.objects(Hotel.self).filter("hotelcity.name = %@", city.name))
            }
        }
        catch {
            print("error")
        }
        tableView.reloadData()
    }
    
    // update
    func update(city: City) {
        do {
            try realm.write {
                realm.add(city, update: .modified)
                city.cityHotels.append(objectsIn: realm.objects(Hotel.self).filter("hotelcity.name = %@", city.name))
                city.cityTours.append(objectsIn: realm.objects(Tour.self).filter("tourcity.name = %@", city.name))
            }
        }
        catch {
            print("error")
        }
        tableView.reloadData()
    }
    
    // load
    func loadItems() {
        cities = realm.objects(City.self)
        tableView.reloadData()
    }
    
    // delete
    override func updateModel(at indexPath: IndexPath) {
        if let cityForDeletion = self.cities?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(cityForDeletion)
                }
            }
            catch {
                print("Error deleting city, \(error)")
            }
        }
    }
    
    // check
    func check(primaryKey: String) -> Bool {
        if let obj = realm.objects(City.self).filter("name = %@", primaryKey).first {
            return true
        }
        return false
    }
    
}

// MARK: - UISEARCHBAR
extension CitiesTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ citiesSearchBar: UISearchBar) {
        cities = cities?.filter("name CONTAINS[cd] %@", citiesSearchBar.text as Any).sorted(byKeyPath: "name", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ citiesSearchBar: UISearchBar, textDidChange searchText: String) {
        if citiesSearchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                citiesSearchBar.resignFirstResponder()
            }
        }
    }
}
