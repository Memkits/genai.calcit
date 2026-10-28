# Google GenAI — Calcit bindings

面向 `@google/genai` 的 Calcit JavaScript 绑定，包含 Node 脚本和独立 Web 音频转录示例。

## Calcit 0.32.0 迁移候选：使用者影响

CLI/procs 配对正式 0.32.0，需要重新安装依赖、生成 Node/Web 产物并刷新。
Respo 0.17.0、UI 0.9.0 当前使用本地候选，JS-FFI 为 0.2.8；正式标签整图待验收。
Google SDK、模型、API 版本和公开 Option/Struct 合同保持不变，不发布 tag/npm。

官方工具转换 165 处旧类型写法，111 个定义 schema 保持；保留全部原门禁，
不新增强转、Dynamic 或测试脚手架。取消过期 procs 单包安装豁免，使用一小时
发布年龄门禁。仅执行原离线断言，不读取真实 API key、不创建真实客户端、
不调用模型服务或上传音频；离线验收不证明真实服务可用性。

本轮完整 strict、Node 入口、Web 全量与双目标公共 SDK 检查、原离线配置断言、
Node/Web 构建及 immutable 安装通过；独立评审无待处理问题。
正式标签整图和远端 CI 尚待验证，没有运行默认 Node 示例或音频上传。

## Calcit 0.31.0：使用者影响

CLI 与 `@calcit/procs` 配对正式 0.31.0，UI/Respo 使用已发布的
0.9.0-alpha.4 / 0.17.0-alpha.4，JS-FFI 0.2.7，传递 Router 0.9.0-alpha.3。
UI 依赖仍是 alpha；请重新安装完整依赖图、生成 JS 并刷新页面。
Google SDK、模型和 API 版本保持不变。

三处嵌套响应读取适配 `get-in` 的 Result/PathError 合同：缺失路径返回原来的 None，
错误的中间数据形状抛出错误，不伪装成缺失；公开 Option/Struct 返回类型不变。
三个入口显式绑定 Respo dispatch 的 Enum 合同，Web 的原空回调仍忽略事件。
保留 Node/Web/公共 SDK 和完整 strict 门禁，没有新增 Dynamic、强转或放宽预算。
离线断言和合成响应不能证明真实 Google 服务或音频上传效果。

## 此前公开 List 折叠方法：使用者影响

共享字段筛选函数改用公开 `.fold`，不直接调用内部 `foldl`。字段顺序、缺失/nil
省略行为及 false/0 保留行为不变；配置、结果 Struct/Option、三个入口和公开接口无需适配。
本轮不升级 Google SDK、模型、工具链或依赖，不删除真实 JS 信任边界；仍配对正式 0.30.1。
沿用原离线断言、Node/Web/公共 SDK 与完整 strict 门禁，不添加测试脚手架或预算。
离线验收不读取 API key、不调用真实 Google 服务、不上传文件；最终 PR CI 以实际运行结果为准，
不代表已合并、发版或部署生产。

## 此前 Option 方法写法：使用者影响

在既有正式 0.30.1 图上，将 UI 事件默认值、Node 环境变量与 SDK 消息字段查询中的
五处 `option:unwrap` / `option:unwrap-or` 改为 `.unwrap` / `.unwrap-or`。
仅修改调用头，保留参数、默认值、缺失值行为、公开类型和三个入口；不升级 SDK、模型或依赖。
原离线断言、Node/Web 检查、公共 SDK 检查、完整 strict 与构建通过，
但离线断言不直接执行这五处 UI/环境变量/消息转换路径，不代表真实 Google 服务或音频上传验收。
不新增验证脚本或工作流，不合并、部署或发版。

## 此前正式 0.30.1 配对

CLI / `@calcit/procs` 配对正式 **0.30.1**，直接依赖固定为已发布的 UI 0.8.0、
Respo 0.16.124、JS-FFI 0.2.5，Router 0.8.37 为传递依赖。
请重新安装整张图、生成 JS 并完整刷新，不混用 alpha 缓存；UI 升级可能有样式差异，
不承诺逐像素相同。SDK 依赖及锁定结果、模型和 API 版本均保持不变。
构建工具从旧 Vite 8.0.3 升级到正式 8.3.5；其 Rolldown 传递依赖随 lock 更新，
不为旧 WASM 可选后端的 peer 警告额外添加业务依赖。

