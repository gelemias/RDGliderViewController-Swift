//
//  RDGliderViewController.swift
//  GliderSample
//
//  Created by Guillermo Delgado on 25/04/2017.
//  Copyright © 2017 Guillermo Delgado. All rights reserved.
//

import UIKit

protocol RDGliderViewControllerDelegate {
    /**
     Delegate method to notify invoke object when offset has changed
     */
    func glideViewController(glideViewController: RDGliderViewController, hasChangedOffsetOfContent offset: CGPoint)
    
    /**
     Delegate method to notify invoke object when glideView will increase offset by one
     */
    func glideViewControllerWillExpand(glideViewController: RDGliderViewController)

    /**
     Delegate method to notify invoke object when glideView will decrease offset by one
     */
    func glideViewControllerWillCollapse(glideViewController: RDGliderViewController)
    
    /**
     Delegate method to notify invoke object when glideView did increase offset by one
     */
    func glideViewControllerDidExpand(glideViewController: RDGliderViewController)
    
    /**
     Delegate method to notify invoke object when glideView did decrease offset by one
     */
    func glideViewControllerDidCollapse(glideViewController: RDGliderViewController)
}

class RDGliderViewController: UIViewController, UIScrollViewDelegate {
    
    var delegate: RDGliderViewControllerDelegate?
    
    private var scrollView: RDScrollView?
    
    /**
     Content view Controller hosted on the scrollView
     */
    public private(set) var contentViewController: UIViewController?
    
    /**
     Margin of elastic animation default is 20px
     */
    var marginOffset: Float {
        get {
            return (self.scrollView?.margin)!
        }
        
        set {
            self.scrollView?.margin = newValue
        }
    }
    
    /**
     Sorted list of offsets in % of contentVC view. from 0 to 1
     */
    var offsets: [NSNumber] {
        get {
            return (self.scrollView?.offsets)!
        }
        
        set {
            self.scrollView?.offsets = newValue
        }
    }
    
    /**
     Orientation type of the glide view
     */
    var orientationType: RDScrollViewOrientationType {
        get {
            if self.scrollView == nil {
                return .RDScrollViewOrientationUnknown
            }
            
            return self.scrollView!.orientationType
        }
    }
    
    /**
     Current offset of the glide view
     */
    var currentOffsetIndex: Int {
        get {
            if self.scrollView == nil {
                return 0
            }
            
            return self.scrollView!.offsetIndex
        }
    }
    
    /**
     Returns a bool for determining if the glide view isn't closed, is different than offset % 0.
     */
    var isOpen: Bool {
        get {
            if self.scrollView == nil {
                return false
            }
            
            return self.scrollView!.isOpen
        }
    }
    
    /**
     Bool meant for enabling the posibility to close the glide view dragging, Default value is NO
     */
    var disableDraggingToClose: Bool = false
    
    /**
     Initializator of the object, it requires the parent view controller to build its components
     * @param parent Parent Class of this instance
     * @param content external ViewController placed as a content of the GlideView
     * @param type of GlideView Left to Right, Right to Left, Bottom To Top and Top to Bottom.
     * @param offsets Array of offsets in % (0 to 1) dependent of Content size if not expecified UIScreen bounds.
     * @return A newly created RDGliderViewController instance
     */
    init(parent: UIViewController, WithContent content: RDGliderContentViewController, AndType type: RDScrollViewOrientationType, WithOffsets offsets: [NSNumber]) {
        
        super.init(nibName: nil, bundle: nil)

        parent.addChildViewController(self)
        self.scrollView = RDScrollView.init(frame: CGRect.init(x:0, y:0, width:parent.view.frame.width, height:parent.view.frame.height))
        parent.view.addSubview(self.scrollView!)

        self.setContentViewController(Content: content, AndType: type, WithOffsets: offsets)
    }
    
    /**
     Init Disabled
     */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Change contentViewController type and offsets after the VC has been initialized.
     * @param contentViewController external ViewController placed as a content of the GlideView
     * @param type of GlideView Left to Right, Right to Left, Bottom To Top and Top to Bottom.
     * @param offsets Array of offsets in % (0 to 1) dependent of Content size if not expecified UIScreen  */
    func setContentViewController(Content content: RDGliderContentViewController, AndType type: RDScrollViewOrientationType, WithOffsets offsets: [NSNumber]) {

        self.parent?.automaticallyAdjustsScrollViewInsets = false
        self.automaticallyAdjustsScrollViewInsets = false
        self.scrollView?.orientationType = type
        self.scrollView?.offsets = offsets
        self.contentViewController = content
        self.scrollView?.content = (self.contentViewController?.view)!
        self.scrollView?.delegate = self
        self.close()
    }
    
    /**
     Increase the position of the Gliver view by one in the list of offsets
     */
    func expand() {
        self.delegate?.glideViewControllerWillExpand(glideViewController: self)
        self.scrollView?.expandWithCompletion(completion: { (completion) in
            self.delegate?.glideViewControllerDidExpand(glideViewController: self)
        })
    }

