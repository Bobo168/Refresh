//
//  CZRefreshView.swift
//  刷新控件
//
//  Created by boboMa on 2018/1/22.
//  Copyright © 2018年 boboMa. All rights reserved.
//

import UIKit
///负责视图 -刷新相关的 UI 显示和动画
class CZRefreshView: UIView {
    ///刷新状态
    /**
     iOS系统中UIView封装的旋转动画
     - 默认顺时针旋转
     - 就近原则
     - 要想实现同方向旋转，需要调整一个 非常小的数字（近）
     - 如果想实现360 旋转 需要核心动画 CABaseAnimation
     */
    var refreshState : CZRefreshState = .Normal{
        didSet{
            switch refreshState {
            case .Normal:
                //恢复状态、
                tipIcon?.isHidden = false
                indicator?.stopAnimating()
                tipLabel?.text = "继续使劲拉..."
                //恢复箭头方向
                UIView.animate(withDuration: 0.25, animations: {
                    self.tipIcon?.transform = CGAffineTransform.identity
                })
                
            case .Pulling:
                tipLabel?.text = "放手刷新..."
                //箭头旋转180度 减去0.001的目的是让箭头顺时针上去逆时针下来
                // 加上0.001是逆时针上去顺时针下来
                UIView.animate(withDuration: 0.25, animations: {
                    self.tipIcon?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi - 0.001))
                })
            
            case .WillRefresh:
                tipLabel?.text = "正在刷新中..."
                //隐藏提示图标
                tipIcon?.isHidden = true
                //显示菊花
                indicator?.startAnimating()
            }
        }
        
    }
    ///父视图的高度----为了刷新控件不需要关心当前具体的刷新视图是谁
   var parentViewHeight:CGFloat = 0
    
///指示器
    @IBOutlet weak var indicator: UIActivityIndicatorView?
    ///提示图标
    @IBOutlet weak var tipIcon: UIImageView?
    ///提示标签
    @IBOutlet weak var tipLabel: UILabel?
  
    
    class func refreshView()-> CZRefreshView {
        
        let nib = UINib(nibName: "CZMeituanRefreshView", bundle: nil)
        
        return nib.instantiate(withOwner: nil, options: nil)[0] as! CZRefreshView
        
    }

}
