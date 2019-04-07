//
//  NewsTableViewController.swift
//  PullAndRefresh
//
//  Created by Wayne Hsiao on 2019/4/2.
//  Copyright © 2019 Hsiao, Wayne. All rights reserved.
//

import UIKit
import MyUIKit

class NewsTableViewController: CustomRefreshTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        enableRefreshControl = true
//        if let tableFooterView = tableView.tableFooterView {
//            tableFooterView.addSubview(footerView())
//        } else {
//            tableView.tableFooterView = footerView()
//        }

    }
    
    func footerView() -> UIView {
        let rect = CGRect(x: 0, y: 0, width: view.bounds.width, height: 25)
        let footerView = UITextView(frame: rect)
        let attributedString = NSMutableAttributedString(string: "Powered by NewsAPI.org")
        let url = URL(string: "https://newsapi.org")!
        attributedString.setAttributes([.link: url], range: NSMakeRange(11, 11))
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
    
    override func refresh(complete: @escaping () -> ()) {
        let delayTime = DispatchTime.now() + .seconds(5)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            
            complete()
        }
    }
    
    override func scrollUp(_ scrollView: UIScrollView) {
        super.scrollUp(scrollView)
    }
    
    override func scrollDown(_ scrollView: UIScrollView) {
        super.scrollDown(scrollView)
    }

}
