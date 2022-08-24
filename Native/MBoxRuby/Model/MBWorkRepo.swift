//
//  MBWorkRepo.swift
//  MBoxRuby
//
//  Created by Whirlwind on 2021/5/13.
//  Copyright © 2021 com.bytedance. All rights reserved.
//

import Foundation
import MBoxContainer
import MBoxDependencyManager

extension MBWorkRepo {

    @_dynamicReplacement(for: fetchContainers())
    public func ruby_fetchContainers() -> [Container] {
        var value = self.fetchContainers()
        for (name, gemfilePath) in self.gemfilePaths {
            let container = Container(name: name, tool: .Bundler, repo: self)
            container.withSpec(path: gemfilePath)
            if let lockPath = self.gemlockPath(for: gemfilePath) {
                container.withLock(path: lockPath)
            }
            value.append(container)
        }
        return value
    }

    private static var gemfileNames: [String] = [
        "Gemfile",
        "gems.rb"
    ]

    private var gemfilePaths: [String: String] {
        var gemfiles = self.setting.bundler?.gemfiles ?? [:]
        if let gemfile = self.setting.bundler?.gemfile {
            gemfiles[self.name] = gemfile
        }
        return self.paths(for: gemfiles, defaults: (self.name, Self.gemfileNames))
    }

    private func gemlockPath(for gemfile: String) -> String? {
        let gemfileName = gemfile.lastPathComponent
        let gemlockName: String
        if gemfileName.lowercased() == "gems.rb" {
            gemlockName = "gems.locked"
        } else {
            gemlockName = gemfileName.deletingPathExtension.appending(pathExtension: "lock")
        }
        let lockPath = gemfile.deletingLastPathComponent.appending(pathComponent: gemlockName)
        guard lockPath.isFile else { return nil }
        if self.git?.checkIgnore(lockPath) == true { return nil }
        return lockPath
    }

    public var gemspecPaths: [String] {
        var paths = self.setting.bundler?.gemspecs ?? []
        if paths.isEmpty, let path = self.setting.bundler?.gemspec {
            paths.append(path)
        }
        return self.paths(for: paths, defaults: ["*.gemspec"])
    }

    @_dynamicReplacement(for: resolveComponents())
    public func ruby_resolveComponents() -> [Component] {
        var names = self.resolveComponents()
        let data = self.gemspecPaths.map {
            Component(name: $0.lastPathComponent.fileName, tool: .Bundler, repo: self)
                .withSpec(path: $0)
        }
        names.append(contentsOf: data)
        return names
    }
}
