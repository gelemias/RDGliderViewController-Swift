//
//  RDGliderContentViewController.swift
//  GliderSample
//
//  Created by Guillermo Delgado on 25/04/2017.
//  Copyright © 2017 Guillermo Delgado. All rights reserved.
//

import UIKit

class RDGliderContentViewController: UIViewController {

    var showShadow: Bool?
    var cornerRadius: CGFloat?
    private var lenght: CGFloat?
    
    required init(lenght: CGFloat) {
        super.init(nibName: nil, bundle: nil)
        self.lenght = lenght
    }
    
    required init() {
        super.init(nibName: nil, bundle: nil)
        self.lenght = 0.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.frame = CGRect.init(x:0, y:0, width:self.lenght!, height:self.lenght!)
        
        self.cornerRadius = 0.0
        self.showShadow = false
    }
    
    func setShowShadow(showShadow: Bool) {
        if showShadow {
            self.view.layer.shadowColor = UIColor.black.cgColor
            self.view.layer.shadowOpacity = 0.5
            self.view.layer.shadowRadius = 5.0
            self.view.layer.shadowOffset = CGSize.init(width: 0, height: 0)
        }
    }
    
    func setCornerRadius(cornerRadius: CGFloat) {
        self.view.layer.cornerRadius = cornerRadius
        self.view.subviews.first?.layer.cornerRadius = cornerRadius
    }
}
