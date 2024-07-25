//
//  AppError.swift
//  AppNetwork
//
//  Created by bormil on 2020/5/9.
//  Copyright © 2020 北京卡友在线科技有限公司. All rights reserved.
//

import UIKit

/* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
 * // MARK: 处理网络请求中的错误信息
 * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

class AppError: NSObject {
    func errorCodesForSystem(error: NSError) -> String {
        let codes = [-998: "发生未知错误",
                     -999: "连接被取消",
                     -1000: "连接失败，由于URL格式错误",
                     -1001: "连接超时",
                     -1002: "连接失败，由于不支持URL方案",
                     -1003: "连接失败，因为找不到主机",
                     -1004: "连接失败，因为无法连接到主机",
                     -1005: "连接失败，因为网络连接丢失",
                     -1006: "连接失败，由于DNS查找失败",
                     -1007: "连接失败，由于HTTP连接重定向太多",
                     -1008: "连接的资源不可用",
                     -1009: "连接失败，因为设备没有连接到网络",
                     -1010: "连接被重定向到不存在的位置",
                     -1011: "连接收到一个无效的服务器响应",
                     -1012: "连接失败，因为用户取消了所需的身份验证",
                     -1013: "连接失败，因为需要身份验证",
                     -1014: "该连接检索的资源为零字节",
                     -1015: "连接无法解码使用已知内容编码编码的数据",
                     -1016: "连接无法解码使用未知内容编码编码的数据",
                     -1017: "连接无法解析服务器的响应",
                     -1018: "连接失败，因为设备上禁用了国际漫游",
                     -1019: "连接失败，由于呼叫处于活动状态",
                     -1020: "连接失败，因为设备上目前不允许使用数据",
                     -1021: "连接失败，因为其请求的正文流已耗尽",
                     -1100: "文件操作失败，因为文件不存在",
                     -1101: "文件操作失败，因为该文件是一个目录",
                     -1102: "文件操作失败，因为它没有读取文件的权限",
                     -1103: "文件操作失败，因为文件太大",
                     -1200: "安全连接失败，由于未知原因",
                     -1201: "安全连接失败，由于服务器证书的日期无效",
                     -1202: "安全连接失败，因为服务器的证书不受信任",
                     -1203: "安全连接失败，由于服务器证书的根目录未知",
                     -1204: "安全连接失败，因为服务器的证书尚未有效",
                     -1205: "安全连接失败，因为客户机的证书被拒绝",
                     -1206: "安全连接失败，因为服务器需要客户端证书",
                     -2000: "连接失败，因为需要它返回缓存的资源，但是没有可用的资源",
                     -3000: "无法创建文件",
                     -3001: "无法打开文件",
                     -3002: "无法关闭文件",
                     -3003: "无法写入文件",
                     -3004: "无法删除文件",
                     -3005: "无法移动文件",
                     -3006: "下载失败，因为下载数据的解码在流中失败",
                     -3007: "下载失败，因为下载数据的解码未能完成"] as [Int: String]

        return codes[error.code] ?? error.localizedDescription
    }
}
