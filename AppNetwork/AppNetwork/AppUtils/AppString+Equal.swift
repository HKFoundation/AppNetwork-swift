//
//  AppString+Equal.swift
//  AppUtils
//
//  Created by bormil on 2020/4/17.
//  Copyright © 2020 北京卡友在线科技有限公司. All rights reserved.
//

import Foundation
import UIKit

extension String {
    private static func regexForCommon(common: String, value: String) -> Bool {
        let regex: NSPredicate = NSPredicate(format: "SELF MATCHES %@", common)
        return regex.evaluate(with: value)
    }

    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: 返回当前设备型号
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    /// 返回当前设备型号
    static func regexForBang() -> String {
        var pInfo = utsname()
        uname(&pInfo)
        var mode = ""
        #if targetEnvironment(simulator)
            mode = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"]!
        #else
            mode = withUnsafePointer(to: &pInfo.machine.0) { p in
                String(cString: p)
            }
        #endif

        switch mode {
        case "iPhone3,1", "iPhone3,2", "iPhone3,3": return "iPhone 4"
        case "iPhone4,1": return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2": return "iPhone 5"
        case "iPhone5,3", "iPhone5,4": return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2": return "iPhone 5s"
        case "iPhone7,2": return "iPhone 6"
        case "iPhone7,1": return "iPhone 6 Plus"
        case "iPhone8,1": return "iPhone 6s"
        case "iPhone8,2": return "iPhone 6s Plus"
        case "iPhone8,4": return "iPhone SE"
        case "iPhone9,1": return "iPhone 7 (CDMA)"
        case "iPhone9,3": return "iPhone 7 (GSM)"
        case "iPhone9,2": return "iPhone 7 Plus (CDMA)"
        case "iPhone9,4": return "iPhone 7 Plus (GSM)"
        case "iPhone10,1", "iPhone10,4": return "iPhone 8"
        case "iPhone10,2", "iPhone10,5": return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6": return "iPhone X"
        case "iPhone11,2": return "iPhone XS"
        case "iPhone11,4", "iPhone11,6": return "iPhone XS Max"
        case "iPhone11,8": return "iPhone XR"
        case "iPhone12,1": return "iPhone 11"
        case "iPhone12,3": return "iPhone 11 Pro"
        case "iPhone12,5": return "iPhone 11 Pro Max"
        case"iPhone12,8": return"iPhone SE (2nd generation)"
        case"iPhone13,1": return"iPhone 12 mini"
        case"iPhone13,2": return"iPhone 12"
        case"iPhone13,3": return"iPhone 12 Pro"
        case"iPhone13,4": return"iPhone 12 Pro Max"
        default: return ""
        }
    }

    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: 返回布尔值表示当前设备是否是留海屏
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    /// 返回布尔值表示当前设备是否是留海屏
    static func AppIphoneXS() -> Bool {
        let mode = ["iPhone X",
                    "iPhone XR",
                    "iPhone XS",
                    "iPhone XS Max",
                    "iPhone 11",
                    "iPhone 11 Pro",
                    "iPhone 11 Pro Max",
                    "iPhone 12 mini",
                    "iPhone 12",
                    "iPhone 12 Pro",
                    "iPhone 12 Pro Max"]

        if mode.contains(regexForBang()) {
            return true
        }
        return false
    }

    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: 返回布尔值表示纯数字是否有效
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    /// 返回布尔值表示纯数字是否有效
    static func regexForDigit(digit: String) -> Bool {
        let regex = "^[0-9]*$"
        return regexForCommon(common: regex, value: digit)
    }

    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: 返回布尔值表示邮箱是否有效
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    /// 返回布尔值表示邮箱是否有效
    static func regexForEmail(email: String) -> Bool {
        let regex = "[A-Za-z0-9._%+-]+[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        return regexForCommon(common: regex, value: email)
    }

    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: 返回布尔值表示手机号码是否有效
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    /// 返回布尔值表示手机号码是否有效
    static func regexForPhone(phone: String) -> Bool {
        let regex = "^1([358][0-9]|4[579]|66|7[0135678]|9[189])[0-9]{8}$"
        return regexForCommon(common: regex, value: phone)
    }

    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: 返回布尔值表示车牌号码是否有效
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    /// 返回布尔值表示车牌号码是否有效
    static func regexForCar(car: String) -> Bool {
        let regex = "^(京[A-HJ-NPQY]|沪[A-HJ-N]|津[A-HJ-NPQR]|渝[A-DFGHN]|冀[A-HJRST]|晋[A-FHJ-M]|蒙[A-HJKLM]|辽[A-HJ-NP]|吉[A-HJK]|黑[A-HJ-NPR]|苏[A-HJ-N-U]|浙[A-HJKL]|皖[A-HJ-NP-S]|闽[A-HJK]|赣[A-HJKLMS]|鲁[A-HJ-NP-SUVWY]|豫[A-HJ-NP-SU]|鄂[A-HJ-NP-S]|湘[A-HJ-NSU]|粤[A-HJ-NP-Y]|桂[A-HJ-NPR]|琼[A-F]|川[A-HJ-MQ-Z]|贵[A-HJ]|云[AC-HJ-NP-SV]|藏[A-HJ]|陕[A-HJKV]|甘[A-HJ-NP]|青[A-H]|宁[A-E]|新[A-HJ-NP-S])([0-9A-HJ-NP-Z]{4}[0-9A-HJ-NP-Z挂试]|[0-9]{4}学|[A-D0-9][0-9]{3}警|[DF][0-9A-HJ-NP-Z][0-9]{4}|[0-9]{5}[DF])$|^WJ[京沪津渝冀晋蒙辽吉黑苏浙皖闽赣鲁豫鄂湘粤桂琼川贵云藏陕甘青宁新]?[0-9]{4}[0-9JBXTHSD]$|^(V[A-GKMORTV]|K[A-HJ-NORUZ]|H[A-GLOR]|[BCGJLNS][A-DKMNORVY]|G[JS])[0-9]{5}$|^[0-9]{6}使$|^([沪粤川渝辽云桂鄂湘陕藏黑]A|闽D|鲁B|蒙[AEH])[0-9]{4}领$|^粤Z[0-9A-HJ-NP-Z][0-9]{3}[港澳]$"
        return regexForCommon(common: regex, value: car)
    }

