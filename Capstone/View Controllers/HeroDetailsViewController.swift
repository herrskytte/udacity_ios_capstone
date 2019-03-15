//
//  HeroDetailsViewController.swift
//  Capstone
//
//  Created by Frederik Skytte on 15/03/2019.
//  Copyright © 2019 Frederik Skytte. All rights reserved.
//

import UIKit

class HeroDetailsViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var heroNameLabel: UILabel!
    @IBOutlet weak var watchlistBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var favoriteBarButtonItem: UIBarButtonItem!
    
    var hero: MarvelCharacter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        heroNameLabel.text = hero.name
        
        MarvelClient.getImage(imgPath: "\(hero.thumbnail.path).\(hero.thumbnail.ext)") { (data, errror) in
            if let data = data {
                self.imageView.image = UIImage(data: data)
            }
            if let errror = errror {
                print(errror)
            }
        }
    }
}
