//
//  ViewController.swift
//  ToursDB
//
//  Created by Elena Nazarova on 04.12.2020.
//

import UIKit
import RealmSwift


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        //или self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func clientsPressed(_ sender: UIButton) {
    }
    
    @IBAction func citiesPressed(_ sender: UIButton) {
    }
    
    @IBAction func hotelsPressed(_ sender: UIButton) {
    }
    
    @IBAction func toursPressed(_ sender: UIButton) {
    }
    
    @IBAction func vouchersPressed(_ sender: UIButton) {
    }
}
