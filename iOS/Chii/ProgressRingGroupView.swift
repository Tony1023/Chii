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
    
    private let puff = RingProgressView()
    
    private func setup() {
        puff.startColor = puffRingStartColor
        puff.endColor = puffRingEndColor
        puff.shadowOpacity = shadowOpacity
        puff.progress = 0.75
        addSubview(puff)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setupPuffRing(toBeVisible visible: Bool, withProgress progress: Double?) {
        self.isVisible = visible
        if let progress = progress {
            puff.progress = progress
        }
    }
    
    private var isVisible = true {
        didSet {
            puff.isHidden = !isVisible
        }
    }
    
    @IBInspectable
    var scale: CGFloat = 0.9
    
    @IBInspectable
    var ringWidthScale: CGFloat = 0.5 {
        didSet {
            let side = min(self.bounds.width, self.bounds.height) * scale
            puff.ringWidth = side * 0.5 * ringWidthScale
        }
    }
    
    @IBInspectable
    var shadowOpacity: CGFloat = 0.5
    
    @IBInspectable
    var puffRingStartColor: UIColor = .blue {
        didSet {
            puff.startColor = puffRingStartColor
        }
    }
    
    @IBInspectable
    var puffRingEndColor: UIColor = .red {
        didSet {
            puff.endColor = puffRingEndColor
        }
    }
    
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
