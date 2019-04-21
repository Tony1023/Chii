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

class YearTabVC: TabChartsVC {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        daysPerGrid = 30.4
    }
    
    override var startDate: Date? {
        return DateConverter.getYearStart(forUTCDate: date)
    }
    
    override func labelGen(_ index: Int, _ dIndex: Double) -> String {
        return String(index + 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chart.xLabels = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
    }
}

extension YearTabVC: IndicatorInfoProvider {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Year")
    }
    
}
