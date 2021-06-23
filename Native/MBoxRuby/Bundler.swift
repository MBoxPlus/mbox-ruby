//
//  Bundler.swift
//  MBoxRuby
//
//  Created by Whirlwind on 2019/7/17.
//  Copyright © 2019 com.bytedance. All rights reserved.
//

import Foundation
import RubyGateway
import MBoxCore

private let rubyQueue = DispatchQueue(label: "RubyQueue")
private let group = DispatchGroup()

@discardableResult
public func rubyTransaction<T>(_ block: () throws -> T) rethrows -> T {
    return try rubyQueue.sync { () -> T in
        return try block()
    }
}

public func rubyFork(_ block: @escaping () throws -> Void) throws {
    var pid: RbObject = .nilObject
    try rubyTransaction {
        group.enter()
        let process = try Ruby.get("Process")
        pid = try process.call("fork") { _ -> RbObject in
            try block()
            group.leave()
            return .nilObject
        }
    }
    try rubyWait(pid)
    group.wait()
}

public func rubyWait(_ pid: RbObject) throws {
    try rubyTransaction {
        let process = try Ruby.get("Process")
        try process.call("wait", args: [pid])
    }
}

public class Bundler {

    public static func require(_ name: String) throws {
        try Ruby.require(filename: name)
    }

}

public func pathname(_ path: String) -> RbObject {
    return RbObject(ofClass: "Pathname", args: [path])!
}
