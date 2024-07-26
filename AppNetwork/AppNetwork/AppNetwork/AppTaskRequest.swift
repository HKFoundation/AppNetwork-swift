//
//  AppTaskRequest.swift
//  AppNetwork
//
//  Created by bormil on 2020/5/9.
//  Copyright © 2020 北京卡友在线科技有限公司. All rights reserved.
//

import Alamofire
import UIKit

open class AppTaskRequest: AppBaseRequest {
    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: 接口请求
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    @discardableResult
    open class func request(url: String, method: HTTPMethod = .get, parameters: Parameters? = nil, succeed: AppTaskDone?, failed: AppTaskError?) -> DataRequest? {
        let path = URL(string: url)?.path(percentEncoded: false) ?? ""

        /// 1.实例化 request 对象
        let req: AppTaskRequest = self.init(path: path)

        /// 2.对参数进行加工
        req.prepare(path: path, method: method, parameters: parameters)

        return req.manager.request(req.url,
                                   method: req.method,
                                   parameters: req.parameters,
                                   encoding: req.encoding,
                                   headers: req.headers,
                                   interceptor: req.interceptor,
                                   modifier: { request in
                                       try req.modifier(request: &request)
                                   }).response { response in
            req.process(response: response, succeed: succeed, failed: failed)
            req.config.interceptor?.interceptor(end: req)
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

    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: 日志 Log
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    /// 请求成功日志
    override open func succeedLog(response: Any) {
        guard let parameters = parameters else {
            printk("🍀 数据请求成功\n URL：\(url.absoluteString)\n 返回数据：\(response)")
            return
        }

        printk("🍀 数据请求成功\n URL：\(url.absoluteString)\n 请求参数：\(parameters)\n 返回数据：\(response)")
    }

    /// 请求失败日志
    override open func failedLog(error: NSError) {
        let code = error.code
        guard let parameters = parameters else {
            printk("⚠️ 数据请求失败\n URL：\(url.absoluteString)\n Error：\(AppError().errorCodesForSystem(error: error)) \(code)")
            return
        }

        printk("⚠️ 数据请求失败\n URL：\(url.absoluteString)\n 请求参数：\(parameters)\n Error：\(AppError().errorCodesForSystem(error: error)) \(code)")
    }
}
