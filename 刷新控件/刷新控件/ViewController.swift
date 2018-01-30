//
//  ViewController.swift
//  刷新控件
//
//  Created by boboMa on 2018/1/18.
//  Copyright © 2018年 boboMa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
   
    lazy var refreshControl = CZRefreshControl()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInsetAdjustmentBehavior = .never
        //设置contentInset
        tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        
   tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
    
        
        loadData()
    
    }

   @objc func loadData() {
    
    print("开始刷新")
   refreshControl.beginRefreshing()
    DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + 2) {
        print("jieshu")
        self.refreshControl.endRefreshing()
    }
    
    }


}

