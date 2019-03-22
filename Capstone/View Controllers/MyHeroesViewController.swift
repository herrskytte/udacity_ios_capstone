//
//  SecondViewController.swift
//  Capstone
//
//  Created by Frederik Skytte on 12/02/2019.
//  Copyright © 2019 Frederik Skytte. All rights reserved.
//

import UIKit
import CoreData

class MyHeroesViewController: UICollectionViewController {
    
    var fetchedResultsController:NSFetchedResultsController<Hero>!
    var selectedHero: Hero?
    
    @IBOutlet weak var collectionFlowLayout: UICollectionViewFlowLayout!
    
    let space:CGFloat = 8.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFetchedResultsController()
        
        self.collectionFlowLayout.minimumInteritemSpacing = space
        self.collectionFlowLayout.minimumLineSpacing = space
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check the current width of the app and resize accordingly
        let horizontalWidth = UIDevice.current.orientation.isPortrait ?
            view.frame.size.width : view.frame.size.height
        
        updateFlowLayoutProperties(toWidth: horizontalWidth)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // When swithcing between landscape and portrait get the new width of the app and resize accordingly
        updateFlowLayoutProperties(toWidth: size.width)
    }
    
    // MARK: Private helper fuctions
    fileprivate func updateFlowLayoutProperties(toWidth width: CGFloat){
        print("Horizontal width \(width). Is portrait? \(UIDevice.current.orientation.isPortrait)")
        
        let heroesPerRow: CGFloat = UIDevice.current.orientation.isPortrait ? 3.0 : 4.0
        let dimension = (width - ((heroesPerRow - 1.0) * self.space)) / heroesPerRow
        
        print("Setting size for images to \(dimension)")
        self.collectionFlowLayout.itemSize = CGSize(width: dimension, height: dimension)
        self.collectionFlowLayout.invalidateLayout()
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Hero> = Hero.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailFromFavorites" {
            let detailVC = segue.destination as! HeroDetailsViewController
            detailVC.savedHero = self.selectedHero
        }
    }
}

// Collection view handler extension
extension MyHeroesViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Size of collection \(fetchedResultsController.sections?[0].numberOfObjects ?? 0)")
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "heroPhoto", for: indexPath) as! ImageCell
        
        let hero = fetchedResultsController.object(at: indexPath)
        
        // Set the image
        if let data = hero.photo {
            cell.photoImageView?.image = UIImage(data: data)
        }
        else {
            cell.photoImageView?.image = UIImage(imageLiteralResourceName: "placeholder_superhero")
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        selectedHero = fetchedResultsController.object(at: indexPath)
        print("Item selected")
        performSegue(withIdentifier: "showDetailFromFavorites", sender: nil)
    }
}

extension MyHeroesViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        print("Controller change of type: \(type)")
        
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
            break
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
            break
        case .update:
            collectionView.reloadItems(at: [indexPath!])
        case .move:
            collectionView.moveItem(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        print("Controller section change of type: \(type)")
        
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: collectionView.insertSections(indexSet)
        case .delete: collectionView.deleteSections(indexSet)
        case .update, .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:).")
        }
    }
    
}
