## Google GenAI Interactions API — Calcit Bindings

> Calcit bindings for the [Google GenAI](https://ai.google.dev/) Interactions API (`@google/genai`), compiled to JavaScript.

### Setup

```bash
yarn          # install dependencies
cr js -1      # compile once to js-out/
```

### Run

```bash
GEMINI_API_KEY=your_key node --require ./.pnp.cjs --loader ./.pnp.loader.mjs main.mjs
```

Set `GEMINI_BASE_URL` to override the API endpoint (e.g. for proxies).

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

### Type Definitions

**Enums**

| Type                | Variants                                                                                                                                          |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| `InteractionStatus` | `:completed` `:failed` `:in-progress` `:cancelled` `:incomplete` `:requires-action`                                                               |
| `ContentOutput`     | `:text TextContent` `:image ImageContent` `:thought ThoughtContent` `:function-call FunctionCallContent` `:function-result FunctionResultContent` |

**Structs**

| Type                    | Key fields                                                                                    |
| ----------------------- | --------------------------------------------------------------------------------------------- |
| `CreateParams`          | `:model :input :system-instruction :previous-interaction-id :store :generation-config :tools` |
| `GenerationConfig`      | `:temperature :max-output-tokens :top-p :top-k`                                               |
| `Interaction`           | `:id :string`, `:status InteractionStatus`, `:outputs :list?`, `:usage Usage?`                |
| `TextContent`           | `:text :string?`                                                                              |
| `ImageContent`          | `:data :string?`, `:mime-type :string?`, `:uri :string?`                                      |
| `FunctionCallContent`   | `:id :string`, `:name :string`, `:arguments :map`                                             |
| `FunctionResultContent` | `:call-id :string`, `:result :any`, `:is-error :bool?`                                        |
| `Usage`                 | `:input-tokens :number?`, `:output-tokens :number?`, `:total-tokens :number?`                 |
| `Turn`                  | `:role :string?`, `:content :any`                                                             |

### Development

```bash
cr js    # watch mode — recompiles on changes
```

### License

MIT
