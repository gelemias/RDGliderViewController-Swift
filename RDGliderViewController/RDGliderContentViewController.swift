//
//  RDGliderContentViewController.swift
//  GliderSample
//
//  Created by Guillermo Delgado on 25/04/2017.
//  Copyright © 2017 Guillermo Delgado. All rights reserved.
//

import UIKit

open class RDGliderContentViewController: UIViewController {

    public var showShadow: Bool = false {
        didSet {
            if showShadow {
                self.view.layer.shadowColor = UIColor.black.cgColor
                self.view.layer.shadowOpacity = 0.5
                self.view.layer.shadowRadius = 5.0
                self.view.layer.shadowOffset = CGSize.init(width: 0, height: 0)
            } else {
                self.view.layer.shadowRadius = 0.0
            }
        }
    }

    public var cornerRadius: Float = 0.0 {
        didSet {
            self.view.layer.cornerRadius = CGFloat(cornerRadius)
            self.view.subviews.first?.layer.cornerRadius = CGFloat(cornerRadius)
        }
    }

    private var length: CGFloat?

    required public init(length: CGFloat) {
        super.init(nibName: nil, bundle: nil)
        self.length = length
    }

    required public init() {
        super.init(nibName: nil, bundle: nil)
        self.length = 0.0
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.view.frame = CGRect.init(x:0, y:0, width:self.length!, height:self.length!)

        self.cornerRadius = 0.0
        self.showShadow = false
    }
}
