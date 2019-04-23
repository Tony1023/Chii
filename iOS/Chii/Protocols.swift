//
//  BluetoothServiceProtocol.swift
//  Chii
//
//  Created by Tony Lyu on 4/17/19.
//  Copyright © 2019 Team_XL. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BluetoothServiceDelegate: class {
    func discoveredNewDevice(_ peripheral: CBPeripheral)
}

protocol ReloadDataDelegate: class {
    func onReloadData()
}

protocol AppSharedResources: class {
    var bluetoothManager: CBCentralManager { get }
    var usageData: UsageDataModel { get }
    var chiiDevice: CBPeripheral? { get }
    func connectTo(peripheral: CBPeripheral, completion: (()->Void)?)
}
