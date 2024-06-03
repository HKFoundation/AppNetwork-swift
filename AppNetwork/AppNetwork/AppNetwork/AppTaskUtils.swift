//
//  AppTaskUtils.swift
//  AppNetwork
//
//  Created by bormil on 2020/4/24.
//  Copyright © 2020 北京卡友在线科技有限公司. All rights reserved.
//

import Alamofire
import UIKit

public typealias AppTaskDone = (_ done: AnyObject) -> Void

public typealias AppTaskError = (_ error: AnyObject) -> Void

public typealias AppTaskProgress = (_ bytesLoad: CLongLong, _ bytesTotal: CLongLong) -> Void

class AppTaskUtils: NSObject {
    private static var appTimed: TimeInterval? = 30 /// 请求超时时间 default 30 秒

    private static var manager: SessionManager? /// SessionManager 实例对象，自定义对象需要强引用

    private static var app_baseURL: String? = "" /// 设置 baseURL

    private var md5CacheURL = String()

    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: - 网络基础配置
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    /// 设置请求超时时间，单位是秒
    func configLoadTimed(pTimed: TimeInterval) {
        AppTaskUtils.appTimed = pTimed
    }

    /// 用于指定网络请求接口的基础URL
    func configBaseURL(url: String) {
        AppTaskUtils.app_baseURL = url
    }

    /// 获取当前的基础URL
    func baseURL(url: String) -> String {
        if url.hasPrefix("http://") || url.hasPrefix("https://") {
            return url
        } else {
            /// 用于判断接口地址属于哪个域名
            AppTaskUtils.app_baseURL = AppURL().baseURL(url: url)
        }
        return AppTaskUtils.app_baseURL!
    }

    fileprivate func app_baseURL(url: String) {
        AppTaskUtils.app_baseURL = baseURL(url: url)
    }

    /// 取消特定连接请求
    func breakTask(url: String) {
        manager().session.getAllTasks { appTask in
            appTask.forEach {
                if $0.originalRequest?.url?.absoluteString == url { $0.cancel() }
            }
        }
    }

    /// 取消当前所有请求
    func breakTask() {
        manager().session.getAllTasks { appTask in
            appTask.forEach { $0.cancel() }
        }
    }

    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: - 接口请求业务
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    @discardableResult
    func reqForGet(url: String, appDone: @escaping AppTaskDone, appError: @escaping AppTaskError) -> DataRequest {
        return reqForGet(url: url, params: [:], appDone: appDone, appError: appError)
    }

    @discardableResult
    func reqForGet(url: String, params: [String: Any], appDone: @escaping AppTaskDone, appError: @escaping AppTaskError) -> DataRequest {
        return reqForGet(url: url, params: params, cache: false, appDone: appDone, appError: appError)
    }

    @discardableResult
    func reqForGet(url: String, params: [String: Any], cache: Bool = false, appDone: @escaping AppTaskDone, appError: @escaping AppTaskError) -> DataRequest {
        return reqForNetwork(url: url, mode: .get, params: params, cache: cache, appDone: appDone, appError: appError)
    }

    @discardableResult
    func reqForForm(url: String, appDone: @escaping AppTaskDone, appError: @escaping AppTaskError) -> DataRequest {
        return reqForForm(url: url, params: [:], appDone: appDone, appError: appError)
    }

    @discardableResult
    func reqForForm(url: String, params: [String: Any], appDone: @escaping AppTaskDone, appError: @escaping AppTaskError) -> DataRequest {
        return reqForForm(url: url, params: params, cache: false, appDone: appDone, appError: appError)
    }

    @discardableResult
    func reqForForm(url: String, params: [String: Any], cache: Bool = false, appDone: @escaping AppTaskDone, appError: @escaping AppTaskError) -> DataRequest {
        return reqForNetwork(url: url, mode: .post, params: params, cache: cache, appDone: appDone, appError: appError)
    }

