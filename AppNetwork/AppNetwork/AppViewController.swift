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

        let button = UIButton(type: .custom)
        button.setTitle("点击暂停", for: .normal)
        button.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        button.backgroundColor = UIColor.red
        button.addTarget(self, action: #selector(config), for: UIControl.Event.touchUpInside)
        view.addSubview(button)

        let button1 = UIButton(type: .custom)
        button1.setTitle("点击下载", for: .normal)
        button1.frame = CGRect(x: 100, y: 200, width: 100, height: 100)
        button1.backgroundColor = UIColor.red
        button1.addTarget(self, action: #selector(config1), for: UIControl.Event.touchUpInside)
        view.addSubview(button1)

        let button2 = UIButton(type: .custom)
        button2.setTitle("点击删除", for: .normal)
        button2.frame = CGRect(x: 100, y: 300, width: 100, height: 100)
        button2.backgroundColor = UIColor.red
        button2.addTarget(self, action: #selector(config2), for: UIControl.Event.touchUpInside)
        view.addSubview(button2)
    }
    
    @objc func config() {

//        let url = "https://test.developerplat.com:8443/resource/49/5_7.3.3.apk"
//        AppNetwork.breakTask(url: url, flag: true)
        AppNetwork.reqForGet(url: "https://api.apiopen.top/getJoke?page=1&count=2&type=video", appDone: { (done) in
            
        }) { (error) in
            
        }
        
        AppNetwork.reqForGet(url: "https://api.apiopen.top/getJoke", params: ["page" : "1", "count" : "2", "type" : "video"], appDone: { (done) in
            
        }) { (error) in
            
        }
        
//        AppNetwork.breakTask(url: "https://api.apiopen.top/getJoke?page=1&count=2&type=video")
    }

    @objc func config1() {
        let url = "https://test.developerplat.com:8443/resource/49/5_7.3.3.apk"

        AppNetwork.reqForDownload(url: url, progess: { _,_  in
            //            AppLog(progess)
        }, appDone: { _ in
            //            AppLog(done)
        }, appError: { _ in

        })

        AppNetwork.reqForDownload(url: "https://mat1.gtimg.com//musictop/mp3/521/kunminghu.mp3", progess: { (_, _) in

        }, appDone: { (_) in

        }) { (_) in

        }
        
//        AppFilesUtils.init().reqForDownload(url: "https://hyjj-chatm.oss-cn-beijing.aliyuncs.com/looktm-eye-report/2018%20%E6%AF%8D%E5%A9%B4%20App%20%E8%A1%8C%E4%B8%9A%E5%88%86%E6%9E%90%E6%8A%A5%E5%91%8A.pdf", params: [:], progess: { (_, _) in
//
//        }, appDone: { (_) in
//
//        }) { (_) in
//
//        }
    }

    @objc func config2() {
        let url = "https://test.developerplat.com:8443/resource/49/5_7.3.3.apk"
        
        AppNetwork.configEmptyCache(url: url, params: [:])
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}
