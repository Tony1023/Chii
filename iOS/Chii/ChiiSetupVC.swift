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

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    var myParent: MonthlyViewVC?
    private weak var shared: AppSharedResources!
    private var deviceDiscovered = [String: CBPeripheral]()
    private var deviceNames = [String]() {
        didSet {
            tableView.reloadData()
        }
    }


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.setupDelegate = self
        shared = appDelegate
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceDiscovered.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath)
        cell.textLabel?.text = deviceNames[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = deviceNames[indexPath.row]
        shared.connectTo(peripheral: deviceDiscovered[name]!) { [weak self] in
            self?.dismiss(animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shared.bluetoothManager.state == .poweredOn {
            shared.bluetoothManager.scanForPeripherals(withServices: [CBUUID(string: "b1a67521-52eb-4d36-e13e-357d7c225465")])
        }
        if shared.chiiDevice?.state == .connected {
            // update icon
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        shared.bluetoothManager.stopScan()
    }

}

extension ChiiSetupVC: BluetoothServiceDelegate {
    func discoveredNewDevice(_ peripheral: CBPeripheral) {
        if let displayName = peripheral.name {
            if (deviceDiscovered[displayName] == nil) {
                deviceDiscovered[displayName] = peripheral
                deviceNames.append(displayName)
            }
        }
    }
}
