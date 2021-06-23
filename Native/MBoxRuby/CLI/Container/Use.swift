//
//  Use.swift
//  MBoxRuby
//
//  Created by cppluwang on 2020/9/9.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import MBoxCore
import MBoxContainer
import MBoxDependencyManager

extension MBCommander.Container.Switch {
    @_dynamicReplacement(for: switchTarget(_:tool:))
    open func ruby_switchTarget(_ name: String, tool: MBDependencyTool) throws {
        try switchTarget(name, tool: tool)
        try self.workspace.setupRepoRubyEnv()
    }
}
