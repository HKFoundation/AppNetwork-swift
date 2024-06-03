//
//  AppCacheUtils.swift
//  AppNetwork
//
//  Created by bormil on 2020/5/8.
//  Copyright © 2020 北京卡友在线科技有限公司. All rights reserved.
//

import UIKit

/* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
 * // MARK: - 本类主要用于文件下载本地缓存使用
 * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

struct AppDownloadDone: Codable {
    var cache: Dictionary<String, Data>?
    init() {}
}

private var app_cache: String = "Documents/AppNetwork"

class AppCacheUtils: NSObject {
    /// 设置缓存数据的目录，默认路径 Documents/AppNetwork，"Documents" 为系统中的文件夹
    func configCacheURL(atPath: String) {
        app_cache = atPath
    }

    /// 获取缓存数据的目录
    func cacheURL() -> String {
        return URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(app_cache).path
    }

    /// 判断文件夹目录是否存在，如果不存在会自动生成对应目录文件夹
    func configNewDocument(atPath: String) -> Bool {
        /// 先判断目录是否存在
        if configDocumentExists(atPath: atPath) {
            return true
        }

        do {
            try FileManager.default.createDirectory(atPath: atPath, withIntermediateDirectories: true, attributes: nil)
            AppLog("🍀 缓存目录创建成功")
            return true
        } catch {
            AppLog("⚠️ 缓存目录创建失败 Error：\(error.localizedDescription)")
            return false
        }
    }

    /// 生成文件并存储
    func configContentSaveLocal(atPath: String, data: Data) -> Bool {
        return FileManager.default.createFile(atPath: atPath, contents: data, attributes: nil)
    }

    /// 读取数据并返回
    func configContentLocal(atPath: String) -> Data? {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: atPath), options: Data.ReadingOptions.mappedIfSafe) else {
            return nil
        }
        return data
    }

    /// 获取缓存文件的大小 单位MB
    func bytesTotalCache() -> CGFloat {
        var bytes: CGFloat = 0

        /// 判断是否存在文件夹，文件夹是否存在文件
        if configDocumentExists(atPath: cacheURL()) == true && configDocumentrEmpty(atPath: cacheURL()) {
            let pArr = try? FileManager.default.contentsOfDirectory(atPath: cacheURL())

            for p in pArr! {
                bytes += bytesTotalCache(atPath: NSURL(fileURLWithPath: cacheURL()).appendingPathComponent(p)!.path)
            }
        }
        return bytes / (1000.0 * 1000.0)
    }

    /// 获取单个文件的大小
    func bytesTotalCache(atPath: String) -> CGFloat {
        guard let p = try? FileManager.default.attributesOfItem(atPath: atPath) as NSDictionary else {
            return 0
        }
        return CGFloat(p.fileSize()) / (1000.0 * 1000.0)
    }

    /// 判断文件夹是否存在
    func configDocumentExists(atPath: String) -> Bool {
        return FileManager.default.fileExists(atPath: atPath)
    }

    /// 判断文件夹是否为空 true 为空文件夹
    func configDocumentrEmpty(atPath: String) -> Bool {
        guard (try? FileManager.default.contentsOfDirectory(atPath: atPath)) != nil else {
            return false
        }
        return true
    }

    /// 清空网络数据缓存
    func configEmptyCache(atPath: String, debugLog: String?) {
        guard configDocumentExists(atPath: atPath) else {
            AppLog("⚠️ 清空缓存失败 Error：没有找到指定的文件目录")
            return
        }

        do {
            try FileManager.default.removeItem(atPath: atPath)
            AppLog(debugLog?.count == 0 ? "🍀 清空缓存成功" : "🍀 \(debugLog!) 文件清空成功")
        } catch {
            AppLog(debugLog?.count == 0 ? "⚠️ 清空缓存失败 Error：\(error.localizedDescription)" : "⚠️ \(debugLog!) 文件清空失败 Error：\(error.localizedDescription)")
        }
    }
}
