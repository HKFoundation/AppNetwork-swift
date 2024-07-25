//
//  AppViewController.swift
//  AppNetwork
//
//  Created by bormil on 2020/9/15.
//  Copyright © 2020 北京卡友在线科技有限公司. All rights reserved.
//

import UIKit

class AppViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // AppCacheManager
        // AppError
        // AppBaseRequest
        // AppTaskRequest
        // AppConfiguration
        // AppNetwork
        // AppURL

        let push_btn = UIButton(type: .custom)
        push_btn.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 12)
        push_btn.titleLabel?.numberOfLines = 0
        push_btn.setTitle("进入\n页面", for: .normal)
        push_btn.setTitleColor(.white, for: .normal)
        push_btn.backgroundColor = .black
        push_btn.addTarget(self, action: #selector(config), for: .touchUpInside)
        push_btn.frame = CGRect(x: 20, y: 100, width: 44, height: 44)
        view.addSubview(push_btn)
    }

    @objc func config() {
        let target = DetailViewController()
        navigationController?.pushViewController(target, animated: true)
    }
}
