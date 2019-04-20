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

class YearTabVC: UIViewController {
    
    let series = ChartSeries([0,5,2,3,7,8,5]);
    var date: Date!
    @IBOutlet weak var chart: Chart!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chart.add(series)
    }
    
}

extension YearTabVC: IndicatorInfoProvider {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Year")
    }
    
}