    /**
     Decrease the position of the Gliver view by one in the list of offsets
     */
    func collapse() {
        self.delegate?.glideViewControllerWillCollapse(glideViewController: self)
        self.scrollView?.collapseWithCompletion(completion: { (completion) in
            self.delegate?.glideViewControllerDidCollapse(glideViewController: self)
        })
    }

    /**
     This method moves the View directly to the first offset which is the default position.
     */
    func close() {
        self.delegate?.glideViewControllerWillCollapse(glideViewController: self)
        self.scrollView?.closeWithCompletion(completion: { (completion) in
            self.delegate?.glideViewControllerDidCollapse(glideViewController: self)
        })
    }

    /**
     This method gives a shake to the Gliver view, is meant to grap users atention.
     */
    func shake() {
        if self.scrollView == nil {
            return
        }
        
        let shakeMargin: CGFloat = 10.0
        
        let animation: CABasicAnimation = CABasicAnimation.init(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
        
        if self.orientationType == .RDScrollViewOrientationRightToLeft {
            animation.fromValue = NSValue.init(cgPoint: self.scrollView!.center)
            animation.toValue = NSValue.init(cgPoint: CGPoint.init(x: self.scrollView!.center.x + shakeMargin,
                                                                   y: self.scrollView!.center.y))
        }
        else if self.orientationType == .RDScrollViewOrientationLeftToRight {
            animation.fromValue = NSValue.init(cgPoint: self.scrollView!.center)
            animation.toValue = NSValue.init(cgPoint: CGPoint.init(x: self.scrollView!.center.x - shakeMargin,
                                                                   y: self.scrollView!.center.y))
        }
        else if self.orientationType == .RDScrollViewOrientationBottomToTop {
            animation.fromValue = NSValue.init(cgPoint: self.scrollView!.center)
            animation.toValue = NSValue.init(cgPoint: CGPoint.init(x: self.scrollView!.center.x, y: self.scrollView!.center.y + shakeMargin))
        }
        else if self.orientationType == .RDScrollViewOrientationTopToBottom {
            animation.fromValue = NSValue.init(cgPoint: self.scrollView!.center)
            animation.toValue = NSValue.init(cgPoint: CGPoint.init(x: self.scrollView!.center.x, y: self.scrollView!.center.y - shakeMargin))
        }
        
        self.scrollView?.layer.add(animation, forKey: "position")
    }
    
    /**
     Change offset of view.
     * @param offsetIndex setNew Offset of GlideView, parameter needs to be within offsets Array count list.
     * @param animated animates the offset change
     */
    func changeOffset(to offsetIndex: Int, animated: Bool) {
        if self.currentOffsetIndex < offsetIndex {
            self.delegate?.glideViewControllerWillExpand(glideViewController: self)
        }
        else if offsetIndex < self.currentOffsetIndex {
            self.delegate?.glideViewControllerWillCollapse(glideViewController: self)
        }
        
        self.scrollView?.changeOffsetTo(offsetIndex: offsetIndex, animated: animated, completion: { (completion) in
            if self.currentOffsetIndex < offsetIndex {
                self.delegate?.glideViewControllerDidExpand(glideViewController: self)
            }
            else {
                self.delegate?.glideViewControllerDidCollapse(glideViewController: self)
            }
        })
    }
    
//MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.glideViewController(glideViewController: self, hasChangedOffsetOfContent: scrollView.contentOffset)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.changeOffset(to: self.nearestOffsetIndex(to: scrollView.contentOffset), animated:false)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)
    }
    
//MARK: - private Methods
    
    func nearestOffsetIndex(to contentOffset:CGPoint) -> Int {
        var index: Int = 0
        var offset: CGFloat = contentOffset.x
        var threshold: CGFloat = self.scrollView!.content!.frame.width
        
        if (self.orientationType == .RDScrollViewOrientationBottomToTop ||
            self.orientationType == .RDScrollViewOrientationTopToBottom) {
            offset = contentOffset.y
            threshold = self.scrollView!.content!.frame.height
        }
        
        var distance: CGFloat = CGFloat.greatestFiniteMagnitude
        
        for i in 0..<self.offsets.count {
            let transformedOffset: CGFloat = CGFloat(self.scrollView!.offsets[i].floatValue) * threshold
            let distToAnchor: CGFloat = fabs(offset - transformedOffset)
            if (distToAnchor < distance) {
                distance = distToAnchor
                index = i
            }

        }
        
        return (index == 0 && self.disableDraggingToClose) ? 1 : index
    }
    
// MARK: - Rotation event
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if self.contentViewController != nil {
            self.contentViewController!.viewWillTransition(to: size, with: coordinator)
        }
    
        coordinator.animate(alongsideTransition: { ctx in
            self.changeOffset(to: self.currentOffsetIndex, animated: true)
        }) { ctx in
            self.scrollView!.recalculateContentSize()
        }
    }
}
