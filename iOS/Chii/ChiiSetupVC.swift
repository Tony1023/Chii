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

    var myParent: ActivityVC?
    let bleManager = CBCentralManager()
    var deviceDiscovered = Set<CBPeripheral>()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        bleManager.delegate = self
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        self.presentingViewController?.dismiss(animated: true) {
            if let activity = self.myParent {
                activity.loadChii(with: "Success")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
