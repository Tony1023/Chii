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

class MonthTabVC: UIViewController {
    
    let series = ChartSeries([4,1,2,3,7,8,5]);
    var date: Date!
    @IBOutlet weak var chart: Chart!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chart.add(series)
        print(CustomDateConverter.getMonthStart(forLocalDate: Date()))
        print(CustomDateConverter.getMonthEnd(forLocalDate: Date()))
    }
    
}

extension MonthTabVC: IndicatorInfoProvider {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Month")
    }
    
}
