//
//  ViewController.swift
//  GliderSample
//
//  Created by Guillermo Delgado on 25/04/2017.
//  Copyright © 2017 Guillermo Delgado. All rights reserved.
//

import UIKit

extension ViewController: RDGliderViewControllerDelegate {
    func glideViewControllerWillExpand(glideViewController: RDGliderViewController) {
        print("Will Expand")
    }
    
    func glideViewControllerDidExpand(glideViewController: RDGliderViewController) {
        print("Did Expand")
    }
    
    func glideViewControllerWillCollapse(glideViewController: RDGliderViewController) {
        print("Will Collapse")
    }
    
    func glideViewControllerDidCollapse(glideViewController: RDGliderViewController) {
        print("Did Collapse")
    }
    
    func glideViewController(glideViewController: RDGliderViewController, hasChangedOffsetOfContent offset: CGPoint) {
        print("New Offset: " + NSStringFromCGPoint(offset))
    }
}

class ViewController: UIViewController {
    
    var rightToLeftGlideVC: RDGliderViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initRightToLeftGlideView()
    }

    func initRightToLeftGlideView() {
        let content:RDGliderContentViewController = RDGliderContentViewController.init(lenght: 0.0)!
        content.view.backgroundColor = UIColor.red
        self.rightToLeftGlideVC = RDGliderViewController.init(parent: self,
                                                              WithContent: content,
                                                              AndType: .RDScrollViewOrientationRightToLeft, WithOffsets: [0.2, 0.6, 1])
        self.rightToLeftGlideVC?.delegate = self
    }

// MARK: - Actions

    @IBAction func rightToLeftBtnPressed(_ sender: Any) {
        if (self.rightToLeftGlideVC != nil) {
            if self.rightToLeftGlideVC!.currentOffsetIndex < Int(self.rightToLeftGlideVC!.offsets.count) - 1 {
                self.rightToLeftGlideVC?.expand()
            } else {
                self.rightToLeftGlideVC?.shake()
            }
        }
    }
        
}
