//
//  RDGliderContentViewController.swift
//  GliderSample
//
//  Created by Guillermo Delgado on 25/04/2017.
//  Copyright © 2017 Guillermo Delgado. All rights reserved.
//

import UIKit

// swiftlint:disable identifier_name

class RDGliderContentViewController: UIViewController {

    var _showShadow: Bool = false
    var showShadow: Bool {
        set {
            _showShadow = newValue

            if _showShadow {
                self.view.layer.shadowColor = UIColor.black.cgColor
                self.view.layer.shadowOpacity = 0.5
                self.view.layer.shadowRadius = 5.0
                self.view.layer.shadowOffset = CGSize.init(width: 0, height: 0)
            } else {
                self.view.layer.shadowRadius = 0.0
            }
        }

        get {
            return _showShadow
        }
    }

    var _cornerRadius: Float = 0.0
    var cornerRadius: Float {
        set {
            _cornerRadius = newValue

            self.view.layer.cornerRadius = CGFloat(_cornerRadius)
            self.view.subviews.first?.layer.cornerRadius = CGFloat(_cornerRadius)
        }

        get {
            return _cornerRadius
        }
    }

    private var length: CGFloat?

    required init(length: CGFloat) {
        super.init(nibName: nil, bundle: nil)
        self.length = length
    }

    required init() {
        super.init(nibName: nil, bundle: nil)
        self.length = 0.0
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.frame = CGRect.init(x:0, y:0, width:self.length!, height:self.length!)

        self.cornerRadius = 0.0
        self.showShadow = false
    }
}
