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
    private var usageData = [Date: Data]()
    private var currentMonth: String! {
        didSet {
            yearLabel.setTitle(currentMonth!, for: .normal)
        }
    }
    private weak var dailyUsageVC: DailyUsageVC?
    private weak var appDelegate: AppDelegate!
    private var firstLoad = true
    
    private struct Data {
        var date: Date
        var puffs: Int
        var average: Double
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate.activityReloadDelegate = self
        UTCFormatter.timeZone = TimeZone(abbreviation: "UTC")
        UTCFormatter.dateFormat = "yyyy.MM.dd"
    }

    private func updateMonthYear(from visibleDates: DateSegmentInfo) {
        guard let date = visibleDates.monthDates.first?.date else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MMM"
        currentMonth = formatter.string(from: date)
    }
    
    private func fetchUsageData() {
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DailyUsage")
        request.returnsObjectsAsFaults = false
        do {
            let sort = NSSortDescriptor(key: "date", ascending: true)
            request.sortDescriptors = [sort]
            let result = try context.fetch(request)
            var dataArray = [Data]()
            for data in result as! [NSManagedObject] {
                let date = data.value(forKey: "date") as! Date
                let puffs = data.value(forKey: "puffs") as! Int
                dataArray.append(MonthlyViewVC.Data(date: date, puffs: puffs, average: 0.0))
            }
            var sum: Int = 0
            for i in 0..<dataArray.count {
                sum += dataArray[i].puffs
                if i >= 14 {
                    sum -= dataArray[i - 14].puffs
                }
                dataArray[i].average = Double(sum) / ((i + 1) >= 14 ? 14.0: Double(i + 1))
                usageData[dataArray[i].date] = dataArray[i]
            }
            
        } catch {
            print("Fetching database went wrong")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        monthYearFormatter.dateFormat = "yyyy MMM"
        yearLabel.setTitle(monthYearFormatter.string(from: Date()), for: .normal)
        currentMonth = monthYearFormatter.string(from: Date())
        calendarView.scrollToDate(monthYearFormatter.date(from: currentMonth)!, triggerScrollToDateDelegate: false, animateScroll: false, preferredScrollPosition: nil, extraAddedOffset: 0.0) { [weak self] in
            self?.fetchUsageData()
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
        if identifier == "toChiiSetup", let _ = segue.destination as? ChiiSetupVC {
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
        } else if identifier == "toDailyUsage", let dailyUsageVC = segue.destination as? DailyUsageVC {
            if let tappedCell = sender as? CustomCalendarCell {
                dailyUsageVC.date = tappedCell.date
                self.dailyUsageVC = dailyUsageVC
            }
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: currentMonth, style: .plain, target: nil, action: nil)
        }
    }
    
}

extension MonthlyViewVC: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    // Preloads cell to improve performance
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let customCell = cell as! CustomCalendarCell
        prepareCell(forCell: customCell, atDate: date, cellState: cellState)
    }
    
    // Loads cell
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCalendarCell", for: indexPath) as! CustomCalendarCell
        prepareCell(forCell: cell, atDate: date, cellState: cellState)
        return cell
    }
    
    // Make adjustments after each scroll
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        self.updateMonthYear(from: visibleDates)
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let localFormatter = DateFormatter()
        localFormatter.timeZone = Calendar.current.timeZone
        localFormatter.locale = Calendar.current.locale
        localFormatter.dateFormat = "yyyy.MM.dd"
        let startDate = localFormatter.date(from: "2019.01.01")
        let endDate = localFormatter.date(from: "2019.12.31")
        calendar.scrollingMode = .nonStopToCell(withResistance: 1.0)
        let params = ConfigurationParameters(startDate: startDate!, endDate: endDate!, numberOfRows: 6, calendar: Calendar.current, generateInDates: .forFirstMonthOnly, generateOutDates: .off, firstDayOfWeek: DaysOfWeek(rawValue: 7)!, hasStrictBoundaries: false)
        return params;
    }
    
    private func prepareCell(forCell cell: CustomCalendarCell, atDate date: Date, cellState: CellState) {
        print(date)
        cell.date = date
        cell.cellLabel.text = cellState.text
        if Calendar.current.isDateInToday(date) {
            cell.cellLabel.textColor = .red
        } else {
            cell.cellLabel.textColor = .black
        }
        let key = converter.convert2UTC(from: date)
        if let cellData = usageData[key] {
            cell.rings.setupPuffRing(toBeVisible: true, withProgress: Double(cellData.puffs) / cellData.average)
        } else {
            cell.rings.setupPuffRing(toBeVisible: false)
        }
    }
    
}

extension MonthlyViewVC: ReloadDataDelegate {
    func onReloadData() {
        fetchUsageData()
//        dailyUsageVC?.reloadData()
    }
}
