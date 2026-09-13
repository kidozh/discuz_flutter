# Discuz X3.5 掌上论坛功能接入

本批实现以下入口，沿用当前账号的 Cookie 会话，接口版本请求为 4（官方插件按模块回退到可用版本）。

| 功能 | App 入口 | 接口与字段 |
| --- | --- | --- |
| 推荐/不推荐主题 | 登录后在首帖下方显示大拇指按钮 | `threadrecommend`，`do=add/sub`、`hash`；显示 `thread.recommend_add/recommend_sub`、`thread.recommend` |
| 我的主题/回复 | 自己的个人资料页主题/帖子统计 | `mythread&type=thread/reply&page=N` |
| 全部点评 | 楼层点评下方 | `viewcomment&tid&pid&page`；读取 `comments[pid]`，按 `count` 判断总量；`commentcount` 显示入口数量 |
| 购买主题 | 付费主题页 | `forum_threadpay` 决定入口；`buythread` 先获取报价，再提交 `paysubmit=yes`、`formhash` |
| 购买附件 | 未购买附件卡片及正文购买链接 | `attachments.price/payed`；`buyattachment&tid&aid`，仅购买所选附件 |

## 官方接口约束

- `mythread` 只支持当前登录用户。查看他人的主题和回复保留网站入口。
- `type=reply` 返回参与过的主题列表，不返回自己的回复正文或 PID，因此打开主题，不伪造楼层定位。分页直到返回空页，不能根据主题条数小于每页帖子数就提前结束。
- `viewcomment.totalcomment` 是汇总评分 HTML，不是总条数。点评允许数值键对象或数组；分页追加时按 ID 去重，失败后保留已有内容并重试同一页。
- 报价 `balance` 是购买后的余额。报价必须有正整数价格、有效余额、积分名称和提交所需 formhash。确认后重新读取报价，价格、余额或积分种类变化时再次确认。
- 购买和推荐只接受明确的成功消息码。网络异常不自动重试提交；结果不明时提示先刷新。已购买/已推荐响应触发刷新，不再次提交。
- 确认期间切换账号会取消提交。购买链接必须匹配当前论坛的来源和安装路径。服务器仍负责权限、库存/积分及交易原子性；报价与扣款间的并发修改无法由这版接口以客户端价格条件锁定。

## 核对来源

