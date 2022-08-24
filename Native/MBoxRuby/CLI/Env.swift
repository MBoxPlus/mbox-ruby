//
//  Env.swift
//  MBoxRuby
//
//  Created by 詹迟晶 on 2021/9/18.
//  Copyright © 2021 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxWorkspace

extension MBPluginModule {

    @_dynamicReplacement(for: modulePathDescription())
    open func ruby_modulePathDescription() -> [String] {
        var desc = self.modulePathDescription()
        if let dir = self.rubyDir, dir.isExists {
            desc << "RUBY:\t\(dir)"
        }
        return desc
    }
}
