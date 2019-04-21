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

class TabChartsVC: UIViewController {
    
    var date: Date! {
        didSet {
            start = startDate
        }
    }
    private var start: Date?
    var needsReloadData = true
    var daysPerGrid = 1.0
    private var needsUpdateUI = false
    private weak var shared: AppSharedResources!
    private weak var context: NSManagedObjectContext!
    private var chartData: [(x: Double, y: Double)]!
    @IBOutlet weak var chart: Chart!
    
    var startDate: Date? { return nil }
    
    func labelGen(_ index: Int, _ dIndex: Double) -> String { return "" }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        shared = appDelegate
        context = appDelegate.persistentContainer.viewContext
    }
    
    private func updateUI() {
        chart.removeAllSeries()
        let series = ChartSeries(data: chartData)
        series.area = true
        series.colors = (above: UIColor.startRed, below: UIColor.endBlue, zeroLevel: shared.usageData.grandAverage)
        chart.add(series)
        needsUpdateUI = false
    }
    
    private func fetchData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DailyUsage")
        request.returnsObjectsAsFaults = false
        guard let start = self.start else { return }
        do {
            let sort = NSSortDescriptor(key: "date", ascending: true)
            let from = NSPredicate(format: "date >= %@", start as NSDate)
            let to = NSPredicate(format: "date <= %@", date as NSDate)
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [from, to])
            request.sortDescriptors = [sort]
            request.predicate = predicate
            let result = try context.fetch(request)
            var chartData = Array(repeating: (x: 0.0, y: 0.0), count: result.count)
            for i in 0..<result.count {
                let data = result[i] as! NSManagedObject
                let puff = data.value(forKey: "puffs") as! Int
                let date = data.value(forKey: "date") as! Date
                let daysSinceStart = date.timeIntervalSince(start) / 86400
                chartData[i].x = daysSinceStart / daysPerGrid
                chartData[i].y = Double(puff)
            }
            DispatchQueue.main.async { [weak self] in
                if self != nil, self?.view.window != nil{
                    self?.chartData = chartData
                    self?.updateUI()
                }
            }
        } catch {
            print("Week tab fetching db error")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chart.xLabelsFormatter = labelGen
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if needsUpdateUI {
            updateUI()
        }
        if needsReloadData {
            needsUpdateUI = true
            needsReloadData = false
            DispatchQueue.global(qos: .userInteractive).async(execute: fetchData)
        }
    }
    
}
