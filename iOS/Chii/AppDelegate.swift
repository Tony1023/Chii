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
import GameKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        _bluetoothManager = CBCentralManager()
        _bluetoothManager.delegate = self
        removeData()
        preLoadData()
        fetchUsageData()
        return true
    }
    
    private var _usageDataModel: UsageDataModel!
    private var _bluetoothManager: CBCentralManager!
    private var _chiiDevice: CBPeripheral?
    weak var monthlyViewReloadDelegate: ReloadDataDelegate?
    weak var settingsReloadDelegate: ReloadDataDelegate?
    weak var dailyViewReloadDelegate: ReloadDataDelegate?
    weak var setupDelegate: BluetoothServiceDelegate?
    private var completionHandler: (()->Void)?
    
    fileprivate var timestamps = [UInt32]() {
        didSet {
            DispatchQueue.global(qos: .userInteractive).async {
                self.storeNewData()
                self.fetchUsageData()
                DispatchQueue.main.async {
                    self.dailyViewReloadDelegate?.onReloadData()
                    self.monthlyViewReloadDelegate?.onReloadData()
                    self.settingsReloadDelegate?.onReloadData()
                }
            }
        }
    }
    
    // self will not be nil since it's appdelegate
    private func fetchUsageData() {
        _usageDataModel = UsageDataModel()
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
                dataArray.append(UsageDataModel.Data(date: date, puffs: puffs, average: 0.0, streak: 0))
            }
            var runningSum: Int = 0
            var grandSum: Int = 0
            var runningStreak: Int = 0
            for i in 0..<dataArray.count {
                runningSum += dataArray[i].puffs
                grandSum += dataArray[i].puffs
                if i >= 14 {
                    runningSum -= dataArray[i - 14].puffs
                }
                dataArray[i].average = Double(runningSum) / ((i + 1) >= 14 ? 14.0: Double(i + 1))
                if Double(dataArray[i].puffs) < dataArray[i].average {
                    runningStreak += 1
                } else {
                    runningStreak = 0
                }
                dataArray[i].streak = runningStreak
                _usageDataModel.dailyUsage[dataArray[i].date] = dataArray[i]
            }
            _usageDataModel.grandAverage = Double(grandSum) / Double(dataArray.count)
            if let first = dataArray.first {
                _usageDataModel.firstDay = first.date
            }
        } catch {
            print("Fetching database went wrong")
        }
    }
    
    private func storeNewData() {
        let lastSync = UserDefaults.standard.value(forKey: "lastSync") as? Double ?? Date().timeIntervalSinceReferenceDate
        UserDefaults.standard.set(Date().timeIntervalSinceReferenceDate, forKey: "lastSync")
        do {
            let context = persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "DailyUsage", in: context)!
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DailyUsage")
            request.returnsObjectsAsFaults = false
            for deltaTime in timestamps {
                let time = Double(deltaTime * 60) + lastSync
                let puffTime = DateConverter.convert2UTC(from: Date(timeIntervalSinceReferenceDate: time))
                let predicate = NSPredicate(format: "date = %@", puffTime as NSDate)
                request.predicate = predicate
                let result = try context.fetch(request)
                if result.count == 1 {
                    let entry = result[0] as! NSManagedObject
                    let puffs = entry.value(forKey: "puffs") as! Int
                    entry.setValue(puffs + 1, forKey: "puffs")
                } else if result.count == 0 {
                    let newEntry = NSManagedObject(entity: entity, insertInto: context)
                    newEntry.setValue(puffTime, forKey: "date")
                    newEntry.setValue(1, forKey: "puffs")
                } else {
                    throw NSError()
                }
                saveContext()
            }
            
        } catch {
            print("Updating value error")
        }
    }
    
    // Adding dummy data to application
    private func preLoadData() {
        let context = persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "DailyUsage", in: context)!
        var date = DateConverter.convert2UTC(from: Date())
        let random = GKRandomSource()
        var upperLimit = 40.0, lowerLimit = 20.0
        let newData = NSManagedObject(entity: entity, insertInto: context)
        newData.setValue(date, forKey: "date")
        newData.setValue(Int(lowerLimit) / 2, forKey: "puffs")
        for _ in 1...100 {
            let dice = GKGaussianDistribution(randomSource: random, lowestValue: Int(lowerLimit), highestValue: Int(upperLimit))
            date = date.addingTimeInterval(-86400)
            let newData = NSManagedObject(entity: entity, insertInto: context)
            newData.setValue(date, forKey: "date")
            newData.setValue(dice.nextInt(), forKey: "puffs")
            upperLimit += 0.1
            lowerLimit += 0.04
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
        if _chiiDevice != nil {
            _bluetoothManager.cancelPeripheralConnection(_chiiDevice!)
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if _chiiDevice?.state != .connected, _chiiDevice?.state != .connecting {
            if let uuid = UserDefaults.standard.string(forKey: "lastConnectedDevice") {
                let id = UUID(uuidString: uuid)!
                _chiiDevice = bluetoothManager.retrievePeripherals(withIdentifiers: [id])[0]
                if (!(_chiiDevice?.state == .connected || _chiiDevice?.state == .connecting)) {
                    _bluetoothManager.connect(_chiiDevice!)
                }
            }
        }
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

extension AppDelegate: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        setupDelegate?.discoveredNewDevice(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral.state == .connected {
            UserDefaults.standard.set(peripheral.identifier.uuidString, forKey: "lastConnectedDevice")
            print("Connected")
            peripheral.delegate = self
            peripheral.discoverServices(nil)
            _chiiDevice = peripheral
        }
    }
}

extension AppDelegate: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        DispatchQueue.global(qos: .userInteractive).async {
            if let data = characteristic.value {
                var dataArray = [UInt32]()
                var runningSum: UInt32 = 0
                for i in 0..<data.count {
                    if i % 4 == 0 {
                        runningSum = 0
                    }
                    runningSum *= 256
                    runningSum += UInt32(data[i])
                    if i % 4 == 3 {
                        dataArray.append(runningSum)
                    }
                }
                self.timestamps = dataArray
            }
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("Characteristic discovered")
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            peripheral.readValue(for: characteristic)
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let handler = completionHandler {
            handler()
            completionHandler = nil
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Service discovered")
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
}

extension AppDelegate: AppSharedResources {
    
    func connectTo(peripheral: CBPeripheral, completion: (() -> Void)?) {
        _bluetoothManager.connect(peripheral)
        completionHandler = completion
    }
    
    var bluetoothManager: CBCentralManager { return self._bluetoothManager }
    
    var usageData: UsageDataModel { return self._usageDataModel }
    
    var chiiDevice: CBPeripheral? { return self._chiiDevice }
}
