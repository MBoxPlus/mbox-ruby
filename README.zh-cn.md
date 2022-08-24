# MBox Ruby

其他语言：[English](./README.md)

MBox 的 Ruby 插件，提供 Ruby 环境支持，同时提供 Bundler 依赖管理能力。

该插件给整个 Workspace 提供了一个 `Gemfile`，该 `Gemfile` 不可修改，会自动加载容器的 `Gemfile`。

## Command

### mbox bundle

在 MBox 环境下执行 `bundle` 命令，会直接使用 Workspace 根目录下的 `Gemfile` 文件，因此该命令和其他衍生命令都可以在任意子目录下执行，不会搜索执行目录的 `Gemfile`，可以放心在任意子目录执行。

```shell
$ mbox status
  Feature: FreeMode
     mbox-test   git@xx.com:xx/xx.git   [master]
  Container:
  => mbox-test   Bundler

$ mbox bundle install
# 安装 mbox-test 容器的 Gemfile 依赖
```

## Launcher

该插件携带了一个 Launcher 脚本 `Bundler`，会在首次安装插件的时候，自动安装 Bundler 配置，将 Bundler Gem 安装路径修改为 `~/.bundle/vendor`，目的是避免将 Gem 安装到系统等其他无权限的路径。

## Hook

该插件提供了 Bundler 依赖管理能力：

1. [MBoxContainer] 通过 Gemfile 识别 Bundler 容器
1. [MBoxDependencyManager] 通过 gemspec 识别 Bundler 组件

## Dependency

该插件只能在 Workspace 下生效

依赖的 MBox 组件：

1. MBoxCore
1. MBoxWorkspace
1. MBoxContainer
1. MBoxDependencyManager

## 激活插件

1. 在 Workspace 层级上激活：
```
$ mbox plugin enable ruby
```

2. 在 仓库 层级上激活，可以同步给其他拥有该仓库的研发人员：

   修改仓库根目录的 `.mboxconfig` 文件，新增配置：
```
{
   "plugins": {
      "MBoxRuby": {}
   }
}
```

## 快速接入

### 主项目/Container 接入

1. 在主项目根目录下有 `Gemfile` 则自动识别为 Bundler 容器
1. 如果 `Gemfile` 文件不在项目根目录，需要在项目根目录下 `.mboxconfig` 配置文件中新增配置：

```json
{
   "ruby": {
      "gemfile": "xxx/Gemfile"
   }
}
```

### 组件/Gem 接入

1. 该插件会自动搜索项目根目录下的 `*.gemspec` 文件
1. 如果 `gemspec` 文件不在根目录，需要在项目根目录下 `.mboxconfig` 配置文件中新增配置：

```json
{
    "ruby": {
        // 只有一个 gemspec 文件
        "gemspec": "xx/yy.gemspec",

        // 使用通配符配置所有 gemspec
        "gemspec": "xx/*.gemspec",

        // 当存在多个 gemspec 文件，可以使用以下形式
        "gemspecs": [
            "xx/yy1.gemspec",
            "xx/yy2.gemspec"
        ]
    }
}
```

如果项目既是 Container 又是 Gem，则需要同时设置上述配置。

## Contributing
Please reference the section [Contributing](https://github.com/MBoxPlus/mbox#contributing)

## License
MBox is available under [GNU General Public License v2.0 or later](./LICENSE).
