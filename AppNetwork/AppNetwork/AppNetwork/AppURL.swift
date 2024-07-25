//
//  AppURL.swift
//  AppNetwork
//
//  Created by bormil on 2020/5/12.
//  Copyright © 2020 北京卡友在线科技有限公司. All rights reserved.
//

import UIKit

/* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
 * // MARK: 处理网络请求地址
 * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

class AppURL: NSObject {
    func baseURL(url: String) -> String {
        #if DEBUG
            return debugURL(url: url)
        #else
            return releaseURL(url: url)
        #endif
    }

    /// 测试库接口域名
    func debugURL(url: String) -> String {
        /// 用于判断接口地址属于哪个域名
        let domain_1: Set<String> = [k_push]

        if domain_1.contains(url) == true {
            return "wss://app.developerplat.com:8088"
        }
        return "http://192.168.1.154:8090"
    }

    /// 正式库接口域名
    func releaseURL(url: String) -> String {
        /// 用于判断接口地址属于哪个域名
        let domain_1: Set<String> = [k_push]

        if domain_1.contains(url) == true {
            return "wss://msg.baoduitong.com:8989/ws"
        }
        return "https://app.baoduitong.com"
    }
}

/// 账号登录
var k_login: String = "/app/doLogin"

/// 验证码登录
var k_login_code: String = "/app/doLoginSms"

/// 获取验证码
var k_code: String = "/app/getSmsCode"

/// 校验验证码
var k_check_code: String = "/app/checkSmsCode"

/// 模型查询
var k_query: String = "/app/query"

/// 模型修改、添加、删除
var k_query_upsert = "/app/upsert"

/// 消息推送
var k_push = "wss://app.developerplat.com:8088/ws/getPushMsg"
