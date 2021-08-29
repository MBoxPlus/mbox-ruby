//
//  Bundle.swift
//  MBoxRuby
//
//  Created by Whirlwind on 2019/8/15.
//  Copyright © 2019 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxWorkspaceCore
import MBoxContainer

extension MBCommander {
    open class Bundle: Exec {
        open class override var description: String? {
            return "Redirect to Bundler with MBox environment"
        }

        open override class var example: String? {
            return """
# Install gems with bundler
$ mbox bundle install
"""
        }

        open override var cmd: MBCMD {
            let cmd = BundlerCMD()
            cmd.showOutput = true
            return cmd
        }

        open override func validate() throws {
            try super.validate()
            try self.validateMultipleContainers(for: .Bundler)
        }

        dynamic
        open override func setupCMD() throws -> (MBCMD, [String]) {
            if self.shouldSetupBundler {
                try BundlerCMD.setup(workingDirectory: self.workspace.rootPath)
            }
            return try super.setupCMD()
        }

        open var shouldSetupBundler: Bool {
            if type(of: self) == Bundle.self {
                return false
            }
            return true
        }
    }
}
