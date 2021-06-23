//
//  MBWorkRepo.swift
//  MBoxRuby
//
//  Created by 詹迟晶 on 2021/5/13.
//  Copyright © 2021 com.bytedance. All rights reserved.
//

import Foundation
import MBoxWorkspaceCore
import MBoxContainer
import MBoxDependencyManager

extension MBWorkRepo {
    public func allGemspecPaths() -> [String] {
        var baseNames = [String]()
        if let gemspec = self.setting.gem?.gemspec {
            baseNames.append(gemspec)
        } else {
            for file in self.path.subFiles {
                let filePath = file.lastPathComponent
                if filePath.lowercased().hasSuffix(".gemspec") {
                    baseNames.append(filePath)
                }
            }
        }
        return baseNames.compactMap {
            self.path.appending(pathComponent: $0)
        }.filter { $0.isExists }
    }

    @_dynamicReplacement(for: resolveDependencyNames())
    open func ruby_resolveDependencyNames() -> [(tool: MBDependencyTool, name: String)] {
        var names = self.resolveDependencyNames()
        let data = self.allGemspecPaths().map {
            (
                tool: MBDependencyTool.Gem,
                name: $0.lastPathComponent.fileName
            )
        }
        names.append(contentsOf: data)
        return names
    }
}
