//
//  Gem.swift
//  MBoxRuby
//
//  Created by Whirlwind on 2019/9/17.
//  Copyright © 2019 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxWorkspaceCore

extension MBCommander {
    open class Gem: Exec {
        open class override var description: String? {
            return "Redirect to Gem with MBox environment"
        }

        open override var cmd: MBCMD {
            let cmd = GemCMD()
            cmd.showOutput = true
            return cmd
        }

    }
}
