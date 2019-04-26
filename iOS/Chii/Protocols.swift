//
//  BluetoothServiceProtocol.swift
//  Chii
//
//  Created by Tony Lyu on 4/17/19.
//  Copyright © 2019 Team_XL. All rights reserved.
//

import UIKit
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
    var isConnected: Bool { get }
}


extension UIColor {
    class var startBlue: UIColor { get { return UIColor(red: 159.0/255.0, green: 219.0/255.0, blue: 236.0/255.0, alpha: 1.0) } }
    class var endBlue: UIColor { get { return UIColor(red: 87.0/255.0, green: 203.0/255.0, blue: 245.0/255.0, alpha: 1.0) } }
    class var startRed: UIColor { get { return UIColor(red: 233.0/255.0, green: 101.0/255.0, blue: 101.0/255.0, alpha: 1.0) } }
    class var endRed: UIColor { get { return UIColor(red: 182.0/255.0, green: 54.0/255.0, blue: 51.0/255.0, alpha: 1.0) } }
    class var appTint: UIColor{ get { return UIColor(red: 115.0/255.0, green: 201.0/255.0, blue: 241.0/255.0, alpha: 1.0) } }
}
