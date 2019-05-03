//
//  CutomViewController.swift
//  MyUIKit
//
//  Created by Wayne Hsiao on 2019/4/27.
//  Copyright © 2019 Wayne Hsiao. All rights reserved.
//

import UIKit

public protocol AnimatedTransition {
    var transition: DragDismissAnimatorDelegate { get }
}

open class CustomViewController: UIViewController {
    var transition = DragDismissAnimatorDelegate()
    var attachedViews = [UIView]()
    var previousProgress: CGFloat = 0
    lazy var panGestures: [UIPanGestureRecognizer] = {
        let action = #selector(CustomViewController.handleGesture(sender:))
        let edgeAction = #selector(CustomViewController.handleEdgeGesture(sender:))
        let panGesture = UIPanGestureRecognizer(target: self, action: action)
        let edgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: edgeAction)
        edgePanGesture.edges = .left
        edgePanGesture.delegate = self
        return [panGesture, edgePanGesture]
    }()
    var enableTransistionAnimation: Bool = false {
        didSet {
            if enableTransistionAnimation == true {
                if include(in: view.gestureRecognizers, by: panGestures) == false ||
                    view.gestureRecognizers == nil {
                    attachedViews.append(view)
                    for view in attachedViews {
                        for gesture in panGestures {
                            view.addGestureRecognizer(gesture)
                        }
                    }
                }
                transitioningDelegate = transition
            } else {
                attachedViews.append(view)
                for view in attachedViews {
                    for gesture in panGestures {
                        view.removeGestureRecognizer(gesture)
                    }
                }
                transitioningDelegate = nil
            }
        }
    }

    func include<T: Equatable>(in: [T]?, by: [T]) -> Bool {
        let contains = by.filter {
            return `in`?.contains($0) ?? false
        }
        return contains.count > 0
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        enableTransistionAnimation = true
    }

    public func attachGesture(_ view: UIView) {

    }

    @objc
    func handleGesture(sender: UIPanGestureRecognizer) {
        let percentThreshold:CGFloat = 0.3

        // convert y-position to downward pull progress (percentage)
        let translation = sender.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)

        switch sender.state {
        case .began:
            guard verticalMovement > 0 else {
                return
            }
            transition.interactor.hasStarted = true
            self.dismiss(animated: true, completion: nil)
        case .changed:
            transition.interactor.shouldFinish = progress > percentThreshold && previousProgress < progress
            transition.interactor.update(progress)
        case .cancelled:
            transition.interactor.hasStarted = false
            transition.interactor.cancel()
        case .ended:
            transition.interactor.hasStarted = false
            transition.interactor.shouldFinish
                ? transition.interactor.finish()
                : transition.interactor.cancel()
        default:
            break
        }
        previousProgress = progress
    }
    
    @objc func handleEdgeGesture(sender: UIScreenEdgePanGestureRecognizer) {
        let percentThreshold:CGFloat = 0.3
        
        // convert y-position to downward pull progress (percentage)
        let translation = sender.translation(in: view)
        let verticalMovement = translation.x / view.bounds.width
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        print(progress)
        
        switch sender.state {
        case .began:
            transition.interactor.hasStarted = true
            self.dismiss(animated: true, completion: nil)
        case .changed:
            transition.interactor.shouldFinish = progress > percentThreshold && previousProgress < progress
            transition.interactor.update(progress)
        case .cancelled:
            transition.interactor.hasStarted = false
            transition.interactor.cancel()
        case .ended:
            transition.interactor.hasStarted = false
            transition.interactor.shouldFinish
                ? transition.interactor.finish()
                : transition.interactor.cancel()
        default:
            break
        }
        previousProgress = progress
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CustomViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
