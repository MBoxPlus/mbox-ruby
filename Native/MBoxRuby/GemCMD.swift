//
//  GemCMD.swift
//  MBoxRuby
//
//  Created by Whirlwind on 2019/9/12.
//  Copyright © 2019 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxWorkspace

open class GemCMD: MBCMD {
    public required init(useTTY: Bool? = nil) {
        super.init(useTTY: useTTY)
        self.bin = "gem"
    }

    open override func setupEnvironment(_ base: [String: String]? = nil) -> [String: String] {
        return super.setupEnvironment(BundlerCMD.environment)
    }

    open func versions(gem: String) -> [String] {
        let args = ["list", "-e", gem.quoted]
        if exec(args.joined(separator: " ")) {
            let regex = try! NSRegularExpression(pattern: "\(gem) \\((.*)\\)", options: .caseInsensitive)
            return self.outputString.split(separator: "\r\n").compactMap { string -> [String]? in
                let string = String(string)
                if let match = regex.firstMatch(in: string, options: [], range: NSMakeRange(0, string.count)) {
                    return string[match.range(at: 1)].split(separator: ",").map { String($0.replacingOccurrences(of: "default:", with: "").trimmingCharacters(in: .whitespaces)) }
                }
                return nil
            }.flatMap { $0 }
        }
        return []
    }

    open func install(gem: String, version: String? = nil, args: [String] = []) -> Bool {
        var cmds = ["install", gem.quoted]
        if let version = version {
            cmds.append(contentsOf: ["-v", version])
        }
        cmds.append(contentsOf: args)
        return exec(cmds.joined(separator: " ")) == 0
    }

    public class var environment: [String: String] {
        var env = ProcessInfo.processInfo.environment
        if env["LANG"] == nil {
            env["LANG"] = "en_US.UTF-8"
        }
        return env
    }

}
