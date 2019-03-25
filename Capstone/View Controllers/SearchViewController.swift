//
//  FirstViewController.swift
//  Capstone
//
//  Created by Frederik Skytte on 12/02/2019.
//  Copyright © 2019 Frederik Skytte. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var heroes = [MarvelCharacter]()
    
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = false
        MarvelClient.getCharacters(completion: searchCompleteHandler(heroes:error:))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let detailVC = segue.destination as! HeroDetailsViewController
            detailVC.hero = heroes[selectedIndex]
        }
    }
    
    func searchCompleteHandler(heroes: [MarvelCharacter], error: Error?){
        activityIndicator.isHidden = true
        if let error = error {
            print(error)
            showAlert("Sorry, but the app could not download your heroes: \(error.localizedDescription)")
        }
        else {
            self.heroes = heroes
            self.tableView.reloadData()
        }
    }
    
    fileprivate func showAlert(_ errorText: String) {
        let alertController = UIAlertController(title: "Ooops", message:
            errorText, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            activityIndicator.isHidden = false
            MarvelClient.getCharacters(completion: searchCompleteHandler(heroes:error:))
        }
        else {
            activityIndicator.isHidden = false
            MarvelClient.search(query: searchText, completion: searchCompleteHandler(heroes:error:))
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return heroes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeroTableViewCell") as! HeroCell
   
        let hero = heroes[indexPath.row]
        
        cell.heroNameLabel.text = "\(hero.name)"

        MarvelClient.getImage(imgPath: "\(hero.thumbnail.path).\(hero.thumbnail.ext)") { (data, errror) in
            if let data = data {
                cell.heroImageView.image = UIImage(data: data)
                cell.setNeedsLayout()
            }
            if let errror = errror {
                print(errror)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "showDetail", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
