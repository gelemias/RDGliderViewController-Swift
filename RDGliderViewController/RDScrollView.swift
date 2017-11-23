//
//  RDScrollView.swift
//  GliderSample
//
//  Created by Guillermo Delgado on 25/04/2017.
//  Copyright © 2017 Guillermo Delgado. All rights reserved.
//

// swiftlint:disable function_body_length type_body_length file_length

import UIKit

@objc public enum RDScrollViewOrientationType: Int {

    case RDScrollViewOrientationUnknown

    case RDScrollViewOrientationLeftToRight

    case RDScrollViewOrientationBottomToTop

    case RDScrollViewOrientationRightToLeft

    case RDScrollViewOrientationTopToBottom
}

@objc public class RDScrollView: UIScrollView {

    /**
     Draggable content
     */
    var content: UIView? {
        didSet {
            self.addContent(content: self.content!)
        }
    }

    /**
     Orientation for draggable container.
     Default value: RDScrollViewOrientationLeftToRight
     */
    public var orientationType: RDScrollViewOrientationType = .RDScrollViewOrientationRightToLeft

    /**
     Expandable offset in % of content view. from 0 to 1.
     */
    private var _offsets: [NSNumber] = []
    public var offsets: [NSNumber] {
        set {
            if newValue.count == 0 {
                NSException(name: NSExceptionName(rawValue: "Invalid offset array"),
                            reason:"offsets array cannot be nil nor empty").raise()
            }

            let clearOffsets: [NSNumber] = (NSOrderedSet.init(array: newValue).array as? [NSNumber])!
            var reversedOffsets = [NSNumber]()

            for number: NSNumber in clearOffsets {
                if number.floatValue < 0.0 || 1.0 < number.floatValue {
                    let m = "offset represents a %% of content to be shown, 0.5 of a content of 100px will show 50px"
                    NSException(name: NSExceptionName(rawValue: "Invalid offset value"), reason: m).raise()
                }

                if self.orientationType == .RDScrollViewOrientationTopToBottom ||
                        self.orientationType == .RDScrollViewOrientationLeftToRight {
                    reversedOffsets.append(NSNumber.init(value: Float(1 - number.floatValue)))
                }
            }

            var newOffsets: [NSNumber] = clearOffsets.sorted { $0.floatValue < $1.floatValue }

            if reversedOffsets.count > 0 {
                newOffsets = reversedOffsets
                newOffsets = newOffsets.sorted { $0.floatValue < $1.floatValue }.reversed()
            }

            _offsets = newOffsets
            self.recalculateContentSize()
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
    public private(set) var offsetIndex: Int = 0

    /**
     Margin of elastic animation default is 20px.
     */
    private var _margin: Float = 20
    var margin: Float {
        set {
            _margin = newValue

            if self.orientationType == .RDScrollViewOrientationTopToBottom {
                self.topToBottomTopContraint?.constant = CGFloat(_margin)

            } else if self.orientationType == .RDScrollViewOrientationLeftToRight {
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
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
     Call this method to force recalculation of contentSize in ScrollView, i.e. when content changes.
     */
    func recalculateContentSize() {

        if self.content == nil || self.offsets.isEmpty {
            return
        }

        var size: CGSize = CGSize.zero

        if self.orientationType == .RDScrollViewOrientationBottomToTop {
            size.height = self.frame.height + (self.content!.frame.height * CGFloat(self.offsets.last!.floatValue)) +
                CGFloat(self.margin)
        } else if self.orientationType == .RDScrollViewOrientationTopToBottom {
            size.height = self.frame.height + (self.content!.frame.height * CGFloat(self.offsets.first!.floatValue)) +
                CGFloat(self.margin)
        } else if self.orientationType == .RDScrollViewOrientationRightToLeft {
            size.width = self.frame.width + (self.content!.frame.width * CGFloat(self.offsets.last!.floatValue)) +
                CGFloat(self.margin)
        } else if self.orientationType == .RDScrollViewOrientationLeftToRight {
            size.width = self.frame.width + (self.content!.frame.width * CGFloat(self.offsets.first!.floatValue)) +
                CGFloat(self.margin)
        }

        self.contentSize = size
        self.layoutIfNeeded()

        DispatchQueue.main.async {
            self.changeOffsetTo(offsetIndex: self.offsetIndex, animated: false, completion: nil)
        }
    }

    // Methods to Increase or decrease offset of content within RDScrollView.
    func changeOffsetTo(offsetIndex: Int, animated: Bool, completion: ((Bool) -> Void)?) {

        panGestureRecognizer.isEnabled = false
        UIView.animate(withDuration: TimeInterval(self.duration),
                       delay: TimeInterval(self.delay),
                       usingSpringWithDamping: CGFloat(self.damping),
                       initialSpringVelocity: CGFloat(self.velocity),
                       options: .curveEaseOut,
                       animations: {() -> Void in

            if self.content == nil || self.offsets.count == 0 {

                self.setContentOffset(CGPoint.zero, animated: animated)
            } else {

                self.content?.isHidden = false
                if self.orientationType == .RDScrollViewOrientationLeftToRight {
                    let margin: Float = (offsetIndex == 0 || offsetIndex == Int(self.offsets.count - 1)) ?
                        self.margin: Float(0.0)
                    self.setContentOffset(CGPoint.init(x: ((CGFloat(self.offsets[Int(offsetIndex)]) *
                        self.content!.frame.width) + CGFloat(margin)),
                                                       y: CGFloat(self.contentOffset.y)), animated: animated)

                } else if self.orientationType == .RDScrollViewOrientationRightToLeft {
                    self.setContentOffset(CGPoint(x: CGFloat(self.offsets[Int(offsetIndex)]) *
                        self.content!.frame.width, y: CGFloat(self.contentOffset.y)), animated: animated)

                } else if self.orientationType == .RDScrollViewOrientationBottomToTop {
                    self.setContentOffset(CGPoint(x: CGFloat(self.contentOffset.x),
                                                  y: (CGFloat(self.offsets[Int(offsetIndex)]) *
                                                    CGFloat(self.content!.frame.height))),
                                          animated: animated)

                } else if self.orientationType == .RDScrollViewOrientationTopToBottom {
                    let margin: Float = (offsetIndex == 0 || Int(offsetIndex) == self.offsets.count - 1) ?
                                        self.margin: Float(0.0)
                    self.setContentOffset(CGPoint(x: CGFloat(self.contentOffset.x),
                                                  y: (CGFloat(self.offsets[Int(offsetIndex)]) *
                                                    CGFloat(self.content!.frame.height)) + CGFloat(margin)),
                                          animated: animated)
                }
            }

        }, completion: {(_ finished: Bool) -> Void in
            self.offsetIndex = offsetIndex
            if self.orientationType == .RDScrollViewOrientationLeftToRight ||
               self.orientationType == .RDScrollViewOrientationTopToBottom {
                self.isOpen = self.offsets[Int(offsetIndex)].floatValue == 1 ? false: true
            } else {
                self.isOpen = self.offsets[Int(offsetIndex)].floatValue == 0 ? false: true
            }

            self.content?.isHidden = !self.isOpen
            self.panGestureRecognizer.isEnabled = true

            completion?(finished)
        })
    }

    func expandWithCompletion(completion: ((Bool) -> Void)?) {
        let nextIndex: Int = self.offsetIndex + 1 < Int(self.offsets.count) ? self.offsetIndex + 1: self.offsetIndex
        self.changeOffsetTo(offsetIndex: nextIndex, animated: false, completion: completion)
    }

    func collapseWithCompletion(completion: ((Bool) -> Void)?) {
        let nextIndex: Int = self.offsetIndex == 0 ? 0: self.offsetIndex - 1
        self.changeOffsetTo(offsetIndex: nextIndex, animated: false, completion: completion)
    }

    func closeWithCompletion(completion: ((Bool) -> Void)?) {
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

    private func addContent(content: UIView) {
        if content.frame.isNull {
            return
        }

        self.subviews.forEach { $0.removeFromSuperview() }

        let container: UIView = UIView.init()
        container.addSubview(content)
        self.addSubview(container)

        container.translatesAutoresizingMaskIntoConstraints = false
        content.translatesAutoresizingMaskIntoConstraints = false

        if self.orientationType == .RDScrollViewOrientationRightToLeft {

            container.addConstraints([NSLayoutConstraint(item: content, attribute: .top, relatedBy: .equal,
                                                       toItem: container, attribute: .top, multiplier: 1.0,
                                                       constant: 0.0),
                                      NSLayoutConstraint(item: content, attribute: .bottom, relatedBy: .equal,
                                                       toItem: container, attribute: .bottom, multiplier: 1.0,
                                                       constant: 0.0),
                                      NSLayoutConstraint(item: content, attribute: .trailing, relatedBy: .equal,
                                                       toItem: container, attribute: .trailing, multiplier: 1.0,
                                                       constant: 0.0)])

            self.addConstraints([NSLayoutConstraint(item: container, attribute: .leading, relatedBy: .equal,
                                                  toItem: self, attribute: .leading, multiplier: 1.0,
                                                  constant: 0.0),
                                 NSLayoutConstraint(item: container, attribute: .top, relatedBy: .equal,
                                                  toItem: self, attribute: .top, multiplier: 1.0,
                                                  constant: 0.0),
                                 NSLayoutConstraint(item: container, attribute: .height, relatedBy: .equal,
                                                  toItem: self, attribute: .height, multiplier: 1.0,
                                                  constant: 0.0)])

            if content.frame.isEmpty {
                self.addConstraints([NSLayoutConstraint(item: content, attribute: .width, relatedBy: .equal,
                                                      toItem: self, attribute: .width, multiplier: 1.0,
                                                      constant: 0.0),
                                     NSLayoutConstraint(item: container, attribute: .width, relatedBy: .equal,
                                                      toItem: self, attribute: .width, multiplier: 2.0,
                                                      constant: 0.0)])
            } else {

                container.addConstraints([NSLayoutConstraint(item: content, attribute: .width, relatedBy: .equal,
                                                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0,
                                                           constant: content.frame.width)])

                self.addConstraints([NSLayoutConstraint(item: container, attribute: .width, relatedBy: .equal,
                                                      toItem: self, attribute: .width, multiplier: 1.0,
                                                      constant: content.frame.width)])
            }
        } else if self.orientationType == .RDScrollViewOrientationLeftToRight {

            self.leftToRightLeadingContraint = NSLayoutConstraint(item: content, attribute: .leading, relatedBy: .equal,
                                                                toItem: container, attribute: .leading, multiplier: 1.0,
                                                                constant: CGFloat(self.margin))

            container.addConstraints([NSLayoutConstraint(item: content, attribute: .top, relatedBy: .equal,
                                                       toItem: container, attribute: .top, multiplier: 1.0,
                                                       constant: 0.0),
                                      NSLayoutConstraint(item: content, attribute: .bottom, relatedBy: .equal,
                                                       toItem: container, attribute: .bottom, multiplier: 1.0,
                                                       constant:0.0),
                                      self.leftToRightLeadingContraint!])

            self.addConstraints([NSLayoutConstraint(item: container, attribute: .leading, relatedBy: .equal,
                                                  toItem: self, attribute: .leading, multiplier: 1.0,
                                                  constant: 0.0),
                                 NSLayoutConstraint(item: container, attribute: .top, relatedBy: .equal,
                                                  toItem: self, attribute: .top, multiplier: 1.0,
                                                  constant: 0.0),
                                 NSLayoutConstraint(item: container, attribute: .height, relatedBy: .equal,
                                                  toItem: self, attribute: .height, multiplier: 1.0,
                                                  constant: 0.0)])

            if content.frame.isEmpty {
                self.addConstraints([NSLayoutConstraint(item: content, attribute: .width, relatedBy: .equal,
                                                      toItem: self, attribute: .width, multiplier: 1.0,
                                                      constant: 0.0),
                                     NSLayoutConstraint(item: container, attribute: .width, relatedBy: .equal,
                                                      toItem: self, attribute: .width, multiplier: 2.0,
                                                      constant: 0.0)])
            } else {

                container.addConstraints([NSLayoutConstraint(item: content, attribute: .width, relatedBy: .equal,
                                                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0,
                                                           constant: content.frame.width)])

                self.addConstraints([NSLayoutConstraint(item: container, attribute: .width, relatedBy: .equal,
                                                      toItem: self, attribute: .width, multiplier: 1.0,
                                                      constant: content.frame.width)])
            }
        } else if self.orientationType == .RDScrollViewOrientationBottomToTop {

            container.addConstraints([NSLayoutConstraint(item: content, attribute: .leading, relatedBy: .equal,
                                                       toItem: container, attribute: .leading, multiplier: 1.0,
                                                       constant: 0.0),
                                      NSLayoutConstraint(item: content, attribute: .trailing, relatedBy: .equal,
                                                       toItem: container, attribute: .trailing, multiplier: 1.0,
                                                       constant: 0.0),
                                      NSLayoutConstraint(item: content, attribute: .bottom, relatedBy: .equal,
                                                       toItem: container, attribute: .bottom, multiplier: 1.0,
                                                       constant: 0.0)])

            self.addConstraints([NSLayoutConstraint(item: container, attribute: .leading, relatedBy: .equal,
                                                  toItem: self, attribute: .leading, multiplier: 1.0,
                                                  constant: 0.0),
                                 NSLayoutConstraint(item: container, attribute: .top, relatedBy: .equal,
                                                  toItem: self, attribute: .top, multiplier: 1.0,
                                                  constant: 0.0),
                                 NSLayoutConstraint(item: container, attribute: .width, relatedBy: .equal,
                                                  toItem: self, attribute: .width, multiplier: 1.0,
                                                  constant: 0.0)])

            if content.frame.isEmpty {
                self.addConstraints([NSLayoutConstraint(item: content, attribute: .height, relatedBy: .equal,
                                                      toItem: self, attribute: .height, multiplier: 1.0,
                                                      constant: 0.0),
                                     NSLayoutConstraint(item: container, attribute: .height, relatedBy: .equal,
                                                      toItem: self, attribute: .height, multiplier: 2.0,
                                                      constant: 0.0)])
            } else {

                container.addConstraints([NSLayoutConstraint(item: content, attribute: .height, relatedBy: .equal,
                                                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0,
                                                           constant: content.frame.height)])

                self.addConstraints([NSLayoutConstraint(item: container, attribute: .height, relatedBy: .equal,
                                                      toItem: self, attribute: .height, multiplier: 1.0,
                                                      constant: content.frame.height)])
            }
        } else if self.orientationType == .RDScrollViewOrientationTopToBottom {

            self.topToBottomTopContraint = NSLayoutConstraint(item: content, attribute: .top, relatedBy: .equal,
                                                            toItem: container, attribute: .top, multiplier: 1.0,
                                                            constant: CGFloat(self.margin))

            container.addConstraints([NSLayoutConstraint(item: content, attribute: .leading, relatedBy: .equal,
                                                       toItem: container, attribute: .leading, multiplier: 1.0,
                                                       constant: 0.0),
                                      NSLayoutConstraint(item: content, attribute: .trailing, relatedBy: .equal,
                                                       toItem: container, attribute: .trailing, multiplier: 1.0,
                                                       constant:0.0),
                                      self.topToBottomTopContraint!])

            self.addConstraints([NSLayoutConstraint(item: container, attribute: .leading, relatedBy: .equal,
                                                  toItem: self, attribute: .leading, multiplier: 1.0,
                                                  constant: 0.0),
                                 NSLayoutConstraint(item: container, attribute: .top, relatedBy: .equal,
                                                  toItem: self, attribute: .top, multiplier: 1.0,
                                                  constant: 0.0),
                                 NSLayoutConstraint(item: container, attribute: .width, relatedBy: .equal,
                                                  toItem: self, attribute: .width, multiplier: 1.0,
                                                  constant: 0.0)])

            if content.frame.isEmpty {
                self.addConstraints([NSLayoutConstraint(item: content, attribute: .height, relatedBy: .equal,
                                                      toItem: self, attribute: .height, multiplier: 1.0,
                                                      constant: 0.0),
                                     NSLayoutConstraint(item: container, attribute: .height, relatedBy: .equal,
                                                      toItem: self, attribute: .height, multiplier: 2.0,
                                                      constant: 0.0)])
            } else {

                container.addConstraints([NSLayoutConstraint(item: content, attribute: .height, relatedBy: .equal,
                                                           toItem: nil, attribute: .notAnAttribute,
                                                           multiplier: 1.0, constant: content.frame.height)])

                self.addConstraints([NSLayoutConstraint(item: container, attribute: .height, relatedBy: .equal,
                                                      toItem: self, attribute: .height,
                                                      multiplier: 1.0, constant: content.frame.height)])
            }
        }

        self.layoutIfNeeded()
        self.recalculateContentSize()
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

    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

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
