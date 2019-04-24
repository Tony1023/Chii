//
//  LaunchVideoVC.swift
//  Chii
//
//  Created by Tony Lyu on 4/23/19.
//  Copyright © 2019 Team_XL. All rights reserved.
//

import UIKit
import SwiftyGif

class LaunchAnimationVC: UIViewController {
    
    @IBOutlet weak var gifView: UIImageView!
    var path: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let path = Bundle.main.path(forResource: "launchGif", ofType: "gif") else {
            self.path = nil
            return
        }
        self.path = path
        gifView.setGifFromURL(URL(fileURLWithPath: path), manager: SwiftyGifManager.defaultManager, loopCount: 1, showLoader: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if path == nil {
            performSegue(withIdentifier: "LoadInitialView", sender: nil)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                self.gifView.stopAnimatingGif()
                self.performSegue(withIdentifier: "LoadInitialView", sender: nil)
            }
        }
    }
}
