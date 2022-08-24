//
//  MBWorkspace.swift
//  MBoxRuby
//
//  Created by Whirlwind on 2020/6/24.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxContainer

extension MBWorkspace {

    public var gemfilePath: String {
        return self.configDir.appending(pathComponent: "Gemfile")
    }

    public var rubyGemsDir: String {
        return self.configDir.appending(pathComponent: "RubyGems")
    }

    public var gemfilesDir: String {
        return self.configDir.appending(pathComponent: "GemfileRepos")
    }

    public func setupRubyEnv() throws {
        try UI.log(verbose: "Add Gemfile into workspace") {
            guard let path = MBoxRuby.bundle.path(forResource: "Gemfile", ofType: nil) else {
                return
            }
            let realTarget = self.gemfilePath
            if realTarget.isExists {
                UI.log(verbose: "Remove exists `.mbox/Gemfile`") {
                    try? FileManager.default.removeItem(atPath: realTarget)
                }
            }
            try UI.log(verbose: "Copy `\(path)` -> .mbox/Gemfile") {
                try FileManager.default.copyItem(atPath: path, toPath: realTarget)
            }
        }
    }

    @_dynamicReplacement(for: pathsToLink)
    public var ruby_pathsToLink: [String: String] {
        var paths = self.pathsToLink

        // Link .mbox/Gemfile
        paths["Gemfile"] = self.relativePath(self.gemfilePath)

        for module in MBPluginManager.shared.modules {
            guard let rubyDir = module.rubyDir else { continue }
            let name = rubyDir.subFiles.first(where: { $0.pathExtension == "gemspec" })?.fileName ?? module.name
            paths[rubyGemsDir.appending(pathComponent: name)] = rubyDir
        }

        // Link Ruby Gems
        for repo in self.workRepos {
            for component in repo.activatedComponents(for: .Bundler) {
                let symbolDir = rubyGemsDir.appending(pathComponent: component.name)
                paths[symbolDir] = component.path.relativePath(from: symbolDir.deletingLastPathComponent)
            }
        }

        // Link Container Gemfile
        for container in self.config.currentFeature.activatedContainers(for: .Bundler) {
            let symbolDir = gemfilesDir.appending(pathComponent: container.name)
            paths[symbolDir] = container.path.relativePath(from: symbolDir.deletingLastPathComponent)
        }

        return paths
    }

    public func updateRubyEnv() throws {
        try? BundlerCMD.setup(workingDirectory: self.rootPath, forceUpdate: true)
    }

    public func teardownRubyEnv() throws {
    }

    public func teardownRepoRubyEnv() throws {
        let gemfileRepo = self.configDir.appending(pathComponent: "GemfileRepos")
        if gemfileRepo.isExists {
            UI.log(verbose: "Remove `.mbox/GemfileRepos`") {
                try? FileManager.default.removeItem(atPath: gemfileRepo)
            }
        }
    }
}
