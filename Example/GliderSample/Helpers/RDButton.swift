//
//  RDButton.swift
//  GliderSample
//
//  Created by Guillermo Delgado on 25/04/2017.
//  Copyright © 2017 Guillermo Delgado. All rights reserved.
//

import UIKit

class RDButton: UIButton {

    var bgColor: UIColor = UIColor.white
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath.init(ovalIn: rect)
        self.bgColor.setFill()
        path.fill()
    }
    
    override var backgroundColor: UIColor? {
        set {
            bgColor = newValue?.copy() as! UIColor
            super.backgroundColor = UIColor.clear
        }
        get {
            return self.bgColor
        }
    }
}