[Discuz 官方 v3.5 mobile 插件](https://gitee.com/Discuz/DiscuzX/tree/v3.5/upload/source/plugin/mobile)：
`api/1/{threadrecommend,mythread,buythread,buyattachment}.php`、`api/4/{viewthread,viewcomment}.php`。
同时核对 `source/module/forum/forum_misc.php`、`forum_guide.php` 与 `source/class/discuz/discuz_application.php` 的表单参数合并和消息码。

自动化覆盖见 `test/forum_interactions_test.dart`，包括报价字段、提交参数、失败码、缓存往返、购买链接范围、取消购买、重新确认、账号切换、点评分页失败恢复及去重。没有向真实论坛提交推荐或扣除积分；上线前仍需在测试站点做端到端验收。

点评数量优先使用 `commentcount[pid]`；明确为 0 时隐藏全部点评入口，缺失时回退到已有点评条数。反馈按钮只出现在 `post.first` 的首帖后，未登录隐藏；已反馈禁用两个方向，避免重复提交。

## 头像与悬赏采纳

- 自己的个人资料页新增“更换头像”：选图、预览并点击上传。客户端将图片转换为最多 512 像素边长的 PNG，重新读取登录用户 profile 的 formhash，使用 `uploadavatar` 的 `Filedata` multipart 字段提交。成功判断以 `Variables.uploadavatar == api_uploadavatar_success` 为准，UCenter 等错误不得按 HTTP 200 判成功；成功后刷新头像缓存和资料。
- 未解决悬赏帖（`thread.special=3` 且 `price>0`）的楼主可以在其他用户的回复下选择最佳答案。普通帖子、自己的回复、游客和已解决悬赏不显示按钮。此入口面向楼主，版主代采纳的悬赏过期策略继续由网站处理。
- `bestanswer` 会结算悬赏，操作前展示确认。确认后通过 `viewthread&viewpid=pid` 重新读取帖子及悬赏，校验目标、权限、金额与登录身份，再 POST `tid`、`pid`、`bestanswersubmit=yes`、`formhash`。只有 `reward_completion` 视为成功；同一账号同一主题不并发采纳，网络异常不自动重试写入。
- `mythread` 沿用已接入的个人资料“主题/帖子”入口。

上述能力已按官方 `api/2/uploadavatar.php`、`api/4/bestanswer.php` 和 `forum_misc.php` 核对；真实站点上传及悬赏结算仍需端到端验证。

## 六项新增功能

| 功能 | App 入口 | 官方模块 |
| --- | --- | --- |
| 好友列表 | 自己的个人资料页，点击好友可查看资料 | `friend`，按 `count` 分页 |
| 热门版块 | 论坛首页 | `hotforum`，游客可浏览 |
| 发布投票帖 | 发帖页添加/编辑投票 | `newthread`，投票选项、可选数量和有效天数随草稿保存 |
| 更多版主管理 | 帖子菜单“管理主题” | `topicadmin`，置顶/取消、精华/取消、关闭/打开、移动、高亮/取消 |
| 活动报名 | 活动帖信息卡 | `forummisc?action=activityapplies`，报名与取消报名 |
| 置顶帖入口 | 版块菜单“置顶主题” | `toplist`，传入当前 `fid`，游客可浏览 |

- 热门版块与置顶主题使用服务器返回的缓存列表，不按客户端分页重复加载。
- 发布投票前通过 `newthread&special=1` 检查权限；提交前重新读取发帖凭证。服务器仍负责站点投票数量上限和用户组权限。
- 管理操作需要填写理由并确认，提交前重新读取版主身份与 formhash。移动主题同时提供目标版块和分类选择；只接受 `admin_succeed` 为成功。
- 活动报名支持文本、长文本、单选和多选资料字段；文件等无法可靠适配的资料表单提供网站入口。提交前重新读取费用、积分和报名字段，发生变化时要求刷新。仅明确的报名/取消成功码视为成功，网络异常不自动重试。
- 参数核对补充覆盖 `source/include/topicadmin/topicadmin_moderate.php`、`source/class/extend/extend_thread_poll.php` 和 `forum_misc.php` 的活动报名分支。

`test/discuz_six_features_test.dart` 覆盖列表访问与分页、投票参数及草稿序列化、管理操作编码与身份复核、活动字段与费用变化、确认取消以及成功提交。自动化使用模拟服务端响应，未对真实论坛执行发帖、管理或活动费用扣除。

## 索引推荐与最新帖子筛选

- 索引页顶部只显示 `hotforum` 返回的前 4 个热门版块，位于 SafeArea 内，复用下方版块分区和版块卡片的样式。进入页面自动读取，下拉刷新时更新；不请求或显示热帖。
- 设置中的“最新帖子的版块”支持下拉切换已添加的论坛，通过 `forumindex` 动态获取目录，多账号站点可切换账号。勾选和全选/全不选均即时保存，不需要确认。选择按站点和账号保存，记录手动取消的版块；此前未出现的新板块默认选中，暂时消失后重新出现的已取消版块仍保持不选。全不选只取消当前已知版块，不发送空 `fids` 请求。旧版白名单根据此前缓存的目录迁移。
- 目录缓存有效期为 10 分钟，设置页每次进入主动刷新；网络失败时可回退到一天以内的同账号目录。最新帖子按选中项与当前目录的交集生成 `fids`。
- 首屏帖子缓存保存 30 分钟，读取时核对账号、站点、完整 `fids`，随后请求新数据。修改筛选会清除首屏缓存和分页状态；不同账号的数据不会混用。

## 看板与常规设置

- “最新帖子的版块”保留论坛选择、即时保存及联排的全选/全不选按钮。选择控件使用对应平台外观，两个设置入口归入“常规”。
- “看板顺序”拖动后立即保存，Material 标签页与 iOS 分段控件使用同一顺序。排序页仅在已添加 `keylol.com`（或 `www.keylol.com`）时提供其乐头条；其乐内容仍仅在当前论坛为其乐时显示，避免使用其他站点的会话或帖子编号。
- 当前选择为空时，最新帖子和热门帖子展示前往版块设置的入口；热门接口本身不按非空的 `fids` 子集筛选。设置变更后页面重新加载。