    /* ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*
     * // MARK: 返回布尔值表示身份证号码是否有效
     * ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄＊ ┄┅┄┅┄┅┄┅┄*/

    /// 返回布尔值表示身份证号码是否有效
    static func regexForCard(card: String) -> Bool {
        /// 1.如果身份证号码不满足15位或18位，返回false
        if card.count != 15 && card.count != 18 {
            return false
        }

        /// 身份证号码省份编码
        let code = ["11", "12", "13", "14", "15", "21", "22", "23", "31", "32", "33", "34", "35", "36", "37", "41", "42", "43", "44", "45", "46", "50", "51", "52", "53", "54", "61", "62", "63", "64", "65", "71", "81", "82", "91"]
        /// 2.如果省份编码不存在，返回false
        if !code.contains(String(card.prefix(2))) {
            return false
        }

        /// 加权因子
        let r = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2]
        /// 校验码 ["1", "0", "X", "9", "8", "7", "6", "5", "4", "3", "2"]
        let checks = [49, 48, 88, 57, 56, 55, 54, 53, 52, 51, 50]
        /// 3.将15位身份证号码转换成18位
        var computed = card
        if card.count == 15 {
            computed.insert(contentsOf: "19", at: computed.index(computed.startIndex, offsetBy: 6))
            var p = 0
            let digit = computed.utf8CString

            for index in 0 ... 16 {
                p += Int(digit[index] - 48) * r[index]
            }
            let obj = String(format: "%c", checks[p % 11])
            computed.insert(contentsOf: obj, at: computed.index(computed.startIndex, offsetBy: computed.count))
        }

        /// 4.如果生日日期无效，返回false
        let bday = computed[computed.index(computed.startIndex, offsetBy: 6) ..< computed.index(computed.startIndex, offsetBy: 14)]
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYYMMdd"

        guard formatter.date(from: String(bday)) != nil else {
            return false
        }

        /// 5.如果不是18位，返回false
        guard strlen(computed) == 18 else {
            return false
        }

        /// 6.如果前17位包含非数字或18位非 X或x，返回false
        let digit = computed.utf8CString
        var verifyCode = 0

        for index in 0 ... 18 {
            if isdigit(Int32(digit[index])) == 0 && !(88 == digit[index] || 120 == digit[index]) && 17 == index {
                return false
            }

            if index <= 16 {
                verifyCode += Int(digit[index] - 48) * r[index]
            }
        }

        /// 7.如果校验码位不正确，返回false
        if checks[verifyCode % 11] != digit[17] {
            return false
        }

        return true
    }
}
