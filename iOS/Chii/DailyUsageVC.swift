//
//  DailyUsageVC.swift
//  Chii
//
//  Created by Tony Lyu on 4/7/19.
//  Copyright © 2019 Team_XL. All rights reserved.
//

import UIKit
import JTAppleCalendar

class DailyUsageVC: UIViewController {
    
    var date: Date!
    @IBOutlet weak var weekView: JTAppleCalendarView! {
        didSet {
            weekView.minimumLineSpacing = 0
            weekView.minimumInteritemSpacing = 0
        }
    }
    private weak var usageData: UsageDataModel!
    private var needsReload = false
    private let converter = CustomDateConverter()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        usageData = appDelegate.usageDataModel
        appDelegate.dailyViewReloadDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weekView.scrollToDate(date, triggerScrollToDateDelegate: false, animateScroll: false, preferredScrollPosition: nil, extraAddedOffset: 0.0) {
            [weak self] in
            self?.weekView.scrollDirection = .none
        }
    }
}

extension DailyUsageVC: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let params = ConfigurationParameters(startDate: date!, endDate: date!, numberOfRows: 1, calendar: Calendar.current, generateInDates: .forAllMonths, generateOutDates: .tillEndOfRow, firstDayOfWeek: DaysOfWeek(rawValue: 7)!)
        calendar.scrollingMode = .nonStopToCell(withResistance: 1.0)
        return params
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = cell as! CustomCalendarCell
        prepare(forCell: cell, atDate: date, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "WeekCell", for: indexPath) as! CustomCalendarCell
        prepare(forCell: cell, atDate: date, cellState: cellState)
        return cell
    }
    
    private func prepare(forCell cell: CustomCalendarCell, atDate date: Date, cellState: CellState) {
        let key = converter.convert2UTC(from: date)
        if let cellData = usageData.dailyUsage[key] {
            cell.rings.setupPuffRing(toBeVisible: true, withProgress: Double(cellData.puffs) / cellData.average)
        } else {
            cell.rings.setupPuffRing(toBeVisible: false)
        }
    }
    
    
}

extension DailyUsageVC: ReloadDataDelegate {
    func onReloadData() {
        needsReload = true
    }
}
