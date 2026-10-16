## Google GenAI Interactions API — Calcit Bindings

> Calcit bindings for the [Google GenAI](https://ai.google.dev/) Interactions API (`@google/genai`), compiled to JavaScript.

### 0.30.1 迁移草稿

本分支使用已发布配对 Calcit/procs **0.30.1-alpha.4**（预发布），保留默认脚本入口和独立 Web 入口。
正式模块为 Respo 0.16.122、UI 0.7.41、js-ffi 0.2.3；移除未被源码使用的 Reel。
已迁移配置及结果的 `Option` 合同、请求序列化和 SDK 响应归一化；SDK 公共定义在 Node/Web 下均为 92/92 通过。
默认脚本与 Web 应用入口仍未完成，不能把公共 SDK 检查通过视为整个项目通过。
不要把本候选用于发布或生产部署；具体待办见 [#8](https://github.com/Memkits/genai.calcit/issues/8)。

配置字段使用 `Option :some value`，缺失的 Option 字段可以省略：

```cirru
genai.sdk/CreateParams :model |fixture :input |hello
  :background $ Option :some false
  :store $ Option :some false
  :generation-config $ Option :some $ genai.sdk/GenerationConfig
    :temperature $ Option :some 0
```

`Some false` 不再因 `or` 被忽略；None 在 SDK 请求对象中省略。
ContentConfig 的 `system-instruction` 放入 SDK 要求的 `config.systemInstruction`。
`yarn test:config` 检查两类离线请求对象，并覆盖交互响应的真实 Struct/枚举、文本提取、零 token 值和未启用搜索工具的情况，不读取密钥、不调用 Google 服务。
这项测试通过不代表整个 SDK 完成迁移；下面的历史 API 示例仍需随 #8 同步到 Option 和真实结果合同。

源码只维护 `calcit.cirru` / `deps.cirru`。CI 保留 canonical、两个入口的全部定义、SDK 公共定义及完整 strict，
不再用数量预算脚本代替语义门禁。前端 COS 继续使用 action 自身 verify，生产 CDN/rsync 路径不变。

### Setup

```bash
caps --strict --ci
yarn install --immutable
caps verify --toolchain
yarn test:config # offline request objects only
yarn compile    # script entry; migration incomplete
yarn compile:web # web entry; migration incomplete
```

### Run

```bash
GEMINI_API_KEY=your_key node main.mjs
```

Set `GEMINI_BASE_URL` to override the API endpoint (e.g. for proxies).

For Vertex AI or custom API versions, use `sdk/new-client-with-options`.

### Usage Examples

#### Basic text interaction

```cirru
let
    client $ sdk/new-client api-key
    params $ %{} sdk/CreateParams
      :model |gemini-2.5-flash
      :input |"Explain how AI works in a few words."
      ...
    interaction $ js-await $ sdk/interactions-create! client params
    result $ sdk/extract-outputs interaction
  println $ :text result
  println $ :status result
  println $ :interaction-id result
```

`sdk/interactions-create!` returns a raw `InteractionResult` record.
`sdk/extract-outputs` converts it into a smaller `ExtractedInteractionOutput` record for common UI and CLI usage.

#### Multi-turn conversation (continuing an interaction)

```cirru
let
    first $ js-await $ sdk/interactions-create! client params
    follow-params $ %{} sdk/CreateParams
      :model |gemini-2.5-flash
      :input |"Tell me more."
      :previous-interaction-id $ .-id first
      ...
    second $ js-await $ sdk/interactions-create! client follow-params
  println $ :text $ sdk/extract-outputs second
```

#### Retrieve / cancel / delete

```cirru
; retrieve
let
    interaction $ js-await (sdk/interactions-get! client interaction-id)
  println $ .-status interaction

; cancel
js-await $ sdk/interactions-cancel! client interaction-id

; delete
js-await $ sdk/interactions-delete! client interaction-id
```

#### Client options

```cirru
let
    client $ sdk/new-client-with-options $ %{} sdk/ClientOptions
      :api-key api-key
      :api-version |v1alpha
      :http-options $ sdk/make-http-options base-url
  println client
```

#### Model metadata and token counting

```cirru
let
    model-info $ js-await $ sdk/models-get! client |gemini-2.5-flash nil
    token-info $ js-await $ sdk/models-count-tokens! client |gemini-2.5-flash ([] |"Hello") nil
  println $ .-name model-info
  println $ .-totalTokens token-info
```

`sdk/models-count-tokens!` returns a `CountTokensResponse` record with at least `.-totalTokens`.

#### Local chat session

```cirru
let
    chat $ sdk/chats-create client |gemini-2.5-flash nil nil
    response $ js-await $ sdk/chat-send-message! chat |"Why is the sky blue?" nil
    history $ sdk/chat-get-history chat
  println $ .-text response
  println history
```

`sdk/chat-get-history` returns a list of `ChatHistoryTurn` values.

#### Files and caches

```cirru
let
    file $ js-await $ sdk/files-upload! client |./notes.txt $ %{} sdk/UploadFileConfig
      :mime-type |text/plain
    cache $ js-await $ sdk/caches-create! client |gemini-2.5-flash $ %{} sdk/CreateCachedContentConfig
      :display-name |sample-cache
      :contents $ [] |"Summarize this file later"
  println $ .-name file
  println $ .-name cache
```

### Common Bindings

- `new-client`, `new-client-with-base-url`, `new-client-with-options`
- `generate-content!`, `generate-content-stream!`, `generate-images!`
- `interactions-create!`, `interactions-get!`, `interactions-cancel!`, `interactions-delete!`
- `models-get!`, `models-list!`, `models-count-tokens!`, `models-compute-tokens!`
- `chats-create`, `chat-send-message!`, `chat-send-message-stream!`, `chat-get-history`
- `files-list!`, `files-upload!`, `files-get!`, `files-delete!`
- `caches-list!`, `caches-create!`, `caches-get!`, `caches-delete!`

### Result Shapes

- Raw SDK-style results:
  - `interactions-create!`, `interactions-get!` -> `InteractionResult`
  - `models-count-tokens!` -> `CountTokensResponse`
  - `chat-get-history` -> `(:: :list ChatHistoryTurn)`
- Normalized helper results:
  - `extract-outputs` -> `ExtractedInteractionOutput`
  - `extract-stream-chunk` -> `StreamChunkOutput`
  - `extract-text` -> `:string?`
  - `extract-image-bytes` -> `:string?`

### Type Definitions

**Enums**

| Type                | Variants                                                                                                                                          |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| `InteractionStatus` | `:completed` `:failed` `:in-progress` `:cancelled` `:incomplete` `:requires-action`                                                               |
| `ContentOutput`     | `:text TextContent` `:image ImageContent` `:thought ThoughtContent` `:function-call FunctionCallContent` `:function-result FunctionResultContent` |

**Structs**

| Type                    | Key fields                                                                                    |
| ----------------------- | --------------------------------------------------------------------------------------------- |
| `ClientOptions`         | `:api-key :vertexai :project :location :api-version :http-options`                           |
| `ContentConfig`         | `:model :contents :system-instruction :thinking-config :tools :tool-config :cached-content`   |
| `CreateParams`          | `:model :input :system-instruction :previous-interaction-id :agent :background :store`        |
| `CreateCachedContentConfig` | `:ttl :expire-time :display-name :contents :system-instruction :tools :tool-config`      |
| `GenerationConfig`      | `:temperature :max-output-tokens :top-p :top-k :candidate-count :stop-sequences`             |
| `Interaction`           | `:id :string`, `:status InteractionStatus`, `:outputs :list?`, `:usage Usage?`                |
| `InteractionResult`     | `:id :string`, `:status InteractionStatus`, `:outputs :list?`, `:role :string?`, `:usage SdkUsage?` |
| `ListParams`            | `:page-size :page-token :filter :query-base :http-options :abort-signal`                      |
| `RequestConfig`         | `:http-options :abort-signal`                                                                  |
| `TextContent`           | `:text :string?`                                                                              |
| `ImageContent`          | `:data :string?`, `:mime-type :string?`, `:uri :string?`                                      |
| `ExtractedInteractionOutput` | `:text :string?`, `:function-calls (:list FunctionCallContent)`, `:interaction-id :string`, `:status InteractionStatus` |
| `FunctionCallContent`   | `:id :string`, `:name :string`, `:arguments :map`                                             |
| `FunctionResultContent` | `:call-id :string`, `:result :any`, `:is-error :bool?`                                        |
| `CountTokensResponse`   | `:totalTokens :number`, `:sdkHttpResponse :any?`                                              |
| `ChatHistoryTurn`       | `:role :string?`, `:parts :list`                                                              |
| `StreamChunkOutput`     | `:text :string?`, `:thinking? :bool`                                                          |
| `SdkUsage`              | raw SDK usage fields such as `:total_tokens`, `:total_input_tokens`, `:total_output_tokens`  |
| `UploadFileConfig`      | `:name :mime-type :display-name :http-options :abort-signal`                                  |
| `Usage`                 | `:input-tokens :number?`, `:output-tokens :number?`, `:total-tokens :number?`                 |
| `Turn`                  | `:role :string?`, `:content :any`                                                             |

### Development

CI 对默认 Node 和 web 入口执行严格检查、生成与原类型预算门禁，再构建前端资源。deprecated 报告已在原预算门禁中检查，不重复执行。COS 上传仅使用 Action 1.2 内置 `public-base-url` verify；PR 预览按 PR 编号/run/attempt 隔离，fork PR 仍构建但不上传。生产 COS 前缀与服务器 rsync 路径不变，串行队列保留待处理运行。此部署改进仍使用正式 Calcit/procs 0.27.0，不代表 0.28 类型迁移完成；不调用真实 Google API 验证部署。

```bash
yarn compile     # script entry
yarn compile:web # web entry
yarn watch       # explicit Web watch mode
```

### License

MIT
