//
//  RDGliderViewController.swift
//  GliderSample
//
//  Created by Guillermo Delgado on 25/04/2017.
//  Copyright © 2017 Guillermo Delgado. All rights reserved.
//

import UIKit

class RDGliderViewController: UIViewController {
    
    private var scrollView: RDScrollView?
    private var contentViewController: UIViewController?
    private var isObservingOffsets: Bool?
    
    init(parent: UIViewController, WithContent content: RDGliderContentViewController, AndType type: RDScrollViewOrientationType, WithOffsets offsets: [NSNumber]) {
        
        super.init(nibName: nil, bundle: nil)

        self.scrollView = RDScrollView(frame: CGRect.init(x:0, y:0, width:parent.view.frame.width, height:parent.view.frame.height))
        setContentViewController(Content: content, AndType: type, WithOffsets: offsets)
        parent.addChildViewController(self)
        parent.view.addSubview(self.scrollView!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

// MARK: - Public methods
    
    func setContentViewController(Content content: RDGliderContentViewController, AndType type: RDScrollViewOrientationType, WithOffsets offsets: [NSNumber]) {

        if  self.scrollView != nil && (self.scrollView?.frame.isNull)! {
            self.parent?.automaticallyAdjustsScrollViewInsets = false
            self.automaticallyAdjustsScrollViewInsets = false
            self.scrollView?.orientationType = type
            self.scrollView?.offsets = offsets
            self.contentViewController = content
            self.scrollView?.content = (self.contentViewController?.view)!
//            self.scrollView.delegate = self
            self.close()
        }
    }
    
    var offsets: [NSNumber] {
        get {
            return (self.scrollView?.offsets)!
        }
        
        set {
            self.scrollView?.offsets = newValue
        }
    }
    
    func currentOffsetIndex() -> UInt {
        return (self.scrollView?.offsetIndex)!
    }
    
    func expand() {
        
    }

    func collapse() {
        
    }

    func close() {
        
    }

    func shake() {
        
    }
}
