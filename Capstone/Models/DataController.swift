//
//  DataController.swift
//  Capstone
//
//  Created by Frederik Skytte on 15/03/2019.
//  Copyright © 2019 Frederik Skytte. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    let persistentContainer:NSPersistentContainer
    
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName:String) {
        persistentContainer = NSPersistentContainer(name: modelName)
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
        }
    }
}
