//
//  DetailViewController.swift
//  AppNetwork
//
//  Created by ✐ ᵕ̈ ᴹᴼᴿᴺᴵᴺᴳ on 2024/7/2.
//  Copyright © 2024 北京卡友在线科技有限公司. All rights reserved.
//

import Alamofire
import UIKit

class DetailViewController: UIViewController {
    
    deinit {
        print("DetailViewController deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let download_btn = UIButton(type: .custom)
        download_btn.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 12)
        download_btn.titleLabel?.numberOfLines = 0
        download_btn.setTitle("下载\n文件", for: .normal)
        download_btn.setTitleColor(.white, for: .normal)
        download_btn.backgroundColor = .black
        download_btn.addTarget(self, action: #selector(config), for: .touchUpInside)
        download_btn.frame = CGRect(x: 20, y: 100, width: 44, height: 44)
        view.addSubview(download_btn)

        let suspend_btn = UIButton(type: .custom)
        suspend_btn.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 12)
        suspend_btn.titleLabel?.numberOfLines = 0
        suspend_btn.setTitle("暂停\n下载", for: .normal)
        suspend_btn.setTitleColor(.white, for: .normal)
        suspend_btn.backgroundColor = .black
        suspend_btn.addTarget(self, action: #selector(config3), for: .touchUpInside)
        suspend_btn.frame = CGRect(x: 84, y: 100, width: 44, height: 44)
        view.addSubview(suspend_btn)

        let resume_btn = UIButton(type: .custom)
        resume_btn.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 12)
        resume_btn.titleLabel?.numberOfLines = 0
        resume_btn.setTitle("继续\n下载", for: .normal)
        resume_btn.setTitleColor(.white, for: .normal)
        resume_btn.backgroundColor = .black
        resume_btn.addTarget(self, action: #selector(config4), for: .touchUpInside)
        resume_btn.frame = CGRect(x: 148, y: 100, width: 44, height: 44)
        view.addSubview(resume_btn)

        let request_btn = UIButton(type: .custom)
        request_btn.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 12)
        request_btn.titleLabel?.numberOfLines = 0
        request_btn.setTitle("接口\n请求", for: .normal)
        request_btn.setTitleColor(.white, for: .normal)
        request_btn.backgroundColor = .black
        request_btn.addTarget(self, action: #selector(config1), for: .touchUpInside)
        request_btn.frame = CGRect(x: 20, y: 164, width: 44, height: 44)
        view.addSubview(request_btn)

        let upload_btn = UIButton(type: .custom)
        upload_btn.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 12)
        upload_btn.titleLabel?.numberOfLines = 0
        upload_btn.setTitle("上传\n文件", for: .normal)
        upload_btn.setTitleColor(.white, for: .normal)
        upload_btn.backgroundColor = .black
        upload_btn.addTarget(self, action: #selector(config2), for: .touchUpInside)
        upload_btn.frame = CGRect(x: 20, y: 228, width: 44, height: 44)
        view.addSubview(upload_btn)
    }

    // 下载文件
    @objc func config() {
        
//    https://download.blender.org/peach/bigbuckbunny_movies/BigBuckBunny_320x180.mp4

        var configuration = AppConfiguration(baseURL: URL(string: "https://download.blender.org"))

//        var configuration = AppConfiguration(baseURL: URL(string: "http://161.189.189.3"))
        configuration.interceptor = nil
        AppNetwork.shared.configuration = configuration

        let url = "https://download.blender.org/peach/bigbuckbunny_movies/BigBuckBunny_320x180.mp4"

//        let url = "http://161.189.189.3/package/update_package_v1.1.any_to_v1.1.30.tar.bz2"

        AppNetwork.shared.download(url: url) { bytesLoad, bytesTotal in
            print(Double(bytesLoad) / Double(bytesTotal) * 100)
//            print(bytesLoad, bytesTotal)
        } succeed: { _ in

        } failed: { _ in
        }
    }

    // 暂停下载
    @objc func config3() {
        let url = "https://download.blender.org/peach/bigbuckbunny_movies/BigBuckBunny_320x180.mp4"
//        AppNetwork.shared.suspend(url: url)
        AppNetwork.shared.cancel(url: url)
    }

    // 继续下载
    @objc func config4() {
//        let url = "https://download.blender.org/peach/bigbuckbunny_movies/BigBuckBunny_320x180.mp4"
//        AppNetwork.shared.resume(url: url)
        config()
    }

    // 接口请求
    @objc func config1() {
        var configuration = AppConfiguration(baseURL: URL(string: "https://api.vvhan.com"))
        configuration.interceptor = nil
        AppNetwork.shared.configuration = configuration

        AppNetwork.shared.request(url: "/api/60s?type=json") { _ in

        } failed: { _ in
        }
    }

    // 文件上传
    @objc func config2() {
        
//        var configuration = AppConfiguration(baseURL: URL(string: "https://file.io"))
        var configuration = AppConfiguration(baseURL: URL(string: "http://localhost:3000"))
        configuration.interceptor = UploadInterceptor()
        AppNetwork.shared.configuration = configuration
//        20210507210619313
//        BigBuckBunny_320x180
        if let local = Bundle.main.path(forResource: "BigBuckBunny_320x180", ofType: "mp4") {
            print("Image path: \(local)")
            
//            video/mp4
//            image/gif
            AppNetwork.shared.upload(url: "http://localhost:3000/upload",remote: "file", local: local, mineType: "video/mp4",resume: false) { bytesLoad, bytesTotal in
//                print(bytesLoad, bytesTotal)
            } succeed: { _ in

            } failed: { _ in
            }

//            AppNetwork.shared.upload(url: "https://file.io/?expires=1w", remote: "file", local: local, mineType: "image/gif") { bytesLoad, _ in
//                print(bytesLoad)
//            } succeed: { _ in
//
//            } failed: { _ in
//            }
        } else {
            print("Image not found in bundle")
        }
    }
}

class UploadInterceptor: AppInterceptor {
    init() {}

    func interceptor(begin request: AppBaseRequest) {
    }

    func interceptor(end request: AppBaseRequest) {
    }

    func interceptor(_ request: AppBaseRequest, parameters: Alamofire.Parameters?) -> Alamofire.Parameters? {
        return parameters
    }

    func interceptor(_ request: AppBaseRequest, headers: HTTPHeaders?) -> HTTPHeaders? {
        var header = HTTPHeaders()
        headers?.dictionary.forEach { header.add(name: $0.key, value: $0.value) }
        header.add(name: "Authorization", value: "0baed7c1-86fa-45dd-85b6-de4442aba28a")
        return header
    }
}
