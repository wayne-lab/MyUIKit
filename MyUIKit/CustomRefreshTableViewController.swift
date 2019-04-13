//
//  CustomRefreshTableViewController.swift
//  PullAndRefresh
//
//  Created by Hsiao, Wayne on 2019/3/29.
//  Copyright © 2019 Hsiao, Wayne. All rights reserved.
//

import UIKit

public enum PullDirection {
    case pullUp, pullDown, unknow
}

public protocol CustomRefreshTableViewControllerDelegate: UITableViewDelegate {
    func refresh(pullDirection: PullDirection, complete: @escaping () -> Void)
    func willShowRefreshController(_ pullDirection: PullDirection) -> Bool
}

open class CustomRefreshTableViewController: UITableViewController {
    enum Constant {
        static let animationStartTimeFrame: CGFloat = 0.0
        static let animationEndTimeFrame: CGFloat = 0.95
        static let animationProgressTime: CGFloat = 100.0
        static let animationDefault: String = "222-trail-loading"
    }

    @IBInspectable var animation: String!
    @IBInspectable var refreshControlBackgroundColor: UIColor!
    public weak var refreshControlDelegate: CustomRefreshTableViewControllerDelegate?
    var topAnimationView: AnimationView!
    var bottomAnimationView: AnimationView!
    var topRefreshControl: UIRefreshControl? {
        get {
            return tableView.refreshControl
        }

        set {
            tableView.refreshControl = newValue
            tableView.refreshControl?.backgroundColor = .clear
            tableView.refreshControl?.tintColor = .clear
            if let rect = topRefreshControl?.bounds {
                topAnimationView.frame = rect
            }
            topRefreshControl?.addSubview(topAnimationView)
        }
    }
    var bottomRefreshControl: UIRefreshControl? {
        didSet {
            let rect = CGRect(x: 0, y: 0,
                              width: view.bounds.width,
                              height: 60)
            let bottomView = UIView(frame: rect)
            bottomView.backgroundColor = .white
            bottomAnimationView?.frame = rect
            bottomView.addSubview(bottomAnimationView)
            tableView.tableFooterView = bottomView
        }
    }
    var lastContentOffset: CGFloat = 0
    var progressTime: AnimationProgressTime {
        let topInset = UIApplication.shared.statusBarFrame.height + tableView.contentInset.top
        let progressTime =  abs(tableView.contentOffset.y + topInset) / Constant.animationProgressTime
        return progressTime
    }
    public private(set) var pullDirection: PullDirection = .unknow
    var previousProgressTime: AnimationProgressTime {
        return progressTime - 0.1
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupAnimation(animation: animation ?? Constant.animationDefault)
    }

    func setupAnimation(animation: String) {
        let animationLoading = Animation.named(animation)
        if topAnimationView == nil {
            topAnimationView = AnimationView(animation: animationLoading)
        }
        if bottomAnimationView == nil {
            bottomAnimationView = AnimationView(animation: animationLoading)
        }
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideFooterView()
    }

    // MARK: - Table vi@objc ew data source

    override open func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    @objc
    open func pullUp(_ scrollView: UIScrollView) {
        guard refreshControlDelegate?.willShowRefreshController(.pullUp) == true else {
            return
        }

        let threshold   = 100.0
        let contentOffset = scrollView.contentOffset.y
        let contentHeight = tableView.tableFooterView != nil ?
            scrollView.contentSize.height - tableView.tableFooterView!.bounds.height : scrollView.contentSize.height
        let diffHeight = contentHeight - contentOffset
        let frameHeight = scrollView.bounds.size.height
        var triggerThreshold  = Float((diffHeight - frameHeight))/Float(threshold)
        triggerThreshold   =  min(triggerThreshold, 0.0)
        let pullRatio  = min(abs(triggerThreshold), 1.0)

        defer {
            lastContentOffset = CGFloat(triggerThreshold)
        }

        addFooterView()

        if pullRatio >= 0.01,
            bottomRefreshControl?.isRefreshing == false {
            UIView.animate(withDuration: 0.2) {
                self.showFooterView()
                if let footerView = self.tableView.tableFooterView {
                    self.tableView.sendSubviewToBack(footerView)
                }
            }

            let progressTime: AnimationProgressTime = CGFloat(abs(triggerThreshold))
            let previousProgressTime: AnimationProgressTime = progressTime - 0.1

            guard progressTime < Constant.animationEndTimeFrame else {
                if bottomRefreshControl?.isRefreshing == false {
                    bottomRefreshControl?.beginRefreshing()
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                }

                return
            }

            if lastContentOffset > CGFloat(triggerThreshold) {
//                print("up")
                bottomAnimationView.play(fromProgress: previousProgressTime,
                                         toProgress: progressTime,
                                         loopMode: .playOnce)
            } else if lastContentOffset < CGFloat(triggerThreshold) {
//                print("down")
                bottomAnimationView.play(fromProgress: progressTime,
                                         toProgress: previousProgressTime,
                                         loopMode: .playOnce)
            } else {

            }
        }
    }

