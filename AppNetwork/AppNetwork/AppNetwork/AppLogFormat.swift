//
//  AppLogFormat.swift
//  AppNetwork
//
//  Created by bormil on 2020/4/29.
//  Copyright © 2020 北京卡友在线科技有限公司. All rights reserved.
//

import UIKit

/* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
 * // MARK: 格式化控制台 Unicode 字符
 * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

extension Array {
    var format: String {
        return description.formatLog
    }
}

extension Dictionary {
    var format: String {
        return description.formatLog
    }
}

extension String {
    var format: String {
        return formatLog
    }

    fileprivate var formatLog: String {
        let p_1 = replacingOccurrences(of: "\\u", with: "\\U")
        let p_2 = p_1.replacingOccurrences(of: "\"", with: "\\\"")
        let p_3 = "\"".appending(p_2).appending("\"")
        let data = p_3.data(using: String.Encoding.utf8)
        var done: String = ""
        do {
            done = try PropertyListSerialization.propertyList(from: data!, options: [.mutableContainers], format: nil) as! String
        } catch {
            AppLog("⚠️ Unicode转换失败 Error：\(error)")
        }
        return done.replacingOccurrences(of: "\\n", with: "\n")
    }
}
