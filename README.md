# NVDA 简体中文翻译

该存储库用于集中管理 NVDA 主程序及插件的简体中文翻译，以实现近似于原 SVN 翻译系统的体验。

有关如何翻译 NVDA 的更多信息，请参看 [NVDA 开发者指南（英语）](https://download.nvaccess.org/documentation/developerGuide.html)的 [Translation](https://download.nvaccess.org/documentation/developerGuide.html#translation) 章节。

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

### 存储库文件结构介绍

此存储库根目录所包含的文件和文件夹的作用简述如下：

- `.github`：用于存储 GitHUB 相关的文件，如工作流文件、PR 模板文件等；
- `PotXliff`：用于供 L10nUtilTools.bat 存储临时文件，有关详细信息，请参看[L10nUtilTools.bat 的使用说明][2]章节；
- `Preview`：用于存储 L10nUtilTools.bat 生成的翻译预览文件以及将 MD 转换为 XLIFF 的原始 Markdown 文件，有关详细信息，请参看[L10nUtilTools.bat 的使用说明][2]章节；
- `Tools`：用于存储 L10nUtilTools.bat 所调用的工具和存储库源代码或其链接；
- `Translation`：用于存储所有需要翻译的文件，这也是主要的工作文件夹，其中

  - `Translation\Addons` 用于存储插件的翻译文件，每个插件的翻译均存储在以插件 ID 命名的子文件夹中；
  - `Translation\LC_MESSAGES` 用于存储 NVDA 界面消息的翻译文件，有关翻译该文件的方式和注意事项请参看 [Translating NVDA's interface（英语）](https://github.com/nvaccess/nvda/blob/master/projectDocs/translating/crowdin.md#translating-nvdas-interface)；
  - `Translation\miscDeps` 用于存储 NVDA 的字符描述、手势配置和符号朗读规则文件，有关翻译这些文件的方式和注意事项请参看[NVDA 开发者指南（英语）](https://download.nvaccess.org/documentation/developerGuide.html)的 [Character Descriptions](https://download.nvaccess.org/documentation/developerGuide.html#characterDescriptions)、[Gestures](https://download.nvaccess.org/documentation/developerGuide.html#TranslatingGestures) 和 [Symbol Pronunciation](https://download.nvaccess.org/documentation/developerGuide.html#symbolPronunciation) 章节；
  - `Translation\user_docs` 用于存储 NVDA 的更新日志和用户指南的 XLIFF 文件，有关翻译这些文件的方式和注意事项请参看 [Translating User Documentation（英语）](https://github.com/nvaccess/nvda/blob/master/projectDocs/translating/crowdin.md#translating-user-documentation)；

- `.gitattributes` 和 `.gitignore`：用于配置 Git 的必要文件；
- `L10nUtilTools.bat`：用于处理翻译的批处理脚本，具体使用方法和注意事项，请参看[L10nUtilTools.bat 的使用说明][2]章节。
- `LICENSE`：许可协议文件。
- `README.md`：此说明文档。

### alpha 开发周期的翻译

可在 `version_year.version_major` 分支提前翻译 alpha 开发周期的界面消息、字符描述、手势配置以及符号朗读规则，修改或完善现有翻译，以供 alpha 测试。

alpha 开发周期界面消息的翻译字符串将由 GitHub Actions 在满足下列条件时从 NVDA 源代码自动更新：

- 推送到 `version_year.version_major` 分支的提交且修改了 `nvda.po` 文件
- 每天 11:00(UTC)
- 每周一至周五 00:00、03:00、06:00、09:00(UTC)
- 手动在任意分支运行 [Automatically update NVDA.po 工作流](https://github.com/nvdacn/zh_CN_Translation/actions/workflows/CheckPot.yaml)

更新后的nvda.po文件会被提交回 `version_year.version_major` 分支。

由于文档的翻译字符串必须由 NV Access 构建，因此在 alpha 开发周期将无法更新，仅可对现有翻译进行改进。

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

- 提交到该存储库的插件翻译会在每天05:00(UTC) 自动更新。
- 还可在任意分支手动运行 [Update Addons Translations from Crowdin 工作流](https://github.com/nvdacn/zh_CN_Translation/actions/workflows/UpdateAddonTranslations.yaml)来新增或更新指定的插件翻译。

  - 留空 Add-on ID 字段会更新该存储库已有插件的翻译。
  - 在 Add-on ID 字段填写特定的插件 ID，如该存储库不包含该插件的翻译，则将其下载到存储库，否则更新该插件的翻译。
  - 如需填写多个插件 ID，多个ID之间使用空格（ ）分隔。

## L10nUtilTools.bat 的使用说明

通过该工具，可快速调用 nvdaL10nUtil 及其他程序对翻译进行处理，主要可

- 生成 NVDA 主程序的翻译御览
- 生成 NVDA 主程序的翻译测试压缩包
- 使用给定的 nvda.pot 更新 NVDA 主程序的界面消息翻译字符串
- Markdown 和 XLIFF 的互转换
- 上传已翻译的文件到 Crowdin
- 从 Crowdin 下载已翻译的文件，并支持将 NVDA 主程序的翻译文件自动提交到您的本地仓库

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
| `GMC` | 生成更新日志的 Markdown 文件。 |
| `GMU` | 生成用户指南的 Markdown 文件。 |
| `MHC` | 从先前创建的 Markdown 文档生成更新日志的 html 文件。 |
| `MHU` | 从先前创建的 Markdown 文档生成用户指南的 html 文件。 |
| `MXC`\* | 从先前创建的 Markdown 文档生成更新日志的 xliff 文件。 |
| `MXU`\* | 从先前创建的 Markdown 文档生成用户指南的 xliff 文件。 |
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
| `GMX`\* | 使用指定插件的 readme.xliff 生成 Markdown 文件。 |
| `MXX`\* | 使用指定插件的 readme.md 文档生成可上传的 XLIFF 文件。 |
| `UAP`\* | 上传指定插件的界面翻译到 Crowdin。 |
| `UAM`\* | 上传指定插件的文档翻译到 Crowdin。 |
| `DAP`\* | 从 Crowdin 下载指定插件的界面翻译。 |
| `DAM`\* | 从 Crowdin 下载指定插件的文档翻译。 |

#### 通用命令

| 命令 | 作用 |
| --- | --- |
| `CLE` | 清理翻译 NVDA 主程序和插件命令生成的所有文件。 |
| `help` | 显示可用命令。 |
| 其他命令 | 退出本工具。 |

### 注意

- 执行标有 `*` 的命令时，可能需要与该工具进行交互或配置必要的运行环境，请根据提示输入信息或配置运行环境后，该命令才可正确执行。
- `GEC`、`GEU`、`GEK`、`GEL`、`MHC`、`MHU` 命令生成的文件位于 `Preview` 文件夹下，为了兼容 Poedit 的使用习惯，`GEL` 命令还会在 nvda.po 的所在文件夹创建 nvda.mo 的复本。
- `GET` 命令生成的文件位于 `Preview\Test` 文件夹下，这些文件符合 NVDA 的文件结构，可直接复制到 NVDA 程序所在文件夹进行测试。
- `GEZ` 命令生成的压缩包位于 `Preview\Archive` 文件夹下，该压缩包符合 NVDA 的文件结构，可直接解压到 NVDA 程序所在文件夹进行测试。
- `GMC`、`GMU` 命令生成的文件位于 `Preview\Markdown` 文件夹下。
- `MXC`、`MXU` 命令使用前需要根据 [创建 NVDA 开发环境（英语）](https://github.com/nvaccess/nvda/blob/master/projectDocs/dev/createDevEnvironment.md)文档准备 NVDA 本地代码仓库并配置 Python 环境。

  准备必须环境后，通过上述命令即可以 NVDA 本地代码仓库当前分支的 `user_docs\en` 中的相应 xliff 文件为模板生成所需 xliff 文件。

  生成的文件会直接替换存储库的原始 xliff 文件以便于将其上传到 Crowdin，因此在执行该命令前，请确保原始文件的翻译更改已提交到存储库。

  由于该命令生成的 xliff 文件与从 Crowdin 获取文件的缩进不同，因此请勿将使用该命令生成的文件直接提交到本存储库，可先在本地上传该文件到 Crowdin，随后再从 Crowdin 下载该文件并提交。
- `UDL` 命令使用前，需要将用于更新 nvda.po 的 nvda.pot 翻译模板复制到存储库的 `PotXliff` 文件夹，并且该命令会直接替换存储库的原始 nvda.po 文件，因此在执行该命令前，请确保原始文件的翻译更改已提交到存储库。
- `UPC`、`UPU` 和 `UPA` 命令使用前，需要将原始 xliff 文件复制到存储库的 `PotXliff` 文件夹，如未检测到所需文件，系统会从存储库的 `main` 分支提取。
- 从 Crowdin 上传或下载文件时，需要 Crowdin 的个人访问令牌，可从 [Crowdin 的账号设置](https://zh.crowdin.com/settings#api-key)页面创建。

  - 创建令牌时，必须选中译文复选框并授予读写权限。
  - 创建后，请将密钥保存到 `"%Userprofile%\.nvda_crowdin"` 文件中。

- 从 Crowdin 下载的已翻译文件会直接替换存储库的原始文件，在执行下载命令前，请确保原始翻译文件已提交并上传到 Crowdin。
- 下载并提交系列命令只会提交已下载的翻译文件到本地存储库，可手动将其推送到远程仓库或撤销更改。
- 翻译 NVDA 插件系列命令使用前需要在本地克隆 [CrowdinRegistration 存储库](https://github.com/nvdaaddons/CrowdinRegistration)并安装 [uv](https://github.com/astral-sh/uv#installation)，如已配置 NVDA Python 运行环境，则无需再次手动安装 uv。
- `MXX` 命令使用前需要将指定插件的 `readme.md` 文档复制到 `Preview\Markdown` 文件夹下，随后通过该命令即可以 CrowdinRegistration 本地代码仓库当前分支的相应插件文档的 xliff 文件为模板生成所需 readme.xliff 文件。

  生成的文件会直接替换存储库的原始 xliff 文件以便于将其上传到 Crowdin，因此在执行该命令前，请确保原始文件的翻译更改已提交到存储库。

  由于该命令生成的 xliff 文件与从 Crowdin 获取文件的缩进不同，因此请勿将使用该命令生成的文件直接提交到本存储库，可先在本地上传该文件到 Crowdin，随后再从 Crowdin 下载该文件并提交。

## 其他注意事项

1. 该存储库的 `main` 分支用于保存发布版本的翻译以供将文档上传到 Crowdin 时的差异比较，因此除更新发布版本的翻译外，不应向该分支提交任何更改。
2. 请尽量通过该存储库提交 NVDA 简体中文的翻译更改，以避免提交的翻译不慎被自动化流程覆盖的可能。
3. 该存储库的部分工作流的正常运行依赖于指定的存储库[变量](https://docs.github.com/actions/learn-github-actions/variables#creating-configuration-variables-for-a-repository)和[机密](https://docs.github.com/actions/automating-your-workflow-with-github-actions/creating-and-using-encrypted-secrets#creating-secrets-for-a-repository)。
   Fork 该存储库时，只有正确设置这些变量和机密，相应的工作流才能正常运行。
   这些变量和机密的名称、值、影响的工作流及作用如下：

   | 类型 | 名称 | 值 | 影响的工作流 | 作用 |
   | --- | --- | --- | --- | --- |
   | 变量 | Run_NVDA_Translations_Workflow | 任意内容 | `PullRequestToNVDA.yaml`、`UpdateTranslations.yaml`、`Upload.yaml` | 控制这些工作流是否运行，当此变量不存在时，这些工作流将被跳过 |
   | 变量 | Run_CheckPot_Workflow | 任意内容 | `CheckPot.yaml` | 控制该工作流是否运行，当此变量不存在时，该工作流将被跳过 |
   | 变量 | Run_Addon_Translations_Workflow | 任意内容 | `UpdateAddonTranslations.yaml`、`UploadAddonTranslations.yaml` | 控制这些工作流是否运行，当此变量不存在时，这些工作流将被跳过 |
   | 机密 | NVDA_CROWDIN | 具有译文读写权限的 [Crowdin 个人访问令牌](https://zh.crowdin.com/settings#api-key) | `UpdateAddonTranslations.yaml`、`UpdateTranslations.yaml`、`Upload.yaml`、`UploadAddonTranslations.yaml` | 从 Crowdin 上传和下载翻译时验证身份 |
   | 机密 | PULLREQUESTTONVDA | 具有 public_repo 和 workflow 权限的 [GitHUB Personal Access Tokens (Classic)](https://github.com/settings/tokens/new) | `PullRequestToNVDA.yaml` | 在 nvaccess/nvda 存储库创建 PR 时验证身份 |

[1]: #%E8%87%AA%E5%8A%A8%E4%B8%8A%E4%BC%A0%E7%BF%BB%E8%AF%91
[2]: #l10nutiltoolsbat-%E7%9A%84%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E
