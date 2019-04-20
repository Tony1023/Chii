//
//  ProgressRingGroupView.swift
//  Chii
//
//  Created by Tony Lyu on 3/30/19.
//  Copyright © 2019 Team_XL. All rights reserved.
//

import UIKit
import MKRingProgressView

class CalendarRingView: UIView {
    
    private let puff = RingProgressView()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        puff.startColor = .startRed
        puff.endColor = .endBlue
        puff.shadowOpacity = shadowOpacity
        puff.gradientImageScale = gradient
        
        addSubview(puff)
    }
    
    func setupPuffRing(toBeVisible visible: Bool, withProgress progress: Double? = nil) {
        self.isVisible = visible
        if let progress = progress {
            puff.progress = progress
            if progress > 1.0 {
                puff.startColor = .startRed
                puff.endColor = .endRed
            } else {
                puff.startColor = .startBlue
                puff.endColor = .endBlue
            }
        }
    }
    
    var isVisible = true {
        didSet {
            puff.isHidden = !isVisible
        }
    }
    
    var scale: CGFloat = 0.9
    
    var ringWidthScale: CGFloat = 0.35 {
        didSet {
            let side = min(self.bounds.width, self.bounds.height) * scale
            puff.ringWidth = side * 0.5 * ringWidthScale
        }
    }
    
    var shadowOpacity: CGFloat = 0.5
    
    var gradient: CGFloat = 0.4
    
    private var puffRingWidth: CGFloat {
        get {
            let side = min(self.bounds.width, self.bounds.height) * scale
            return side * 0.5 * ringWidthScale
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var side = min(self.bounds.width, self.bounds.height) * scale
        var ringFrameOrigin: CGPoint {
            get { return CGPoint(x: self.bounds.midX - side / 2, y: self.bounds.midY - side / 2) }
        }
        var ringFrameSize: CGSize {
            get { return CGSize(width: side, height: side) }
        }
        puff.ringWidth = puffRingWidth
        puff.frame = CGRect(origin: ringFrameOrigin, size: ringFrameSize)
    }
    
}

extension UIColor {
    class var startBlue: UIColor { get { return UIColor(red: 159.0/255.0, green: 219.0/255.0, blue: 236.0/255.0, alpha: 1.0) } }
    class var endBlue: UIColor { get { return UIColor(red: 87.0/255.0, green: 203.0/255.0, blue: 245.0/255.0, alpha: 1.0) } }
    class var startRed: UIColor { get { return UIColor(red: 233.0/255.0, green: 101.0/255.0, blue: 101.0/255.0, alpha: 1.0) } }
    class var endRed: UIColor { get { return UIColor(red: 182.0/255.0, green: 54.0/255.0, blue: 51.0/255.0, alpha: 1.0) } }
}
