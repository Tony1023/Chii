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

class ActivityVC: UIViewController {
    
    private let converter = CustomDateConverter()
    private let localFormatter = DateFormatter()
    private let UTCFormatter = DateFormatter()
    private let monthParser = DateFormatter()
    @IBOutlet weak var calendarView: JTAppleCalendarView! {
        didSet {
            calendarView.minimumLineSpacing = 0
            calendarView.minimumInteritemSpacing = 0
        }
    }
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    private var usageData = [Date: Data]()
    
    private struct Data {
        var date: Date
        var puffs: Int
        var average: Double
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UTCFormatter.timeZone = TimeZone(abbreviation: "UTC")
        UTCFormatter.dateFormat = "yyyy.MM.dd"
        localFormatter.dateFormat = "yyyy.MM.dd"
        localFormatter.timeZone = Calendar.current.timeZone
        localFormatter.locale = Calendar.current.locale
        monthParser.timeZone = Calendar.current.timeZone
        monthParser.dateFormat = "MMM"
    }
    
    func loadChii(with arg: String) {
        calendarView.reloadData()
    }
    
    private func updateMonthYear(from visibleDates: DateSegmentInfo) {
        guard let date = visibleDates.monthDates.first?.date else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        yearLabel.text = formatter.string(from: date)
        formatter.dateFormat = "MMMM"
        monthLabel.text = formatter.string(from: date)
    }
    
    private func fetchUsageData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
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
                dataArray.append(ActivityVC.Data(date: date, puffs: puffs, average: 0.0))
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        fetchUsageData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.visibleDates { visibleDates in
            self.updateMonthYear(from: visibleDates)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let navigationVC = segue.destination as? UINavigationController else { return }
        guard let chiiSetup = navigationVC.viewControllers.first as? ChiiSetupVC else { return }
        chiiSetup.myParent = self
    }
    
}

extension ActivityVC: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let customCell = cell as! CustomCalendarCell
        prepareCell(forCell: customCell, atDate: date, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        self.updateMonthYear(from: visibleDates)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCalendarCell", for: indexPath) as! CustomCalendarCell
        prepareCell(forCell: cell, atDate: date, cellState: cellState)
        return cell
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let startDate = localFormatter.date(from: "2019.01.01")
        let endDate = localFormatter.date(from: "2019.12.31")
        calendar.scrollingMode = .none
        
        let params = ConfigurationParameters(startDate: startDate!, endDate: endDate!, numberOfRows: 6, calendar: Calendar.current, generateInDates: .forFirstMonthOnly, generateOutDates: .off, firstDayOfWeek: DaysOfWeek(rawValue: 7)!, hasStrictBoundaries: false)
        return params;
    }
    
    private func prepareCell(forCell cell: CustomCalendarCell, atDate date: Date, cellState: CellState) {
        let month = monthParser.string(from: date)
        cell.cellLabel.text = cellState.text
        cell.monthLabel.text = cellState.text == "1" ? month : " "
        let key = converter.convert2UTC(from: date)
        if let cellData = usageData[key] {
            cell.rings.setupPuffRing(toBeVisible: true, withProgress: Double(cellData.puffs) / cellData.average)
        } else {
            cell.rings.setupPuffRing(toBeVisible: false, withProgress: nil)
        }
    }
    
}
