//
//  MBoxRuby.swift
//  MBoxRuby
//
//  Created by Whirlwind on 2019/8/15.
//  Copyright © 2019 com.bytedance. All rights reserved.
//

import Cocoa
import MBoxCore
import MBoxWorkspaceCore
import MBoxWorkspace

@objc(MBoxRuby)
open class MBoxRuby: NSObject, MBWorkspacePluginProtocol {

    public func registerCommanders() {
        MBCommanderGroup.shared.addCommand(MBCommander.Gem.self)
        MBCommanderGroup.shared.addCommand(MBCommander.Bundle.self)
    }

    public func enablePlugin(workspace: MBWorkspace, from version: String?) throws {
        try workspace.setupRubyEnv()
    }

    public func disablePlugin(workspace: MBWorkspace) throws {
        try workspace.teardownRepoRubyEnv()
    }
}

