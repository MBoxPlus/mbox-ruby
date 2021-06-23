//
//  MBDependencyTool.swift
//  MBoxRubyLoader
//
//  Created by 詹迟晶 on 2021/5/13.
//  Copyright © 2021 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxDependencyManager

extension MBDependencyTool {
    public static let Gem = MBDependencyTool("Gem")

    @_dynamicReplacement(for: allTools)
    public static var ruby_allTools: [MBDependencyTool] {
        var tools = self.allTools
        tools.insert(.Gem, at: 0)
        return tools
    }
}
