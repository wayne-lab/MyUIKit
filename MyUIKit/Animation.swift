//
//  Animation.swift
//  PullAndRefresh
//
//  Created by Wayne Hsiao on 2019/4/5.
//  Copyright © 2019 Hsiao, Wayne. All rights reserved.
//

import UIKit
import Lottie

public protocol Animatable {
    init(name: String)
}

public class Animation: NSObject, Animatable {
    public static func named(_ name: String) -> Animation {
        let animation = Animation(name: name)
        return animation
    }
    
    var animation: Lottie.Animation?
    required public init(name: String) {
        let bundle = Bundle(for: Animation.self)
        animation = Lottie.Animation.named(name, bundle: bundle)
    }
}
