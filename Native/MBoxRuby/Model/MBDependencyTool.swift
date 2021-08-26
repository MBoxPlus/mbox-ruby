//
//  MBDependencyTool.swift
//  MBoxRubyLoader
//
//  Created by Whirlwind on 2021/5/13.
//  Copyright © 2021 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxDependencyManager

extension MBDependencyTool {
    public static let Bundler = MBDependencyTool("Bundler")

    @_dynamicReplacement(for: allTools)
    public static var ruby_allTools: [MBDependencyTool] {
        var tools = self.allTools
        tools.insert(.Bundler, at: 0)
        return tools
    }
}
