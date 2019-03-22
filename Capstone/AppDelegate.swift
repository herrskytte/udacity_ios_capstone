//
//  AppDelegate.swift
//  Capstone
//
//  Created by Frederik Skytte on 12/02/2019.
//  Copyright © 2019 Frederik Skytte. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    let dataController = DataController(modelName: "CapstoneDataModel")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.saveContext()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data Saving support
    func saveContext () {
        try? dataController.viewContext.save()
    }
}

// Give singleton access to dataController
extension UIViewController {
    
    var dataController:DataController {
        return (UIApplication.shared.delegate as! AppDelegate).dataController
    }
}
