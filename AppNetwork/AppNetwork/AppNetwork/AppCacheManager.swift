//
//  AppCacheManager.swift
//  AppNetwork
//
//  Created by bormil on 2020/5/8.
//  Copyright © 2020 北京卡友在线科技有限公司. All rights reserved.
//

import UIKit

/* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
 * // MARK: 下载文件本地缓存
 * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

class AppCacheManager: NSObject {
    static let shared = AppCacheManager()

    private var url: URL?

    /// 设置缓存数据的目录，默认路径 Documents/AppNetwork，"Documents" 为系统中的文件夹
    func configCacheURL(url: URL) {
        self.url = url
    }

    /// 获取缓存数据的目录
    func cacheURL() -> URL {
        guard let url = url else {
            return URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/AppNetwork")
        }
        return url
    }

    /// 判断文件夹目录是否存在，如果不存在会自动生成对应目录文件夹
    func configCacheDocument(atPath: String) -> Bool {
        /// 先判断目录是否存在
        if configFileExists(atPath: atPath) {
            return true
        }

        do {
            try FileManager.default.createDirectory(atPath: atPath, withIntermediateDirectories: true, attributes: nil)
            printk("🍀 缓存目录创建成功")
            return true
        } catch {
            printk("⚠️ 缓存目录创建失败 Error：\(error.localizedDescription)")
            return false
        }
    }

    /// 生成文件并存储
    func configContentSaveLocal(atPath: String, data: Data) -> Bool {
        return FileManager.default.createFile(atPath: atPath, contents: data, attributes: nil)
    }

    /// 读取数据并返回
    func configContentLoadLocal(atPath: String) -> Data? {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: atPath), options: Data.ReadingOptions.mappedIfSafe) else {
            return nil
        }
        return data
    }

    /// 获取缓存文件的大小 单位MB
    func bytesTotalCache() -> CGFloat {
        var bytes: CGFloat = 0

        /// 判断是否存在文件夹，文件夹是否存在文件
        if configFileExists(atPath: cacheURL().path) == true && configDocumentrEmpty(atPath: cacheURL().path) {
            let contents = try? FileManager.default.contentsOfDirectory(atPath: cacheURL().path)

            for url in contents! {
                bytes += bytesTotalCache(atPath: NSURL(fileURLWithPath: cacheURL().path).appendingPathComponent(url)!.path)
            }
        }
        return bytes / (1000.0 * 1000.0)
    }

    /// 获取单个文件的大小 单位MB
    func bytesTotalCache(atPath: String) -> CGFloat {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: atPath) as NSDictionary else {
            return 0
        }
        return CGFloat(attributes.fileSize()) / (1000.0 * 1000.0)
    }

    /// 判断文件或是目录是否存在
    func configFileExists(atPath: String) -> Bool {
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
    func configEmptyCache(atPath: String) {
        guard configFileExists(atPath: atPath) else {
            printk("⚠️ 清空缓存失败 Error：没有找到指定的文件目录")
            return
        }

        let url = URL(fileURLWithPath: atPath)
        do {
            try FileManager.default.removeItem(atPath: atPath)
            printk("🍀 \(url.lastPathComponent) 文件清空成功")
        } catch {
            printk("⚠️ \(url.lastPathComponent) 文件清空失败 Error：\(error.localizedDescription)")
        }
    }
}
