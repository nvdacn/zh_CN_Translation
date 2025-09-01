# NVDA 简体中文翻译

该存储库用于日常维护 NVDA 简体中文翻译。

## 翻译 NVDA 主程序

### 测试翻译

如需测试翻译，请

1. 在 [GitHub 的 Actions](https://github.com/nvdacn/zh_CN_Translation/actions) 页面选择由 [Build NVDA translation test files 工作流](https://github.com/nvdacn/zh_CN_Translation/actions/workflows/build.yaml)触发的操作。

   - alpha 版本请选择与您 NVDA 版本相同分支的操作。
   - beta 版本请选择 Uploads 分支的操作。

2. 在工作流详情的页面，按 T 键导航到 Artifacts 区域的表格。
3. 浏览到 Download NVDA_TranslationTest 并点击，此时将开始下载由 GitHub Actions 自动生成的翻译压缩包。
4. 将下载的压缩文件解压到 NVDA 程序所在文件夹。
5. 重启 NVDA。

**请注意：此页面的文件具有时效性，文件过期后将无法下载。**

### alpha 开发周期的翻译

可在 `version_year.version_major` 分支提前翻译 alpha 开发周期的界面消息、手势、字符以及符号描述，修改或完善现有翻译，以供 alpha 测试。

alpha 开发周期界面消息的翻译字符串将由 GitHub Actions 在满足下列条件时从 NVDA 源代码自动更新：

- 推送到 `version_year.version_major` 分支的提交且修改了 `nvda.po` 文件
- 每天 11:00(UTC)
- 每周一至周五 00:00、03:00、06:00、09:00(UTC)
- 手动在任意分支运行 [Automatically update NVDA.po 工作流](https://github.com/nvdacn/zh_CN_Translation/actions/workflows/CheckPot.yaml)

更新后的nvda.po文件会被提交回 `version_year.version_major` 分支。

由于文档的翻译字符串必须由 NV Access 构建，在 alpha 开发周期将无法翻译。

#### 注意

- `version_year.version_major` 分支名称会随NVDA源代码 `version_year` 和 `version_major` 的值而变化。例：当 `version_year = 2025`、`version_major = 1` 时，该分支名为 `2025.1`。
- 为避免合并到 `Uploads` 分支时累积大量过时提交，NVDA alpha 到达下一开发周期时，该分支将从 `Uploads` 分支重新创建。
该操作将由 GitHub Actions 在更新 alpha 周期界面消息的翻译字符串时自动完成。

### beta 开发周期的翻译

可在  `Uploads` 分支翻译 beta 开发周期的所有翻译。具体注意事项，请参看[自动上传翻译][1]章节。
beta 开发周期的界面消息和文档的翻译字符串可在任意分支手动运行 [Update NVDA Translations from Crowdin 工作流](https://github.com/nvdacn/zh_CN_Translation/actions/workflows/UpdateTranslations.yaml)进行更新，或在本地通过 `L10nUtilTools.bat` 的相关命令更新。
`L10nUtilTools.bat` 的具体使用方法和注意事项，请参看[L10nUtilTools.bat 的使用说明][2]章节。

### 自动上传翻译

当 `Uploads` 分支的翻译被修改时，GitHUB 会自动将其上传到 Crowdin 或在 nvaccess/nvda 存储库的 beta分支创建Pull request，具体根据更改的翻译文件而定。
下面简述该功能的使用步骤和注意事项：

1. 将需要上传的翻译提交或合并到 `Uploads` 分支，并将其推送到远程存储库。

   - 如包含大量提交或无法进行 Fast Forward merge，推荐使用Squash and merge 进行合并，已避免产生过多无用提交。
   - 如需保留提交历史记录，可通过 GitHUB 打开 Pull request，然后使用Squash and merge 进行合并。

2. 等待工作流运行完成。
3. 拉取 `Uploads` 分支到本地仓库，请勿在拉取远程 `Uploads` 分支前向本地 `Uploads` 分支提交新的翻译更改，以避免合并冲突。
4. 当推送 `Translation/miscDeps` 文件夹中的翻译到 `Uploads` 分支时，GitHub Actions 会自动在 nvaccess/nvda 存储库的 beta分支创建Pull request。

   - PR 初始为 Draft 状态，此时仍可向 `Uploads` 分支推送 `Translation/miscDeps` 文件夹中的翻译更改。
   - 当准备让 NV Access 合并这些更改到 NVDA 时，请通知 PR 的作者或 NV Access 将 PR 标记为 Ready for review，在此之后不应再向 `Uploads` 分支推送 `Translation/miscDeps` 文件夹中的翻译更改。

5. 仅可使用该功能上传 NVDA beta 开发周期的翻译。
6. 当 NVDA 的 [beta 发布通道](https://download.nvaccess.org/releases/beta/)有新版本发布时，请通过 Pull request 将 `Uploads` 合并到 `main`。

   - 应以`发布版本号 翻译`（如 `2025.1beta1 翻译`）命名 PR。
   - 应使用 Create a merge commit 进行合并。
   - PR 完成后还需将 `main` 合并回 `Uploads`，以避免合并冲突。

   还可通过在任意分支手动运行 [Sync Uploads and main branches 工作流](https://github.com/nvdacn/zh_CN_Translation/actions/workflows/SyncBranches.yaml)来自动完成上述操作。

7. 当到达 NV Access 宣布的 Translatable string freeze 时间后，除非 NV Access 宣布延长 Translatable string freeze 的时间，否则不应再向 `Uploads` 分支推送任何翻译更改，在此之后如有其他翻译更改，请将其推送到适用于 alpha 开发周期的 `version_year.version_major` 分支。

## 翻译 NVDA 插件

该存储库可自动上传和下载在 [Crowdin 的 nvdaAddons 项目](https://zh.crowdin.com/project/nvdaaddons)中注册的插件的翻译。

- 可在 `version_year.version_major` 分支的 `Translation/Addons` 文件夹提交针对这些插件的翻译。

  - 应以插件 ID 命名存储插件翻译的文件夹。
  - 插件的界面翻译命名为 `nvda.po`。
  - 插件的文档翻译命名为 `readme.xliff`。

- 提交到该存储库的插件翻译会在每天00:00(UTC) 自动更新。
- 还可在任意分支手动运行 [Update Addons Translations from Crowdin 工作流](https://github.com/nvdacn/zh_CN_Translation/actions/workflows/UpdateAddonTranslations.yaml)来新增或更新指定的插件翻译。

  - 留空 Add-on ID 字段会更新该存储库已有插件的翻译。
  - 在 Add-on ID 字段填写特定的插件 ID，如该存储库不包含该插件的翻译，则将其下载到存储库，否则更新该插件的翻译。
  - 如需填写多个插件 ID，多个ID之间使用空格（ ）分隔。

## L10nUtilTools.bat 的使用说明

通过该工具，可快速调用 nvdaL10nUtil 及其他程序对翻译进行处理，主要可

- 生成翻译御览
- 生成翻译测试的压缩包
- 使用给定的 nvda.pot 更新 nvda.po 的翻译字符串。
- 上传已翻译的文件到 Crowdin
- 从 Crowdin 下载已翻译的文件，并支持将其自动提交到您的本地仓库

### 支持的命令

下面简单介绍该工具支持的命令，可通过运行该工具后输入，亦可通过命令行直接传入：

#### 翻译 NVDA 主程序的命令

| 命令 | 作用 |
| --- | --- |
| `GEC` | 生成更新日志的 html 文件。 |
| `GEU` | 生成用户指南的 html 文件。 |
| `GEK` | 生成热键快速参考的 html 文件。 |
| `GEL` | 生成界面翻译的 mo 文件。 |
| `GET` | 生成翻译测试文件（不压缩）。 |
| `GEZ` | 生成翻译测试文件的压缩包。 |
| `UDL`\* | 从给定的 nvda.pot 更新 nvda.po 的翻译字符串。 |
| `UPC` | 上传已翻译的 changes.xliff 文件到 Crowdin。 |
| `UPU` | 上传已翻译的 userGuide.xliff 文件到 Crowdin。 |
| `UPL` | 上传已翻译的 nvda.po 文件到 Crowdin。 |
| `UPA` | 上传所有已翻译的文件到 Crowdin。 |
| `DLC` | 从 Crowdin 下载已翻译的 changes.xliff 文件。 |
| `DLU` | 从 Crowdin 下载已翻译的 userGuide.xliff 文件。 |
| `DLL` | 从 Crowdin 下载已翻译的 nvda.po 文件。 |
| `DLA` | 从 Crowdin 下载所有已翻译的文件。 |
| `DCC` | 从 Crowdin 下载已翻译的 changes.xliff 文件并将其提交到存储库。 |
| `DCU` | 从 Crowdin 下载已翻译的 userGuide.xliff 文件并将其提交到存储库。 |
| `DCL` | 从 Crowdin 下载已翻译的 nvda.po 文件并将其提交到存储库。 |
| `DCA` | 从 Crowdin 下载所有已翻译的文件并将其提交到存储库。 |

#### 翻译 NVDA 插件的命令

| 命令 | 作用 |
| --- | --- |
| `MXX`\* | 使用插件的 readme.md 文档生成可上传的 XLIFF 文件。 |
| `UAP`\* | 上传指定插件的界面翻译到 Crowdin。 |
| `UAX`\* | 上传指定插件的文档翻译到 Crowdin。 |
| `DAP`\* | 从 Crowdin 下载指定插件的界面翻译。 |
| `DAX`\* | 从 Crowdin 下载指定插件的文档翻译。 |

#### 通用命令

| 命令 | 作用 |
| --- | --- |
| `CLE` | 清理翻译 NVDA 主程序和插件命令生成的所有文件。 |
| 其他命令 | 退出本工具。 |

### 注意

- 执行标有 `*` 的命令时，可能需要与该工具进行交互或配置必要的运行环境，请根据提示输入信息或配置运行环境后，该命令才可正确执行。
- `GEC`、`GEU`、`GEK`、`GEL` 命令生成的文件位于 `Preview` 文件夹下，为了兼容 Poedit 的使用习惯，`GEL` 命令还会在 nvda.po 的所在文件夹创建 nvda.mo 的复本。
- `GET` 命令生成的文件位于 `Preview\Test` 文件夹下，这些文件符合 NVDA 的文件结构，可直接复制到 NVDA 程序所在文件夹进行测试。
- `GEZ` 命令生成的压缩包位于 `Preview\Archive` 文件夹下，该压缩包符合 NVDA 的文件结构，可直接解压到 NVDA 程序所在文件夹进行测试。
- `UDL` 命令使用前，需要将用于更新 nvda.po 的 nvda.pot 翻译模板复制到存储库的 `PotXliff` 文件夹，并且该命令会直接替换存储库的原始 nvda.po 文件，因此在执行该命令前，请确保原始文件的翻译更改已提交到存储库。
- `UPC`、`UPU` 和 `UPA` 命令使用前，需要将原始 xliff 文件复制到存储库的 `PotXliff` 文件夹，如未检测到所需文件，系统会从存储库的 `main` 分支提取。
- 从 Crowdin 上传或下载文件时，需要 Crowdin 的个人访问令牌，可从 [Crowdin 的账号设置](https://zh.crowdin.com/settings#api-key)页面创建。

  - 创建令牌时，必须选中译文复选框并授予读写权限。
  - 创建后，请将密钥保存到 `"%Userprofile%\.nvda_crowdin"` 文件中。

- 从 Crowdin 下载的已翻译文件会直接替换存储库的原始文件，在执行下载命令前，请确保原始翻译文件已提交并上传到 Crowdin。
- 下载并提交系列命令只会提交已下载的翻译文件到本地存储库，可手动将其推送到远程仓库或撤销更改。
- 翻译 NVDA 插件系列命令主要供 GitHUB Actions 工作流使用，文档仅作为备注，不对这些命令的使用方法做过多介绍。

### 其他注意事项

1. 该存储库的 `main` 分支用于保存发布版本的翻译以供将文档上传到 Crowdin 时的差异比较，因此除更新发布版本的翻译外，不应向该分支提交任何更改。
2. 请尽量通过该存储库提交 NVDA 简体中文的翻译更改，以避免提交的翻译不慎被自动化流程覆盖的可能。

[1]: #%E8%87%AA%E5%8A%A8%E4%B8%8A%E4%BC%A0%E7%BF%BB%E8%AF%91
[2]: #l10nutiltoolsbat-%E7%9A%84%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E
