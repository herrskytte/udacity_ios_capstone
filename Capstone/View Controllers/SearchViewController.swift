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
    
    var heroes = [MarvelCharacter]()
    
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MarvelClient.getCharacters(completion: searchCompleteHandler(heroes:error:))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            //let detailVC = segue.destination as! MovieDetailViewController
            //detailVC.movie = movies[selectedIndex]
        }
    }
    
    func searchCompleteHandler(heroes: [MarvelCharacter], error: Error?){
        if let error = error {
            print(error)
        }
        else {
            self.heroes = heroes
            self.tableView.reloadData()
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            MarvelClient.getCharacters(completion: searchCompleteHandler(heroes:error:))
        }
        else {
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
        //MarvelClient.getImage(imgPath: hero.thumbnail.path) { (data, errror) in
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
