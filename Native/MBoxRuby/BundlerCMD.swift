//
//  BundlerCMD.swift
//  MBoxRuby
//
//  Created by Whirlwind on 2019/7/19.
//  Copyright © 2019 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxWorkspaceCore
import MBoxContainer

open class BundlerCMD: GemCMD {
    public required init(useTTY: Bool? = nil) {
        super.init(useTTY: useTTY)
        if let version = Self.version {
            self.bin = "bundle _\(version)_"
        } else {
            self.bin = "bundle"
        }
    }

    open override func setupEnvironment(_ base: [String: String]? = nil) -> [String: String] {
        var env = super.setupEnvironment(BundlerCMD.environment)
        env["BUNDLE_GEMFILE"] = self.workingDirectory?.appending(pathComponent: "Gemfile")
        return env
    }

    open func check() -> Bool {
        return exec("check") == 0
    }

    open func install() -> Bool {
        return exec("install") == 0
    }

    open func update(gems: [String] = []) -> Bool {
        let gems = gems.isEmpty ? ["--all"] : gems
        return exec("update \(gems.map { $0.quoted }.joined(separator: " "))") == 0
    }

    public static func check(version: String? = nil) -> String? {
        let cmd = GemCMD()
        let versions = cmd.versions(gem: "bundler")
        if versions.isEmpty { return nil }
        guard let version = version else {
            return versions.first!
        }
        if versions.contains(version) {
            return version
        }
        return nil
    }

    public static func isSystemRuby() -> Bool {
        let cmd = MBCMD()
        if !cmd.exec("command which ruby") {
            return false
        }
        return cmd.outputString.hasPrefix("/usr/bin/")
    }

    public static func install(version: String? = nil) -> Bool {
        var args = ["--no-document"]
        if self.isSystemRuby() {
            args.append("--user-install")
        }

        let cmd = GemCMD()
        return cmd.install(gem: "bundler", version: version, args: args)
    }

    private static func bundlerVersion(lockPath: String) -> String? {
        guard lockPath.isExists,
              let lock = try? String(contentsOfFile: lockPath) else {
            UI.log(verbose: "Gemfile.lock not exists.")
            return nil
        }
        let regex = try! NSRegularExpression(pattern: "BUNDLED WITH\\n +(.*?) *\\n", options: .caseInsensitive)
        guard let match = regex.firstMatch(in: lock, options: [], range: NSMakeRange(0, lock.count)) else {
            UI.log(verbose: "Gemfile.lock parse failed!")
            return nil
        }
        let version = String(lock[match.range(at: 1)])
        UI.log(verbose: "Require bundler \(version)")
        return version
    }

    private static func checkBundlerVersion(workingDirectory: String) -> (String?, Bool) {
        return UI.log(verbose: "Check Bundler Version") {
            let lockPath = workingDirectory.appending(pathComponent: "Gemfile.lock")
            let requiredVersion = bundlerVersion(lockPath: lockPath)
            let installedVersion = check(version: requiredVersion)
            if let installedVersion = installedVersion {
                return (installedVersion, true)
            }
            UI.log(verbose: "Should install bundler `\(requiredVersion ?? "Any")`.")
            return (requiredVersion, false)
        }
    }

    private static func checkBundlerGems(workingDirectory: String) -> Bool {
        return UI.log(verbose: "Check Bundler Gems") {
            let bundler = BundlerCMD()
            return bundler.check()
        }
    }

    public static var version: String?

    private static func setupBundler(workingDirectory: String) throws {
        let (bundlerVersion, status) = self.checkBundlerVersion(workingDirectory: workingDirectory)
        if !status {
            try UI.log(verbose: "Setup Bundler Environment") {
                if !BundlerCMD.install(version: bundlerVersion) {
                    throw RuntimeError("Setup Bundler Error")
                }
            }
        }
        if let bundlerVersion = bundlerVersion {
            UI.log(verbose: "Using Bundler v\(bundlerVersion)")
        }
        self.version = bundlerVersion
    }

    @discardableResult
    private static func setupLockfile(workingDirectory: String) throws -> Bool {
        return try UI.log(verbose: "Setup Gemfile.lock") {
            var userLockPath: String? = nil
            for repo in Workspace.config.currentFeature.activatedContainerRepos {
                let path = repo.workingPath.appending(pathComponent: "Gemfile.lock")
                if path.isExists {
                    userLockPath = path
                    break
                }
            }
            if let userLockPath = userLockPath {
                let lockPath = workingDirectory.appending(pathComponent: "Gemfile.lock")
                try UI.log(verbose: "Copy \(Workspace.relativePath(userLockPath)) -> \(Workspace.relativePath(lockPath))") {
                    if lockPath.isExists {
                        try FileManager.default.removeItem(atPath: lockPath)
                    }
                    try FileManager.default.copyItem(atPath: userLockPath, toPath: lockPath)
                }
                return true
            } else {
                UI.log(verbose: "No valid Gemfile.lock to copy.")
                return false
            }
        }
    }

    public static func setup(workingDirectory: String, forceUpdate: Bool = false) throws {
        let lockPath = workingDirectory.appending(pathComponent: "Gemfile.lock")
        if !lockPath.isExists {
            try self.setupLockfile(workingDirectory: workingDirectory)
        }

        try self.setupBundler(workingDirectory: workingDirectory)

        if self.checkBundlerGems(workingDirectory: workingDirectory) {
            return
        }

        if try self.setupLockfile(workingDirectory: workingDirectory) {
            // retry setup the Bundler, due to the Gemfile.lock changed
            try self.setupBundler(workingDirectory: workingDirectory)
            if self.checkBundlerGems(workingDirectory: workingDirectory) {
                return
            }
        }

        try UI.log(verbose: "Setup Bundler Gems") {
            let bundler = BundlerCMD(workingDirectory: workingDirectory)
            if !bundler.update() {
                throw RuntimeError("Setup Gems Error")
            }
        }
    }
}