此前配对未修改应用 Snapshot、公开 Option/Struct 合同、离线请求/响应断言或 Node/Web/test-config
三入口。保留双 target 和公共 SDK 门禁，CI 显式启用 fail-fast/pipefail，不新增验证脚本、
预算、强转或 concurrently。COS 仅使用 action 自带 verify，部署路径不变。
不配置密钥、不调用 Google/付费 API、不上传音频到远端，不合并、部署或发版。

## 历史：此前已合并的 Option 与 SDK 合同迁移

此前源码迁移使用 0.30.1-alpha.4 配对 Respo 0.16.122、UI 0.7.41、JS-FFI 0.2.3；
旧验收不代表本轮正式图已通过。

这是有调用方影响的类型迁移，不能按旧的 nil/Map/JS 属性写法直接使用：

- 配置可选字段和可选配置参数使用 `Option`。缺失的 Option 字段可省略；显式值使用 `Option :some value`。
- `Some false` / `Some 0` 保留；None 在 SDK 请求中省略，不作为 Enum 数组发送。
- `interactions-create!` / `interactions-get!` 返回真实 `InteractionResult` Struct，状态是 `InteractionStatus` Enum，不是原始 JS 字符串。
- `models-count-tokens!` 返回 `CountTokensResponse` Struct，`:totalTokens` 是 `Option<Number>`，SDK 未提供计数时是 None。
- `chat-get-history` 返回 `List<ChatHistoryTurn>`；`chats-create` 的 history 参数使用 `Option<List<ChatHistoryTurn>>`，由专门序列化器发送。
- `extract-text`、`extract-image-bytes`、`ExtractedInteractionOutput.text` 和 `StreamChunkOutput.text` 返回 `Option<String>`。
- `make-search-tools` 返回 `Option<List<Map<Tag, Dynamic>>>`，可直接作为 ContentConfig.tools；不是 JS 数组或 nil。

