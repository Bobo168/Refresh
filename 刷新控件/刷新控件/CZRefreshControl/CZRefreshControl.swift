//
//  CZRefreshControl.swift
//  传智微博
//
//  Created by boboMa on 2018/1/18.
//  Copyright © 2018年 boboMa. All rights reserved.
//

import UIKit
///刷新状态切换的临界点
private let CZRefreshOffset : CGFloat = 126

/// 刷新状态
///
/// - Normal: 普通状态，什么都不做
/// - Pulling: 超过临界点，如果放手，开始刷新
/// - WillRefresh: 用户超过临界点，并且放手
enum CZRefreshState {
    case Normal
    case Pulling
    case WillRefresh
}


///刷新控件 - 负责刷新相关的逻辑处理
class CZRefreshControl: UIControl {
    
    
    //MARK: -属性
    ///刷新控件的父视图，下拉刷新控件应该适用于UITableView / UICollectionView
    //addSubView时候会父视图强引用刷新控件，刷新控件再强引用父视图会循环引用，所以用weak
    private weak var scrollView : UIScrollView?
    ///刷新视图懒加载
    lazy var refreshView = CZRefreshView.refreshView()
    //MARK: 构造函数
    init() {
        super.init(frame: CGRect())
        
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    /**
     willMove addSubview 方法会调用
     - 当添加到父视图的时候，newSuperview 是父视图
     - 当父视图被移除，newSuperview 是 nil
     */
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        //判断父视图的类型
        guard let sv = newSuperview as? UIScrollView else {
            return
        }
        //记录父视图
        scrollView = sv
        
        //KVO监听父视图的contentOffset
        
        scrollView?.addObserver(self, forKeyPath:"contentOffset", options: [], context: nil)
        
    }
    //本视图从父视图移除
    //提示：所有的下拉刷新框架都是监听父视图的contentOffset
    //所有的框架的KVO监听思路都是这个
    override func removeFromSuperview() {
        //superView 还存在
        superview?.removeObserver(self, forKeyPath: "contentOffset")
        
        super.removeFromSuperview()
        //superView 还存在不存在
    }
    //所有KVO 方法会统一调用此方法
    //在程序中，通常只监听某一个对象的某几个属性，如果属性太多，就会很乱
    //观察者模式，在不需要的时候，都需要释放
    //- 通知中心：如果不释放，什么也不会发生，但是会有内存泄漏，会有多次注册的可能
    //- KVO： 如果不释放会崩溃
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //contentOffset 的 y 值跟contentInset 的 top有关
        guard let sv = scrollView else {
            return
        }
        //初始高度应该是0
        let height = -(sv.contentInset.top + sv.contentOffset.y)
        //如果高度小于0 直接返回 防止上推出现刷新控件
        if height < 0 {
            return
        }
        
        //可以根据高度设置刷新控件的frame
        self.frame = CGRect(x: 0,
                            y: -height,
                            width: sv.bounds.width,
                            height: height)
        //=------传递父视图高度
        refreshView.parentViewHeight = height
        
       //判断临界点 - 只需要判断一次
        if sv.isDragging{
            if height > CZRefreshOffset && refreshView.refreshState == .Normal{
                print("放手刷新")
                refreshView.refreshState = .Pulling
            }else if height <= CZRefreshOffset && refreshView.refreshState == .Pulling{
                print("继续使劲...")
                 //刷新结束之后，将状态修改为 .Normal 才能够继续响应刷新
                refreshView.refreshState = .Normal
            }
        }else{
           //放手 - 判断是否超过临界点
            if refreshView.refreshState == .Pulling{
                print("准备刷新")
              
                beginRefreshing()
                //发送刷新数据事件
                sendActions(for: .valueChanged)
                
            }
        }
        
        
    }
    //开始刷新
     func beginRefreshing(){
        print("开始刷新")
        //判断父视图
        guard let sv = scrollView else { return  }
        //判断是否正在刷新，如果正在刷新直接返回 （可以防止多次下拉刷新？）
        if refreshView.refreshState == .WillRefresh{
            return
        }
        
        //设置刷新视图的状态
        refreshView.refreshState = .WillRefresh
        //调整表格的间距
        var inset = sv.contentInset
        inset.top += CZRefreshOffset
        sv.contentInset = inset
        //设置刷新视图的父视图高度
        
        refreshView.parentViewHeight = CZRefreshOffset
      /**  //如果开始调用beginRefresh会重复发送刷新事件（因为已经设置了contentInse   .valueChanged 已经触发会导致再次调用刷新事件 ）
        //发送刷新数据事件
       // sendActions(for: .valueChanged)
      */
    }
    
    //结束刷新
    func endRefreshing(){
        print("结束刷新")
        
        guard let sv = scrollView else { return  }
        //判断状态，是否正在刷新，如果不是，直接返回 （防止重复修改表格间距）
        if refreshView.refreshState != .WillRefresh {
            return
        }
        
        //恢复刷新视图的状态
        refreshView.refreshState = .Normal
        
        //恢复刷新视图的contentInset
        var inset = sv.contentInset
        inset.top -= CZRefreshOffset
        sv.contentInset = inset
        
    }

}
extension CZRefreshControl{
    
  func setupUI(){
      backgroundColor = superview?.backgroundColor
    
    //设置超出边界不显示 因为一进来刷新控件是0
   // clipsToBounds = true
    
    //添加刷新视图 - 从xib 加载出来，默认的是xib中指定的宽高
    addSubview(refreshView)
    //自动布局 - 设置xib控件的自动布局需要指定宽高约束
    refreshView.translatesAutoresizingMaskIntoConstraints = false
    
    addConstraint(NSLayoutConstraint(item: refreshView,
                                     attribute: .centerX,
                                     relatedBy: .equal,
                                     toItem: self,
                                     attribute: .centerX,
                                     multiplier: 1.0,
                                     constant: 0))
    addConstraint(NSLayoutConstraint(item: refreshView,
                                     attribute: .bottom,
                                     relatedBy: .equal,
                                     toItem: self,
                                     attribute: .bottom,
                                     multiplier: 1.0,
                                     constant: 0))
    
    addConstraint(NSLayoutConstraint(item: refreshView,
                                     attribute: .width,
                                     relatedBy: .equal,
                                     toItem: nil,
                                     attribute: .notAnAttribute,
                                     multiplier: 1.0,
                                     constant: refreshView.bounds.width))
    
    addConstraint(NSLayoutConstraint(item: refreshView,
                                     attribute: .height,
                                     relatedBy: .equal,
                                     toItem: nil,
                                     attribute: .notAnAttribute,
                                     multiplier: 1.0,
                                     constant: refreshView.bounds.height))
    
    
    
    
    
    
    
    
    
    
    
    }
}
