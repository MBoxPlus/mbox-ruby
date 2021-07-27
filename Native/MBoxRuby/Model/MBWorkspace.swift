//
//  MBWorkspace.swift
//  MBoxRuby
//
//  Created by 詹迟晶 on 2020/6/24.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxWorkspaceCore
import MBoxContainer

extension MBWorkspace {

    open var gemfilePath: String {
        return self.configDir.appending(pathComponent: "Gemfile")
    }

    open var rubyGemsDir: String {
        return self.configDir.appending(pathComponent: "RubyGems")
    }

    open func setupRubyEnv() throws {
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

        for plugin in MBPluginManager.shared.packages {
            guard let rubyDir = plugin.rubyDir else { continue }
            let name = rubyDir.subFiles.first(where: { $0.pathExtension == "gemspec" })?.fileName ?? plugin.name
            paths[rubyGemsDir.appending(pathComponent: name)] = rubyDir
        }

        // Link Ruby Gems
        for repo in self.repos {
            guard let gemspecPaths = repo.workRepository?.allGemspecPaths() else {
                continue
            }
            var gemspecs = [String: String]()
            for path in gemspecPaths {
                gemspecs[path.lastPathComponent.fileName] = path
            }
            for name in repo.activatedComponents(for: .Gem) {
                guard let path = gemspecs[name] else { continue }
                paths[rubyGemsDir.appending(pathComponent: name)] = path.deletingLastPathComponent
            }
        }

        // Link Container Gemfile
        let currentContainerRepos = self.config.currentFeature.activatedContainerRepos(for: .Gem).compactMap(\.workRepository)
        guard currentContainerRepos.count > 0 else {
            return paths
        }

        let gemfileRepoGroup = self.configDir.appending(pathComponent: "GemfileRepos")
        for repo in currentContainerRepos {
            let gemfilePath = repo.path.appending(pathComponent: "Gemfile")
            if !gemfilePath.isExists {
                continue
            }

            let gemfileRepo = gemfileRepoGroup.appending(pathComponent: repo.name)
            let relativePath = repo.path.relativePath(from: gemfileRepo.deletingLastPathComponent)
            paths[self.relativePath(gemfileRepo)] = relativePath
        }

        return paths
    }

    open func updateRubyEnv() throws {
        try? BundlerCMD.setup(workingDirectory: self.rootPath, forceUpdate: true)
    }

    open func teardownRubyEnv() throws {
    }

    open func teardownRepoRubyEnv() throws {
        let gemfileRepo = self.configDir.appending(pathComponent: "GemfileRepos")
        if gemfileRepo.isExists {
            UI.log(verbose: "Remove `.mbox/GemfileRepos`") {
                try? FileManager.default.removeItem(atPath: gemfileRepo)
            }
        }
    }
}