项目迁移的 CI / 实际消费者验收完成前保留 draft，不发布或部署。进度与合同说明见 [#8](https://github.com/Memkits/genai.calcit/issues/8)。

## 安装、构建与门禁

```bash
caps --strict --ci
yarn install --immutable
caps deps.cirru verify --toolchain
yarn test:config
yarn compile       # 默认 Node 脚本入口
yarn compile:web   # 独立 browser 入口
yarn build
yarn dev           # Web
yarn watch         # 独立 Web 编译监听
```

源码仅维护 `calcit.cirru` / `deps.cirru`，不恢复 compact.cirru/package.cirru，不提交 js-out。
Node 检查默认可达入口和全部公共 SDK；Web 检查所有项目定义及全部公共 SDK。
一次 `calcit fix --workflow strict --verify` 覆盖 default/test-config/web 三个入口。
Node 不强行检查浏览器 DOM 定义，但 Web 全量门禁不能删除。

`yarn test:config` 复用单一离线入口，覆盖请求的 false/0、省略字段、systemInstruction，
以及交互结果 Struct/状态/文本/usage、零 token、history 序列化和搜索未启用的情况。
不读取真实密钥，不创建真实 Google 客户端，不上传文件或调用付费 API。
真实服务的权限、模型可用性、网络和音频转录效果不在离线验收范围内。

## Node 脚本与 Web 示例

默认脚本读取 GEMINI_API_KEY，GEMINI_BASE_URL 可选。只有以下显式命令会执行实际脚本请求：

```bash
yarn compile
node --input-type=module -e 'import("./js-out/genai.main.mjs").then(m => m.main_$x_())'
```

根目录 `main.mjs` 是 Web bootstrap，不能当作 Node 脚本运行。
Web 示例保留原音频选择与转录流程；通过已有的 window.GEMINI_API_KEY 边界取得密钥。
浏览器密钥会暴露给页面使用者，只适合本地/受控 Demo，不应把生产密钥写入仓库或公开构建。
未配置密钥时显示 Missing GEMINI_API_KEY，不发送请求。此次没有升级示例原有模型。

## Calcit API 示例

以下片段放在具有 `:js-ffi` 功能的函数中；含 js-await 的函数也需声明 `:async true`。

### 创建并继续交互

```cirru
let
    client $ sdk/new-client api-key
    generation $ sdk/GenerationConfig :temperature $ Option :some 0
    params $ sdk/CreateParams :model |gemini-2.5-flash :input "|Explain how AI works." :background (Option :some false) :generation-config (Option :some generation)
    interaction $ js-await $ sdk/interactions-create! client params
    result $ sdk/extract-outputs interaction
    follow-params $ sdk/CreateParams :model |gemini-2.5-flash :input "|Tell me more." :previous-interaction-id (Option :some (:id interaction))
  println $ .unwrap-or (:text result) |
  println $ :status result
  js-await $ sdk/interactions-create! client follow-params
```

Struct 用 `(:field value)` 读取，不用 get 或 JS 的 .-field。

### 查询、取消与删除

```cirru
let
    interaction $ js-await $ sdk/interactions-get! client interaction-id
  println $ :status interaction

js-await $ sdk/interactions-cancel! client interaction-id
js-await $ sdk/interactions-delete! client interaction-id
```

### 内容请求与工具

```cirru
sdk/generate-content! client $ sdk/ContentConfig :model |gemini-2.5-flash :contents |hello :system-instruction (Option :some |system) :tools (sdk/make-search-tools true false)
```

systemInstruction 序列化到 SDK 的 config 内，而不是请求顶层。

### 客户端、计数与历史

```cirru
let
    client $ sdk/new-client-with-options $ sdk/ClientOptions :api-key $ Option :some api-key
    tokens $ js-await $ sdk/models-count-tokens! client |gemini-2.5-flash ([] |Hello) (Option :none)
    chat $ sdk/chats-create client |gemini-2.5-flash (Option :none) (Option :none)
    history $ sdk/chat-get-history chat
  println $ :totalTokens tokens
  sdk/chats-create client |gemini-2.5-flash (Option :none) (Option :some history)
```

### 文件与缓存

```cirru
let
    upload-config $ sdk/UploadFileConfig :mime-type $ Option :some |text/plain
    cache-config $ sdk/CreateCachedContentConfig :display-name (Option :some |sample-cache) :contents (Option :some ([] "|Summarize this file later"))
    file $ js-await $ sdk/files-upload! client |./notes.txt (Option :some upload-config)
    cache $ js-await $ sdk/caches-create! client |gemini-2.5-flash (Option :some cache-config)
  println file
  println cache
```

文件、缓存、模型元数据及异构原生 SDK 返回值仍是有意保留的 FFI Dynamic 边界；
本次没有把未建模的服务响应伪装成 Struct。按需要在真实使用位置检查/解码。

## 结果合同

| API / 类型 | 合同 |
| --- | --- |
| interactions-create! / interactions-get! | InteractionResult；id String，status InteractionStatus，outputs Option<List<Map<Tag, Dynamic>>> |
| extract-outputs | ExtractedInteractionOutput；text Option<String>，function-calls List<FunctionCallContent>，interaction-id String，status InteractionStatus |
| models-count-tokens! | CountTokensResponse；totalTokens Option<Number>，sdkHttpResponse Option<Dynamic> |
| chat-get-history | List<ChatHistoryTurn>；role Option<String>，parts Option<List<Map<Tag, Dynamic>>> |
| extract-stream-chunk | StreamChunkOutput；text Option<String>，thinking? Bool |
| InteractionStatus | completed / failed / in-progress / cancelled / incomplete / requires-action，均无载荷 |

原始 SDK 下划线状态字符串会转为上表的 Enum。归一化仅保留已建模的响应字段，
对字段值进行运行时检查；未知状态不会伪装成成功结果。任意业务 payload 和原生宿主对象仍保持明确 FFI 边界。

## 部署

只迁移前端资源：原生产 COS/CDN 前缀与 rsync 路径保持不变。
COS 使用 action 1.2.0 自带 public-base-url verify，无额外上传验证脚本。
PR 预览按编号/run/attempt 隔离；fork PR 构建但不上传；只有 main push 才执行生产 rsync。
未经授权不合并 Demo 或业务应用；离线测试不代表真实 Google 服务验收。

MIT
