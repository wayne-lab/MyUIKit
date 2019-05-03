//
//  DismissAnimator.swift
//  MyUIKit
//
//  Created by Wayne Hsiao on 2019/4/22.
//  Copyright © 2019 Wayne Hsiao. All rights reserved.
//

import UIKit

public class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var userInteractiveDismissal = false
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to),
            let fromViewSnapshot = fromViewController.view.snapshotView(afterScreenUpdates: false) ?? fromViewController.view,
            let toViewSnapshot = toViewController.view.snapshotView(afterScreenUpdates: false) ?? toViewController.view else
        {
            transitionContext.completeTransition(true)
            return
        }

        fromViewController.view.isHidden = true
        transitionContext.containerView.addSubview(toViewSnapshot)
        fromViewController.view.isHidden = true
        transitionContext.containerView.addSubview(fromViewSnapshot)

        let screenBounds = UIScreen.main.bounds
        let bottomLeftCorner = CGPoint(x: 0, y: screenBounds.height)
        let finalFrame = CGRect(origin: bottomLeftCorner, size: screenBounds.size)

//        fromViewSnapshot.alpha = 1
        let duration = transitionDuration(using: transitionContext)
        if userInteractiveDismissal {
            UIView.animate(withDuration: duration, animations: {
                fromViewSnapshot.frame = finalFrame
            }, completion: { (_) in
                fromViewSnapshot.removeFromSuperview()
                toViewSnapshot.removeFromSuperview()
                fromViewController.view.isHidden = false
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        } else {
            UIView.animate(withDuration: duration,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 10,
                           options: .curveEaseInOut,
                           animations: {
                            fromViewSnapshot.frame = finalFrame
            }, completion: { (_) in
                fromViewSnapshot.removeFromSuperview()
                toViewSnapshot.removeFromSuperview()
                fromViewController.view.isHidden = false
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}
