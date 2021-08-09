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
import MBoxDependencyManager

@objc(MBoxRuby)
open class MBoxRuby: NSObject, MBWorkspacePluginProtocol {

    public func registerCommanders() {
        MBCommanderGroup.shared.addCommand(MBCommander.Gem.self)
        MBCommanderGroup.shared.addCommand(MBCommander.Bundle.self)
    }

    public func enablePlugin(workspace: MBWorkspace, from version: String?) throws {
        try workspace.setupRubyEnv()
        // Change Gem to Bundler
        var changed = false
        for container in workspace.config.currentFeature.currentContainers where container.tool == "Gem" {
            container.tool = .Bundler
            changed = true
        }
        for repo in workspace.config.currentFeature.repos {
            for component in repo.components where component.tool == "Gem" {
                component.tool = .Bundler
                changed = true
            }
        }
        if changed {
            workspace.config.save()
        }
    }

    public func disablePlugin(workspace: MBWorkspace) throws {
        try workspace.teardownRepoRubyEnv()
    }
}

