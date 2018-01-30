//
//  CZMeituanRefreshView.swift
//  刷新控件
//
//  Created by boboMa on 2018/1/24.
//  Copyright © 2018年 boboMa. All rights reserved.
//

import UIKit

class CZMeituanRefreshView: CZRefreshView {
    @IBOutlet weak var kangarooIconView: UIImageView!
    
    @IBOutlet weak var buildingIconView: UIImageView!
    
    @IBOutlet weak var earthIconView: UIImageView!
   override var parentViewHeight:CGFloat  {
        didSet{
            print("父视图高度\(parentViewHeight)")
        
            var scale : CGFloat
            if parentViewHeight < 23 {
                return;
            }
        //高度差 / 最大高度差
            if parentViewHeight > 126 {
                scale = 1
            }else{
                scale = 1 - ((126 - parentViewHeight) / (126 - 23))
            }
            kangarooIconView.transform = CGAffineTransform(scaleX:scale,y:scale)
        }
    }
    override func awakeFromNib() {
        //1.房子动
        let bImage1 = #imageLiteral(resourceName: "icon_building_loading_1")
        let bImage2 = #imageLiteral(resourceName: "icon_building_loading_2")
        buildingIconView.image = UIImage.animatedImage(with: [bImage1,bImage2], duration: 0.5)
        //2.地球
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        //加-保证地球逆时针转
        anim.toValue = -2 * Double.pi
        anim.repeatCount = MAXFLOAT
        anim.duration = 3
        anim.isRemovedOnCompletion = false
        earthIconView.layer.add(anim, forKey: nil)
        //3.袋鼠
        //0.设置袋鼠动画
        let kImage1 = #imageLiteral(resourceName: "icon_small_kangaroo_loading_1")
        let kImage2 = #imageLiteral(resourceName: "icon_small_kangaroo_loading_2")
        kangarooIconView.image = UIImage.animatedImage(with: [kImage1,kImage2], duration: 0.25)
        //1.设置锚点
        kangarooIconView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        //2.设置center
        let x = self.bounds.width * 0.5
        let y = self.bounds.height - 21
        kangarooIconView.center = CGPoint(x: x, y: y)
        kangarooIconView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        
    }


}
