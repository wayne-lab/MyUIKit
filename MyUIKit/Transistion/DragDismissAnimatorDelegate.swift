//
//  DragDismissAnimatorDelegate.swift
//  MyUIKit
//
//  Created by Wayne Hsiao on 2019/4/21.
//  Copyright © 2019 Wayne Hsiao. All rights reserved.
//

import UIKit

public protocol InteractionProtocol: UIPercentDrivenInteractiveTransition {
    var hasStarted: Bool { get set }
    var shouldFinish: Bool { get set }
}

class Interaction: UIPercentDrivenInteractiveTransition, InteractionProtocol {
    var hasStarted = false
    var shouldFinish = false
}

public protocol Interactable {
    var interactor: InteractionProtocol { get }
    var dismissAnimation: UIViewControllerAnimatedTransitioning { get }
}

@objcMembers
public class DragDismissAnimatorDelegate: UIPercentDrivenInteractiveTransition, UIViewControllerTransitioningDelegate, Interactable {

    public var dismissAnimation: UIViewControllerAnimatedTransitioning
    public var interactor: InteractionProtocol
    override public init () {
        self.dismissAnimation = DismissAnimator()
        self.interactor = Interaction()
    }

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomAnimatedTransitioning()
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let dismissAnimator = dismissAnimation as? DismissAnimator {
            dismissAnimator.userInteractiveDismissal = interactor.hasStarted
        }
        return dismissAnimation
    }

    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted == true ? interactor : nil
    }
}
