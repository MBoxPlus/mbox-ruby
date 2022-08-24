//
//  MBPluginModule.swift
//  MBoxRuby
//
//  Created by 詹迟晶 on 2021/9/10.
//  Copyright © 2021 com.bytedance. All rights reserved.
//

import MBoxCore

extension MBPluginModule {
    public var hasRuby: Bool {
        set {
            self.setValue(newValue, forPath: "RUBY")
        }
        get {
            return self.value(forPath: "RUBY")
        }
    }

    public var rubyDir: String? {
        guard hasRuby else { return nil }
        let path = self.path.appending(pathComponent: "Ruby")
        guard path.isDirectory else { return nil }
        return path
    }

}

