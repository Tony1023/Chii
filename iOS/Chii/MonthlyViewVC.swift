//
//  FirstViewController.swift
//  Chii
//
//  Created by Tony Lyu on 3/24/19.
//  Copyright © 2019 Team_XL. All rights reserved.
//

import UIKit
import JTAppleCalendar
import MKRingProgressView
import CoreData

class MonthlyViewVC: UIViewController {
    
    private let converter = CustomDateConverter()
    private let UTCFormatter = DateFormatter()
    private let monthYearFormatter = DateFormatter()
    @IBOutlet private weak var calendarView: JTAppleCalendarView! {
        didSet {
            calendarView.minimumLineSpacing = 0
            calendarView.minimumInteritemSpacing = 0
        }
    }
    @IBOutlet private weak var yearLabel: UIButton!
    private weak var usageData: UsageDataModel!
    private var currentMonth: String! {
        didSet {
            yearLabel.setTitle(currentMonth!, for: .normal)
        }
    }
    private weak var dailyUsageVC: DailyUsageVC?
    private var needsReload = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.monthlyViewReloadDelegate = self
        usageData = appDelegate.usageDataModel
        UTCFormatter.timeZone = TimeZone(abbreviation: "UTC")
        UTCFormatter.dateFormat = "yyyy.MM.dd"
    }

    private func updateMonthYear(from visibleDates: DateSegmentInfo) {
        guard let date = visibleDates.monthDates.first?.date else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MMM"
        currentMonth = formatter.string(from: date)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        monthYearFormatter.dateFormat = "yyyy MMM"
        yearLabel.setTitle(monthYearFormatter.string(from: Date()), for: .normal)
        currentMonth = monthYearFormatter.string(from: Date())
        calendarView.scrollToDate(monthYearFormatter.date(from: currentMonth)!, triggerScrollToDateDelegate: false, animateScroll: false, preferredScrollPosition: nil, extraAddedOffset: 0.0) { [weak self] in
            self?.calendarView.reloadData()
            self?.calendarView.scrollingMode = .nonStopToSection(withResistance: 1.0)
        }
        calendarView.visibleDates { visibleDates in self.updateMonthYear(from: visibleDates) }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let identifier = segue.identifier else { return }
        if identifier == "ToChiiSetup", let _ = segue.destination as? ChiiSetupVC {
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
        } else if identifier == "ToDailyUsage", let dailyUsageVC = segue.destination as? DailyUsageVC {
            if let tappedCell = sender as? CustomCalendarCell {
                dailyUsageVC.date = tappedCell.date
                self.dailyUsageVC = dailyUsageVC
            }
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: currentMonth, style: .plain, target: nil, action: nil)
        }
    }
    
}

extension MonthlyViewVC: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let localFormatter = DateFormatter()
        localFormatter.timeZone = Calendar.current.timeZone
        localFormatter.locale = Calendar.current.locale
        localFormatter.dateFormat = "yyyy.MM.dd"
        let startDate = localFormatter.date(from: "2019.01.01")
        let endDate = localFormatter.date(from: "2019.12.31")
        calendar.scrollingMode = .nonStopToCell(withResistance: 1.0)
        let params = ConfigurationParameters(startDate: startDate!, endDate: endDate!, numberOfRows: 6, calendar: Calendar.current, generateInDates: .forAllMonths, generateOutDates: .tillEndOfRow, firstDayOfWeek: DaysOfWeek(rawValue: 7)!)
        return params;
    }
    
    // Preloads cell to improve performance
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let customCell = cell as! CustomCalendarCell
        prepare(forCell: customCell, atDate: date, cellState: cellState)
    }
    
    // Loads cell
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCalendarCell", for: indexPath) as! CustomCalendarCell
        prepare(forCell: cell, atDate: date, cellState: cellState)
        return cell
    }
    
    // Make adjustments after each scroll
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        self.updateMonthYear(from: visibleDates)
    }
    
    private func prepare(forCell cell: CustomCalendarCell, atDate date: Date, cellState: CellState) {
        cell.date = date
        cell.cellLabel.text = cellState.text
        if Calendar.current.isDateInToday(date) {
            cell.cellLabel.textColor = .red
        } else if cellState.dateBelongsTo == .thisMonth {
            cell.cellLabel.textColor = .black
            let key = converter.convert2UTC(from: date)
            if let cellData = usageData.dailyUsage[key] {
                cell.rings.setupPuffRing(toBeVisible: true, withProgress: Double(cellData.puffs) / cellData.average)
            } else {
                cell.rings.setupPuffRing(toBeVisible: false)
            }
        } else {
            cell.cellLabel.textColor = .gray
            cell.rings.setupPuffRing(toBeVisible: false)
        }
    }
    
}

extension MonthlyViewVC: ReloadDataDelegate {
    func onReloadData() {
        needsReload = true
    }
}
