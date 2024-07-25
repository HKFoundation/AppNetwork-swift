//
//  AppBaseRequest.swift
//  AppNetwork
//
//  Created by bormil on 2020/4/24.
//  Copyright © 2020 北京卡友在线科技有限公司. All rights reserved.
//

import Alamofire
import UIKit

public typealias AppTaskDone = (_ response: Any) -> Void

public typealias AppTaskError = (_ error: Any) -> Void

public typealias AppTaskProgress = (_ bytesLoad: CLongLong, _ bytesTotal: CLongLong) -> Void

open class AppBaseRequest: NSObject {
    /// AppNetwork 对象
    var manager: AppNetwork { AppNetwork.shared }

    var cache: AppCacheManager { AppCacheManager.shared }

    /// 全局网络框架配置信息
    open var config: AppConfiguration { manager.configuration }

    /// 除域名以外的路径
    open var path: String = ""

    /// 由 baseURL 和 path 构造的 URL
    open var url: URL {
        URL(string: path, relativeTo: manager.baseURL) ?? manager.baseURL
    }

    /// 发送方式. `.get` by default.
    open var method: HTTPMethod = .get

    /// 请求参数 `[String: Any]`. `nil` by default.
    open var parameters: Parameters?

    /// 配置拦截器、用于统一处理每个请求发送前后的一些自定义操作 比如 Loding 转圈圈. `nil` by default.
    open var interceptor: RequestInterceptor?

    /// 用于发送请求之前修改 `URLRequest`
    open var modifier: Alamofire.Session.RequestModifier?

    /// 编码格式. `URLEncoding.default` by default.
    open var encoding: ParameterEncoding = URLEncoding.default

    /// 配置请求头信息. `nil` by default.
    open var headers: HTTPHeaders?

    /// 缓存策略. `.useProtocolCachePolicy` by default.
    open var cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy

    /// 接收端超时时间. `30` by default.
    open var timeout: TimeInterval = 30

    override public required init() {}

    public required convenience init(path: String) {
        self.init()
        self.path = path
        prepare()
    }

    /// override it then set the request's properties, it called after init
    open func prepare() {}

    internal func modifier(request: inout URLRequest) throws {
        request.timeoutInterval = timeout
        request.cachePolicy = cachePolicy
        try modifier?(&request)
    }

    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: 日志 Log
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    /// 请求成功日志
    open func succeedLog(response: Any) {}

    /// 请求失败日志
    open func failedLog(error: NSError) {}

    deinit {
        print("deinit")
    }
}
