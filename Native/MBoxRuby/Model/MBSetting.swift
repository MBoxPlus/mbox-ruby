//
//  MBSetting.swift
//  MBoxRuby
//
//  Created by Whirlwind on 2020/8/21.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxWorkspaceCore

extension MBSetting {
    public class Gem: MBCodableObject {
        @Codable
        public var gemspec: String?
    }

    public var gem: Gem? {
        set {
            self.setValue(newValue, forPath: "gem")
        }
        get {
            return self.value(forPath: "gem")
        }
    }
}
