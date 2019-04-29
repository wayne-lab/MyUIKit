//
//  NewsTableViewController.swift
//  PullAndRefresh
//
//  Created by Wayne Hsiao on 2019/4/2.
//  Copyright © 2019 Hsiao, Wayne. All rights reserved.
//

import UIKit
import MyUIKit

class NewsTableViewController: CustomRefreshTableViewController, CustomRefreshTableViewControllerDelegate {

    var selectedCell: UITableViewCell?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func footerView() -> UIView {
        let rect = CGRect(x: 0, y: 0, width: view.bounds.width, height: 25)
        let footerView = UITextView(frame: rect)
        let attributedString = NSMutableAttributedString(string: "Powered by NewsAPI.org")
        let url = URL(string: "https://newsapi.org")!
        attributedString.setAttributes([.link: url],
                                       range: NSRange(location: 11, length: 11))
        footerView.attributedText = attributedString
        footerView.isUserInteractionEnabled = true
        footerView.isEditable = false
        footerView.linkTextAttributes = [
            .foregroundColor: UIColor.blue
        ]
        return footerView
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 20
    }

    func refresh(pullDirection: PullDirection,
                 complete: @escaping () -> Void) {
        let delayTime = DispatchTime.now() + .seconds(5)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            complete()
        }
    }

    func willShowRefreshController(_ pullDirection: PullDirection) -> Bool {
        switch pullDirection {
        case .pullUp:
            return true
        case .pullDown:
            return true
        case .unknow:
            return false
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let demoView = DemoViewController.initFromStoryboard() else {
            return
        }
        selectedCell = tableView.cellForRow(at: indexPath)
        present(demoView, animated: true, completion: nil)
    }
}
