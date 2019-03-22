//
//  HeroDetailsViewController.swift
//  Capstone
//
//  Created by Frederik Skytte on 15/03/2019.
//  Copyright © 2019 Frederik Skytte. All rights reserved.
//

import UIKit
import CoreData

class HeroDetailsViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var heroNameLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var hero: MarvelCharacter!
    var imageData: Data?
    var savedHero: Hero?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateSaveState()
        
        // Show saved data
        if let savedHero = self.savedHero {
            heroNameLabel.text = savedHero.name
            if let data = savedHero.photo {
                self.imageData = data
                self.imageView.image = UIImage(data: data)
            }
        }
        // Show data from api backend
        else {
            heroNameLabel.text = hero.name
            MarvelClient.getImage(imgPath: "\(hero.thumbnail.path).\(hero.thumbnail.ext)") { (data, errror) in
                if let data = data {
                    self.imageData = data
                    self.imageView.image = UIImage(data: data)
                }
                if let errror = errror {
                    print(errror)
                }
            }
        }
    }
    
    @IBAction func favoriteClicked(_ sender: Any) {
        if let savedHero = self.savedHero {
            // Delete saved hero and close view
            print("Deleting hero \(savedHero.name ?? "x")")
            dataController.viewContext.delete(savedHero)
            try? dataController.viewContext.save()
            _ = navigationController?.popViewController(animated: true)
        }
        else {
            // Save a new hero
            let newHero = Hero(context: dataController.viewContext)
            newHero.heroId = Int64(hero.id)
            newHero.name = hero.name
            if let imageData = self.imageData {
                newHero.photo = imageData
            }
            try? dataController.viewContext.save()
            updateSaveState()
        }
    }
    
    func updateSaveState() {
        if savedHero == nil {
            tryLoadSavedHero()
        }
        
        if savedHero != nil {
            self.favoriteButton.setTitle("Remove from favorites", for: .normal)
        }
        else {
            self.favoriteButton.setTitle("Add to favorites", for: .normal)
        }
    }
    
    func tryLoadSavedHero(){
        let fetchRequest:NSFetchRequest<Hero> = Hero.fetchRequest()
        let predicate = NSPredicate(format: "heroId == %i", hero.id)
        fetchRequest.predicate = predicate
        do {
            let match = try dataController.viewContext.fetch(fetchRequest)
            if match.count > 0 {
                self.savedHero = match[0]
            }
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
}
