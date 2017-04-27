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
    var bottomToTopGlideVC: RDGliderViewController? = nil
    var leftToRightGlideVC: RDGliderViewController? = nil
    var topToBottomGlideVC: RDGliderViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initRightToLeftGlideView()
        initBottomToTopGlideView()
        initLeftToRightGlideView()
        initTopToBottomGlideView()
    }

    func initRightToLeftGlideView() {
        let content:RDGliderContentViewController = RDGliderContentViewController.init()
        content.view.backgroundColor = UIColor.red
        content.showShadow = true
        content.cornerRadius = 20.0
        
        self.rightToLeftGlideVC = RDGliderViewController.init(parent: self,
                                                              WithContent: content,
                                                              AndType: .RDScrollViewOrientationRightToLeft,
                                                              WithOffsets: [0, 0.6, 1])
        self.rightToLeftGlideVC?.marginOffset = 0.0
        self.rightToLeftGlideVC?.delegate = self
    }

    func initBottomToTopGlideView() {
        let content:RDGliderContentViewController = RDGliderContentViewController.init(lenght: 300.0)
        content.view.backgroundColor = UIColor.purple
        content.showShadow = true
        content.cornerRadius = 20.0
        
        self.bottomToTopGlideVC = RDGliderViewController.init(parent: self,
                                                              WithContent: content,
                                                              AndType: .RDScrollViewOrientationBottomToTop,
                                                              WithOffsets: [0.6, 0, 0.3, 1])
        self.bottomToTopGlideVC?.delegate = self
    }

    func initLeftToRightGlideView() {
        let content:RDGliderContentViewController = RDGliderContentViewController.init()
        content.view.backgroundColor = UIColor.purple
        content.showShadow = true
        content.cornerRadius = 20.0
        
        self.leftToRightGlideVC = RDGliderViewController.init(parent: self,
                                                              WithContent: content,
                                                              AndType: .RDScrollViewOrientationLeftToRight,
                                                              WithOffsets: [0, 0.2, 0.4, 0.6, 0.8])
        self.leftToRightGlideVC?.delegate = self
    }
    
    func initTopToBottomGlideView() {
        let content:RDGliderContentViewController = RDGliderContentViewController.init(lenght: 200.0)
        content.view.backgroundColor = UIColor.purple
        content.showShadow = true
        content.cornerRadius = 20.0
        
        self.topToBottomGlideVC = RDGliderViewController.init(parent: self,
                                                              WithContent: content,
                                                              AndType: .RDScrollViewOrientationTopToBottom,
                                                              WithOffsets: [0, 0.5, 1])
        self.topToBottomGlideVC?.delegate = self
    }
    
// MARK: - Actions

    @IBAction func btnPressed(_ sender: UIButton) {
        
        var gliderVC: RDGliderViewController?
        
        switch sender.tag {
        case 1:
            gliderVC = rightToLeftGlideVC
        case 2:
            gliderVC = bottomToTopGlideVC
        case 3:
            gliderVC = leftToRightGlideVC
        default:
            gliderVC = topToBottomGlideVC
        }
        
        if (gliderVC != nil) {
            if gliderVC!.currentOffsetIndex < Int(gliderVC!.offsets.count) - 1 {
                gliderVC?.expand()
            } else {
                gliderVC?.shake()
            }
        }
    }
}
