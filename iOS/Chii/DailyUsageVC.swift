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
    @IBOutlet weak var chiiButton: UIBarButtonItem!
    @IBOutlet weak var progressArea: DailyProgressView!
    @IBOutlet weak var puffNumber: UILabel!
    @IBOutlet weak var dailyGoal: UILabel!
    @IBOutlet weak var puffPercent: UILabel!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var topLabelWrapper: UIView!
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var dayCountLabel: UILabel!
    
    private weak var shared: AppSharedResources!
    private var needsUpdateUI = false {
        didSet {
            if needsUpdateUI, view.window != nil { updateUI() }
        }
    }
    private var noData: Bool {
        get { return topLabelWrapper.isHidden }
        set {
            noDataLabel.isHidden = !newValue
            topLabelWrapper.isHidden = newValue
            if newValue {
                puffNumber.text = nil
                dailyGoal.text = nil
                puffPercent.text = nil
                text.text = nil
                progressArea.setupRing(toBeVisible: false)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        shared = appDelegate
        appDelegate.dailyViewReloadDelegate = self
    }
    
    private func updateUI() {
        if shared.isConnected {
            chiiButton.tintColor = .appTint
        } else {
            chiiButton.tintColor = .gray
        }
        if needsUpdateUI { weekView.reloadData() }
        if let data = shared.usageData.dailyUsage[date] {
            noData = false
            // Streaks and day count
            dayCountLabel.text = "Day \(Int(date.timeIntervalSince(shared.usageData.firstDay) / 86400))"
            streakLabel.text = "Streak \(data.streak)"
            let percentage = Double(data.puffs) / data.average.rounded(.towardZero)
            progressArea.setupRing(toBeVisible: true, withProgress: percentage)
            puffNumber.text = String(data.puffs)
            let newPuff = "/\(Int(data.average.rounded(.towardZero))) puffs"
            dailyGoal.text = "/\(Int(data.average.rounded(.towardZero))) puffs"
            puffPercent.text = String(format: "%.0f", percentage * 100)
            text.text = "% usage"
    
            if dailyGoal.text != newPuff {
                dailyGoal.text = newPuff
                if needsUpdateUI {
                    let scale: CGFloat = 42.0 / 60.0
                    self.puffNumber.transform = .identity
                    puffNumber.font = puffNumber.font.withSize(60)
                    UIView.animate(withDuration: 1.0, animations: {
                        self.puffNumber.transform = CGAffineTransform(scaleX: scale, y: scale)
                    })
                }
            }
        } else {
            noData = true
        }
        needsUpdateUI = false
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weekView.scrollToDate(DateConverter.convert2LocalDate(fromUTCDate: date), triggerScrollToDateDelegate: false, animateScroll: false, preferredScrollPosition: nil, extraAddedOffset: 0.0)
        updateUI()
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
