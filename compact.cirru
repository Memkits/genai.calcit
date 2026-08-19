
{} (:about "|Machine-generated snapshot. Do not edit directly — changes will be overwritten. Use `cr query` to inspect and `cr edit`/`cr tree` to modify. Run `cr docs agents --full` first. Manual edits must follow format and schema conventions, then run `cr edit format`.") (:package |genai)
  :entries $ {}
    :default $ {} (:description |) (:init-fn 'genai.main/main!) (:mode :native) (:reload-fn 'genai.main/reload!)
      :feature-policy $ {}
      :modules $ [] |respo.calcit/ |respo-ui.calcit/ |reel.calcit/ |js-ffi/
      :type-slots $ {}
    :web $ {} (:description |) (:init-fn 'genai.main/web-main!) (:mode :native) (:reload-fn 'genai.main/web-reload!)
      :feature-policy $ {}
      :modules $ [] |respo.calcit/ |respo-ui.calcit/ |reel.calcit/ |js-ffi/
      :type-slots $ {}
  :files $ {}
    |genai.main $ %{} 'FileEntry
      :defs $ {}
        |*store $ %{} 'CodeEntry (:doc |)
          :code $ quote
            def *store $ atom
              {} (:result nil) (:loading? false) (:error-msg nil)
          :examples $ []
          :schema $ :: 'Dynamic
        |comp-container $ %{} 'CodeEntry (:doc |)
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
                            if (js-present? file) (on-transcribe file)
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
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'Dynamic 'Bool 'Dynamic 'Dynamic
        |handle-transcribe! $ %{} 'CodeEntry (:doc |)
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
          :schema $ :: 'Fn
            {} (:return 'Unit)
              :args $ [] 'Dynamic 'Dynamic
        |main! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn main! ()
              hint-fn $ {} (:async true)
              let
                  env $ unsafe-coerce (.-env js-process) 'JsObject
                  api-key $ .-GEMINI_API_KEY env
                  base-url $ .-GEMINI_BASE_URL env
                  client $ if (js-present? api-key)
                    if (js-present? base-url)
                      sdk/new-client-with-base-url (unsafe-coerce api-key 'String) (unsafe-coerce base-url 'String)
                      sdk/new-client $ unsafe-coerce api-key 'String
                    do (println "|Error: GEMINI_API_KEY not set") (js/process.exit 1)
                  params $ %{}? sdk/CreateParams (:model |gemini-2.5-flash) (:input "|Explain how AI works in a few words.")
                  interaction $ js-await (sdk/interactions-create! client params)
                  result $ sdk/extract-outputs interaction
                println |Response: $ &map:get result :text
                println |Status: $ &map:get result :status
                println |Interaction-id: $ &map:get result :interaction-id
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Unit)
              :args $ []
        |read-as-base64 $ %{} 'CodeEntry (:doc |)
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
          :schema $ :: 'Fn
            {} (:return 'String)
              :args $ [] 'Dynamic
        |reload! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn reload! () $ println |reloaded
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Unit)
              :args $ []
        |render-app! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn render-app! () $ render! (.!querySelector js/document |.app)
              comp-container (:result @*store) (:loading? @*store) (:error-msg @*store)
                fn (file)
                  let
                      env $ unsafe-coerce (.-env js-process) 'JsObject
                      api-key $ if
                        js-present? $ .-GEMINI_API_KEY env
                        .-GEMINI_API_KEY env
                        .-GEMINI_API_KEY js/window
                    if
                      not $ js-present? api-key
                      swap! *store assoc :error-msg "|Missing GEMINI_API_KEY"
                      let
                          client $ sdk/new-client (unsafe-coerce api-key 'String)
                        handle-transcribe! client file
              , nil
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Unit)
              :args $ []
        |web-main! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn web-main! () $ do (println "|Web app started.") (render-app!)
              add-watch *store :rerender $ fn (s r) (render-app!)
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Tag)
              :args $ []
        |web-reload! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn web-reload! () $ do (clear-cache!) (render-app!) (println |web-reloaded)
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Unit)
              :args $ []
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote
          ns genai.main $ :require (genai.sdk :as sdk)
            respo.core :refer $ render! clear-cache! defcomp <> div button input span
            respo-ui.core :as ui
            |node:process :default js-process
    |genai.sdk $ %{} 'FileEntry
      :defs $ {}
        |ChatHistoryTurn $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defstruct ChatHistoryTurn
              :role $ :: 'Optional 'String
              :parts 'List
          :examples $ []
          :schema $ :: 'Enum
        |ClientOptions $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defstruct ClientOptions
              :api-key $ :: 'Optional 'String
              :vertexai $ :: 'Optional 'Bool
              :project $ :: 'Optional 'String
              :location $ :: 'Optional 'String
              :api-version $ :: 'Optional 'String
              :http-options $ :: 'Optional 'Dynamic
          :examples $ []
          :schema $ :: 'Enum
        |ContentConfig $ %{} 'CodeEntry (:doc "|config struct for generateContent/generateContentStream, fields: model contents system-instruction thinking-config tools response-modalities response-mime-type abort-signal http-options")
          :code $ quote
            defstruct ContentConfig (:model 'String) (:contents 'Dynamic)
              :system-instruction $ :: 'Optional 'Dynamic
              :thinking-config $ :: 'Optional 'Dynamic
              :tools $ :: 'Optional 'List
              :tool-config $ :: 'Optional 'Dynamic
              :response-modalities $ :: 'Optional 'List
              :response-mime-type $ :: 'Optional 'String
              :cached-content $ :: 'Optional 'String
              :abort-signal $ :: 'Optional 'Dynamic
              :http-options $ :: 'Optional 'Dynamic
          :examples $ []
          :schema $ :: 'Enum
        |ContentOutput $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defenum ContentOutput (:text TextContent) (:image ImageContent) (:thought ThoughtContent) (:function-call FunctionCallContent) (:function-result FunctionResultContent)
          :examples $ []
          :schema $ :: 'Enum
        |CountTokensResponse $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defstruct CountTokensResponse (:totalTokens 'Number)
              :sdkHttpResponse $ :: 'Optional 'Dynamic
          :examples $ []
          :schema $ :: 'Enum
        |CreateCachedContentConfig $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defstruct CreateCachedContentConfig
              :ttl $ :: 'Optional 'String
              :expire-time $ :: 'Optional 'String
              :display-name $ :: 'Optional 'String
              :contents $ :: 'Optional 'Dynamic
              :system-instruction $ :: 'Optional 'Dynamic
              :tools $ :: 'Optional 'List
              :tool-config $ :: 'Optional 'Dynamic
              :kms-key-name $ :: 'Optional 'String
              :http-options $ :: 'Optional 'Dynamic
              :abort-signal $ :: 'Optional 'Dynamic
          :examples $ []
          :schema $ :: 'Enum
        |CreateParams $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defstruct CreateParams (:model 'String) (:input 'Dynamic)
              :system-instruction $ :: 'Optional 'Dynamic
              :previous-interaction-id $ :: 'Optional 'String
              :agent $ :: 'Optional 'String
              :background $ :: 'Optional 'Bool
              :store $ :: 'Optional 'Bool
              :generation-config $ :: 'Optional GenerationConfig
              :tools $ :: 'Optional 'List
              :response-modalities $ :: 'Optional 'List
              :response-format $ :: 'Optional 'Dynamic
              :response-mime-type $ :: 'Optional 'String
              :abort-signal $ :: 'Optional 'Dynamic
              :http-options $ :: 'Optional 'Dynamic
          :examples $ []
          :schema $ :: 'Enum
        |ExtractedInteractionOutput $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defstruct ExtractedInteractionOutput
              :text $ :: 'Optional 'String
              :function-calls $ :: 'List FunctionCallContent
              :interaction-id 'String
              :status InteractionStatus
          :examples $ []
          :schema $ :: 'Enum
        |FunctionCallContent $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defstruct FunctionCallContent (:id 'String) (:name 'String) (:arguments 'Map)
          :examples $ []
          :schema $ :: 'Enum
        |FunctionResultContent $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defstruct FunctionResultContent (:call-id 'String) (:result 'Dynamic)
              :is-error $ :: 'Optional 'Bool
              :name $ :: 'Optional 'String
          :examples $ []
          :schema $ :: 'Enum
        |GenerationConfig $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defstruct GenerationConfig
              :temperature $ :: 'Optional 'Number
              :max-output-tokens $ :: 'Optional 'Number
              :top-p $ :: 'Optional 'Number
              :top-k $ :: 'Optional 'Number
              :candidate-count $ :: 'Optional 'Number
              :stop-sequences $ :: 'Optional 'List
              :response-mime-type $ :: 'Optional 'String
          :examples $ []
          :schema $ :: 'Enum
        |ImageContent $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defstruct ImageContent
              :data $ :: 'Optional 'String
              :mime-type $ :: 'Optional 'String
              :uri $ :: 'Optional 'String
          :examples $ []
          :schema $ :: 'Enum
        |ImageGenConfig $ %{} 'CodeEntry (:doc "|config struct for generateImages, fields: model prompt number-of-images include-rai-reason abort-signal http-options")
          :code $ quote
            defstruct ImageGenConfig (:model 'String) (:prompt 'String)
              :number-of-images $ :: 'Optional 'Number
              :include-rai-reason $ :: 'Optional 'Bool
              :abort-signal $ :: 'Optional 'Dynamic
              :http-options $ :: 'Optional 'Dynamic
          :examples $ []
          :schema $ :: 'Enum
        |Interaction $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defstruct Interaction (:id 'String) (:status InteractionStatus)
              :outputs $ :: 'Optional 'List
              :model $ :: 'Optional 'String
              :created $ :: 'Optional 'String
              :updated $ :: 'Optional 'String
              :usage $ :: 'Optional Usage
          :examples $ []
          :schema $ :: 'Enum
        |InteractionResult $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defstruct InteractionResult (:id 'String) (:status InteractionStatus)
              :outputs $ :: 'Optional 'List
              :model $ :: 'Optional 'String
              :created $ :: 'Optional 'String
              :updated $ :: 'Optional 'String
              :role $ :: 'Optional 'String
              :object $ :: 'Optional 'String
              :usage $ :: 'Optional 'SdkUsage
          :examples $ []
          :schema $ :: 'Enum
        |InteractionStatus $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defenum InteractionStatus (:completed 'Dynamic) (:failed 'Dynamic) (:in-progress 'Dynamic) (:cancelled 'Dynamic) (:incomplete 'Dynamic) (:requires-action 'Dynamic)
          :examples $ []
          :schema $ :: 'Enum
        |ListParams $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defstruct ListParams
              :page-size $ :: 'Optional 'Number
              :page-token $ :: 'Optional 'String
              :filter $ :: 'Optional 'String
              :query-base $ :: 'Optional 'Bool
              :http-options $ :: 'Optional 'Dynamic
              :abort-signal $ :: 'Optional 'Dynamic
          :examples $ []
          :schema $ :: 'Enum
        |RequestConfig $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defstruct RequestConfig
              :http-options $ :: 'Optional 'Dynamic
              :abort-signal $ :: 'Optional 'Dynamic
          :examples $ []
          :schema $ :: 'Enum
        |SdkUsage $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defstruct SdkUsage
              :total_tokens $ :: 'Optional 'Number
              :total_input_tokens $ :: 'Optional 'Number
              :input_tokens_by_modality $ :: 'Optional 'List
              :total_cached_tokens $ :: 'Optional 'Number
              :total_output_tokens $ :: 'Optional 'Number
              :total_tool_use_tokens $ :: 'Optional 'Number
              :total_thought_tokens $ :: 'Optional 'Number
          :examples $ []
          :schema $ :: 'Enum
        |StreamChunkOutput $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defstruct StreamChunkOutput
              :text $ :: 'Optional 'String
              :thinking? 'Bool
          :examples $ []
          :schema $ :: 'Enum
        |TextContent $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defstruct TextContent $ :text (:: 'Optional 'String)
          :examples $ []
          :schema $ :: 'Enum
        |ThoughtContent $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defstruct ThoughtContent
              :signature $ :: 'Optional 'String
              :summary $ :: 'Optional 'List
          :examples $ []
          :schema $ :: 'Enum
        |Turn $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defstruct Turn
              :role $ :: 'Optional 'String
              :content 'Dynamic
          :examples $ []
          :schema $ :: 'Enum
        |UploadFileConfig $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defstruct UploadFileConfig
              :name $ :: 'Optional 'String
              :mime-type $ :: 'Optional 'String
              :display-name $ :: 'Optional 'String
              :http-options $ :: 'Optional 'Dynamic
              :abort-signal $ :: 'Optional 'Dynamic
          :examples $ []
          :schema $ :: 'Enum
        |Usage $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defstruct Usage
              :input-tokens $ :: 'Optional 'Number
              :output-tokens $ :: 'Optional 'Number
              :total-tokens $ :: 'Optional 'Number
          :examples $ []
          :schema $ :: 'Enum
        |cached-content-config->js $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn cached-content-config->js (cfg)
              if (js-present? cfg)
                let
                    contents $ :contents cfg
                    sys $ :system-instruction cfg
                    tools-v $ :tools cfg
                    tool-config $ :tool-config cfg
                  js-object
                    :ttl $ or (:ttl cfg) js/undefined
                    :expireTime $ or (:expire-time cfg) js/undefined
                    :displayName $ or (:display-name cfg) js/undefined
                    :contents $ if (js-present? contents) (maybe-to-js-data contents) js/undefined
                    :systemInstruction $ if (js-present? sys) (maybe-to-js-data sys) js/undefined
                    :tools $ if (js-present? tools-v) (to-js-data tools-v) js/undefined
                    :toolConfig $ if (js-present? tool-config) (maybe-to-js-data tool-config) js/undefined
                    :kmsKeyName $ or (:kms-key-name cfg) js/undefined
                    :httpOptions $ or (:http-options cfg) js/undefined
                    :abortSignal $ or (:abort-signal cfg) js/undefined
                , js/undefined
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'CreateCachedContentConfig
        |caches-create! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn caches-create! (client model cfg)
              hint-fn $ {} (:async true)
              .!create
                unsafe-coerce (.-caches client) 'JsObject
                js-object (:model model)
                  :config $ cached-content-config->js cfg
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'Dynamic 'String 'CreateCachedContentConfig
        |caches-delete! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn caches-delete! (client name cfg)
              hint-fn $ {} (:async true)
              .!delete (.-caches client)
                js-object (:name name)
                  :config $ request-config->js cfg
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'Dynamic 'String 'RequestConfig
        |caches-get! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn caches-get! (client name cfg)
              hint-fn $ {} (:async true)
              .!get (.-caches client)
                js-object (:name name)
                  :config $ request-config->js cfg
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'Dynamic 'String 'RequestConfig
        |caches-list! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn caches-list! (client cfg)
              hint-fn $ {} (:async true)
              .!list (.-caches client)
                if (js-present? cfg)
                  js-object $ :config (list-config->js cfg)
                  , js/undefined
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'Dynamic 'ListParams
        |chat-get-history $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn chat-get-history (chat)
              to-calcit-data $ .!getHistory chat
          :examples $ []
          :schema $ :: 'Fn
            {}
              :args $ [] 'Dynamic
              :return $ :: 'List 'ChatHistoryTurn
        |chat-send-message! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn chat-send-message! (chat message config)
              hint-fn $ {} (:async true)
              .!sendMessage chat $ js-object
                :message $ maybe-to-js-data message
                :config $ if (js-present? config) (maybe-to-js-data config) js/undefined
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'Dynamic 'Dynamic (:: 'Optional 'GenerationConfig)
        |chat-send-message-stream! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn chat-send-message-stream! (chat message config)
              hint-fn $ {} (:async true)
              .!sendMessageStream chat $ js-object
                :message $ maybe-to-js-data message
                :config $ if (js-present? config) (maybe-to-js-data config) js/undefined
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'Dynamic 'Dynamic (:: 'Optional 'GenerationConfig)
        |chats-create $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn chats-create (client model config history)
              .!create
                unsafe-coerce (.-chats client) 'JsObject
                js-object (:model model)
                  :config $ if (js-present? config) (maybe-to-js-data config) js/undefined
                  :history $ if (js-present? history) (maybe-to-js-data history) js/undefined
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'Dynamic 'String (:: 'Optional 'GenerationConfig) (:: 'Optional 'List)
        |content-config->js $ %{} 'CodeEntry (:doc "|converts ContentConfig struct to JS object for SDK calls, maps fields to camelCase JS properties")
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
                  :contents $ if (js-present? contents) (maybe-to-js-data contents) js/undefined
                  :systemInstruction $ if (js-present? sys) (maybe-to-js-data sys) js/undefined
                  :config $ js-object
                    :thinkingConfig $ or thinking js/undefined
                    :tools $ if (js-present? tools-v) (to-js-data tools-v) js/undefined
                    :toolConfig $ if (js-present? tool-config) (maybe-to-js-data tool-config) js/undefined
                    :responseModalities $ or modalities js/undefined
                    :responseMimeType $ or mime-type js/undefined
                    :cachedContent $ or cached-content js/undefined
                    :abortSignal $ or signal js/undefined
                    :httpOptions $ or http-opts js/undefined
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'ContentConfig
        |extract-content-parts $ %{} 'CodeEntry (:doc "|extracts candidates[0].content.parts from a non-streaming generateContent response")
          :code $ quote
            defn extract-content-parts (result) (-> result .-candidates .-0 .-content .-parts)
          :examples $ []
          :schema $ :: 'Fn
            {}
              :args $ [] 'Dynamic
              :return $ :: 'Optional 'List
        |extract-image-bytes $ %{} 'CodeEntry (:doc "|extracts base64 imageBytes from generatedImages[0].image of a generateImages response")
          :code $ quote
            defn extract-image-bytes (response) (-> response .-generatedImages .-0 .-image .-imageBytes)
          :examples $ []
          :schema $ :: 'Fn
            {}
              :args $ [] 'Dynamic
              :return $ :: 'Optional 'String
        |extract-outputs $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn extract-outputs (interaction)
              let
                  raw-outputs $ .-outputs interaction
                  outputs $ unsafe-coerce
                    if (js-present? raw-outputs) raw-outputs $ js-array
                    , 'JsArray
                  text-out $ -> outputs
                    .!find $ fn (o & args)
                      = (.-type o) |text
                  function-outputs $ unsafe-coerce
                    -> outputs $ .!filter
                      fn (o & args)
                        = (.-type o) |function_call
                    , 'JsArray
                  fn-calls $ -> function-outputs
                    .!map $ fn (o & args)
                      %{}? FunctionCallContent
                        :name $ .-name o
                        :arguments $ to-calcit-data (.-arguments o)
                        :id $ .-id o
                    , to-calcit-data
                %{}? ExtractedInteractionOutput
                  :text $ if (js-present? text-out)
                    unsafe-coerce (.-text text-out) 'String
                    , nil
                  :function-calls fn-calls
                  :interaction-id $ .-id interaction
                  :status $ .-status interaction
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'ExtractedInteractionOutput)
              :args $ [] 'Dynamic
        |extract-stream-chunk $ %{} 'CodeEntry (:doc "|extracts text and thinking? from a stream chunk, returns {:text :thinking?} map; handles optional chaining")
          :code $ quote
            defn extract-stream-chunk (chunk)
              let
                  part js/chunk.candidates?.[0]?.content?.parts?.[0]
                  is-thinking? $ if (js-present? part) (.-thought part) false
                  text $ if (js-present? part) (.-text part) (.-text chunk)
                  fallback $ or text (-> chunk .?-promptFeedback .?-blockReason)
                %{}? StreamChunkOutput (:text fallback) (:thinking? is-thinking?)
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'StreamChunkOutput)
              :args $ [] 'Dynamic
        |extract-text $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn extract-text (result)
              let
                  parts $ extract-content-parts result
                if (js-present? parts)
                  let
                      first-part $ .-0 parts
                    .-text first-part
                  , nil
          :examples $ []
          :schema $ :: 'Fn
            {}
              :args $ [] 'Dynamic
              :return $ :: 'Optional 'String
        |files-delete! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn files-delete! (client name cfg)
              hint-fn $ {} (:async true)
              .!delete (.-files client)
                js-object (:name name)
                  :config $ request-config->js cfg
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'Dynamic 'String 'RequestConfig
        |files-get! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn files-get! (client name cfg)
              hint-fn $ {} (:async true)
              .!get (.-files client)
                js-object (:name name)
                  :config $ request-config->js cfg
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'Dynamic 'String 'RequestConfig
        |files-list! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn files-list! (client cfg)
              hint-fn $ {} (:async true)
              .!list (.-files client)
                if (js-present? cfg)
                  js-object $ :config (list-config->js cfg)
                  , js/undefined
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'Dynamic 'ListParams
        |files-upload! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn files-upload! (client file cfg)
              hint-fn $ {} (:async true)
              .!upload (.-files client)
                js-object (:file file)
                  :config $ upload-file-config->js cfg
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'Dynamic 'Dynamic 'UploadFileConfig
        |generate-content! $ %{} 'CodeEntry (:doc "|async, calls models.generateContent with ContentConfig, returns full response (non-streaming)")
          :code $ quote
            defn generate-content! (client cfg)
              hint-fn $ {} (:async true)
              .!generateContent (.-models client) (content-config->js cfg)
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'Dynamic 'ContentConfig
        |generate-content-stream! $ %{} 'CodeEntry (:doc "|async, calls models.generateContentStream with ContentConfig, returns stream for js-for-await")
          :code $ quote
            defn generate-content-stream! (client cfg)
              hint-fn $ {} (:async true)
              .!generateContentStream (.-models client) (content-config->js cfg)
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'Dynamic 'ContentConfig
        |generate-images! $ %{} 'CodeEntry (:doc "|async, calls models.generateImages with ImageGenConfig, returns image generation response")
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
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'Dynamic 'ImageGenConfig
        |generation-config->js $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn generation-config->js (cfg)
              if (js-present? cfg)
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
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'GenerationConfig
        |inline-audio $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn inline-audio (data mime-type)
              {} $ :inline_data
                {} (:data data) (:mime_type mime-type)
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'String 'String
        |input->js $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn input->js (v)
              if (string? v)
                js-array $ js-object (:type |text) (:text v)
                if (list? v) (to-js-data v)
                  if (map? v)
                    if (contains? v :type) (to-js-data v)
                      if (contains? v :content)
                        js-array $ js-object (:type |text)
                          :text $ &map:get v :content
                        to-js-data v
                    identity v
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'T
              :generics $ [] 'T
        |interactions-cancel! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn interactions-cancel! (client id)
              hint-fn $ {} (:async true)
              .!cancel (.-interactions client) id
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'Dynamic 'String
        |interactions-create! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn interactions-create! (client params)
              hint-fn $ {} (:async true)
              unsafe-coerce
                .!create
                  unsafe-coerce (.-interactions client) 'JsObject
                  params->js params
                , 'InteractionResult
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'InteractionResult)
              :args $ [] 'Dynamic 'CreateParams
        |interactions-delete! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn interactions-delete! (client id)
              hint-fn $ {} (:async true)
              .!delete (.-interactions client) id
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'Dynamic 'String
        |interactions-get! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn interactions-get! (client id)
              hint-fn $ {} (:async true)
              .!get (.-interactions client) id
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'InteractionResult)
              :args $ [] 'Dynamic 'String
        |list-config->js $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn list-config->js (cfg)
              if (js-present? cfg)
                js-object
                  :httpOptions $ or (:http-options cfg) js/undefined
                  :abortSignal $ or (:abort-signal cfg) js/undefined
                  :pageSize $ or (:page-size cfg) js/undefined
                  :pageToken $ or (:page-token cfg) js/undefined
                  :filter $ or (:filter cfg) js/undefined
                  :queryBase $ or (:query-base cfg) js/undefined
                , js/undefined
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'ListParams
        |make-abort-signal $ %{} 'CodeEntry (:doc "|creates AbortController, stores in *abort-control atom, returns signal; pass atom for external abort control")
          :code $ quote
            defn make-abort-signal (*abort-control)
              let
                  abort $ new js/AbortController
                reset! *abort-control abort
                .-signal abort
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'Ref
        |make-http-options $ %{} 'CodeEntry (:doc "|creates httpOptions JS object with baseUrl for proxy endpoint")
          :code $ quote
            defn make-http-options (base-url)
              js-object $ :baseUrl base-url
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'String
        |make-search-tools $ %{} 'CodeEntry (:doc "|builds tools array with googleSearch and/or urlContext based on boolean flags; returns nil if neither")
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
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'Bool 'Bool
        |make-thinking-config $ %{} 'CodeEntry (:doc "|creates thinkingConfig JS object with thinkingBudget and includeThoughts fields")
          :code $ quote
            defn make-thinking-config (budget include-thoughts?)
              js-object (:thinkingBudget budget) (:includeThoughts include-thoughts?)
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'Number 'Bool
        |maybe-to-js-data $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn maybe-to-js-data (x)
              if
                or (list? x) (map? x)
                to-js-data x
                , x
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'T
              :generics $ [] 'T
        |messages->contents $ %{} 'CodeEntry (:doc "|converts Calcit messages [{:role :user/:assistant :content str}] to Gemini contents format [{role parts:[{text}]}]")
          :code $ quote
            defn messages->contents (messages)
              let
                  messages0 $ if (js-present? messages) messages ([])
                to-js-data $ map messages0
                  fn (m)
                    {}
                      :role $ if
                        = :assistant $ :role m
                        , |model |user
                      :parts $ []
                        {} $ :text (:content m)
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'List
        |models-compute-tokens! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn models-compute-tokens! (client model contents config)
              hint-fn $ {} (:async true)
              .!computeTokens (.-models client)
                js-object (:model model)
                  :contents $ maybe-to-js-data contents
                  :config $ if (js-present? config) (maybe-to-js-data config) js/undefined
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'Dynamic 'String 'Dynamic (:: 'Optional 'GenerationConfig)
        |models-count-tokens! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn models-count-tokens! (client model contents config)
              hint-fn $ {} (:async true)
              .!countTokens (.-models client)
                js-object (:model model)
                  :contents $ maybe-to-js-data contents
                  :config $ if (js-present? config) (maybe-to-js-data config) js/undefined
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'CountTokensResponse)
              :args $ [] 'Dynamic 'String 'Dynamic (:: 'Optional 'GenerationConfig)
        |models-get! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn models-get! (client model cfg)
              hint-fn $ {} (:async true)
              .!get (.-models client)
                js-object (:model model)
                  :config $ request-config->js cfg
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'Dynamic 'String 'RequestConfig
        |models-list! $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn models-list! (client cfg)
              hint-fn $ {} (:async true)
              .!list (.-models client)
                if (js-present? cfg)
                  js-object $ :config (list-config->js cfg)
                  , js/undefined
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'Dynamic 'ListParams
        |new-client $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn new-client (api-key)
              new GoogleGenAI $ js-object (:apiKey api-key)
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'String
        |new-client-with-base-url $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn new-client-with-base-url (api-key base-url)
              new GoogleGenAI $ js-object (:apiKey api-key)
                :httpOptions $ js-object (:baseUrl base-url)
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'String 'String
        |new-client-with-options $ %{} 'CodeEntry (:doc |)
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
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'ClientOptions
        |params->js $ %{} 'CodeEntry (:doc |)
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
                  :system_instruction $ if
                    js-present? $ unsafe-coerce sys 'JsObject
                    maybe-to-js-data sys
                    , js/undefined
                  :agent $ or agent js/undefined
                  :background $ or background js/undefined
                  :store $ or (:store p) js/undefined
                  :config $ if
                    js-present? $ unsafe-coerce gen-cfg 'JsObject
                    generation-config->js $ unsafe-coerce gen-cfg 'GenerationConfig
                    , js/undefined
                  :tools $ if
                    js-present? $ unsafe-coerce tools-v 'JsObject
                    to-js-data tools-v
                    , js/undefined
                  :response_modalities $ or response-modalities js/undefined
                  :response_mime_type $ or response-mime-type js/undefined
                  :response_format $ if
                    js-present? $ unsafe-coerce response-format 'JsObject
                    maybe-to-js-data response-format
                    , js/undefined
                  :abortSignal $ or signal js/undefined
                  :httpOptions $ or http-opts js/undefined
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'CreateParams
        |request-config->js $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn request-config->js (cfg)
              if (js-present? cfg)
                js-object
                  :httpOptions $ or (:http-options cfg) js/undefined
                  :abortSignal $ or (:abort-signal cfg) js/undefined
                , js/undefined
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'RequestConfig
        |text-part $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn text-part (text)
              {} $ :text text
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'String
        |upload-file-config->js $ %{} 'CodeEntry (:doc |)
          :code $ quote
            defn upload-file-config->js (cfg)
              if (js-present? cfg)
                js-object
                  :name $ or (:name cfg) js/undefined
                  :mimeType $ or (:mime-type cfg) js/undefined
                  :displayName $ or (:display-name cfg) js/undefined
                  :httpOptions $ or (:http-options cfg) js/undefined
                  :abortSignal $ or (:abort-signal cfg) js/undefined
                , js/undefined
          :examples $ []
          :schema $ :: 'Fn
            {} (:return 'Dynamic)
              :args $ [] 'UploadFileConfig
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote
          ns genai.sdk $ :require
            |@google/genai :refer $ GoogleGenAI