    @discardableResult
    fileprivate func reqForNetwork(url: String, mode: HTTPMethod, params: [String: Any], cache: Bool, appDone: @escaping AppTaskDone, appError: @escaping AppTaskError) -> DataRequest {
        var appTask: DataRequest?

        md5CacheURL = md5String(pText: append(url: url, params: params))
        /// 1.首先对接口地址做格式化处理，设置域名、拼接地址、格式化地址
        let format = formatURL(url: url)

        appTask = manager().request(format, method: mode, parameters: params, encoding: URLEncoding.default, headers: nil).response(completionHandler: { done in

            if done.data != nil && done.data?.count != 0 {
                /// 2.控制台打印当前请求信息
                let data = String(data: done.data!, encoding: .utf8)?.format as AnyObject

                self.appDoneLog(url: format, params: params, done: data)
                /// 3.如果需要缓存则存储当前数据
                if cache == true {
                    self.configCache(url: (appTask?.request?.url!.absoluteString)!, params: params, done: data)
                }
                /// 如果数据可以解析成字典则返回字典格式
                let obj = self.configForFormat(data: done.data!)

                appDone(obj != nil ? obj as AnyObject : data)
            } else {
                if cache == true {
                    let verify = self.verifyCacheURL(url: (appTask?.request?.url!.absoluteString)!, params: params)
                    /// 4.如果当前数据有缓存则返回缓存数据
                    if verify.flag {
                        let data = String(data: verify.cache!, encoding: .utf8)?.format as AnyObject
                        let obj = self.configForFormat(data: verify.cache!)
                        appDone(obj != nil ? obj as AnyObject : data)
                        self.appCacheLog(url: format, params: params, done: data)
                    }
                } else {
                    /// 5.当没有缓存数据时，直接返回错误信息
                    self.appErrorLog(url: format, params: params, done: done.error! as NSError)
                    appError(done.error as AnyObject)
                }
            }
        })

        return appTask!
    }

