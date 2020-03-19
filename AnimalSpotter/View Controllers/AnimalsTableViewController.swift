//
//  AnimalsTableViewController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 4/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AnimalsTableViewController: UITableViewController {
    
    // MARK: - Properties
    private let apiController = APIController()
    private var animalNames: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // transition to login view if conditions require
        // pretending that we're persisting login
        if apiController.bearer == nil {
            performSegue(withIdentifier: "LoginViewModalSegue", sender: self)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animalNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnimalCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = animalNames[indexPath.row]

        return cell
    }

    // MARK: - Actions
    
    @IBAction func getAnimals(_ sender: UIBarButtonItem) {
        // fetch all animals from API
        apiController.fetchAllAnimalsNames { (result) in
            do {
                let names = try result.get()
                DispatchQueue.main.async {
                    self.animalNames = names
                }
            } catch {
                if let error = error as? NetworkError {
                    switch error {
                    case .noAuth:
                        print("Error: No bearer token exists.")
                    case .unauthorized:
                        print("Error: Bearer token invalid.")
                    case .noData:
                        print("Error: The response had no data.")
                    case .decodeFailed:
                        print("Error: The data could not be decoded.")
                    case .otherError(let otherError):
                        print("Error: \(otherError)")
                    }
                } else {
                    print("Error: \(error)")
                }
            }
        }
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginViewModalSegue",
            let loginVC = segue.destination as? LoginViewController {
            // inject dependencies
            loginVC.apiController = apiController
        } else if segue.identifier == "ShowAnimalDetailSegue",
            let detailVC = segue.destination as? AnimalDetailViewController,
            let selectedIndexPath = tableView.indexPathForSelectedRow {
            detailVC.apiController = apiController
            detailVC.animalName = animalNames[selectedIndexPath.row]
        }
    }
}
