
{} (:about "|file is generated - never edit directly; learn cr edit/tree workflows before changing") (:package |genai)
  :configs $ {} (:init-fn |genai.main/main!) (:reload-fn |genai.main/reload!) (:version |0.0.2)
    :modules $ [] |lilac/ |memof/ |respo.calcit/ |respo-ui.calcit/ |reel.calcit/
  :entries $ {}
    :web $ {} (:init-fn |genai.main/web-main!) (:reload-fn |genai.main/web-reload!) (:version |0.0.0)
      :modules $ [] |lilac/ |memof/ |respo.calcit/ |respo-ui.calcit/ |reel.calcit/
  :files $ {}
    |genai.main $ %{} :FileEntry
      :defs $ {}
        |*store $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            def *store $ atom
              {} (:result nil) (:loading? false) (:error-msg nil)
          :examples $ []
        |comp-container $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defcomp comp-container (result loading? error-msg on-transcribe)
              div
                {} $ :style
                  {} (:padding |20px) (:font-family ui/font-normal)
                div
                  {} $ :style
                    {} (:font-size |24px) (:font-weight |bold) (:margin-bottom |20px)
                  <> "|Gemini Audio Transcription"
                div
                  {} $ :style ({})
                  if loading?
                    div ({}) (<> "|Transcribing... (Please Wait)")
                    div ({}) (<> "|Select an audio file: ")
                      input $ {} (:type |file) (:accept |audio/*)
                        :on-change $ fn (e d!)
                          let
                              file $ -> e :event .-target .-files .-0
                            if (some? file) (on-transcribe file)
                if (some? error-msg)
                  div
                    {} $ :style
                      {} (:color |red) (:margin-top |10px)
                    <> error-msg
                if (some? result)
                  div
                    {} $ :style
                      {} (:margin-top |20px) (:padding |15px) (:border "|1px solid #eee") (:border-radius |4px) (:background-color |#f9f9f9) (:white-space |pre-wrap) (:min-height |100px)
                    <> result
          :examples $ []
        |handle-transcribe! $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn handle-transcribe! (client file)
              hint-fn $ {} (:async true)
              do (swap! *store assoc :loading? true :error-msg nil)
                try
                  let
                      base64 $ js-await (read-as-base64 file)
                      mime-type $ .-type file
                      cfg $ %{}? sdk/ContentConfig (:model |gemini-1.5-flash)
                        :contents $ []
                          {} (:role |user)
                            :parts $ [] (sdk/text-part "|请将这段音频转录为简体中文文字。") (sdk/inline-audio base64 mime-type)
                      response $ js-await (sdk/generate-content! client cfg)
                      text $ sdk/extract-text response
                    swap! *store assoc :result text :loading? false
                  fn (err)
                    do (js/console.error err)
                      swap! *store assoc :loading? false :error-msg $ str err
          :examples $ []
        |main! $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn main! ()
              hint-fn $ {} (:async true)
              let
                  api-key $ or
                    .-GEMINI_API_KEY $ .-env js-process
                    do (println "|Error: GEMINI_API_KEY not set") (js/process.exit 1)
                  base-url $ .-GEMINI_BASE_URL (.-env js-process)
                  client $ if (some? base-url) (sdk/new-client-with-base-url api-key base-url) (sdk/new-client api-key)
                  params $ %{}? sdk/CreateParams (:model |gemini-2.5-flash) (:input "|Explain how AI works in a few words.")
                  interaction $ js-await (sdk/interactions-create! client params)
                  result $ sdk/extract-outputs interaction
                println |Response: $ :text result
                println |Status: $ :status result
                println |Interaction-id: $ :interaction-id result
          :examples $ []
        |read-as-base64 $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn read-as-base64 (file)
              hint-fn $ {} (:async true)
              new js/Promise $ fn (resolve reject)
                let
                    reader $ new js/FileReader
                  set! (.-onload reader)
                    fn (e)
                      let
                          data-url $ .-result (.-target e)
                        resolve $ .-1 (.!split data-url |,)
                  set! (.-onerror reader)
                    fn (e) (reject e)
                  .!readAsDataURL reader file
          :examples $ []
        |reload! $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn reload! () $ println |reloaded
          :examples $ []
        |render-app! $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn render-app! () $ render! (.!querySelector js/document |.app)
              comp-container (:result @*store) (:loading? @*store) (:error-msg @*store)
                fn (file)
                  let
                      api-key $ or
                        .-GEMINI_API_KEY $ .-env js-process
                        .-GEMINI_API_KEY js/window
                    if
                      not $ some? api-key
                      swap! *store assoc :error-msg "|Missing GEMINI_API_KEY"
                      let
                          client $ sdk/new-client api-key
                        handle-transcribe! client file
              , nil
          :examples $ []
        |web-main! $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn web-main! () $ do (println "|Web app started.") (render-app!)
              add-watch *store :rerender $ fn (s r) (render-app!)
          :examples $ []
        |web-reload! $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn web-reload! () $ do (clear-cache!) (render-app!) (println |web-reloaded)
          :examples $ []
      :ns $ %{} :NsEntry (:doc |)
        :code $ quote
          ns genai.main $ :require (genai.sdk :as sdk)
            respo.core :refer $ render! clear-cache! defcomp <> div button input span
            respo-ui.core :as ui
            |node:process :default js-process
    |genai.sdk $ %{} :FileEntry
      :defs $ {}
        |ClientOptions $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defstruct ClientOptions
              :api-key $ :: :optional :string
              :vertexai $ :: :optional :bool
              :project $ :: :optional :string
              :location $ :: :optional :string
              :api-version $ :: :optional :string
              :http-options $ :: :optional :dynamic
          :examples $ []
        |ContentConfig $ %{} :CodeEntry (:doc "|config struct for generateContent/generateContentStream, fields: model contents system-instruction thinking-config tools response-modalities response-mime-type abort-signal http-options") (:schema nil)
          :code $ quote
            defstruct ContentConfig (:model :string) (:contents :dynamic)
              :system-instruction $ :: :optional :dynamic
              :thinking-config $ :: :optional :dynamic
              :tools $ :: :optional :list
              :tool-config $ :: :optional :dynamic
              :response-modalities $ :: :optional :list
              :response-mime-type $ :: :optional :string
              :cached-content $ :: :optional :string
              :abort-signal $ :: :optional :dynamic
              :http-options $ :: :optional :dynamic
          :examples $ []
        |ContentOutput $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defenum ContentOutput (:text TextContent) (:image ImageContent) (:thought ThoughtContent) (:function-call FunctionCallContent) (:function-result FunctionResultContent)
          :examples $ []
        |CreateCachedContentConfig $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defstruct CreateCachedContentConfig
              :ttl $ :: :optional :string
              :expire-time $ :: :optional :string
              :display-name $ :: :optional :string
              :contents $ :: :optional :dynamic
              :system-instruction $ :: :optional :dynamic
              :tools $ :: :optional :list
              :tool-config $ :: :optional :dynamic
              :kms-key-name $ :: :optional :string
              :http-options $ :: :optional :dynamic
              :abort-signal $ :: :optional :dynamic
          :examples $ []
        |CreateParams $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defstruct CreateParams (:model :string) (:input :dynamic)
              :system-instruction $ :: :optional :dynamic
              :previous-interaction-id $ :: :optional :string
              :agent $ :: :optional :string
              :background $ :: :optional :bool
              :store $ :: :optional :bool
              :generation-config $ :: :optional GenerationConfig
              :tools $ :: :optional :list
              :response-modalities $ :: :optional :list
              :response-format $ :: :optional :dynamic
              :response-mime-type $ :: :optional :string
              :abort-signal $ :: :optional :dynamic
              :http-options $ :: :optional :dynamic
          :examples $ []
        |FunctionCallContent $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defstruct FunctionCallContent (:id :string) (:name :string) (:arguments :map)
          :examples $ []
        |FunctionResultContent $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defstruct FunctionResultContent (:call-id :string) (:result :dynamic)
              :is-error $ :: :optional :bool
              :name $ :: :optional :string
          :examples $ []
        |GenerationConfig $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defstruct GenerationConfig
              :temperature $ :: :optional :number
              :max-output-tokens $ :: :optional :number
              :top-p $ :: :optional :number
              :top-k $ :: :optional :number
              :candidate-count $ :: :optional :number
              :stop-sequences $ :: :optional :list
              :response-mime-type $ :: :optional :string
          :examples $ []
        |ImageContent $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defstruct ImageContent
              :data $ :: :optional :string
              :mime-type $ :: :optional :string
              :uri $ :: :optional :string
          :examples $ []
        |ImageGenConfig $ %{} :CodeEntry (:doc "|config struct for generateImages, fields: model prompt number-of-images include-rai-reason abort-signal http-options") (:schema nil)
          :code $ quote
            defstruct ImageGenConfig (:model :string) (:prompt :string)
              :number-of-images $ :: :optional :number
              :include-rai-reason $ :: :optional :bool
              :abort-signal $ :: :optional :dynamic
              :http-options $ :: :optional :dynamic
          :examples $ []
        |Interaction $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defstruct Interaction (:id :string) (:status InteractionStatus)
              :outputs $ :: :optional :list
              :model $ :: :optional :string
              :created $ :: :optional :string
              :updated $ :: :optional :string
              :usage $ :: :optional Usage
          :examples $ []
        |InteractionStatus $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defenum InteractionStatus (:completed :dynamic) (:failed :dynamic) (:in-progress :dynamic) (:cancelled :dynamic) (:incomplete :dynamic) (:requires-action :dynamic)
          :examples $ []
        |ListParams $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defstruct ListParams
              :page-size $ :: :optional :number
              :page-token $ :: :optional :string
              :filter $ :: :optional :string
              :query-base $ :: :optional :bool
              :http-options $ :: :optional :dynamic
              :abort-signal $ :: :optional :dynamic
          :examples $ []
        |RequestConfig $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defstruct RequestConfig
              :http-options $ :: :optional :dynamic
              :abort-signal $ :: :optional :dynamic
          :examples $ []
        |TextContent $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defstruct TextContent $ :text (:: :optional :string)
          :examples $ []
        |ThoughtContent $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defstruct ThoughtContent
              :signature $ :: :optional :string
              :summary $ :: :optional :list
          :examples $ []
        |Turn $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defstruct Turn
              :role $ :: :optional :string
              :content :dynamic
          :examples $ []
        |UploadFileConfig $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defstruct UploadFileConfig
              :name $ :: :optional :string
              :mime-type $ :: :optional :string
              :display-name $ :: :optional :string
              :http-options $ :: :optional :dynamic
              :abort-signal $ :: :optional :dynamic
          :examples $ []
        |Usage $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defstruct Usage
              :input-tokens $ :: :optional :number
              :output-tokens $ :: :optional :number
              :total-tokens $ :: :optional :number
          :examples $ []
        |cached-content-config->js $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn cached-content-config->js (cfg)
              if (some? cfg)
                let
                    contents $ :contents cfg
                    sys $ :system-instruction cfg
                    tools-v $ :tools cfg
                    tool-config $ :tool-config cfg
                  js-object
                    :ttl $ or (:ttl cfg) js/undefined
                    :expireTime $ or (:expire-time cfg) js/undefined
                    :displayName $ or (:display-name cfg) js/undefined
                    :contents $ if (some? contents) (maybe-to-js-data contents) js/undefined
                    :systemInstruction $ if (some? sys) (maybe-to-js-data sys) js/undefined
                    :tools $ if (some? tools-v) (to-js-data tools-v) js/undefined
                    :toolConfig $ if (some? tool-config) (maybe-to-js-data tool-config) js/undefined
                    :kmsKeyName $ or (:kms-key-name cfg) js/undefined
                    :httpOptions $ or (:http-options cfg) js/undefined
                    :abortSignal $ or (:abort-signal cfg) js/undefined
                , js/undefined
          :examples $ []
        |caches-create! $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn caches-create! (client model cfg)
              hint-fn $ {} (:async true)
              .!create (.-caches client)
                js-object (:model model)
                  :config $ cached-content-config->js cfg
          :examples $ []
        |caches-delete! $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn caches-delete! (client name cfg)
              hint-fn $ {} (:async true)
              .!delete (.-caches client)
                js-object (:name name)
                  :config $ request-config->js cfg
          :examples $ []
        |caches-get! $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn caches-get! (client name cfg)
              hint-fn $ {} (:async true)
              .!get (.-caches client)
                js-object (:name name)
                  :config $ request-config->js cfg
          :examples $ []
        |caches-list! $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn caches-list! (client cfg)
              hint-fn $ {} (:async true)
              .!list (.-caches client)
                if (some? cfg)
                  js-object $ :config (list-config->js cfg)
                  , js/undefined
          :examples $ []
        |chat-get-history $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn chat-get-history (chat)
              to-calcit-data $ .!getHistory chat
          :examples $ []
        |chat-send-message! $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn chat-send-message! (chat message config)
              hint-fn $ {} (:async true)
              .!sendMessage chat $ js-object
                :message $ maybe-to-js-data message
                :config $ if (some? config) (maybe-to-js-data config) js/undefined
          :examples $ []
        |chat-send-message-stream! $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn chat-send-message-stream! (chat message config)
              hint-fn $ {} (:async true)
              .!sendMessageStream chat $ js-object
                :message $ maybe-to-js-data message
                :config $ if (some? config) (maybe-to-js-data config) js/undefined
          :examples $ []
        |chats-create $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn chats-create (client model config history)
              .!create (.-chats client)
                js-object (:model model)
                  :config $ if (some? config) (maybe-to-js-data config) js/undefined
                  :history $ if (some? history) (maybe-to-js-data history) js/undefined
          :examples $ []
        |content-config->js $ %{} :CodeEntry (:doc "|converts ContentConfig struct to JS object for SDK calls, maps fields to camelCase JS properties") (:schema nil)
          :code $ quote
            defn content-config->js (cfg)
              let
                  model $ :model cfg
                  contents $ :contents cfg
                  sys $ :system-instruction cfg
                  thinking $ :thinking-config cfg
                  tools-v $ :tools cfg
                  tool-config $ :tool-config cfg
                  modalities $ :response-modalities cfg
                  mime-type $ :response-mime-type cfg
                  cached-content $ :cached-content cfg
                  signal $ :abort-signal cfg
                  http-opts $ :http-options cfg
                js-object (:model model)
                  :contents $ if (some? contents) (maybe-to-js-data contents) js/undefined
                  :systemInstruction $ if (some? sys) (maybe-to-js-data sys) js/undefined
                  :config $ js-object
                    :thinkingConfig $ or thinking js/undefined
                    :tools $ if (some? tools-v) (to-js-data tools-v) js/undefined
                    :toolConfig $ if (some? tool-config) (maybe-to-js-data tool-config) js/undefined
                    :responseModalities $ or modalities js/undefined
                    :responseMimeType $ or mime-type js/undefined
                    :cachedContent $ or cached-content js/undefined
                    :abortSignal $ or signal js/undefined
                    :httpOptions $ or http-opts js/undefined
          :examples $ []
        |extract-content-parts $ %{} :CodeEntry (:doc "|extracts candidates[0].content.parts from a non-streaming generateContent response") (:schema nil)
          :code $ quote
            defn extract-content-parts (result) (-> result .-candidates .-0 .-content .-parts)
          :examples $ []
        |extract-image-bytes $ %{} :CodeEntry (:doc "|extracts base64 imageBytes from generatedImages[0].image of a generateImages response") (:schema nil)
          :code $ quote
            defn extract-image-bytes (response) (-> response .-generatedImages .-0 .-image .-imageBytes)
          :examples $ []
        |extract-outputs $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn extract-outputs (interaction)
              let
                  outputs $ either (.-outputs interaction) (js-array)
                  text-out $ -> outputs
                    .!find $ fn (o & args)
                      = (.-type o) |text
                  fn-calls $ -> outputs
                    .!filter $ fn (o & args)
                      = (.-type o) |function_call
                    .!map $ fn (o & args)
                      js-object
                        :name $ .-name o
                        :arguments $ .-arguments o
                        :id $ .-id o
                    , to-calcit-data
                {}
                  :text $ if (some? text-out) (.-text text-out) nil
                  :function-calls fn-calls
                  :interaction-id $ .-id interaction
                  :status $ .-status interaction
          :examples $ []
        |extract-stream-chunk $ %{} :CodeEntry (:doc "|extracts text and thinking? from a stream chunk, returns {:text :thinking?} map; handles optional chaining") (:schema nil)
          :code $ quote
            defn extract-stream-chunk (chunk)
              let
                  part js/chunk.candidates?.[0]?.content?.parts?.[0]
                  is-thinking? $ if (some? part) (.-thought part) false
                  text $ if (some? part) (.-text part) (.-text chunk)
                  fallback $ or text (-> chunk .?-promptFeedback .?-blockReason)
                {} (:text fallback) (:thinking? is-thinking?)
          :examples $ []
        |extract-text $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn extract-text (result)
              let
                  parts $ extract-content-parts result
                if (some? parts)
                  let
                      first-part $ .-0 parts
                    .-text first-part
                  , nil
          :examples $ []
        |files-delete! $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn files-delete! (client name cfg)
              hint-fn $ {} (:async true)
              .!delete (.-files client)
                js-object (:name name)
                  :config $ request-config->js cfg
          :examples $ []
        |files-get! $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn files-get! (client name cfg)
              hint-fn $ {} (:async true)
              .!get (.-files client)
                js-object (:name name)
                  :config $ request-config->js cfg
          :examples $ []
        |files-list! $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn files-list! (client cfg)
              hint-fn $ {} (:async true)
              .!list (.-files client)
                if (some? cfg)
                  js-object $ :config (list-config->js cfg)
                  , js/undefined
          :examples $ []
        |files-upload! $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn files-upload! (client file cfg)
              hint-fn $ {} (:async true)
              .!upload (.-files client)
                js-object (:file file)
                  :config $ upload-file-config->js cfg
          :examples $ []
        |generate-content! $ %{} :CodeEntry (:doc "|async, calls models.generateContent with ContentConfig, returns full response (non-streaming)") (:schema nil)
          :code $ quote
            defn generate-content! (client cfg)
              hint-fn $ {} (:async true)
              .!generateContent (.-models client) (content-config->js cfg)
          :examples $ []
        |generate-content-stream! $ %{} :CodeEntry (:doc "|async, calls models.generateContentStream with ContentConfig, returns stream for js-for-await") (:schema nil)
          :code $ quote
            defn generate-content-stream! (client cfg)
              hint-fn $ {} (:async true)
              .!generateContentStream (.-models client) (content-config->js cfg)
          :examples $ []
        |generate-images! $ %{} :CodeEntry (:doc "|async, calls models.generateImages with ImageGenConfig, returns image generation response") (:schema nil)
          :code $ quote
            defn generate-images! (client cfg)
              hint-fn $ {} (:async true)
              let
                  model $ :model cfg
                  prompt $ :prompt cfg
                  signal $ :abort-signal cfg
                  http-opts $ :http-options cfg
                  num-images $ either (:number-of-images cfg) 1
                  include-rai $ :include-rai-reason cfg
                .!generateImages (.-models client)
                  js-object (:model model) (:prompt prompt)
                    :config $ js-object (:numberOfImages num-images)
                      :includeRaiReason $ or include-rai js/undefined
                      :httpOptions $ or http-opts js/undefined
                      :signal $ or signal js/undefined
          :examples $ []
        |generation-config->js $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn generation-config->js (cfg)
              if (some? cfg)
                js-object
                  :temperature $ or (:temperature cfg) js/undefined
                  :maxOutputTokens $ or (:max-output-tokens cfg) js/undefined
                  :topP $ or (:top-p cfg) js/undefined
                  :topK $ or (:top-k cfg) js/undefined
                  :candidateCount $ or (:candidate-count cfg) js/undefined
                  :stopSequences $ or (:stop-sequences cfg) js/undefined
                  :responseMimeType $ or (:response-mime-type cfg) js/undefined
                , js/undefined
          :examples $ []
        |inline-audio $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn inline-audio (data mime-type)
              {} $ :inline_data
                {} (:data data) (:mime_type mime-type)
          :examples $ []
        |input->js $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn input->js (v)
              if (string? v)
                js-array $ js-object (:type |text) (:text v)
                if (list? v) (to-js-data v)
                  if (map? v)
                    if (contains? v :type) (to-js-data v)
                      if (contains? v :content)
                        js-array $ js-object (:type |text)
                          :text $ :content v
                        to-js-data v
                    v
          :examples $ []
        |interactions-cancel! $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn interactions-cancel! (client id)
              hint-fn $ {} (:async true)
              .!cancel (.-interactions client) id
          :examples $ []
        |interactions-create! $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn interactions-create! (client params)
              hint-fn $ {} (:async true)
              .!create (.-interactions client) (params->js params)
          :examples $ []
        |interactions-delete! $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn interactions-delete! (client id)
              hint-fn $ {} (:async true)
              .!delete (.-interactions client) id
          :examples $ []
        |interactions-get! $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn interactions-get! (client id)
              hint-fn $ {} (:async true)
              .!get (.-interactions client) id
          :examples $ []
        |list-config->js $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn list-config->js (cfg)
              if (some? cfg)
                js-object
                  :httpOptions $ or (:http-options cfg) js/undefined
                  :abortSignal $ or (:abort-signal cfg) js/undefined
                  :pageSize $ or (:page-size cfg) js/undefined
                  :pageToken $ or (:page-token cfg) js/undefined
                  :filter $ or (:filter cfg) js/undefined
                  :queryBase $ or (:query-base cfg) js/undefined
                , js/undefined
          :examples $ []
        |make-abort-signal $ %{} :CodeEntry (:doc "|creates AbortController, stores in *abort-control atom, returns signal; pass atom for external abort control") (:schema nil)
          :code $ quote
            defn make-abort-signal (*abort-control)
              let
                  abort $ new js/AbortController
                reset! *abort-control abort
                .-signal abort
          :examples $ []
        |make-http-options $ %{} :CodeEntry (:doc "|creates httpOptions JS object with baseUrl for proxy endpoint") (:schema nil)
          :code $ quote
            defn make-http-options (base-url)
              js-object $ :baseUrl base-url
          :examples $ []
        |make-search-tools $ %{} :CodeEntry (:doc "|builds tools array with googleSearch and/or urlContext based on boolean flags; returns nil if neither") (:schema nil)
          :code $ quote
            defn make-search-tools (search? has-url?)
              let
                  t $ ->
                    js-array
                      if search? $ js-object
                        :googleSearch $ js-object
                      if has-url? $ js-object
                        :urlContext $ js-object
                    .!filter $ fn (x & _a) x
                if
                  = 0 $ .-length t
                  , nil t
          :examples $ []
        |make-thinking-config $ %{} :CodeEntry (:doc "|creates thinkingConfig JS object with thinkingBudget and includeThoughts fields") (:schema nil)
          :code $ quote
            defn make-thinking-config (budget include-thoughts?)
              js-object (:thinkingBudget budget) (:includeThoughts include-thoughts?)
          :examples $ []
        |maybe-to-js-data $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn maybe-to-js-data (x)
              if
                or (list? x) (map? x)
                to-js-data x
                , x
          :examples $ []
        |messages->contents $ %{} :CodeEntry (:doc "|converts Calcit messages [{:role :user/:assistant :content str}] to Gemini contents format [{role parts:[{text}]}]") (:schema nil)
          :code $ quote
            defn messages->contents (messages)
              let
                  messages0 $ if (some? messages) messages ([])
                to-js-data $ map messages0
                  fn (m)
                    {}
                      :role $ if
                        = :assistant $ :role m
                        , |model |user
                      :parts $ []
                        {} $ :text (:content m)
          :examples $ []
        |models-compute-tokens! $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn models-compute-tokens! (client model contents config)
              hint-fn $ {} (:async true)
              .!computeTokens (.-models client)
                js-object (:model model)
                  :contents $ maybe-to-js-data contents
                  :config $ if (some? config) (maybe-to-js-data config) js/undefined
          :examples $ []
        |models-count-tokens! $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn models-count-tokens! (client model contents config)
              hint-fn $ {} (:async true)
              .!countTokens (.-models client)
                js-object (:model model)
                  :contents $ maybe-to-js-data contents
                  :config $ if (some? config) (maybe-to-js-data config) js/undefined
          :examples $ []
        |models-get! $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn models-get! (client model cfg)
              hint-fn $ {} (:async true)
              .!get (.-models client)
                js-object (:model model)
                  :config $ request-config->js cfg
          :examples $ []
        |models-list! $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn models-list! (client cfg)
              hint-fn $ {} (:async true)
              .!list (.-models client)
                if (some? cfg)
                  js-object $ :config (list-config->js cfg)
                  , js/undefined
          :examples $ []
        |new-client $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn new-client (api-key)
              new GoogleGenAI $ js-object (:apiKey api-key)
          :examples $ []
        |new-client-with-base-url $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn new-client-with-base-url (api-key base-url)
              new GoogleGenAI $ js-object (:apiKey api-key)
                :httpOptions $ js-object (:baseUrl base-url)
          :examples $ []
        |new-client-with-options $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn new-client-with-options (options)
              new GoogleGenAI $ js-object
                :apiKey $ or (:api-key options) js/undefined
                :vertexai $ or (:vertexai options) js/undefined
                :project $ or (:project options) js/undefined
                :location $ or (:location options) js/undefined
                :apiVersion $ or (:api-version options) js/undefined
                :httpOptions $ or (:http-options options) js/undefined
          :examples $ []
        |params->js $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn params->js (p)
              let
                  model $ :model p
                  input $ :input p
                  prev-id $ :previous-interaction-id p
                  sys $ :system-instruction p
                  gen-cfg $ :generation-config p
                  tools-v $ :tools p
                  response-modalities $ :response-modalities p
                  response-mime-type $ :response-mime-type p
                  response-format $ :response-format p
                  agent $ :agent p
                  background $ :background p
                  signal $ :abort-signal p
                  http-opts $ :http-options p
                js-object (:model model)
                  :input $ input->js input
                  :previous_interaction_id $ or prev-id js/undefined
                  :system_instruction $ if (some? sys) (maybe-to-js-data sys) js/undefined
                  :agent $ or agent js/undefined
                  :background $ or background js/undefined
                  :store $ or (:store p) js/undefined
                  :config $ generation-config->js gen-cfg
                  :tools $ if (some? tools-v) (to-js-data tools-v) js/undefined
                  :response_modalities $ or response-modalities js/undefined
                  :response_mime_type $ or response-mime-type js/undefined
                  :response_format $ if (some? response-format) (maybe-to-js-data response-format) js/undefined
                  :abortSignal $ or signal js/undefined
                  :httpOptions $ or http-opts js/undefined
          :examples $ []
        |request-config->js $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn request-config->js (cfg)
              if (some? cfg)
                js-object
                  :httpOptions $ or (:http-options cfg) js/undefined
                  :abortSignal $ or (:abort-signal cfg) js/undefined
                , js/undefined
          :examples $ []
        |text-part $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn text-part (text)
              {} $ :text text
          :examples $ []
        |upload-file-config->js $ %{} :CodeEntry (:doc |) (:schema nil)
          :code $ quote
            defn upload-file-config->js (cfg)
              if (some? cfg)
                js-object
                  :name $ or (:name cfg) js/undefined
                  :mimeType $ or (:mime-type cfg) js/undefined
                  :displayName $ or (:display-name cfg) js/undefined
                  :httpOptions $ or (:http-options cfg) js/undefined
                  :abortSignal $ or (:abort-signal cfg) js/undefined
                , js/undefined
          :examples $ []
      :ns $ %{} :NsEntry (:doc |)
        :code $ quote
          ns genai.sdk $ :require
            |@google/genai :refer $ GoogleGenAI
