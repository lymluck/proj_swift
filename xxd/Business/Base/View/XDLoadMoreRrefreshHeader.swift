//
//  XDLoadMoreRrefreshHeader.swift
//  xxd
//
//  Created by remy on 2018/1/4.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class XDLoadMoreRrefreshHeader: MJRefreshHeader {

    private lazy var loadingView: UIActivityIndicatorView = {
        let loadingView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        loadingView.hidesWhenStopped = true
        addSubview(loadingView)
        return loadingView
    }()
    
    override func prepare() {
        super.prepare()
        mj_h = 50
    }
    
    override func placeSubviews() {
        super.placeSubviews()
        loadingView.center = CGPoint(x: mj_w * 0.5, y: mj_h * 0.5)
    }
    
    override func scrollViewContentOffsetDidChange(_ change: [AnyHashable : Any]!) {
        super.scrollViewContentOffsetDidChange(change)
        // 在刷新的refreshing状态
        if state == .refreshing {
            if window == nil { return }
            // sectionheader停留解决
            var insetT = -scrollView.mj_offsetY > scrollViewOriginalInset.top ? -scrollView.mj_offsetY : scrollViewOriginalInset.top
            insetT = insetT > mj_h + scrollViewOriginalInset.top ? mj_h + scrollViewOriginalInset.top : insetT
            scrollView.mj_insetT = insetT
            return
        }
        // 跳转到下一个控制器时，contentInset可能会变
        // swift中只能获取只读属性
//        scrollViewOriginalInset = scrollView.contentInset
        // 当前的contentOffset
        let offsetY = scrollView.mj_offsetY
        // 头部控件刚好出现的offsetY
        // 由于 scrollViewOriginalInset 只读,这里直接读取 scrollView.contentInset
        let happenOffsetY = scrollView.contentInset.top
        // 如果是向上滚动到看不见头部控件，直接返回
        if offsetY > happenOffsetY { return }
        // 普通 和 即将刷新 的临界点
        let normal2pullingOffsetY = happenOffsetY
        let pullingPercent = (happenOffsetY - offsetY) / mj_h
        if scrollView.isDragging {
            // 如果正在拖拽
            self.pullingPercent = pullingPercent
            if state == .idle && offsetY < normal2pullingOffsetY {
                // 转为即将刷新状态
                beginRefreshing()
            } else if state == .pulling && offsetY >= normal2pullingOffsetY {
                // 转为普通状态
                state = .idle
            } else {
                
            }
        } else if state == .pulling {
            // 即将刷新 && 手松开
            // 开始刷新
            beginRefreshing()
        } else if pullingPercent < 1 {
            self.pullingPercent = pullingPercent
        }
    }
    
    override var state: MJRefreshState {
        get {
            return super.state
        }
        set {
            if newValue != state {
                let oldValue = state
                super.state = newValue
                layer.removeAllAnimations()
                switch state {
                case .idle:
                    if oldValue == .refreshing {
                        UIView.animate(withDuration: TimeInterval(MJRefreshSlowAnimationDuration), animations: {
                            [weak self] in
                            self?.loadingView.alpha = 0
                        }, completion: { [weak self] (finished) in
                            // 如果执行完动画发现不是idle状态，就直接返回，进入其他状态
                            guard self?.state == .idle else { return }
                            self?.loadingView.alpha = 1
                            self?.loadingView.stopAnimating()
                        })
                    } else {
                        loadingView.stopAnimating()
                    }
                case .pulling:
                    loadingView.stopAnimating()
                case .refreshing:
                    // 防止refreshing -> idle的动画完毕动作没有被执行
                    loadingView.alpha = 1
                    loadingView.startAnimating()
                default:
                    break
                }
            }
        }
    }
}
