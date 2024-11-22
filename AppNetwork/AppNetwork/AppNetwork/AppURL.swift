//
//  AppURL.swift
//  AppNetwork
//
//  Created by bormil on 2020/5/12.
//  Copyright © 2020 深眸科技（北京）有限公司. All rights reserved.
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
        let domain_1: Set<String> = [k_upgrade]
        let domain_2: Set<String> = [k_package]

        if domain_1.contains(where: { url.hasPrefix($0) }) {
            return "https://api.blinktech.com.cn"
        }
        
        if domain_2.contains(where: { url.hasPrefix($0) }) {
            return "https://static.xbotgo.com"
        }
        return "http://161.189.189.3"
    }

    /// 正式库接口域名
    func releaseURL(url: String) -> String {
        /// 用于判断接口地址属于哪个域名
        let domain_1: Set<String> = [k_upgrade]
        let domain_2: Set<String> = [k_package]

        if domain_1.contains(where: { url.hasPrefix($0) }) {
            return ""
        }

        if domain_2.contains(where: { url.hasPrefix($0) }) {
            return ""
        }
        
        return ""
    }
}

/// 账号登录
var k_login: String = "/device/api/login"

/// 获取 taskId
var k_receive: String = "/device/api/receive"

/// 上传操作行为
var k_opt: String = "/device/api/opt"

/// 获取 OTA 升级包下载地址
var k_upgrade: String = "/upgrade"

/// 下载 OTA 升级包
var k_package: String = "/package/chameleon"

/// 上报设备信息
var k_clone: String = "/device/api/clone"

/// 上报抽检结果
var k_spot_check: String = "/device/api/spot/check/state"
