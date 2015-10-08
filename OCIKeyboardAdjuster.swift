//
//  KeyboardAdjuster.swift
//
//
//  Created by Hristo Todorov - Oci on 6/5/15.
//  Copyright (c) 2015
//

import UIKit

class OCIKeyboardAdjuster: NSObject
{
    static let sharedKeyboardAdjuster = OCIKeyboardAdjuster()
    
    weak var focusedControl: UIView?
    
    private override init() {
        //this way users will always use singleton instance
    }
    
    private(set) weak var scrollView: UIScrollView?
    private(set) weak var view: UIView!

    private var originalScrollOffset: CGPoint?
    private var originalScrollSize: CGSize?
    
    func startObserving(scrollableView: UIScrollView, holderView: UIView)
    {
        scrollView = scrollableView
        view = holderView
        
        //remove old observers
        stopObserving()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func stopObserving()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //MARK: scrollview ajust when keyboard present
    @objc private func keyboardWillShow(notification: NSNotification)
    {
        if nil == self.view || self.view.window == nil
        {
            return
        }
        
        if let scrollView = scrollView,
            let userInfo = notification.userInfo,
            let keyboardFrameInWindow = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue,
            let keyboardFrameInWindowBegin = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue,
            let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber,
            let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
        {
            // the keyboard frame is specified in window-level coordinates. this calculates the frame as if it were a subview of our view, making it a sibling of the scroll view
            let keyboardFrameInView = self.view.convertRect(keyboardFrameInWindow.CGRectValue(), fromView: nil)
            
            let scrollViewKeyboardIntersection = CGRectIntersection(scrollView.frame, keyboardFrameInView)
            
            UIView.animateWithDuration(animationDuration.doubleValue,
                delay: 0,
                options: UIViewAnimationOptions(rawValue: UInt(animationCurve.unsignedLongValue)),
                animations: { [weak self] in
                    
                    if let strongSelf = self,
                        let scrollView = strongSelf.scrollView
                    {
                        if let focusedControl = strongSelf.focusedControl
                        {
                            // if the control is a deep in the hierarchy below the scroll view, this will calculate the frame as if it were a direct subview
                            var controlFrameInScrollView = scrollView.convertRect(focusedControl.bounds, fromView: focusedControl)
                            controlFrameInScrollView = CGRectInset(controlFrameInScrollView, 0, -10)
                            
                            let controlVisualOffsetToTopOfScrollview = controlFrameInScrollView.origin.y - scrollView.contentOffset.y
                            let controlVisualBottom = controlVisualOffsetToTopOfScrollview + controlFrameInScrollView.size.height
                            
                            // this is the visible part of the scroll view that is not hidden by the keyboard
                            let scrollViewVisibleHeight = scrollView.frame.size.height - scrollViewKeyboardIntersection.size.height
                            
                            var newContentOffset = scrollView.contentOffset
                            //store it to better update latter
                            strongSelf.originalScrollOffset = newContentOffset
                            
                            if controlVisualBottom > scrollViewVisibleHeight // check if the keyboard will hide the control in question
                            {
                                newContentOffset.y += (controlVisualBottom - scrollViewVisibleHeight)
                                
                                //check for impossible offset
                                newContentOffset.y = min(newContentOffset.y, scrollView.contentSize.height - scrollViewVisibleHeight)
                            }
                            else if controlFrameInScrollView.origin.y < scrollView.contentOffset.y // if the control is not fully visible, make it so (useful if the user taps on a partially visible input field
                            {
                                newContentOffset.y = controlFrameInScrollView.origin.y
                            }
                            
                            //no animation as we had own animation already going
                            scrollView.setContentOffset(newContentOffset, animated: false)
                        }
                        
                        var scrollSize = scrollView.contentSize
                        if let _ = strongSelf.originalScrollSize
                        {
                            //subtract old keyboard value
                            scrollSize.height -= strongSelf.view.convertRect(keyboardFrameInWindowBegin.CGRectValue(), fromView: nil).size.height
                        }
                        strongSelf.originalScrollSize = scrollSize
                        scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, scrollSize.height + keyboardFrameInView.height)
                    }
                    
                },
                completion: nil)
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification)
    {
        if self.view == nil || self.view.window == nil
        {
            return
        }
        
        if let _ = scrollView,
            let userInfo = notification.userInfo,
            let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber,
            let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
        {
            UIView.animateWithDuration(animationDuration.doubleValue,
                delay: 0,
                options: UIViewAnimationOptions(rawValue: UInt(animationCurve.unsignedLongValue)),
                animations: {
                    
                    if let scrollView = self.scrollView
                    {
                        if let originalContentSize = self.originalScrollSize
                        {
                            scrollView.contentSize = originalContentSize
                        }
                        if let originalScrollOffset = self.originalScrollOffset
                        {
                            scrollView.setContentOffset( originalScrollOffset, animated: false)
                        }
                    }
                    
                },
                completion: { success in
                    
                    self.originalScrollOffset = nil
                    self.originalScrollSize = nil
                    
            })
        }
    }

}
