//
//  CustomCalendarCell.swift
//  Chii
//
//  Created by Tony Lyu on 3/29/19.
//  Copyright © 2019 Team_XL. All rights reserved.
//

import UIKit
import JTAppleCalendar
import MKRingProgressView

class CustomCalendarCell: JTAppleCell {
    
    var date: Date! {
        didSet { }
    }
    
    @IBOutlet weak var cellLabel: UILabel!
    
    @IBOutlet weak var rings: ProgressRingGroupView!
    
    
}