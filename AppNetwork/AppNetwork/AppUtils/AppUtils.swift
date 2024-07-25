//
//  AppUtils.swift
//  AppUtils
//
//  Created by bormil on 2020/4/17.
//  Copyright © 2020 北京卡友在线科技有限公司. All rights reserved.
//

import Foundation
import UIKit

/* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
 * // MARK: - 日志输出
 * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/
public func AppLog(_ k: Any..., file: String = #file, func: String = #function, line: Int = #line) {
    #if DEBUG
        let message = k.compactMap { "\($0)" }.joined(separator: "")
        print("🇺🇳 \((file as NSString).lastPathComponent)[\(line)] - [message: \(message)]")
    #else
        // TODO: 线上环境日志保存到沙盒
    #endif
}

/* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
 * // MARK: 系统功能模块
 * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

/// Application代理
public let UIAppDelegate = UIApplication.shared.delegate

/// UserDefaults
public let AppUserDefaults: UserDefaults = UserDefaults.standard

/// 系统版本号
public let AppSystemVersion: String = UIDevice.current.systemVersion

/// App当前版本号
public let AppVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String

/// App当前显示的名字
public let AppName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String

/// 系统语言
public let AppPreferredLanguages: String = Locale.preferredLanguages.first!

/// 获取Temp目录
public let AppTemp: String = NSTemporaryDirectory()

/// 获取Document目录
public let AppDocument: String = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!

/// 获取Cache目录
public let AppCache: String = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!

/* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
 * // MARK: App中使用到的尺寸
 * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

/// 屏幕的长
public let AppWidth: CGFloat = UIScreen.main.bounds.size.width

/// 屏幕的高
public let AppHeight: CGFloat = UIScreen.main.bounds.size.height

/// 状态栏高度
public func AppTopBarHeight() -> CGFloat {
    if #available(iOS 13.0, *) {
        return UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 20.0
    } else {
        return UIApplication.shared.statusBarFrame.height
    }
}

/// TabBar高度
public let AppTabBarHeight: CGFloat = AppIphoneXS() ? 83.0 : 49.0

/// NavigationBar高度44.f
public let AppNavigationBarHeight: CGFloat = 44.0

/// 状态栏 + 导航栏高度
public let AppHeadHeight: CGFloat = AppTopBarHeight() + AppNavigationBarHeight

/// 底部安全区高度
public let AppFootHeight: CGFloat = (UIApplication.shared.delegate as? AppDelegate)?.window?.safeAreaInsets.bottom ?? 0.0

/* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
 * // MARK: 常用的数据类型校验 - AppString+Equal
 * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

/// 返回当前设备型号
public func regexForBang() -> String {
    return String.regexForBang()
}

/// 返回布尔值表示当前设备是否是留海屏
public func AppIphoneXS() -> Bool {
    return String.AppIphoneXS()
}

/// 返回布尔值表示纯数字是否有效
public func regexForDigit(digit: String) -> Bool {
    return String.regexForDigit(digit: digit)
}

/// 返回布尔值表示邮箱是否有效
public func regexForEmail(email: String) -> Bool {
    return String.regexForEmail(email: email)
}

/// 返回布尔值表示手机号码是否有效
public func regexForPhone(phone: String) -> Bool {
    return String.regexForPhone(phone: phone)
}

/// 返回布尔值表示车牌号码是否有效
public func regexForCar(car: String) -> Bool {
    return String.regexForCar(car: car)
}

/// 返回布尔值表示身份证号码是否有效
public func regexForCard(card: String) -> Bool {
    return String.regexForCard(card: card)
}

/* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
 * // MARK: 常用的字符串分类 - AppString+Utils
 * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

/// 返回 String 类型的大写加密字符串
public func md5String(text: String) -> String {
    return text.md5String()
}

/// 通过文本字体，计算文本的宽度
public func widthForFont(text: String, font: UIFont) -> CGFloat {
    return text.widthForFont(font: font)
}

/// 通过文本字体、文本宽度，计算文本的高度
public func heightForFont(text: String, font: UIFont, width: CGFloat) -> CGFloat {
    return text.heightForFont(font: font, width: width)
}

/// 从 index 开始截取字符串到结束
public func subText(text: String, from index: Int) -> String {
    return text.subText(from: index)
}

/// 从开始截取字符串到 index 结束
public func subText(text: String, to index: Int) -> String {
    return text.subText(to: index)
}

/* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
 * // MARK: 常用的字号大小
 * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

public let TEXTMEDIUM14: CGFloat = fontForType(14.0)

public func fontForType(_ font: CGFloat) -> CGFloat {
    if AppWidth == 375.0 && AppHeight == 667.0 {
        return font
    } else {
        return AppHeight / 667.0 * font
    }
}

/* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
 * // MARK: 常用的颜色
 * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

/// Hex颜色 0xFFFFFF
public func configHex(color: Int) -> UIColor {
    return UIColor(red: CGFloat((color & 0xFF0000) >> 16) / 255.0, green: CGFloat((color & 0xFF00) >> 8) / 255.0, blue: CGFloat(color & 0xFF) / 255.0, alpha: 1.0)
}

/// 随机颜色
public func configDiffColor() -> UIColor {
    return UIColor(red: CGFloat(arc4random() % 256) / 255.0, green: CGFloat(arc4random() % 256) / 255.0, blue: CGFloat(arc4random() % 256) / 255.0, alpha: 1.0)
}

public let App_black: UIColor = UIColor(red: 0.24, green: 0.24, blue: 0.33, alpha: 1.0)
public let App_gray: UIColor = UIColor(white: 0.57, alpha: 1.0)
