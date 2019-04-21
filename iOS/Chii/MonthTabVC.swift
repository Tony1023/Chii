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

class MonthTabVC: TabChartsVC {
    
    private let labels = ["1", "6", "11", "16", "21", "26", "31"]
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        daysPerGrid = 5.0
    }
    
    override var startDate: Date? {
        return DateConverter.getMonthStart(forUTCDate: date)
    }
    
    override func labelGen(_ index: Int, _ dIndex: Double) -> String {
        return labels[index]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chart.xLabels = [0, 1, 2, 3, 4, 5, 6]
    }
    
}

extension MonthTabVC: IndicatorInfoProvider {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Month")
    }
    
}
