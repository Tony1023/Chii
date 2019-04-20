//
//  DailyProgressView.swift
//  Chii
//
//  Created by Tony Lyu on 4/16/19.
//  Copyright © 2019 Team_XL. All rights reserved.
//

import UIKit
import MKRingProgressView

@IBDesignable
class DailyProgressView: UIView {
    
    private var ring = RingProgressView();
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        ring.startColor = .startRed
        ring.endColor = .endBlue
        ring.shadowOpacity = shadowOpacity
        ring.gradientImageScale = gradient
        addSubview(ring)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        ring.shadowOpacity = shadowOpacity
        ring.gradientImageScale = gradient
        addSubview(ring)
    }
    
    func setupRing(toBeVisible visible: Bool, withProgress progress: Double? = nil) {
        self.isVisible = visible
        if let progress = progress {
            ring.progress = progress
            if progress > 1.0 {
                ring.startColor = .startRed
                ring.endColor = .endRed
            } else {
                ring.startColor = .startBlue
                ring.endColor = .endBlue
            }
        }
    }
    
    var isVisible = true {
        didSet {
            ring.isHidden = !isVisible
        }
    }
    
    @IBInspectable
    var scale: CGFloat = 0.9
    
    @IBInspectable
    var shadowOpacity: CGFloat = 0.5
    
    @IBInspectable
    var gradient: CGFloat = 0.1
    
    @IBInspectable
    var ringWidthScale: CGFloat = 0.2 {
        didSet {
            let side = min(self.bounds.width, self.bounds.height) * scale
            ring.ringWidth = side * 0.5 * ringWidthScale
        }
    }
    
    private var ringRingWidth: CGFloat {
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
        ring.ringWidth = ringRingWidth
        ring.frame = CGRect(origin: ringFrameOrigin, size: ringFrameSize)
    }
}
