//
//  CustomAnimatedTransitioning.swift
//  MyUIKit
//
//  Created by Wayne Hsiao on 2019/4/21.
//  Copyright © 2019 Wayne Hsiao. All rights reserved.
//

import UIKit

@objcMembers
public class CustomAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func transformFromRect(from source: CGRect, toRect destination: CGRect) -> CGAffineTransform {
        return CGAffineTransform.identity
            .translatedBy(x: destination.midX - source.midX, y: destination.midY - source.midY)
            .scaledBy(x: destination.width / source.width, y: destination.height / source.height)
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to),
            let fromViewController = transitionContext.viewController(forKey: .from) else {
                transitionContext.completeTransition(true)
                return
        }

        let duration = transitionDuration(using: transitionContext)
        let containerView = transitionContext.containerView

        guard let toView = toViewController.view,
            let snapshot = toView.snapshotView(afterScreenUpdates: true) else {
                transitionContext.completeTransition(true)
                return
        }
        let fromViewSnapshot = fromViewController.view.snapshotView(afterScreenUpdates: false)
        containerView.addSubview(toView)
        containerView.addSubview(fromViewSnapshot!)
        let finalFrame = CGRect(x: containerView.frame.minX,
                                y: containerView.frame.minY,
                                width: containerView.bounds.width,
                                height: containerView.bounds.height)
        toView.frame = finalFrame
        snapshot.frame = CGRect(x: containerView.frame.minX,
                                y: containerView.frame.maxY,
                                width: containerView.bounds.width,
                                height: containerView.bounds.height)
        containerView.addSubview(snapshot)
        containerView.sendSubviewToBack(toView)
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveEaseInOut,
                       animations: {
                        snapshot.frame = finalFrame
        }, completion: { (finished) in
            snapshot.removeFromSuperview()
            fromViewSnapshot!.removeFromSuperview()
            transitionContext.completeTransition(finished)
        })
    }
}
