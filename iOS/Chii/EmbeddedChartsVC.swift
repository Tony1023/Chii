//
//  EmbeddedChartsVC.swift
//  Chii
//
//  Created by Tony Lyu on 4/18/19.
//  Copyright © 2019 Team_XL. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class EmbeddedChartsVC: ButtonBarPagerTabStripViewController {

    let purpleInspireColor = UIColor(red:0.13, green:0.03, blue:0.25, alpha:1.0)
    
    var date: Date!
    
    private var weekTabVC: WeekTabVC!
    private var monthTabVC: MonthTabVC!
    private var yearTabVC: YearTabVC!
    
    func setNeedsUpdateCharts() {
        weekTabVC.needsReloadData = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // change selected bar color
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = purpleInspireColor
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .black
            newCell?.label.textColor = self?.purpleInspireColor
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        moveTo(viewController: weekTabVC, animated: false)
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        weekTabVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WeekTab") as? WeekTabVC
        monthTabVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MonthTab") as? MonthTabVC
        yearTabVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "YearTab") as? YearTabVC
        weekTabVC.date = date
        monthTabVC.date = date
        yearTabVC.date = date
        return [yearTabVC, monthTabVC, weekTabVC]
    }
}
