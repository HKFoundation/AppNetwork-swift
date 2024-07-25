//
//  AppNetwork.swift
//  AppNetwork
//
//  Created by bormil on 2020/4/24.
//  Copyright © 2020 北京卡友在线科技有限公司. All rights reserved.
//

import Alamofire
import UIKit

class AppNetwork {
    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: - 网络基础配置
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    public var configuration: AppConfiguration
    public var session: Alamofire.Session
    public var monitor = ClosureEventMonitor()

    /// 获取域名
    var baseURL: URL {
        assert(configuration.baseURL != nil, "AppNetwork: Please config the baseURL")
        return configuration.baseURL!
    }

    /// 拦截器配置
    var interceptor: AppInterceptor? {
        configuration.interceptor
    }

    /// 取消当前全部请求
    public func cancel() {
        session.session.getAllTasks { sessions in
            sessions.forEach { $0.cancel() }
        }
    }

    /// 取消当前特定请求
    public func cancel(url: String) {
        session.session.getAllTasks { sessions in
            for session in sessions {
                if session.originalRequest?.url?.absoluteString == url {
                    session.cancel(); break
                }
            }
        }
    }

    public func suspend(url: String) {
        session.session.getAllTasks { sessions in
            for session in sessions {
                if session.originalRequest?.url?.absoluteString == url {
                    session.suspend(); break
                }
            }
        }
    }

    public func resume(url: String) {
        session.session.getAllTasks { sessions in
            for session in sessions {
                if session.originalRequest?.url?.absoluteString == url {
                    session.resume(); break
                }
            }
        }
    }

    public static let shared = AppNetwork()

    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: 初始化方法
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    public init(configuration: AppConfiguration) {
        self.configuration = configuration
        session = Session(eventMonitors: [monitor])
    }

    convenience init() {
        self.init(
            configuration: AppConfiguration(baseURL: nil)
        )
    }

    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: AppNetwork 接口请求
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    /// 网络请求接口
    /// - Parameters:
    ///   - url: 接口地址
    ///   - method: 发送方式. `.get` by default.
    ///   - parameters: 发送参数
    ///   - succeed: 接口请求完成回调
    ///   - failed: 接口请求出错回调
    ///   - Returns: 返回 DataRequest 对象
    @discardableResult
    func request(url: String,
                 method: HTTPMethod = .get,
                 parameters: Parameters? = nil,
                 succeed: @escaping AppTaskDone,
                 failed: @escaping AppTaskError) -> DataRequest? {
        return AppTaskRequest.request(url: url, method: method, parameters: parameters, succeed: succeed, failed: failed)
    }

    /// 下载文件接口
    /// - Parameters:
    ///   - url: 接口地址
    ///   - method: 发送方式. `.get` by default.
    ///   - parameters: 发送参数
    ///   - resume: 重新开始. `true` by default.
    ///             true 会在下载完成后才保存在沙盒，同名文件会覆盖 false 会继续之前的下载进度
    ///   - progress: 下载进度
    ///   - succeed: 接口请求完成回调
    ///   - failed: 接口请求出错回调
    /// - Returns: 返回 Request 对象
    @discardableResult
    func download(url: String,
                  method: HTTPMethod = .get,
                  parameters: Parameters? = nil,
                  resume: Bool = true,
                  progress: @escaping AppTaskProgress,
                  succeed: @escaping AppTaskDone,
                  failed: @escaping AppTaskError) -> Request? {
        return AppDownloadRequest.request(url: url, method: method, parameters: parameters, resume: resume, progress: progress, succeed: succeed, failed: failed)
    }

    /// 上传文件接口
    /// - Parameters:
    ///   - url: 接口地址
    ///   - method: 发送方式. `.post` by default.
    ///   - remote: 服务器用来接收文件的字段
    ///   - local: 待上传文件存在的目录
    ///   - mineType: 待上传文件的类型
    ///   - resume: 重新开始. `true` by default.
    ///             true 主要做一次性上传，上传图片、文件等 false 会将文件分片上传、会记录分片信息、可中断上传
    ///   - progress: 上传进度
    ///   - succeed: 接口请求完成回调
    ///   - failed: 接口请求出错回调
    /// - Returns: 返回 Request 对象
    @discardableResult
    func upload(url: String,
                method: HTTPMethod = .post,
                remote: String,
                local: String,
                mineType: String,
                resume: Bool = true,
                progress: @escaping AppTaskProgress,
                succeed: @escaping AppTaskDone,
                failed: @escaping AppTaskError) -> UploadRequest? {
        return AppUploadRequest.request(url: url, method: method, remote: remote, local: local, mineType: mineType, resume: resume, progress: progress, succeed: succeed, failed: failed)
    }

    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: Alamofire 接口请求
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    @discardableResult
    func request(_ convertible: URLConvertible,
                 method: HTTPMethod = .get,
                 parameters: Parameters? = nil,
                 encoding: ParameterEncoding = URLEncoding.default,
                 headers: HTTPHeaders? = nil,
                 interceptor: RequestInterceptor? = nil,
                 modifier: Alamofire.Session.RequestModifier? = nil) -> DataRequest {
        return session.request(convertible, method: method, parameters: parameters, encoding: encoding, headers: headers, interceptor: interceptor, requestModifier: modifier)
    }

    @discardableResult
    func download(_ convertible: URLConvertible,
                  method: HTTPMethod = .get,
                  parameters: Parameters? = nil,
                  encoding: ParameterEncoding = URLEncoding.default,
                  headers: HTTPHeaders? = nil,
                  interceptor: RequestInterceptor? = nil,
                  modifier: Alamofire.Session.RequestModifier? = nil,
                  to destination: DownloadRequest.Destination? = nil) -> DownloadRequest {
        return session.download(convertible, method: method, parameters: parameters, encoding: encoding, headers: headers, interceptor: interceptor, requestModifier: modifier, to: destination)
    }

    @discardableResult
    func upload(multipartFormData: @escaping (MultipartFormData) -> Void,
                to url: URLConvertible,
                method: HTTPMethod = .post,
                headers: HTTPHeaders? = nil,
                interceptor: RequestInterceptor? = nil,
                modifier: Alamofire.Session.RequestModifier? = nil) -> UploadRequest {
        return session.upload(multipartFormData: multipartFormData, to: url, method: method, headers: headers, interceptor: interceptor, requestModifier: modifier)
    }
}
