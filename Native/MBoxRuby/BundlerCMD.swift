//
//  BundlerCMD.swift
//  MBoxRuby
//
//  Created by Whirlwind on 2019/7/19.
//  Copyright © 2019 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxContainer

open class BundlerCMD: GemCMD {
    public required init(useTTY: Bool? = nil) {
        super.init(useTTY: useTTY)
        self.bin = "bundle"
        if let version = Self.version {
            self.args.append("_\(version)_")
        }
    }

    open lazy var gemfilePath: String? = {
        var path = self.workingDirectory.appending(pathComponent: "Gemfile")
        if path.isExists {
            return path
        }
        path = workspace.rootPath.appending(pathComponent: "Gemfile")
        if path.isExists {
            return path
        }
        return nil
    }()

    open override func setupEnvironment(_ base: [String: String]? = nil) -> [String: String] {
        var env = super.setupEnvironment(BundlerCMD.environment)
        env["BUNDLE_GEMFILE"] = self.gemfilePath
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
        let cmd = GemCMD(useTTY: false)
        let versions = cmd.versions(gem: "bundler")
        if versions.isEmpty { return nil }
        guard let version = version else {
            return versions.sorted(by: {
                $0.compare($1, options: .numeric) == .orderedDescending
            }).first!
        }
        if versions.contains(version) {
            return version
        }
        return nil
    }

    public static func gemdirIsWritable() -> Bool {
        let cmd = MBCMD(useTTY: false)
        if !cmd.exec("ruby -e 'puts Gem.dir;puts Gem.bindir'") {
            UI.log(verbose: "Could not get gem installation directory.")
            return false
        }
        let info: [Substring] = cmd.outputString.split(separator: "\n")
        let gemdir = String(info[0]) + "/"
        let bindir = String(info[1]) + "/"
        let gemDirIsWritable = FileManager.default.isWritableFile(atPath: gemdir)
        UI.log(verbose: "gemdir \(gemDirIsWritable ? "is" : "is NOT") writable: `\(gemdir)`")
        let binDirIsWritable = FileManager.default.isWritableFile(atPath: bindir)
        UI.log(verbose: "bindir \(binDirIsWritable ? "is" : "is NOT") writable: `\(bindir)`")
        return gemDirIsWritable && binDirIsWritable
    }

    public static func install(version: String? = nil) -> Bool {
        var args = ["--no-document"]
        if !self.gemdirIsWritable() {
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
        UI.log(verbose: "Parse `\(lockPath)`")
        let regex = try! NSRegularExpression(pattern: "BUNDLED WITH\\n +(.*?) *\\n", options: .caseInsensitive)
        guard let match = regex.firstMatch(in: lock, options: [], range: NSMakeRange(0, lock.count)) else {
            UI.log(verbose: "Gemfile.lock parse failed!")
            return nil
        }
        let version = String(lock[match.range(at: 1)])
        UI.log(verbose: "Require bundler `\(version)` from the \(lockPath.lastPathComponent)")
        return version
    }

    private static let minVersion = "2.2.8"

    private static func checkBundlerVersion(workingDirectory: String) -> (String?, Bool) {
        return UI.log(verbose: "Check Bundler Version") {
            let lockPath = workingDirectory.appending(pathComponent: "Gemfile.lock")
            var requiredVersion = bundlerVersion(lockPath: lockPath)
            if let version = requiredVersion,
                version.compare(self.minVersion, options: .numeric) == .orderedAscending {
                UI.log(verbose: "The required version `\(version)` is too low. Instead, use the min bundler version `\(self.minVersion)`.")
                requiredVersion = nil
                UI.log(verbose: "Remove expired Gemfile.lock")
                try? FileManager.default.removeItem(atPath: lockPath)
            }
            let installedVersion = check(version: requiredVersion)
            if let installedVersion = installedVersion,
               installedVersion.compare(self.minVersion, options: .numeric) != .orderedAscending {
                return (installedVersion, true)
            }
            UI.log(verbose: "Should install bundler `\(requiredVersion ?? self.minVersion)`.")
            return (requiredVersion ?? self.minVersion, false)
        }
    }

    private static func checkBundlerGems(workingDirectory: String) -> Bool {
        return UI.log(verbose: "Check Bundler Gems") {
            guard self.executableExists("bundle") else { return false }
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
    public static func setupLockfile(workingDirectory: String) throws -> Bool {
        return try UI.log(verbose: "Setup Gemfile.lock") {
            var userLockPath: String? = nil
            for container in Workspace.config.currentFeature.activatedContainers(for: .Bundler) {
                if let path = container.lockAbsolutePath {
                    userLockPath = path
                    break
                }
            }
            let lockPath = workingDirectory.appending(pathComponent: "Gemfile.lock")
            if let userLockPath = userLockPath {
                try UI.log(verbose: "Copy \(Workspace.relativePath(userLockPath)) -> \(Workspace.relativePath(lockPath))") {
                    if lockPath.isExists {
                        try FileManager.default.removeItem(atPath: lockPath)
                    }
                    try FileManager.default.copyItem(atPath: userLockPath, toPath: lockPath)
                }
                return true
            } else {
                try? FileManager.default.removeItem(atPath: lockPath)
                UI.log(verbose: "No valid Gemfile.lock to copy.")
                return false
            }
        }
    }

    public static func install(workingDirectory: String) throws {
        let lockPath = workingDirectory.appending(pathComponent: "Gemfile.lock")
        if !lockPath.isExists {
            try self.setupLockfile(workingDirectory: workingDirectory)
        }
        try self.setupBundler(workingDirectory: workingDirectory)
    }

    public static var ready = false

    public static func setup(workingDirectory: String, forceUpdate: Bool = false) throws {
        if ready {
            UI.log(verbose: "Bundler environment is ready. Skip setup.")
            return
        }

        try install(workingDirectory: workingDirectory)

        if self.checkBundlerGems(workingDirectory: workingDirectory) {
            ready = true
            return
        }

        if try self.setupLockfile(workingDirectory: workingDirectory) {
            // retry setup the Bundler, due to the Gemfile.lock changed
            try self.setupBundler(workingDirectory: workingDirectory)
            if self.checkBundlerGems(workingDirectory: workingDirectory) {
                ready = true
                return
            }
        }

        try UI.log(verbose: "Setup Bundler Gems") {
            let bundler = BundlerCMD(workingDirectory: workingDirectory)
            if !bundler.update() {
                throw RuntimeError("Setup Gems Error")
            }
        }

        ready = true
    }
}
