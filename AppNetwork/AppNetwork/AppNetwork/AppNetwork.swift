//
//  AppNetwork.swift
//  AppNetwork
//
//  Created by Code on 2020/4/24.
//  Copyright © 2020 北京卡友在线科技有限公司. All rights reserved.
//

import Alamofire
import UIKit

class AppNetwork: NSObject {
    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: - 网络基础配置
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    /// 设置请求超时时间，单位是秒
    class func configLoadTimed(pTimed: TimeInterval) {
        AppTaskUtils().configLoadTimed(pTimed: pTimed)
    }

    /// 用于指定网络请求接口的基础URL
    class func configBaseURL(url: String) {
        AppTaskUtils().configBaseURL(url: url)
    }

    /// 获取网络缓存的文件夹目录
    class func cacheURL() -> String {
        return AppCacheUtils().cacheURL()
    }

    /// 设置网络缓存的文件夹目录 default "Documents/AppNetwork"
    class func configCacheURL(atPath: String) {
        AppCacheUtils().configCacheURL(atPath: atPath)
    }

    /// 获取缓存文件的大小 单位MB
    class func bytesTotalCache() -> CGFloat {
        return AppCacheUtils().bytesTotalCache()
    }

    /// 清空网络数据缓存（所有的缓存包括下载文件）
    class func configEmptyCache() {
        AppCacheUtils().configEmptyCache(atPath: AppCacheUtils().cacheURL(), debugLog: nil)
    }

    /// 取消特定连接请求
    class func breakTask(url: String) {
        AppTaskUtils().breakTask(url: url)
    }

    /// 取消当前所有请求
    class func breakTask() {
        AppTaskUtils().breakTask()
    }

    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: - 文件下载基础配置
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    /// 取消特定连接文件下载请求（也用于暂停下载）
    class func breakTask(url: String, flag: Bool = true) {
        AppFilesUtils().breakTask(url: url)
    }

    /// 取消当前所有的文件下载请求
    class func breakTask(flag: Bool = true) {
        AppFilesUtils().breakTask()
    }

    /// 删除已下载的文件
    class func configEmptyCache(url: String, params: [String: Any]) {
        AppFilesUtils().configEmptyCache(url: url, params: params)
    }

    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: - 接口请求业务
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    /// 没有参数的 GET 网络请求
    ///
    /// - Parameters:
    ///   - url: 接口地址
    ///   - appDone: 接口请求完成回调
    ///   - appError: 接口请求出错回调
    /// - Returns: 返回 DataRequest 对象
    @discardableResult
    class func reqForGet(url: String, appDone: @escaping AppTaskDone, appError: @escaping AppTaskError) -> DataRequest {
        return AppTaskUtils().reqForGet(url: url, appDone: appDone, appError: appError)
    }

    /// 有参数的 GET 网络请求
    ///
    /// - Parameters:
    ///   - url: 接口地址
    ///   - params: 接口请求参数
    ///   - appDone: 接口请求完成回调
    ///   - appError: 接口请求出错回调
    /// - Returns: 返回 DataRequest 对象
    @discardableResult
    class func reqForGet(url: String, params: [String: Any], appDone: @escaping AppTaskDone, appError: @escaping AppTaskError) -> DataRequest {
        return AppTaskUtils().reqForGet(url: url, params: params, appDone: appDone, appError: appError)
    }

    /// 有参数、有缓存的 GET 网络请求
    ///
    /// - Parameters:
    ///   - url: 接口地址
    ///   - params: 接口请求参数
    ///   - cache: 是否缓存数据 default false
    ///   - appDone: 接口请求完成回调
    ///   - appError: 接口请求出错回调
    /// - Returns: 返回 DataRequest 对象
    @discardableResult
    class func reqForGet(url: String, params: [String: Any], cache: Bool = false, appDone: @escaping AppTaskDone, appError: @escaping AppTaskError) -> DataRequest {
        return AppTaskUtils().reqForGet(url: url, params: params, cache: cache, appDone: appDone, appError: appError)
    }

    /// 没有参数的 POST 网络请求
    ///
    /// - Parameters:
    ///   - url: 接口地址
    ///   - appDone: 接口请求完成回调
    ///   - appError: 接口请求出错回调
    /// - Returns: 返回 DataRequest 对象
    @discardableResult
    class func reqForForm(url: String, appDone: @escaping AppTaskDone, appError: @escaping AppTaskError) -> DataRequest {
        return AppTaskUtils().reqForForm(url: url, appDone: appDone, appError: appError)
    }

    /// 有参数的 POST 网络请求
    ///
    /// - Parameters:
    ///   - url: 接口地址
    ///   - params: 接口请求参数
    ///   - appDone: 接口请求完成回调
    ///   - appError: 接口请求出错回调
    /// - Returns: 返回 DataRequest 对象
    @discardableResult
    class func reqForForm(url: String, params: [String: Any], appDone: @escaping AppTaskDone, appError: @escaping AppTaskError) -> DataRequest {
        return AppTaskUtils().reqForForm(url: url, params: params, appDone: appDone, appError: appError)
    }

    /// 有参数、有缓存的 POST 网络请求
    ///
    /// - Parameters:
    ///   - url: 接口地址
    ///   - params: 接口请求参数
    ///   - cache: 是否缓存数据 default false
    ///   - appDone: 接口请求完成回调
    ///   - appError: 接口请求出错回调
    /// - Returns: 返回 DataRequest 对象
    @discardableResult
    class func reqForForm(url: String, params: [String: Any], cache: Bool = false, appDone: @escaping AppTaskDone, appError: @escaping AppTaskError) -> DataRequest {
        return AppTaskUtils().reqForForm(url: url, params: params, cache: cache, appDone: appDone, appError: appError)
    }

    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: - 文件下载请求业务
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    /// 下载文件请求
    ///
    /// - Parameters:
    ///   - url: 接口地址
    ///   - params: 接口请求参数
    ///   - appProgess: 接口请求进度回调
    ///   - appDone: 接口请求完成回调
    ///   - appError: 接口请求出错回调
    /// - Returns: 返回 DownloadRequest 对象
    @discardableResult
    class func reqForDownload(url: String, progess: @escaping AppTaskProgress, appDone: @escaping AppTaskDone, appError: @escaping AppTaskError) -> DataRequest? {
        return AppFilesUtils().reqForDownload(url: url, progess: progess, appDone: appDone, appError: appError)
    }
}
