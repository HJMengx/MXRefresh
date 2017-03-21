//
//  Defines.swift
//  MXRefresh
//
//  Created by mx on 2017/3/19.
//  Copyright © 2017年 mengx. All rights reserved.
//

import UIKit

func colorWith(red : CGFloat,green : CGFloat,blue : CGFloat)->UIColor{
    return UIColor.init(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1.0)
}

func angle(value : Double)->Double {
    return value / 180.0 * M_PI
}

typealias MXOperation = (_ isComplete : Bool)->Void
