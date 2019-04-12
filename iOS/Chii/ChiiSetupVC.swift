//
//  ChiiSetupVC.swift
//  Chii
//
//  Created by Tony Lyu on 3/24/19.
//  Copyright © 2019 Team_XL. All rights reserved.
//

import UIKit
import CoreBluetooth

class ChiiSetupVC: UITableViewController {

    var myParent: MonthlyViewVC?
    let bleManager = CBCentralManager()
    var deviceDiscovered = Set<CBPeripheral>()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        bleManager.delegate = self
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.bluetoothManager = bleManager
    }
    
}

extension ChiiSetupVC: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch(central.state) {
        case .poweredOn:
            bleManager.scanForPeripherals(withServices: nil)
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
