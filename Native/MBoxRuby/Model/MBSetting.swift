//
//  MBSetting.swift
//  MBoxRuby
//
//  Created by Whirlwind on 2020/8/21.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore

extension MBSetting {
    public class Bundler: MBCodableObject {
        @Codable
        public var gemfile: String?

        @Codable
        public var gemfiles: [String: String]?

        @Codable
        public var gemspec: String?

        @Codable
        public var gemspecs: [String]?
    }

    public var bundler: Bundler? {
        set {
            self.setValue(newValue, forPath: "bundler")
        }
        get {
            return self.value(forPath: "bundler")
        }
    }
}
