//
//  AppConfiguration.swift
//  AppNetwork
//
//  Created by bormil on 2024/6/12.
//  Copyright © 2024 北京卡友在线科技有限公司. All rights reserved.
//

import Alamofire
import UIKit

public protocol AppInterceptor {
    /// 在 request 开始时处理的任务
    /// - Parameter request: 当前 `AppBaseRequest`
    func interceptor(begin request: AppBaseRequest) -> Void

    /// 在 request 结束时处理的任务
    /// - Parameter request: 当前 `AppBaseRequest`
    func interceptor(end request: AppBaseRequest) -> Void

    /// 配置公共参数字段
    /// - Parameters:
    ///   - request: 当前 `AppBaseRequest`
    ///   - parameters: 配置前参数
    /// - Returns: 配置后参数
    func interceptor(_ request: AppBaseRequest, parameters: Parameters?) -> Parameters?

    /// 配置请求头字段
    /// - Parameters:
    ///   - request: 当前 `AppBaseRequest`
    ///   - headers: 配置前参数
    /// - Returns: 配置后参数
    func interceptor(_ request: AppBaseRequest, headers: HTTPHeaders?) -> HTTPHeaders?
}

public enum AppDebugLevel: Int {
    case none
    case debug
    case info
    case warning
    case error
}

public func print(message: String, level: AppDebugLevel = .debug) {
    switch AppNetwork.shared.configuration.debugLevel {
    case .none:
        return
    case .debug:
        AppLog(message)
    case .info:
        if level == .info { AppLog(message) }
    case .warning:
        if level == .warning { AppLog(message) }
    case .error:
        if level == .error { AppLog(message) }
    }
}

public struct AppConfiguration {
    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: 公共属性
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    /// 配置域名
    public var baseURL: URL? {
        didSet {
            configBaseURL()
        }
    }

    /// 配置拦截器、并会在每一个 `AppBaseRequest` 中应用. `nil` by default.
    public var interceptor: AppInterceptor?

    public var debugLevel: AppDebugLevel

    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: 初始化方法
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    public init(baseURL: URL?, interceptor: AppInterceptor? = nil, debugLevel: AppDebugLevel = .debug) {
        self.baseURL = baseURL
        self.interceptor = interceptor
        self.debugLevel = debugLevel
        configBaseURL()
    }

    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: 私有方法
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    /// 格式化域名以反斜杠结尾. `http://www.baidu.com/`.
    private mutating func configBaseURL() {
        if let url: URL = baseURL {
            if url.path.count > 0 && !url.absoluteString.hasSuffix("/") {
                baseURL = url.appendingPathComponent("")
            }
        }
    }
}
