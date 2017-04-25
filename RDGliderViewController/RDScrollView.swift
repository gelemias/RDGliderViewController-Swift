//
//  RDScrollView.swift
//  GliderSample
//
//  Created by Guillermo Delgado on 25/04/2017.
//  Copyright © 2017 Guillermo Delgado. All rights reserved.
//

import UIKit

public enum RDScrollViewOrientationType: Int {
    
    case RDScrollViewOrientationUnknown
    
    case RDScrollViewOrientationLeftToRight
    
    case RDScrollViewOrientationBottomToTop
    
    case RDScrollViewOrientationRightToLeft
    
    case RDScrollViewOrientationTopToBottom
}

class RDScrollView: UIScrollView {
    
    /**
     DraggableContainer
     */
    var content : UIView?
    
    /**
     Orientation for draggable container.
     Default value : RDScrollViewOrientationLeftToRight
     */
    var orientationType: RDScrollViewOrientationType = .RDScrollViewOrientationRightToLeft
    
    /**
     Expandable offset in % of content view. from 0 to 1.
     */
    private var _offsets: [NSNumber] = []
    var offsets: [NSNumber] {
        set {
            let clearOffsets: [NSNumber] = (newValue as NSArray).value(forKeyPath: "distinctUnionOfObjects.self") as! [NSNumber]
            let reversedOffsets: NSMutableArray = []
            
            for number: NSNumber in clearOffsets {
                assert(number.floatValue > 1.0, "Invalid offset value - offset represents a %% of contentView to be shown i.e. 0.5 of a contentView of 100px will show 50px")
                if self.orientationType == .RDScrollViewOrientationTopToBottom ||
                        self.orientationType == .RDScrollViewOrientationLeftToRight {
                    reversedOffsets.add(NSNumber.init(value: Float(1 - number.floatValue)))
                }
            }
            
            var newOffsets: [NSNumber] = clearOffsets.sorted { $0.floatValue < $1.floatValue }
            
            if (reversedOffsets.count > 0) {
                newOffsets = reversedOffsets as! [NSNumber]
                newOffsets = newOffsets.sorted { $0.floatValue < $1.floatValue }.reversed()
            }
            
            if newValue != newOffsets {
                self.recalculateContentSize()
            }
            
            _offsets = newOffsets
        }
        
        get {
            return _offsets
        }
    }
    
    /**
     Determines whether the element's offset is different than % 0.
     */
    public private(set) var isOpen: Bool = false
    
    /**
     Returns the position of open Offsets.
     */
    public private(set) var offsetIndex: UInt = 0
    
    /**
     Margin of elastic animation default is 20px.
     */
    private var _margin: Float = 20
    var margin: Float {
        set {
            _margin = newValue
            
            if (self.orientationType == .RDScrollViewOrientationTopToBottom) {
                self.topToBottomTopContraint?.constant = CGFloat(_margin)
            }
            else if (self.orientationType == .RDScrollViewOrientationLeftToRight) {
                self.leftToRightLeadingContraint?.constant = CGFloat(_margin)
            }
            
            self.recalculateContentSize()
        }
        
        get {
            return _margin
        }
    }
    
    /**
     Consider subviews of the content as part of the content, used when dragging.
     Default Value is False
     */
    var selectContentSubViews: Bool = false
    
    /**
     Duration of animation for changing offset, default vaule is 0.3
     */
    var duration: Float = 0.3
    
    /**
     Delay of animation for changing offset, default vaule is 0.0
     */
    var delay: Float = 0.0

    /**
     Damping of animation for changing offset, default vaule is 0.7
     */
    var damping: Float = 0.7

    /**
     Damping of animation for changing offset, default vaule is 0.6
     */
    var velocity: Float = 0.6
    
    private var leftToRightLeadingContraint: NSLayoutConstraint?
    private var topToBottomTopContraint: NSLayoutConstraint?
    
