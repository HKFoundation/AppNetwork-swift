//
//  AppUIView+Utils.swift
//  AppUtils
//
//  Created by bormil on 2020/6/19.
//  Copyright © 2020 深眸科技（北京）有限公司. All rights reserved.
//

import UIKit

extension UIView {
    public var x: CGFloat {
        get { return frame.origin.x }
        set {
            var f = frame
            f.origin.x = newValue
            frame = f
        }
    }

    public var y: CGFloat {
        get { return frame.origin.y }
        set {
            var f = frame
            f.origin.y = newValue
            frame = f
        }
    }

    public var width: CGFloat {
        get { return frame.size.width }
        set {
            var f = frame
            f.size.width = newValue
            frame = f
        }
    }

    public var height: CGFloat {
        get { return frame.size.height }
        set {
            var f = frame
            f.size.height = newValue
            frame = f
        }
    }

    public var right: CGFloat {
        return frame.origin.x + frame.size.width
    }

    public var bottom: CGFloat {
        return frame.origin.y + frame.size.height
    }
}