    @objc
    open func pullDown(_ scrollView: UIScrollView) {
        defer {
            lastContentOffset = scrollView.contentOffset.y
        }

        guard refreshControlDelegate?.willShowRefreshController(.pullDown) == true else {
            removeTopView()
            return
        }

        addTopView()

        guard tableView.refreshControl?.isRefreshing == false else {
            return
        }

        let progressTime = self.progressTime
        let previousProgressTime = self.previousProgressTime

        guard progressTime < Constant.animationEndTimeFrame else {
            if tableView.refreshControl?.isRefreshing == false {
                tableView.refreshControl?.beginRefreshing()
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
            }

            return
        }

        if lastContentOffset > scrollView.contentOffset.y {
            topAnimationView.play(fromProgress: previousProgressTime,
                                  toProgress: progressTime,
                                  loopMode: .playOnce)
        } else if lastContentOffset < scrollView.contentOffset.y {
            topAnimationView.play(fromProgress: progressTime,
                                  toProgress: previousProgressTime,
                                  loopMode: .playOnce)
        } else {

        }
    }
}

extension CustomRefreshTableViewController {

    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text = "\(indexPath.row)"
        return cell!
    }

    override open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let refreshControl = tableView.refreshControl {
            tableView.sendSubviewToBack(refreshControl)
        }
        lastContentOffset = scrollView.contentOffset.y

        if let bottomRefresh = bottomRefreshControl?.isRefreshing,
            bottomRefresh == false {
            hideFooterView()
        }
    }

    override open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            pullDown(scrollView)
        } else {
            pullUp(scrollView)
        }
    }

    override open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if tableView.refreshControl?.isRefreshing == true ||
            bottomRefreshControl?.isRefreshing == false {
            hideFooterView()
        }
    }

    override open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        guard tableView.refreshControl?.isRefreshing == true ||
            bottomRefreshControl?.isRefreshing == true else {
                hideFooterView()
                return
        }

        var pullDirection: PullDirection = .unknow
        if topRefreshControl?.isRefreshing == true {
            topAnimationView.play()
            topAnimationView.loopMode = .loop
            pullDirection = .pullDown
        } else if bottomRefreshControl?.isRefreshing == true {
            bottomAnimationView.play()
            bottomAnimationView.loopMode = .loop
            removeTopView()
            pullDirection = .pullUp
        }

        refreshControlDelegate?.refresh(pullDirection: pullDirection) { [weak self] in

            guard let strongSelf = self else {
                return
            }

            DispatchQueue.main.async {
                if strongSelf.topRefreshControl?.isRefreshing == true {
                    strongSelf.topAnimationView.stop()
                    strongSelf.topRefreshControl?.endRefreshing()
                    // Tricky part: We want to hide footer view but at this moment the top refreshcontrol doesn't hidden. So force set this flag to hide footer view in scrollViewWillBeginDragging.
                    strongSelf.tableView.tableFooterView?.isHidden = false
                } else if strongSelf.bottomRefreshControl?.isRefreshing == true {
                    strongSelf.bottomAnimationView.stop()
                    strongSelf.bottomRefreshControl?.endRefreshing()
                    strongSelf.hideFooterView()
                    strongSelf.addTopView()
                }
            }
        }
    }

    func removeFooterView() {
        tableView.tableFooterView = nil
    }

    func addFooterView() {
        guard tableView.tableFooterView == nil else {
            return
        }
        bottomRefreshControl = UIRefreshControl()
    }

    func hideFooterView() {
        UIView.animate(withDuration: 0.5) {
            guard self.tableView.tableFooterView?.isHidden == false else {
                return
            }
            self.tableView.tableFooterView?.isHidden = true
            let size = self.tableView.contentSize
            let height = self.tableView.tableFooterView?.bounds.height ?? 60
            self.tableView.contentSize = CGSize(width: size.width, height: size.height - height)
        }
    }

    func showFooterView() {
        guard tableView.tableFooterView?.isHidden == true else {
            return
        }
        self.tableView.tableFooterView?.isHidden = false
        let size = self.tableView.contentSize
        let height = self.tableView.tableFooterView?.bounds.height ?? 60
        self.tableView.contentSize = CGSize(width: size.width, height: size.height + height)
    }

    func removeTopView() {
        tableView.refreshControl = nil
        topAnimationView.removeFromSuperview()
    }

    func addTopView() {
        guard tableView.refreshControl == nil else {
            return
        }
        topRefreshControl = UIRefreshControl()
    }
}
