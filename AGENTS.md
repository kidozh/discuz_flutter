# 发布约定

## TestFlight 更新说明

- 每次已获用户授权的 iOS / TestFlight 发布，都必须为该构建填写 TestFlight 的“测试内容 / What to Test”更新说明。这是发布任务的一部分，无需另行请求确认文案。
- 发布前更新 `docs/testflight-release-notes.txt`。首行必须为 `版本号 (构建号)`，与实际 IPA 的 `CFBundleShortVersionString`、`CFBundleVersion` 一致。
- 使用简体中文，简要列出本次相较上一个 TestFlight 构建新增、修复和优化的内容，优先写用户能感知的变化；按需补充重点测试项和已知限制。不能只写“修复已知问题”，也不能把未打包的功能或未经验证的问题写成已完成。
- 上传前运行 `python3 scripts/prepare_testflight_notes.py`。构建号有覆盖时传入实际 `--build-number`；校验失败先修正文案。工作流手动输入的说明替代文件内容，不能拼接旧版本说明。
- CI 上传必须传入生成后的 `release-notes` 并等待 Apple 处理。通过 Xcode、Transporter 或其他本地方式上传时，也必须在 App Store Connect 为同一个版本和构建号补填同一份说明，或通过 `betaBuildLocalizations.whatsNew` 写入。
- 上传后核对该构建的 TestFlight 说明与文案一致，再报告发布完成。若构建还在处理或说明写入失败，应继续处理并如实报告剩余步骤，不能仅凭 IPA 上传成功就声称整个发布已完成。
