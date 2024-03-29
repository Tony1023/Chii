//
//  ActivityNavigationVC.swift
//  Chii
//
//  Created by Tony Lyu on 4/12/19.
//  Copyright © 2019 Team_XL. All rights reserved.
//

import UIKit

class ActivityNavigationVC: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let dailyUsageVC = self.storyboard?.instantiateViewController(withIdentifier: "dailyUsage") as? DailyUsageVC {
            dailyUsageVC.date = DateConverter.convert2UTC(from: Date())
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy MMM"
            viewControllers.first!.navigationItem.backBarButtonItem = UIBarButtonItem(title: formatter.string(from: Date()), style: .plain, target: nil, action: nil)
            dailyUsageVC.navigationItem.title = "Today"
            pushViewController(dailyUsageVC, animated: false)
        }
    }
}
