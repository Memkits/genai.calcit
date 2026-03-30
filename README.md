## Google GenAI Interactions API — Calcit Bindings

> Calcit bindings for the [Google GenAI](https://ai.google.dev/) Interactions API (`@google/genai`), compiled to JavaScript.

### Setup

```bash
yarn          # install dependencies
cr js         # compile once to js-out/
```

### Run

```bash
GEMINI_API_KEY=your_key node --require ./.pnp.cjs --loader ./.pnp.loader.mjs main.mjs
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

#### Local chat session

```cirru
let
    chat $ sdk/chats-create client |gemini-2.5-flash nil nil
    response $ js-await $ sdk/chat-send-message! chat |"Why is the sky blue?" nil
  println $ .-text response
  println $ sdk/chat-get-history chat
```

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
| `ListParams`            | `:page-size :page-token :filter :query-base :http-options :abort-signal`                      |
| `RequestConfig`         | `:http-options :abort-signal`                                                                  |
| `TextContent`           | `:text :string?`                                                                              |
| `ImageContent`          | `:data :string?`, `:mime-type :string?`, `:uri :string?`                                      |
| `FunctionCallContent`   | `:id :string`, `:name :string`, `:arguments :map`                                             |
| `FunctionResultContent` | `:call-id :string`, `:result :any`, `:is-error :bool?`                                        |
| `UploadFileConfig`      | `:name :mime-type :display-name :http-options :abort-signal`                                  |
| `Usage`                 | `:input-tokens :number?`, `:output-tokens :number?`, `:total-tokens :number?`                 |
| `Turn`                  | `:role :string?`, `:content :any`                                                             |

### Development

```bash
cr js    # watch mode — recompiles on changes
```

### License

MIT
