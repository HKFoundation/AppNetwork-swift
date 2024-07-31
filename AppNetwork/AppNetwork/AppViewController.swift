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


        // 创建并配置 UINavigationBarAppearance 实例
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground() // 配置为不透明背景
        appearance.backgroundColor = UIColor.systemYellow // 设置背景颜色
        appearance.shadowColor = UIColor.red // 设置分隔线颜色
//        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemCyan]

        // 设置按钮颜色
        let buttonAppearance = UIBarButtonItemAppearance()
//        buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemMint]
        appearance.buttonAppearance = buttonAppearance
        appearance.backButtonAppearance = buttonAppearance

        // 应用配置到导航栏
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        // 设置导航栏按钮颜色（如果设置了UIBarButtonItemAppearance，则只会更改返回箭头等图标的颜色，否则也会改变按钮的颜色）
        navigationController?.navigationBar.tintColor = UIColor.systemFill

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
