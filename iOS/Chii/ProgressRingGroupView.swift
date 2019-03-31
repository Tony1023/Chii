//
//  ProgressRingGroupView.swift
//  Chii
//
//  Created by Tony Lyu on 3/30/19.
//  Copyright © 2019 Team_XL. All rights reserved.
//

import UIKit
import MKRingProgressView

@IBDesignable
class ProgressRingGroupView: UIView {
    
    private let pullRing = RingProgressView()
    private let timeRing = RingProgressView()
    private lazy var allRings: [RingProgressView] = [pullRing, timeRing]
    
    private var ringWidth: CGFloat! {
        didSet {
            for ring in allRings { ring.ringWidth = ringWidth }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        for ring in allRings {
            ring.startColor = .red
            ring.endColor = .magenta
            ring.gradientImageScale = 0.5
            addSubview(ring)
        }
    }
    
    // set to false when needed to be hidden (e.g. no data found for the day)
    var isVisible: Bool! {
        didSet {
            for ring in allRings { ring.isHidden = !isVisible }
        }
    }
    
    @IBInspectable
    var shadowOpacity: CGFloat {
        get { return pullRing.shadowOpacity }
        set(opacity) { for ring in allRings { ring.shadowOpacity = opacity} }
    }
    
    @IBInspectable
    var pullRingStartColor: UIColor {
        get { return pullRing.startColor }
        set(newColor) { pullRing.startColor = newColor }
    }
    
    @IBInspectable
    var pullRingEndColor: UIColor {
        get { return pullRing.endColor }
        set(newColor) { pullRing.endColor = newColor }
    }
    
    @IBInspectable
    var timeRingStartColor: UIColor {
        get { return timeRing.startColor }
        set(newColor) { timeRing.startColor = newColor }
    }
    
    @IBInspectable
    var timeRingEndColor: UIColor {
        get { return timeRing.endColor }
        set(newColor) { timeRing.endColor = newColor }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var side = min(self.bounds.width, self.bounds.height)
        ringWidth = side / (CGFloat(allRings.count) * 2 + 1)
        var ringFrameOrigin: CGPoint {
            get { return CGPoint(x: self.bounds.midX - side / 2, y: self.bounds.midY - side / 2) }
        }
        var ringFrameSize: CGSize {
            get { return CGSize(width: side, height: side) }
        }
        pullRing.frame = CGRect(origin: ringFrameOrigin, size: ringFrameSize)
        side -= ringWidth * 2
        timeRing.frame = CGRect(origin: ringFrameOrigin, size: ringFrameSize)
    }
    
}