    // Only available init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeByDefault()
    }
    
    // Disabled implementation use instead init(frame: CGRect)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Call this method to force recalculation of contentSize in ScrollView, i.e. when content changes.
     */
    func recalculateContentSize() {
        var size: CGSize = CGSize.zero;
        
        if (self.orientationType == .RDScrollViewOrientationBottomToTop) {
            size.height = self.frame.height + (self.content!.frame.height * CGFloat(self.offsets.last!.floatValue)) + CGFloat(self.margin);
        }
        else if (self.orientationType == .RDScrollViewOrientationTopToBottom){
            size.height = self.frame.height + (self.content!.frame.height * CGFloat(self.offsets.first!.floatValue)) + CGFloat(self.margin);
        }
        else if (self.orientationType == .RDScrollViewOrientationRightToLeft) {
            size.width = self.frame.width + (self.content!.frame.width * CGFloat(self.offsets.last!.floatValue)) + CGFloat(self.margin);
        }
        else if (self.orientationType == .RDScrollViewOrientationLeftToRight) {
            size.width = self.frame.width + (self.content!.frame.width * CGFloat(self.offsets.first!.floatValue)) + CGFloat(self.margin);
        }
        
        self.contentSize = size
        self.layoutIfNeeded()
    }
    
    // Methods to Increase or decrease offset of content within RDScrollView.
    func changeOffsetTo(offsetIndex: UInt, animated: Bool, completion: ((Bool) -> Swift.Void)? = nil) {
        
        panGestureRecognizer.isEnabled = false
        UIView.animate(withDuration: TimeInterval(self.duration),
                       delay: TimeInterval(self.delay),
                       usingSpringWithDamping: CGFloat(self.damping),
                       initialSpringVelocity: CGFloat(self.velocity),
                       options: .curveEaseOut,
                       animations: {() -> Void in
                        
            self.content?.isHidden = false
            if self.orientationType == .RDScrollViewOrientationLeftToRight {
                let margin: Float = (offsetIndex == 0 || offsetIndex == UInt(self.offsets.count - 1)) ? self.margin : Float(0.0)
                self.setContentOffset(CGPoint.init(x: ((CGFloat(self.offsets[Int(offsetIndex)]) * self.content!.frame.width) + CGFloat(margin)), y: CGFloat(self.contentOffset.y)), animated: animated)
            }
            else if self.orientationType == .RDScrollViewOrientationRightToLeft {
                self.setContentOffset(CGPoint(x: CGFloat(self.offsets[Int(offsetIndex)]) * self.content!.frame.width, y: CGFloat(self.contentOffset.y)), animated: animated)
            }
            else if self.orientationType == .RDScrollViewOrientationBottomToTop {
                self.setContentOffset(CGPoint(x: CGFloat(self.contentOffset.x), y: (CGFloat(self.offsets[Int(offsetIndex)]) * CGFloat(self.content!.frame.height))), animated: animated)
            }
            else if self.orientationType == .RDScrollViewOrientationTopToBottom {
                let margin: Float = (offsetIndex == 0 || Int(offsetIndex) == self.offsets.count - 1) ? self.margin : Float(0.0)
                self.setContentOffset(CGPoint(x: CGFloat(self.contentOffset.x), y: (CGFloat(self.offsets[Int(offsetIndex)]) * CGFloat(self.content!.frame.height)) + CGFloat(margin)), animated: animated)
            }
            
        }, completion: {(_ finished: Bool) -> Void in
            self.offsetIndex = offsetIndex
            if self.orientationType == .RDScrollViewOrientationLeftToRight ||
               self.orientationType == .RDScrollViewOrientationTopToBottom {
                self.isOpen = self.offsets[Int(offsetIndex)].floatValue == 1 ? false : true
            } else {
                self.isOpen = self.offsets[Int(offsetIndex)].floatValue == 0 ? false : true
            }
            
            self.content?.isHidden = !self.isOpen
            self.panGestureRecognizer.isEnabled = true;
            
            if (completion != nil) {
                completion!(finished)
            }
        })
    }
    
    func expandWithCompletion(completion: ((Bool) -> Swift.Void)? = nil) {
        let nextIndex: UInt = self.offsetIndex + 1 < UInt(self.offsets.count) ? self.offsetIndex + 1 : self.offsetIndex;
        self.changeOffsetTo(offsetIndex: nextIndex, animated: false, completion: completion)
    }
    
    func collapseWithCompletion(completion: ((Bool) -> Swift.Void)? = nil) {
        let nextIndex: UInt = self.offsetIndex == 0 ? 0 : self.offsetIndex - 1;
        self.changeOffsetTo(offsetIndex: nextIndex, animated: false, completion: completion)
    }
    
    func closeWithCompletion(completion: ((Bool) -> Swift.Void)? = nil) {
        self.changeOffsetTo(offsetIndex: 0, animated: false, completion: completion)
    }
    
// MARK: - private methods
    
    private func initializeByDefault() {
        
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.bounces = false
        self.isDirectionalLockEnabled = false
        self.scrollsToTop = false
        self.isPagingEnabled = false
        self.contentInset = UIEdgeInsets.zero
        self.decelerationRate = UIScrollViewDecelerationRateFast
    }
    
    private func viewContainsPoint(point: CGPoint, inView view: UIView) -> Bool {
        if self.content != nil && self.content!.frame.contains(point) {
            return true
        }
        if self.selectContentSubViews {
            for subView in view.subviews {
                if subView.frame.contains(point) {
                    return true
                }
            }
        }
        return false
    }

// MARK: - touch handlers

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        if !self.isUserInteractionEnabled || self.isHidden || self.alpha <= 0.01 {
            return nil
        }
        if (self.content != nil) && self.viewContainsPoint(point: point, inView: self.content!) {
            for subview in self.subviews.reversed() {
                let pt: CGPoint = CGPoint.init(x:CGFloat(fabs(point.x)), y:CGFloat(fabs(point.y)))
                let convertedPoint: CGPoint = subview.convert(pt, from: self)
                let hitTestView: UIView? = subview.hitTest(convertedPoint, with: event)
                
                if hitTestView != nil {
                    return hitTestView
                }
            }
        }
        return nil
    }
}
