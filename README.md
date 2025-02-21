# NVDA 简体中文翻译

该存储库用于日常维护 NVDA 简体中文翻译。

### 翻译测试

如需测试 alpha 或 beta 版本的翻译，请
1. 在 [GitHub 的 Actions](https://github.com/nvdacn/zh_CN_Translation/actions) 页面选择要获取的翻译，推荐选择与您 NVDA 版本相同分支的翻译。
2. 在工作流详情的页面，按 T 键导航到 Artifacts 区域的表格。
3. 浏览到 Download NVDA_TranslationTest 并点击，此时将开始下载由 GitHub Actions 自动生成的翻译压缩包。
4. 将下载的压缩文件解压到 NVDA 程序所在文件夹。
5. 重启 NVDA。

请注意：此页面的文件具有时效性，文件过期后将无法下载。

### 文件生成工具.bat 的使用说明

通过该工具，可快速调用 nvdaL10nUtil 及其他程序对翻译进行处理，主要可
- 生成翻译御览
- 生成翻译测试的压缩包
- 上传已翻译的文件到 Crowdin
- 从 Crowdin 下载已翻译的文件，并支持将其自动提交到此存储库

#### 支持的命令参数

下面简单介绍该工具支持的命令参数，可通过运行该工具后输入，亦可通过命令行直接传入：

| 参数 | 作用 |
| ---- | --------- |
| `C` | 生成更新日志的 html 文件。 |
| `U` | 生成用户指南的 html 文件。 |
| `K` | 生成热键快速参考的 html 文件。 |
| `D` | 生成所有文档的 html 文件。 |
| `L` | 生成界面翻译的 mo 文件。 |
| `T` | 生成翻译测试文件（不压缩）。 |
| `Z` | 生成翻译测试文件的压缩包。 |
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
| `CLE` | 清理上述命令生成的所有文件。 |
| `Build_Translation`、`Upload_nvda`、`Upload_changes` 和 `Upload_userGuide`（仅支持命令行传入 | 这些命令由GitHub Actions 工作流调用，不推荐日常使用。 |
| 其他命令 | 退出本工具。 |

#### 注意

- `C`、`U`、`K`、`D`、`L` 命令生成的文件位于 `Preview`文件夹下。
- `T` 命令生成的文件位于`Preview\Test` 文件夹下，这些文件符合 NVDA 的文件结构，可直接复制到 NVDA 程序所在文件夹进行测试。
- `Z` 命令生成的压缩包位于 `Preview\Archive` 文件夹下，该压缩包符合 NVDA 的文件结构，可直接解压到 NVDA 程序所在文件夹进行测试。
- `UPC`、`UPU` 和 `UPA` 命令使用前，需要将原始 xliff 文件复制到存储库的 `Crowdin\OldXLIFF` 文件夹，如未检测到所需文件，系统会从存储库的 `main` 分支提取。

