//
//  AppUploadRequest.swift
//  AppNetwork
//
//  Created by bormil on 2024/6/29.
//  Copyright © 2024 北京卡友在线科技有限公司. All rights reserved.
//

import Alamofire
import UIKit

open class AppUploadRequest: AppBaseRequest {
    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: 文件上传
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    @discardableResult
    open class func request(url: String, method: HTTPMethod = .post, parameters: Parameters? = nil, remote: String, local: String, mineType: String, resume: Bool = true, progress: @escaping AppTaskProgress, succeed: AppTaskDone?, failed: AppTaskError?) -> UploadRequest? {
        let path = URL(string: url)?.path(percentEncoded: false) ?? ""

        /// 1.实例化 request 对象
        let req: AppUploadRequest = self.init(path: path)

        /// 2.对参数进行加工
        req.prepare(path: path, method: method, parameters: parameters)

        if resume {
            return upload(req: req, remote: remote, local: local, mineType: mineType, progress: progress, succeed: succeed, failed: failed)
        } else {
            return request(req: req, remote: remote, local: local, mineType: mineType, progress: progress, succeed: succeed, failed: failed)
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
            guard let data = data else { return }

            do {
                let obj = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                succeedLog(response: String(data: data, encoding: .utf8)?.format ?? "")
                succeed?(obj)
            } catch {
                let error = AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: error))

                failedLog(error: error as NSError)
                failed?(error)
            }
        case let .failure(error):
            failedLog(error: error as NSError)
            failed?(error)
        }
    }

    /// 断点续传方式上传
    private class func request(req: AppUploadRequest, remote: String, local: String, mineType: String, progress: @escaping AppTaskProgress, succeed: AppTaskDone?, failed: AppTaskError?) -> UploadRequest? {
        let bytesTotal = (try? FileManager.default.attributesOfItem(atPath: URL(fileURLWithPath: local).path)[.size] as? Int) ?? 0
        var bytesLoad: Int64 = 0

        let chunk: Int = 1024 * 1024 // 1 MB 1048576

        let count = Int(ceil(Double(bytesTotal) / Double(chunk)))

        for index in 0 ..< count {
            let begin = index * chunk
            let end = min(begin + chunk, bytesTotal)
            let data = readForFile(url: URL(fileURLWithPath: local), begin: begin, end: end)

            req.manager.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(data, withName: remote, fileName: URL(fileURLWithPath: local).lastPathComponent, mimeType: mineType)
            }, to: req.url,
            method: req.method,
            headers: req.headers,
            interceptor: req.interceptor,
            modifier: { request in
                try req.modifier(request: &request)
            }).uploadProgress { _ in
            }.response { response in
                // TODO: 中途有分片上传失败应该直接返回
                if index == count - 1 { // 最后一个分片
                    progress(CLongLong(end), CLongLong(bytesTotal))
                    req.process(response: response, succeed: succeed, failed: failed)
                    req.config.interceptor?.interceptor(end: req)
                } else {
                    bytesLoad += Int64(chunk)
                    progress(bytesLoad, CLongLong(bytesTotal))
                }
            }
        }

        func readForFile(url: URL, begin: Int, end: Int) -> Data {
            let handle = try! FileHandle(forReadingFrom: url)
            handle.seek(toFileOffset: UInt64(begin))
            let data = handle.readData(ofLength: end - begin)
            handle.closeFile()
            return data
        }

        return nil
    }

    /// 普通方式上传
    private class func upload(req: AppUploadRequest, remote: String, local: String, mineType: String, progress: @escaping AppTaskProgress, succeed: AppTaskDone?, failed: AppTaskError?) -> UploadRequest? {
        return req.manager.upload(multipartFormData: { multipartFormData in
            // 上传文件的命名方式为以毫秒为单位的时间戳 String(Int(Date().timeIntervalSince1970 * 1000))
            multipartFormData.append(URL(fileURLWithPath: local), withName: remote, fileName: URL(fileURLWithPath: local).lastPathComponent, mimeType: mineType)
        }, to: req.url,
        method: req.method,
        headers: req.headers,
        interceptor: req.interceptor,
        modifier: { request in
            try req.modifier(request: &request)
        }).uploadProgress { response in
            progress(response.completedUnitCount, response.totalUnitCount)
        }.response { response in
            req.process(response: response, succeed: succeed, failed: failed)
            req.config.interceptor?.interceptor(end: req)
        }
    }

    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: 日志 Log
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    override open func succeedLog(response: Any) {
        guard let parameters = parameters else {
            printk("🍀 文件上传成功\n URL：\(url.absoluteString)\n 返回数据：\(response)")
            return
        }

        printk("🍀 文件上传成功\n URL：\(url.absoluteString)\n 请求参数：\(parameters)\n 返回数据：\(response)")
    }

    override open func failedLog(error: NSError) {
        let code = error.code
        guard let parameters = parameters else {
            printk("⚠️ 文件上传失败\n URL：\(url.absoluteString)\n Error：\(AppError().errorCodesForSystem(error: error)) \(code)")
            return
        }

        printk("⚠️ 文件上传失败\n URL：\(url.absoluteString)\n 请求参数：\(parameters)\n Error：\(AppError().errorCodesForSystem(error: error)) \(code)")
    }
}
