//
//  AppDownloadRequest.swift
//  AppNetwork
//
//  Created by bormil on 2024/6/25.
//  Copyright © 2024 北京卡友在线科技有限公司. All rights reserved.
//

import Alamofire
import UIKit

open class AppDownloadRequest: AppBaseRequest {
    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: 文件下载
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    private var handle: FileHandle?

    deinit {
        try? handle?.close()
        handle = nil
    }

    @discardableResult
    open class func request(url: String, method: HTTPMethod = .get, parameters: Parameters? = nil, resume: Bool = true, progress: @escaping AppTaskProgress, succeed: AppTaskDone?, failed: AppTaskError?) -> Request? {
        let path = URL(string: url)?.path ?? ""

        /// 1.实例化 request 对象
        let req: AppDownloadRequest = self.init(path: path)

        /// 2.如果需要存储下载文件的目录不存在，就先新建目录
        if req.cache.configFileExists(atPath: req.cache.cacheURL().path) == false {
            _ = req.cache.configCacheDocument(atPath: req.cache.cacheURL().path)
        }

        /// 3.对参数进行加工
        req.prepare(path: path, method: method, parameters: parameters)

        if resume {
            return download(req: req, progress: progress, succeed: succeed, failed: failed)
        } else {
            return request(req: req, progress: progress, succeed: succeed, failed: failed)
        }
    }

    /// 网络请求前的预处理方法、对请求头、请求参数等进行配置
    /// - Parameters:
    ///   - path: 接口路径
    ///   - method: 发送方式
    ///   - parameters: 发送参数
    open func prepare(path: String, method: HTTPMethod = .get, parameters: Parameters? = nil) {
        self.method = method

        let parameters: Parameters? = config.interceptor?.interceptor(self, parameters: parameters) ?? parameters
        self.parameters = parameters

        let headers: HTTPHeaders? = config.interceptor?.interceptor(self, headers: self.headers) ?? self.headers
        self.headers = headers

        config.interceptor?.interceptor(begin: self)
    }

    /// 处理网络请求、可在子类中重写
    /// - Parameters:
    ///   - response: 返回数据
    ///   - succeed: 接口请求完成回调
    ///   - failed: 接口请求出错回调
    open func process(response: AFDataResponse<Data?>, succeed: AppTaskDone?, failed: AppTaskError? = nil) {
        switch response.result {
        case let .success(data):
            succeedLog(response: response)
            succeed?(data as Any)

        case let .failure(error):
            failedLog(error: error as NSError)
            failed?(error)
        }
    }

    /// 处理网络请求、可在子类中重写
    /// - Parameters:
    ///   - response: 返回数据
    ///   - succeed: 接口请求完成回调
    ///   - failed: 接口请求出错回调
    open func process(response: AFDownloadResponse<URL?>, succeed: AppTaskDone?, failed: AppTaskError? = nil) {
        switch response.result {
        case let .success(data):
            succeedLog(response: response)
            succeed?(data as Any)

        case let .failure(error):
            failedLog(error: error as NSError)
            failed?(error)
        }
    }

    /// 断点续传方式下载
    private class func request(req: AppDownloadRequest, progress: @escaping AppTaskProgress, succeed: AppTaskDone?, failed: AppTaskError?) -> DataRequest? {
        /// 4.获取当前下载信息的缓存信息，如果为 0 则从头下载 否则继续下载
        let bytes: CLongLong = CLongLong(req.cache.bytesTotalCache(atPath: req.cache.cacheURL().appendingPathComponent(req.url.lastPathComponent).path) * 1000.0 * 1000.0)

        // TODO: 这里下载过的文件不会再次下载，但是会发起请求，可以修改为已下载的直接返回

        /// 5.配置断点续传请求头信息
        if req.headers != nil {
            req.headers?.add(name: "Range", value: "bytes=\(bytes)-")
        } else {
            req.headers = HTTPHeaders([HTTPHeader(name: "Range", value: "bytes=\(bytes)-")])
        }

        var url = req.cache.cacheURL()

        /// 6.开始接受到下载请求信息
        req.manager.monitor.dataTaskDidReceiveResponse = { [weak req] _, _, response in

            /// 获取文件名拼接到保存路径下
            url = url.appendingPathComponent(response.url?.lastPathComponent ?? "")

            /// 判断当前文件是否下载过，如果没有则建立文件
            if req?.cache.configFileExists(atPath: url.path) == false {
                FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
            }

            /// 生成文件句柄
            do {
                req?.handle = try FileHandle(forWritingTo: url)
            } catch {
                // 无法打开文件进行写入
            }
        }

        /// 7.开始接收已完成的数据片段
        req.manager.monitor.dataTaskDidReceiveData = { [weak req] _, request, data in

            guard request.response?.expectedContentLength != -1 else {
                return
            }
            do {
                try req?.handle?.seekToEnd()
                try req?.handle?.write(contentsOf: data)
            } catch {
                // 文件写入失败
            }
        }

        /// 8.下载完成
        req.manager.monitor.taskDidComplete = { _, _, _ in
        }

        return req.manager.request(req.url,
                                   method: req.method,
                                   parameters: req.parameters,
                                   encoding: req.encoding,
                                   headers: req.headers,
                                   interceptor: req.interceptor,
                                   modifier: { request in
                                       try req.modifier(request: &request)
                                   }).downloadProgress(closure: { response in
            if response.totalUnitCount == -1 {
                progress(bytes, bytes)
            } else {
                progress(response.completedUnitCount + bytes, response.totalUnitCount + bytes)
            }
        }).response { response in
            req.process(response: response, succeed: succeed, failed: failed)
            req.config.interceptor?.interceptor(end: req)
        }
    }

    /// 普通方式下载
    private class func download(req: AppDownloadRequest, progress: @escaping AppTaskProgress, succeed: AppTaskDone?, failed: AppTaskError?) -> DownloadRequest? {
        /// 指定下载文件保存路径. `Documents/AppNetwork/` by default.
        let destination: DownloadRequest.Destination = { _, _ in
            // removePreviousFile 覆盖同名文件
            // createIntermediateDirectories 如果文件夹不存在会自动创建
            (req.cache.cacheURL().appendingPathComponent(req.url.lastPathComponent), [.removePreviousFile, .createIntermediateDirectories])
        }

        return req.manager.download(req.url,
                                    method: req.method,
                                    parameters: req.parameters,
                                    encoding: req.encoding,
                                    headers: req.headers,
                                    interceptor: req.interceptor,
                                    modifier: { request in
                                        try req.modifier(request: &request)
                                    }, to: destination)
            .downloadProgress(closure: { response in
                progress(response.completedUnitCount, response.totalUnitCount)
            }).response { response in
                req.process(response: response, succeed: succeed, failed: failed)
                req.config.interceptor?.interceptor(end: req)
            }
    }

    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: 日志 Log
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    override open func succeedLog(response: Any) {
        printk("🍀 文件下载成功\n URL：\(cache.cacheURL().appendingPathComponent(url.lastPathComponent).path)")
    }

    override open func failedLog(error: NSError) {
        let code = error.code
        printk("⚠️ 文件下载失败 Error：\(AppError().errorCodesForSystem(error: error)) \(code)")
    }
}
