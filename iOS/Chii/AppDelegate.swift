//
//  AppDelegate.swift
//  Chii
//
//  Created by Tony Lyu on 3/24/19.
//  Copyright © 2019 Team_XL. All rights reserved.
//

import UIKit
import CoreData
import CoreBluetooth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        bluetoothManager = CBCentralManager()
        bluetoothManager.delegate = self
        removeData()
        preLoadData()
        fetchUsageData()
        return true
    }
    
    var usageDataModel = UsageDataModel()
    var bluetoothManager: CBCentralManager!
    private var deviceDiscovered = Set<CBPeripheral>()
    weak var monthlyViewReloadDelegate: ReloadDataDelegate?
    weak var settingsReloadDelegate: ReloadDataDelegate?
    weak var dailyViewReloadDelegate: ReloadDataDelegate?
    
    private func fetchUsageData() {
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DailyUsage")
        request.returnsObjectsAsFaults = false
        do {
            let sort = NSSortDescriptor(key: "date", ascending: true)
            request.sortDescriptors = [sort]
            let result = try context.fetch(request)
            var dataArray = [UsageDataModel.Data]()
            for data in result as! [NSManagedObject] {
                let date = data.value(forKey: "date") as! Date
                let puffs = data.value(forKey: "puffs") as! Int
                dataArray.append(UsageDataModel.Data(date: date, puffs: puffs, average: 0.0))
            }
            var sum: Int = 0
            for i in 0..<dataArray.count {
                sum += dataArray[i].puffs
                if i >= 14 {
                    sum -= dataArray[i - 14].puffs
                }
                dataArray[i].average = Double(sum) / ((i + 1) >= 14 ? 14.0: Double(i + 1))
                usageDataModel.dailyUsage[dataArray[i].date] = dataArray[i]
            }
            
        } catch {
            print("Fetching database went wrong")
        }
    }
    
    // Adding dummy data to application
    private func preLoadData() {
        let context = persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "DailyUsage", in: context)!
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        let dateString = formatter.string(from: today)
        formatter.timeZone = TimeZone(identifier: "UTC")
        var date = formatter.date(from: dateString)!
        for _ in 1...60 {
            date = date.addingTimeInterval(-86400)
            let newData = NSManagedObject(entity: entity, insertInto: context)
            newData.setValue(date, forKey: "date")
            newData.setValue(Int.random(in: 30...45), forKey: "puffs")
        }
        saveContext()
    }

    // Removing the previously added dummy data
    private func removeData() {
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DailyUsage")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                context.delete(data)
            }
        } catch {
            print("Fetching database went wrong")
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Go try to connect to the last connected ble device
        // pull data
        // update data
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

protocol ReloadDataDelegate: class {
    func onReloadData()
}

extension AppDelegate: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch(central.state) {
        case .poweredOn:
            bluetoothManager.scanForPeripherals(withServices: [CBUUID(string: "b1a67521-52eb-4d36-e13e-357d7c225465")])
        default:
            break
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !deviceDiscovered.contains(peripheral) {
            deviceDiscovered.insert(peripheral)
            print(peripheral.name ?? "Anonymous")
            
        }
    }
}
