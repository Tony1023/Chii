//
//  SecondViewController.swift
//  Chii
//
//  Created by Tony Lyu on 3/24/19.
//  Copyright © 2019 Team_XL. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {
    
    private weak var appDelegate: AppDelegate!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate.settingsReloadDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Appeared")
    }


}

extension SettingsVC: ReloadDataDelegate {
    func onReloadData() {
        // Reload with new connection
    }
}

