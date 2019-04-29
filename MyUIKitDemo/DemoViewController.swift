//
//  DemoViewController.swift
//  MyUIKitDemo
//
//  Created by Wayne Hsiao on 2019/4/21.
//  Copyright © 2019 Wayne Hsiao. All rights reserved.
//

import UIKit
import MyUIKit

class DemoViewController: CustomViewController {
    @IBOutlet weak var contentView: UIView!

    static func initFromStoryboard() -> DemoViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let demoViewController = storyboard.instantiateViewController(withIdentifier: "DemoViewController") as? DemoViewController else {
            return nil
        }
        demoViewController.view.backgroundColor = .clear
        demoViewController.contentView.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        demoViewController.modalPresentationStyle = .overCurrentContext
        return demoViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first,
            touch.view != contentView {
            dismissTapped(touches)
        }
    }

    @IBAction func dismissTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
