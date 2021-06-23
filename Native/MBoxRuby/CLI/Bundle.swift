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

        open override var cmd: MBCMD {
            let cmd = BundlerCMD()
            cmd.showOutput = true
            return cmd
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