    /// 获取缓存数据时用于校验数据有效性
    ///
    /// - Parameters:
    ///   - url: 接口地址
    ///   - params: 接口请求参数
    /// - Returns: flag: 是否有缓存数据 cache: 缓存数据
    func verifyCacheURL(url: String, params: [String: Any]) -> (flag: Bool, cache: Data?) {
        /// 获取缓存目录
        let cacheURL = NSURL(fileURLWithPath: AppCacheUtils().cacheURL()).appendingPathComponent(md5CacheURL)?.path
        /// 如果当前数据有缓存则返回缓存数据
        let cache = AppCacheUtils().configContentLocal(atPath: cacheURL!)
        if cacheURL != nil && cache != nil {
            return (true, cache)
        }
        return (false, nil)
    }

    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: - 网络框架的私有工具方法
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    func manager() -> SessionManager {
        objc_sync_enter(self)
        guard AppTaskUtils.manager != nil else {
            let configuration = URLSessionConfiguration.default
            configuration.httpMaximumConnectionsPerHost = 3
            if AppTaskUtils.appTimed != 30 {
                configuration.timeoutIntervalForRequest = AppTaskUtils.appTimed!
            }

            AppTaskUtils.manager = Alamofire.SessionManager(configuration: configuration)

            /// 忽略非法证书
            AppTaskUtils.manager?.delegate.sessionDidReceiveChallenge = { _, challenge in
                (URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
            }

            return AppTaskUtils.manager!
        }
        objc_sync_exit(self)

        return AppTaskUtils.manager!
    }

    /// 用于对每一个接口地址进行最后的格式化处理
    func formatURL(url: String) -> String {
        if url.hasPrefix("http://") || url.hasPrefix("https://") {
            return url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        }
        app_baseURL(url: url)
        let append = appendURL(url: url).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        return append
    }

    /// 用于拼接完整的请求URL
    func appendURL(url: String) -> String {
        if url.count <= 0 {
            return ""
        }
        if baseURL(url: url).count <= 0 {
            return url
        }

        var appendURL = url
        if !url.hasPrefix("http://") && !url.hasPrefix("https://") {
            if AppTaskUtils.app_baseURL!.hasSuffix("/") == true { /// baseURL末尾有"/"
                if url.hasPrefix("/") == true {
                    var p = url
                    appendURL = AppTaskUtils.app_baseURL! + String(p.removeFirst())
                } else {
                    appendURL = AppTaskUtils.app_baseURL! + url
                }
            } else { /// baseURL末尾没有"/"
                if url.hasPrefix("/") == true {
                    appendURL = AppTaskUtils.app_baseURL! + url
                } else {
                    appendURL = AppTaskUtils.app_baseURL! + "/" + url
                }
            }
        }

        return appendURL
    }

    /// 用于拼接完整参数
    func append(url: String, params: Dictionary<String, Any>) -> String {
        var p = ""

        /// 对字典中的参数做正序排列
        let order = params.sorted { (arg0, arg1) -> Bool in
            if arg0.key < arg1.key {
                return false
            }
            return true
        }

        /// 对请求地址拼接参数
        for (key, value) in order.reversed() {
            if value is Dictionary < String, Any> || value is Array < Any> || value is Set<String> {
                continue
            } else {
                p = "\(p.count == 0 ? "" : p)\(key)=\(value)&"
            }
        }

        /// 删除末尾 & 符号
        if p.count > 1 {
            p = String(p[..<p.index(p.startIndex, offsetBy: p.count - 1)])
        }

        /// 将拼接参数和域名拼接在一起
        if (url.hasPrefix("http://") || url.hasPrefix("https://")) && p.count > 1 {
            if url.range(of: "?") != nil || url.range(of: "#") != nil {
                p = url + p
            } else {
                p = String(p[p.index(p.startIndex, offsetBy: 0)...])
                p = url + "?" + p
            }
        }
        return p.count == 0 ? url : p
    }

    /// 用于缓存网络数据到本地沙盒
    func configCache(url: String, params: Dictionary<String, Any>, done: AnyObject) {
        guard AppCacheUtils().configNewDocument(atPath: AppCacheUtils().cacheURL()) else {
            return
        }

        let cacheURL = NSURL(fileURLWithPath: AppCacheUtils().cacheURL()).appendingPathComponent(md5CacheURL)?.path

        var p = ""
        if done is String {
            p = done as! String
        }

        if AppCacheUtils().configContentSaveLocal(atPath: cacheURL!, data: p.count == 0 ? done as! Data : p.data(using: .utf8)!) {
            AppLog("🍀 数据缓存成功\n URL：\(AppCacheUtils().cacheURL())")
        } else {
            AppLog("⚠️ 数据缓存失败")
        }
    }

    func configForFormat(data: Data) -> Dictionary<String, Any>? {
        do {
            let p = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            return (p as! Dictionary<String, Any>)
        } catch {
            AppLog("⚠️ 原始数据转换字典失败")
            return nil
        }
    }

    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: - 日志Log
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    /// 请求成功日志
    func appDoneLog(url: String, params: Dictionary<String, Any>, done: AnyObject) {
        if params["refundItemVo"] is NSNull {
            AppLog("🍀 数据请求成功\n URL：\(url)\n 返回数据：\(done)")
            return
        }

        AppLog("🍀 数据请求成功\n URL：\(append(url: url, params: params))\n 请求参数：\(params)\n 返回数据：\(done)")
    }

    /// 加载缓存数据日志
    func appCacheLog(url: String, params: Dictionary<String, Any>, done: AnyObject) {
        if params["refundItemVo"] is NSNull {
            AppLog("📝 缓存加载成功\n URL：\(url)\n 返回数据：\(done)")
            return
        }

        AppLog("📝 缓存加载成功\n URL：\(append(url: url, params: params))\n 请求参数：\(params)\n 返回数据：\(done)")
    }

    /// 请求失败日志
    func appErrorLog(url: String, params: Dictionary<String, Any>, done: NSError) {
        let code = done.code
        if params["refundItemVo"] is NSNull {
            AppLog("⚠️ 数据请求失败\n URL：\(url)\n Error：\(AppError().errorCodesForSystem(code: code)) \(code)")
            return
        }

        AppLog("⚠️ 数据请求失败\n URL：\(url)\n 请求参数：\(params)\n Error：\(AppError().errorCodesForSystem(code: code)) \(code)")
    }
}
