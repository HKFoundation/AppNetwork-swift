//
//  AppFilesUtils.swift
//  AppNetwork
//
//  Created by bormil on 2020/5/9.
//  Copyright © 2020 北京卡友在线科技有限公司. All rights reserved.
//

import Alamofire
import UIKit

/* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
 * // MARK: - 文件下载
 * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

private var dataTasks = [String: DataRequest]()

class AppFilesUtils: NSObject {
    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: - 文件下载基础配置
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    private var manager: SessionManager? /// SessionManager 实例对象，自定义对象需要强引用

    override init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpMaximumConnectionsPerHost = 3
        configuration.timeoutIntervalForRequest = 30

        manager = SessionManager(configuration: configuration)

        /// 忽略非法证书
        manager?.delegate.sessionDidReceiveChallenge = { _, challenge in
            (URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        }
    }

    /// 取消特定连接文件下载请求（也用于暂停下载）
    func breakTask(url: String) {
        for (md5CacheURL, appTask) in dataTasks {
            if appTask.request?.url?.absoluteString == url {
                appTask.cancel()
                dataTasks.removeValue(forKey: md5CacheURL)
                break
            }
        }
    }

    /// 取消当前所有的文件下载请求
    func breakTask() {
        for (md5CacheURL, appTask) in dataTasks {
            appTask.cancel()
            dataTasks.removeValue(forKey: md5CacheURL)
        }
    }

    /// 删除已下载的文件
    func configEmptyCache(url: String, params: [String: Any]) {
        let url = AppTaskUtils().formatURL(url: url)
        let md5CacheURL = md5String(pText: AppTaskUtils().append(url: url, params: params))

        breakTask(url: url)

        let cache = configContentLoadLocal(md5CacheURL: md5CacheURL)
        var cacheURL: String = ""

        if let cache = cache {
            cacheURL = cache["cacheURL"] as! String
        }

        /// 如果当前文件有缓存
        if cacheURL.count != 0 {
            /// 如果已下载完成则清除
            AppCacheUtils().configEmptyCache(atPath: URL(fileURLWithPath: AppCacheUtils().cacheURL()).appendingPathComponent((cacheURL.components(separatedBy: "/").last)!).path, debugLog: cacheURL.components(separatedBy: "/").last)
        }

        AppCacheUtils().configEmptyCache(atPath: URL(fileURLWithPath: AppCacheUtils().cacheURL()).appendingPathComponent(md5CacheURL).path, debugLog: md5CacheURL)
    }

    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: - 接口请求业务
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    @discardableResult
    func reqForDownload(url: String, progess: @escaping AppTaskProgress, done: @escaping AppTaskDone, error: @escaping AppTaskError) -> DataRequest? {
        /// 1.首先对接口地址做格式化处理，设置域名、拼接地址、格式化地址
        let format = AppTaskUtils().formatURL(url: url)

        /// 2.如果需要存储下载文件的目录不存在，就先新建目录
        if AppCacheUtils().configDocumentExists(atPath: AppCacheUtils().cacheURL()) == false {
            _ = AppCacheUtils().configCacheDocument(atPath: AppCacheUtils().cacheURL())
        }

        /// 3.判断该文件是否已经下载完成，如果完成则直接返回
        let md5CacheURL = md5String(pText: AppTaskUtils().append(url: url, params: [:]))
        var cache = Dictionary<String, Any>.init()
        cache = configContentLoadLocal(md5CacheURL: md5CacheURL) ?? [:]

        /// 判断条件，progress 下载进度，code 自定义标识符
        /// 这里不能完全通过断点续传来判断是否下载完成，需要自己增加一个标识
        if cache["code"] != nil && cache["progress"] != nil && (cache["code"] as! String) == "success" && (cache["progress"] as! Double) == 1.0 {
            AppLog("🍀 文件下载成功\n URL：\(cache["cacheURL"] ?? "")")
            return nil
        }

        var appTask: DataRequest?

        /// 4.获取当前下载信息的缓存信息，如果为 0 则充新下载 否则继续下载
        var currentLength: CLongLong = CLongLong(AppCacheUtils().bytesTotalCache(atPath: URL(fileURLWithPath: AppCacheUtils().cacheURL()).appendingPathComponent(format.components(separatedBy: "/").last!).path) * 1000.0 * 1000.0)

        /// 5.建立请求信息
        var request = URLRequest(url: URL(string: format)!)
        request.setValue("bytes=\(currentLength)-", forHTTPHeaderField: "Range")
        var app_flag: FileHandle?

        appTask = manager?.request(request).response(completionHandler: { response in
            dataTasks.removeValue(forKey: md5CacheURL)

            if !(response.error != nil) {
                done(response.response as AnyObject)
            } else {
                error(response.error as AnyObject)
            }
        })

        /// 6.开始接受到下载请求信息
        manager?.delegate.dataTaskDidReceiveResponse = { _, _, response in
            let arr = response.url?.absoluteString.components(separatedBy: "/")
            let cacheURL = URL(fileURLWithPath: AppCacheUtils().cacheURL()).appendingPathComponent((arr?.last)!).path

            /// 判断当前文件是否下载过，如果没有则建立文件
            if AppCacheUtils().configDocumentExists(atPath: cacheURL) == false {
                FileManager.default.createFile(atPath: cacheURL, contents: nil, attributes: nil)
                cache["cacheURL"] = cacheURL
                cache["pTotalLength"] = response.expectedContentLength
                self.configContentSaveLocal(done: cache, md5CacheURL: md5CacheURL)
            }

            app_flag = FileHandle(forWritingAtPath: cacheURL)!

            return .allow
        }

        /// 7.开始接受下载数据
        manager?.delegate.dataTaskDidReceiveData = { _, pTask, data in
            app_flag?.seekToEndOfFile()
            app_flag?.write(data)

            /// 8.实时监听下载进度，累加当前下载量
            currentLength += Int64(data.count)

            /// 下载总量，如果有缓存则按照缓存中记录的总量
            var pTotalLength: CLongLong = pTask.progress.totalUnitCount
            if cache["pTotalLength"] != nil {
                pTotalLength = cache["pTotalLength"] as! CLongLong
            }

            pTask.progress.totalUnitCount = pTotalLength
            pTask.progress.completedUnitCount = currentLength
            if pTask.progress.fractionCompleted <= 1.0 {
                cache["progress"] = pTask.progress.fractionCompleted
                self.configContentSaveLocal(done: cache, md5CacheURL: md5CacheURL)
            }

            progess(pTask.progress.completedUnitCount, pTotalLength)
        }

        /// 9.下载完成
        manager?.delegate.taskDidComplete = { _, pTask, error in
            if !(error != nil) {
                AppLog("🍀 文件下载成功\n URL：\(URL(fileURLWithPath: AppCacheUtils().cacheURL()).appendingPathComponent((pTask.response?.url?.absoluteString.components(separatedBy: "/").last)!).path)")
                cache["code"] = "success"
                self.configContentSaveLocal(done: cache, md5CacheURL: md5CacheURL)
            } else {
                let code = (error! as NSError).code
                AppLog("⚠️ 文件下载失败 Error：\(AppError().errorCodesForSystem(code: code)) \(code)")
            }
        }

        if appTask != nil {
            dataTasks[md5CacheURL] = appTask
        }

        return appTask!
    }

    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: - 文件下载的私有工具方法
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    /// 保存当前下载文件信息
    private func configContentSaveLocal(done: Dictionary<String, Any>, md5CacheURL: String) {
        var cache: Data?
        do {
            cache = try JSONSerialization.data(withJSONObject: done, options: .prettyPrinted)
        } catch {
        }
        if cache != nil {
            _ = AppCacheUtils().configContentSaveLocal(atPath: URL(fileURLWithPath: AppCacheUtils().cacheURL()).appendingPathComponent(md5CacheURL).path, data: cache!)
        }
    }

    /// 读取缓存数据
    private func configContentLoadLocal(md5CacheURL: String) -> Dictionary<String, Any>? {
        let cache = AppCacheUtils().configContentLoadLocal(atPath: URL(fileURLWithPath: AppCacheUtils().cacheURL()).appendingPathComponent(md5CacheURL).path)

        if let cache = cache {
            var done: Any?
            do {
                done = try JSONSerialization.jsonObject(with: cache, options: .allowFragments)
            } catch {
            }
            if done != nil {
                return (done as! Dictionary<String, Any>)
            }
        }
        return nil
    }
}
