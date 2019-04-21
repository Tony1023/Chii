//
//  WeekTabVCViewController.swift
//  Chii
//
//  Created by Tony Lyu on 4/18/19.
//  Copyright © 2019 Team_XL. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SwiftChart
import CoreData
import JTAppleCalendar

class WeekTabVC: TabChartsVC {
    
    private let labels = ["S", "M", "T", "W", "T", "F", "S"]
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        daysPerGrid = 1.0
    }
    
    override var startDate: Date? {
        return DateConverter.getWeekStart(forUTCDate: date)
    }
    
    override func labelGen(_ index: Int, _ dIndex: Double) -> String {
        return labels[index]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chart.xLabels = [0, 1, 2, 3, 4, 5, 6]
    }
    
}

extension WeekTabVC: IndicatorInfoProvider {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Week")
    }
    
}
