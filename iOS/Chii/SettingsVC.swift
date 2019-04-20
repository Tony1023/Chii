//
//  SecondViewController.swift
//  Chii
//
//  Created by Tony Lyu on 3/24/19.
//  Copyright © 2019 Team_XL. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {
    
    private var needsReload = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
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
        needsReload = true
    }
}

