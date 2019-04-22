//
//  DailyUsageVC.swift
//  Chii
//
//  Created by Tony Lyu on 4/7/19.
//  Copyright © 2019 Team_XL. All rights reserved.
//

import UIKit
import JTAppleCalendar
import MKRingProgressView

class DailyUsageVC: UIViewController {
    
    var date: Date!
    @IBOutlet weak var weekView: JTAppleCalendarView! {
        didSet {
            weekView.minimumLineSpacing = 0
            weekView.minimumInteritemSpacing = 0
        }
    }
    @IBOutlet weak var progressArea: DailyProgressView!
    @IBOutlet weak var puffNumber: UILabel!
    @IBOutlet weak var dailyGoal: UILabel!
    @IBOutlet weak var puffPercent: UILabel!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var noDataLabel: UILabel!
    
    @IBAction func tapped(_ sender: Any) {
        updateUI()
    }
    private weak var shared: AppSharedResources!
    private var needsUpdateUI = false {
        didSet {
            if needsUpdateUI, view.window != nil { updateUI() }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        shared = appDelegate
        appDelegate.dailyViewReloadDelegate = self
    }
    
    private func updateUI() {
        needsUpdateUI = false
        weekView.reloadData()
        if let data = shared.usageData.dailyUsage[date] {
            noDataLabel.isHidden = true
            let percentage = Double(data.puffs) / data.average
            progressArea.setupRing(toBeVisible: true, withProgress: percentage)
            puffNumber.text = String(data.puffs)
            dailyGoal.text = "/\(Int(data.average)) puffs"
            puffPercent.text = String(format: "%.0f", percentage * 100)
            text.text = "% usage"
    
            let scale: CGFloat = 42.0 / 60.0
            self.puffNumber.transform = .identity
            puffNumber.font = puffNumber.font.withSize(60)
            UIView.animate(withDuration: 1.0, animations: {
                self.puffNumber.transform = CGAffineTransform(scaleX: scale, y: scale)
            })
        } else {
            progressArea.setupRing(toBeVisible: false)
            noDataLabel.isHidden = false
            puffNumber.text = nil
            dailyGoal.text = nil
            puffPercent.text = nil
            text.text = nil
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weekView.scrollToDate(DateConverter.convert2LocalDate(fromUTCDate: date), triggerScrollToDateDelegate: false, animateScroll: false, preferredScrollPosition: nil, extraAddedOffset: 0.0)
        if let data = shared.usageData.dailyUsage[date] {
            noDataLabel.isHidden = true
            let percentage = Double(data.puffs) / data.average
            progressArea.setupRing(toBeVisible: true, withProgress: percentage)
            puffNumber.text = String(data.puffs)
            dailyGoal.text = "/\(Int(data.average)) puffs"
            puffPercent.text = String(format: "%.0f", percentage * 100)
        } else {
            progressArea.setupRing(toBeVisible: false)
            noDataLabel.isHidden = false
            puffNumber.text = nil
            dailyGoal.text = nil
            puffPercent.text = nil
            text.text = nil
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if needsUpdateUI { updateUI() }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let identifier = segue.identifier else { return }
        if identifier ==  "LoadEmbeddedCharts", let embeddedVC = segue.destination as? EmbeddedChartsVC {
            embeddedVC.date = date
        }
    }
}

extension DailyUsageVC: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let localDate = DateConverter.convert2LocalDate(fromUTCDate: date)
        let params = ConfigurationParameters(startDate: localDate, endDate: localDate, numberOfRows: 1, calendar: Calendar.current, generateInDates: .forAllMonths, generateOutDates: .tillEndOfRow, firstDayOfWeek: DaysOfWeek(rawValue: 1)!)
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
        let key = DateConverter.convert2UTC(from: date)
        if let cellData = shared.usageData.dailyUsage[key] {
            cell.rings.setupPuffRing(toBeVisible: true, withProgress: Double(cellData.puffs) / cellData.average)
        } else {
            cell.rings.setupPuffRing(toBeVisible: false)
        }
    }
    
    
}

extension DailyUsageVC: ReloadDataDelegate {
    func onReloadData() {
        needsUpdateUI = true
    }
}
