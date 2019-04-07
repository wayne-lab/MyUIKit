//
//  AnimationView.swift
//  PullAndRefresh
//
//  Created by Wayne Hsiao on 2019/4/5.
//  Copyright © 2019 Hsiao, Wayne. All rights reserved.
//

import UIKit
import Lottie

public enum LoopMode {
    
    /// Animation is played once then stops.
    case playOnce
    
    /// Animation will loop from end to beginning until stopped.
    case loop
    
    /// Animation will play forward, then backwards and loop until stopped.
    case autoReverse
}

public typealias AnimationProgressTime = CGFloat

public protocol AnimationViewProtocol {
    init(animation: Animation)
    func play()
    func stop()
    func play(fromProgress: AnimationProgressTime, toProgress: AnimationProgressTime, loopMode: LoopMode)
    var loopMode: LoopMode { get set }
}

class AnimationView: UIView, AnimationViewProtocol {
    var loopMode: LoopMode {
        didSet {
            animationView?.loopMode = toLottieLoopMode(loopMode)
        }
    }
    var animationView: Lottie.AnimationView?
    
    required convenience init(animation: Animation) {
        self.init(animation: animation, frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    
    required init(animation: Animation, frame: CGRect) {
        animationView = Lottie.AnimationView(animation: animation.animation)
        loopMode = .playOnce
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        loopMode = .playOnce
        super.init(coder: aDecoder)
    }

    func play() {
        animationView?.play()
    }
    
    func stop() {
        animationView?.stop()
    }
    
    func play(fromProgress: AnimationProgressTime,
              toProgress: AnimationProgressTime,
              loopMode: LoopMode) {
        animationView?.play(fromProgress: fromProgress,
                           toProgress: toProgress,
                           loopMode: toLottieLoopMode(loopMode),
                           completion: nil)
    }
    
    func toLottieLoopMode(_ loopMode: LoopMode) -> Lottie.LottieLoopMode {
        switch loopMode {
        case .playOnce:
            return Lottie.LottieLoopMode.playOnce
        case .loop:
            return Lottie.LottieLoopMode.loop
        case .autoReverse:
            return Lottie.LottieLoopMode.autoReverse
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if let animationView = animationView {
            animationView.frame = bounds
            addSubview(animationView)
        }
    }   
}
