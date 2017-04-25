//
//  ViewController.swift
//  GliderSample
//
//  Created by Guillermo Delgado on 25/04/2017.
//  Copyright © 2017 Guillermo Delgado. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var rightToLeftGlideVC: RDGliderViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        initRightToLeftGlideView()
    }

    func initRightToLeftGlideView() {
        self.rightToLeftGlideVC = RDGliderViewController.init(parent: self,
                                                              WithContent: RDGliderContentViewController.init(lenght: 200.0)!,
                                                              AndType: .RDScrollViewOrientationRightToLeft, WithOffsets: [0,1])
    //    self.rightToLeftGlideVC.delegate = self
    }

// MARK: - Actions

    @IBAction func rightToLeftBtnPressed(_ sender: Any) {
        if (self.rightToLeftGlideVC != nil) {
            if (self.rightToLeftGlideVC?.currentOffsetIndex())! < UInt((self.rightToLeftGlideVC?.offsets.count)! - 1) {
                self.rightToLeftGlideVC?.expand()
            } else {
                self.rightToLeftGlideVC?.shake()
            }
        }
    }
        
}
