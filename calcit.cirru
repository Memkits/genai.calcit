
{}
  :about "|Machine-generated snapshot. Do not edit directly — changes will be overwritten. Use `calcit query` to inspect and `calcit edit`/`calcit tree` to modify. Run `calcit docs agents --contract` before mutations; use `--full` for first orientation or changed contract digest. Manual edits must follow format and schema conventions, then run `calcit edit format`."
  :package |genai
  :entries $ {}
    :default $ {} (:description |) (:init-fn 'genai.main/main!) (:mode :js) (:reload-fn 'genai.main/reload!) (:target :node)
      :feature-policy $ {}
      :modules $ [] |respo.calcit/ |respo-ui.calcit/ |js-ffi/
      :type-slots $ {}
    :test-config $ {} (:description |) (:init-fn 'genai.test-config/main!) (:mode :js) (:reload-fn 'genai.test-config/main!) (:target :node)
      :feature-policy $ {}
      :modules $ [] |respo.calcit/ |respo-ui.calcit/ |js-ffi/
      :type-slots $ {}
    :web $ {} (:description |) (:init-fn 'genai.main/web-main!) (:mode :js) (:reload-fn 'genai.main/web-reload!) (:target :browser)
      :feature-policy $ {}
      :modules $ [] |respo.calcit/ |respo-ui.calcit/ |js-ffi/
      :type-slots $ {}
  :files $ {}
    'genai.main $ %{} 'FileEntry
      :defs $ {}
        '*store $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def *store
            atom $ {} (:result nil) (:loading? false) (:error-msg nil)
          :examples $ []
          :schema $ :: 'Ref $ :: 'Map 'Tag 'Dynamic
        'BrowserFileHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait BrowserFileHost (:type 'String)
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object)
          :schema $ :: 'Trait
        'FileInputEventHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait FileInputEventHost
            :event-target $ :: 'JsNullish 'genai.main/FileInputTargetHost
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object)
            :names $ {} $ :event-target |target
          :schema $ :: 'Trait
        'FileInputTargetHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait FileInputTargetHost
            :files $ :: 'JsNullish 'JsObject
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object)
          :schema $ :: 'Trait
        'FileReaderHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait FileReaderHost (:onload 'Dynamic) (:onerror 'Dynamic)
            :result $ :: 'JsNullish 'String
            .read-as-data-url! $ :: 'Fn $ {}
              :args $ [] 'genai.main/FileReaderHost 'Dynamic
              :return 'Unit
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object)
            :names $ {} $ :read-as-data-url! |readAsDataURL
            :writable $ #{} :onerror :onload
          :schema $ :: 'Trait
        'browser-api-key $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn browser-api-key ()
            let
                key |GEMINI_API_KEY
                window-host $ unsafe-coerce js/window 'JsObject
                raw $ js-get window-host key
              if (js-nullish? raw) (Option :none)
                Option :some $ unsafe-coerce raw 'String
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ []
            :features $ #{} :js-ffi
            :return $ :: 'calcit.core/Option 'String
        'comp-container $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-container (result loading? error-msg on-transcribe)
            div
              {} $ :style $ {} (:padding |20px) (:font-family ui/font-normal)
              div
                {} $ :style $ {} (:font-size |24px) (:font-weight |bold) (:margin-bottom |20px)
                <> "|Gemini Audio Transcription"
              div
                {} $ :style $ {}
                if loading?
                  div ({}) (<> "|Transcribing... (Please Wait)")
                  div ({}) (<> "|Select an audio file: ")
                    input $ {} (:type |file) (:accept |audio/*)
                      :on-change $ fn (e d!)
                        match
                          event-first-file $ option:unwrap-or (get e :event) nil
                          (:none) &unit
                          (:some file) (on-transcribe file)
              if (some? error-msg)
                div
                  {} $ :style $ {} (:color |red) (:margin-top |10px)
                  <> error-msg
              if (some? result)
                div
                  {} $ :style $ {} (:margin-top |20px) (:padding |15px) (:border "|1px solid #eee") (:border-radius |4px) (:background-color |#f9f9f9) (:white-space |pre-wrap) (:min-height |100px)
                  <> result
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Component)
            :args $ [] 'Dynamic 'Bool 'Dynamic 'Dynamic
            :features $ #{} :js-ffi
        'event-first-file $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn event-first-file (event)
            let
                input-event $ unsafe-coerce event 'genai.main/FileInputEventHost
                target $ input-event :event-target
              if (js-nullish? target) (Option :none)
                let
                    input-target $ unsafe-coerce target 'genai.main/FileInputTargetHost
                    files $ .-files input-target
                  if (js-nullish? files) (Option :none)
                    let
                        list-object $ unsafe-coerce files 'JsObject
                        index 0
                        file $ js-get list-object index
                      if (js-nullish? file) (Option :none)
                        Option :some $ unsafe-coerce file 'genai.main/BrowserFileHost
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'Dynamic
            :features $ #{} :js-ffi
            :return $ :: 'calcit.core/Option 'genai.main/BrowserFileHost
        'handle-transcribe! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn handle-transcribe! (client file)
            hint-fn $ {} $ :async true
            do
              reset! *store $ assoc (assoc @*store :loading? true) :error-msg nil
              try
                let
                    base64 $ js-await $ read-as-base64 file
                    mime-type $ file :type
                    cfg $ sdk/ContentConfig :model |gemini-1.5-flash :contents $ []
                      {} (:role |user)
                        :parts $ [] (sdk/text-part "|请将这段音频转录为简体中文文字。") (sdk/inline-audio base64 mime-type)
                    response $ js-await $ sdk/generate-content! client cfg
                    text $ option:unwrap-or (sdk/extract-text response) nil
                  reset! *store $ assoc (assoc @*store :result text) :loading? false
                fn (err)
                  do (js/console.error err)
                    reset! *store $ assoc (assoc @*store :loading? false) :error-msg $ str err
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] 'genai.sdk/GoogleClientHost 'genai.main/BrowserFileHost
            :features $ #{} :js-ffi
        'main! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn main! ()
            hint-fn $ {} $ :async true
            let
                api-key $ get-env |GEMINI_API_KEY
                base-url $ get-env |GEMINI_BASE_URL
              if (.none? api-key) (raise "|GEMINI_API_KEY not set")
                let
                    key $ option:unwrap api-key
                    client $ if (.some? base-url)
                      sdk/new-client-with-base-url key $ option:unwrap base-url
                      sdk/new-client key
                    params $ sdk/CreateParams :model |gemini-2.5-flash :input "|Explain how AI works in a few words."
                    interaction $ js-await $ sdk/interactions-create! client params
                    result $ sdk/extract-outputs interaction
                  println |Response: $ option:unwrap-or (get result :text) nil
                  println |Status: $ option:unwrap-or (get result :status) nil
                  println |Interaction-id: $ option:unwrap-or (get result :interaction-id) nil
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
            :features $ #{} :js-ffi
        'read-as-base64 $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn read-as-base64 (file)
            hint-fn $ {} $ :async true
            js-await $ new js/Promise $ fn (resolve reject)
              let
                  reader $ unsafe-coerce (new js/FileReader) 'genai.main/FileReaderHost
                js-set reader :onload $ fn (e)
                  let
                      raw-result $ reader :result
                    if (js-present? raw-result)
                      let
                          data-url $ unsafe-coerce raw-result 'String
                        resolve $ nth (split data-url |,) 1
                      reject "|FileReader completed without a data URL"
                js-set reader :onerror $ fn (e) (reject e)
                reader .read-as-data-url! file
          :examples $ []
          :schema $ :: 'Fn $ {} (:async true) (:return 'String)
            :args $ [] 'genai.main/BrowserFileHost
            :features $ #{} :js-ffi
        'reload! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn reload! () (println |reloaded)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
        'render-app! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-app! ()
            render! (respo.main/query-mount-target)
              comp-container
                option:unwrap-or (get @*store :result) nil
                option:unwrap-or (get @*store :loading?) false
                option:unwrap-or (get @*store :error-msg) nil
                fn (file)
                  let
                      api-key $ match (get-env |GEMINI_API_KEY)
                        (:some key) (Option :some key)
                        (:none) (browser-api-key)
                    match api-key
                      (:none) (swap! *store assoc :error-msg "|Missing GEMINI_API_KEY")
                      (:some key)
                        let
                            client $ sdk/new-client key
                          handle-transcribe! client file
              fn (op) &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
            :features $ #{} :js-ffi
        'web-main! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn web-main! ()
            do (println "|Web app started.") (render-app!)
              add-watch *store :rerender $ fn (s r) (render-app!)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
        'web-reload! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn web-reload! ()
            do (clear-cache!) (render-app!) (println |web-reloaded)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns genai.main
          :require (genai.sdk :as sdk)
            respo.core :refer $ render! clear-cache! defcomp <> div button input span
            respo-ui.core :as ui
    'genai.sdk $ %{} 'FileEntry
      :defs $ {}
        'CachesHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait CachesHost
            .create $ :: 'Fn $ {}
              :args $ [] 'genai.sdk/CachesHost 'Dynamic
              :return 'Dynamic
            .delete $ :: 'Fn $ {}
              :args $ [] 'genai.sdk/CachesHost 'Dynamic
              :return 'Dynamic
            .get $ :: 'Fn $ {}
              :args $ [] 'genai.sdk/CachesHost 'Dynamic
              :return 'Dynamic
            .list $ :: 'Fn $ {}
              :args $ [] 'genai.sdk/CachesHost 'Dynamic
              :return 'Dynamic
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object)
          :schema $ :: 'Trait
        'CandidateHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait CandidateHost
            :content $ :: 'JsNullish 'genai.sdk/ContentHost
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object)
          :schema $ :: 'Trait
        'ChatHistoryTurn $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct ChatHistoryTurn
            :role $ :: 'Optional 'String
            :parts 'List
          :examples $ []
          :schema $ :: 'Enum
        'ChatHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait ChatHost
            .getHistory $ :: 'Fn $ {}
              :args $ [] 'genai.sdk/ChatHost
              :return 'Dynamic
            .sendMessage $ :: 'Fn $ {}
              :args $ [] 'genai.sdk/ChatHost 'Dynamic
              :return 'Dynamic
            .sendMessageStream $ :: 'Fn $ {}
              :args $ [] 'genai.sdk/ChatHost 'Dynamic
              :return 'Dynamic
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object)
          :schema $ :: 'Trait
        'ChatsHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait ChatsHost
            .create $ :: 'Fn $ {}
              :args $ [] 'genai.sdk/ChatsHost 'Dynamic
              :return 'genai.sdk/ChatHost
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object)
          :schema $ :: 'Trait
        'ClientOptions $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct ClientOptions
            :api-key $ :: 'Option 'String
            :vertexai $ :: 'Option 'Bool
            :project $ :: 'Option 'String
            :location $ :: 'Option 'String
            :api-version $ :: 'Option 'String
            :http-options $ :: 'Option 'Dynamic
          :examples $ []
          :schema $ :: 'StructDef
        'ContentConfig $ %{} 'CodeEntry
          :doc "|config struct for generateContent/generateContentStream, fields: model contents system-instruction thinking-config tools response-modalities response-mime-type abort-signal http-options"
          :code $ quote $ defstruct ContentConfig (:model 'String) (:contents 'Dynamic)
            :system-instruction $ :: 'Option 'Dynamic
            :thinking-config $ :: 'Option 'Dynamic
            :tools $ :: 'Option $ :: 'List 'Dynamic
            :tool-config $ :: 'Option 'Dynamic
            :response-modalities $ :: 'Option $ :: 'List 'Dynamic
            :response-mime-type $ :: 'Option 'String
            :cached-content $ :: 'Option 'String
            :abort-signal $ :: 'Option 'Dynamic
            :http-options $ :: 'Option 'Dynamic
          :examples $ []
          :schema $ :: 'StructDef
        'ContentHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait ContentHost
            :parts $ :: 'JsNullish 'JsArray
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object)
          :schema $ :: 'Trait
        'ContentOutput $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defenum ContentOutput (:text TextContent) (:image ImageContent) (:thought ThoughtContent) (:function-call FunctionCallContent) (:function-result FunctionResultContent)
          :examples $ []
          :schema $ :: 'Enum
        'CountTokensResponse $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct CountTokensResponse (:totalTokens 'Number)
            :sdkHttpResponse $ :: 'Optional 'Dynamic
          :examples $ []
          :schema $ :: 'Enum
        'CreateCachedContentConfig $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct CreateCachedContentConfig
            :ttl $ :: 'Option 'String
            :expire-time $ :: 'Option 'String
            :display-name $ :: 'Option 'String
            :contents $ :: 'Option 'Dynamic
            :system-instruction $ :: 'Option 'Dynamic
            :tools $ :: 'Option $ :: 'List 'Dynamic
            :tool-config $ :: 'Option 'Dynamic
            :kms-key-name $ :: 'Option 'String
            :http-options $ :: 'Option 'Dynamic
            :abort-signal $ :: 'Option 'Dynamic
          :examples $ []
          :schema $ :: 'StructDef
        'CreateParams $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct CreateParams (:model 'String) (:input 'Dynamic)
            :system-instruction $ :: 'Option 'Dynamic
            :previous-interaction-id $ :: 'Option 'String
            :agent $ :: 'Option 'String
            :background $ :: 'Option 'Bool
            :store $ :: 'Option 'Bool
            :generation-config $ :: 'Option 'genai.sdk/GenerationConfig
            :tools $ :: 'Option $ :: 'List 'Dynamic
            :response-modalities $ :: 'Option $ :: 'List 'Dynamic
            :response-format $ :: 'Option 'Dynamic
            :response-mime-type $ :: 'Option 'String
            :abort-signal $ :: 'Option 'Dynamic
            :http-options $ :: 'Option 'Dynamic
          :examples $ []
          :schema $ :: 'StructDef
        'ExtractedInteractionOutput $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct ExtractedInteractionOutput
            :text $ :: 'Optional 'String
            :function-calls $ :: 'List FunctionCallContent
            :interaction-id 'String
            :status InteractionStatus
          :examples $ []
          :schema $ :: 'Enum
        'FilesHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait FilesHost
            .delete $ :: 'Fn $ {}
              :args $ [] 'genai.sdk/FilesHost 'Dynamic
              :return 'Dynamic
            .get $ :: 'Fn $ {}
              :args $ [] 'genai.sdk/FilesHost 'Dynamic
              :return 'Dynamic
            .list $ :: 'Fn $ {}
              :args $ [] 'genai.sdk/FilesHost 'Dynamic
              :return 'Dynamic
            .upload $ :: 'Fn $ {}
              :args $ [] 'genai.sdk/FilesHost 'Dynamic
              :return 'Dynamic
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object)
          :schema $ :: 'Trait
        'FunctionCallContent $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct FunctionCallContent (:id 'String) (:name 'String) (:arguments 'Map)
          :examples $ []
          :schema $ :: 'Enum
        'FunctionResultContent $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct FunctionResultContent (:call-id 'String) (:result 'Dynamic)
            :is-error $ :: 'Optional 'Bool
            :name $ :: 'Optional 'String
          :examples $ []
          :schema $ :: 'Enum
        'GenerateResponseHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait GenerateResponseHost
            :candidates $ :: 'JsNullish 'JsArray
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object)
          :schema $ :: 'Trait
        'GenerationConfig $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct GenerationConfig
            :temperature $ :: 'Option 'Number
            :max-output-tokens $ :: 'Option 'Number
            :top-p $ :: 'Option 'Number
            :top-k $ :: 'Option 'Number
            :candidate-count $ :: 'Option 'Number
            :stop-sequences $ :: 'Option $ :: 'List 'Dynamic
            :response-mime-type $ :: 'Option 'String
          :examples $ []
          :schema $ :: 'StructDef
        'GoogleClientHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait GoogleClientHost (:caches 'genai.sdk/CachesHost) (:chats 'genai.sdk/ChatsHost) (:files 'genai.sdk/FilesHost) (:models 'genai.sdk/ModelsHost) (:interactions 'genai.sdk/InteractionsHost)
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object)
          :schema $ :: 'Trait
        'ImageContent $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct ImageContent
            :data $ :: 'Optional 'String
            :mime-type $ :: 'Optional 'String
            :uri $ :: 'Optional 'String
          :examples $ []
          :schema $ :: 'Enum
        'ImageGenConfig $ %{} 'CodeEntry
          :doc "|config struct for generateImages, fields: model prompt number-of-images include-rai-reason abort-signal http-options"
          :code $ quote $ defstruct ImageGenConfig (:model 'String) (:prompt 'String)
            :number-of-images $ :: 'Option 'Number
            :include-rai-reason $ :: 'Option 'Bool
            :abort-signal $ :: 'Option 'Dynamic
            :http-options $ :: 'Option 'Dynamic
          :examples $ []
          :schema $ :: 'StructDef
        'Interaction $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct Interaction (:id 'String) (:status InteractionStatus)
            :outputs $ :: 'Optional 'List
            :model $ :: 'Optional 'String
            :created $ :: 'Optional 'String
            :updated $ :: 'Optional 'String
            :usage $ :: 'Optional Usage
          :examples $ []
          :schema $ :: 'Enum
        'InteractionOutputHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait InteractionOutputHost (:type 'String)
            :text $ :: 'JsNullish 'String
            :name 'String
            :arguments 'JsObject
            :id 'String
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object)
          :schema $ :: 'Trait
        'InteractionResponseHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait InteractionResponseHost
            :outputs $ :: 'JsNullish 'JsArray
            :id 'String
            :status 'genai.sdk/InteractionStatus
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object)
          :schema $ :: 'Trait
        'InteractionResult $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct InteractionResult (:id 'String) (:status InteractionStatus)
            :outputs $ :: 'Optional 'List
            :model $ :: 'Optional 'String
            :created $ :: 'Optional 'String
            :updated $ :: 'Optional 'String
            :role $ :: 'Optional 'String
            :object $ :: 'Optional 'String
            :usage $ :: 'Optional 'SdkUsage
          :examples $ []
          :schema $ :: 'Enum
        'InteractionStatus $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defenum InteractionStatus (:completed 'Dynamic) (:failed 'Dynamic) (:in-progress 'Dynamic) (:cancelled 'Dynamic) (:incomplete 'Dynamic) (:requires-action 'Dynamic)
          :examples $ []
          :schema $ :: 'Enum
        'InteractionsHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait InteractionsHost
            .cancel $ :: 'Fn $ {}
              :args $ [] 'genai.sdk/InteractionsHost 'Dynamic
              :return 'Dynamic
            .create $ :: 'Fn $ {}
              :args $ [] 'genai.sdk/InteractionsHost 'Dynamic
              :return 'genai.sdk/InteractionResponseHost
            .delete $ :: 'Fn $ {}
              :args $ [] 'genai.sdk/InteractionsHost 'Dynamic
              :return 'Dynamic
            .get $ :: 'Fn $ {}
              :args $ [] 'genai.sdk/InteractionsHost 'Dynamic
              :return 'Dynamic
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object)
          :schema $ :: 'Trait
        'ListParams $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct ListParams
            :page-size $ :: 'Option 'Number
            :page-token $ :: 'Option 'String
            :filter $ :: 'Option 'String
            :query-base $ :: 'Option 'Bool
            :http-options $ :: 'Option 'Dynamic
            :abort-signal $ :: 'Option 'Dynamic
          :examples $ []
          :schema $ :: 'StructDef
        'ModelsHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait ModelsHost
            .generateContent $ :: 'Fn $ {}
              :args $ [] 'genai.sdk/ModelsHost 'Dynamic
              :return 'genai.sdk/GenerateResponseHost
            .generateContentStream $ :: 'Fn $ {}
              :args $ [] 'genai.sdk/ModelsHost 'Dynamic
              :return 'Dynamic
            .generateImages $ :: 'Fn $ {}
              :args $ [] 'genai.sdk/ModelsHost 'Dynamic
              :return 'Dynamic
            .computeTokens $ :: 'Fn $ {}
              :args $ [] 'genai.sdk/ModelsHost 'Dynamic
              :return 'Dynamic
            .countTokens $ :: 'Fn $ {}
              :args $ [] 'genai.sdk/ModelsHost 'Dynamic
              :return 'Dynamic
            .get $ :: 'Fn $ {}
              :args $ [] 'genai.sdk/ModelsHost 'Dynamic
              :return 'Dynamic
            .list $ :: 'Fn $ {}
              :args $ [] 'genai.sdk/ModelsHost 'Dynamic
              :return 'Dynamic
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object)
          :schema $ :: 'Trait
        'PartHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait PartHost
            :text $ :: 'JsNullish 'String
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object)
          :schema $ :: 'Trait
        'RequestConfig $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct RequestConfig
            :http-options $ :: 'Option 'Dynamic
            :abort-signal $ :: 'Option 'Dynamic
          :examples $ []
          :schema $ :: 'StructDef
        'SdkUsage $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct SdkUsage
            :total_tokens $ :: 'Optional 'Number
            :total_input_tokens $ :: 'Optional 'Number
            :input_tokens_by_modality $ :: 'Optional 'List
            :total_cached_tokens $ :: 'Optional 'Number
            :total_output_tokens $ :: 'Optional 'Number
            :total_tool_use_tokens $ :: 'Optional 'Number
            :total_thought_tokens $ :: 'Optional 'Number
          :examples $ []
          :schema $ :: 'Enum
        'StreamChunkOutput $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct StreamChunkOutput
            :text $ :: 'Optional 'String
            :thinking? 'Bool
          :examples $ []
          :schema $ :: 'Enum
        'TextContent $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct TextContent
            :text $ :: 'Optional 'String
          :examples $ []
          :schema $ :: 'Enum
        'ThoughtContent $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct ThoughtContent
            :signature $ :: 'Optional 'String
            :summary $ :: 'Optional 'List
          :examples $ []
          :schema $ :: 'Enum
        'Turn $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct Turn
            :role $ :: 'Optional 'String
            :content 'Dynamic
          :examples $ []
          :schema $ :: 'Enum
        'UploadFileConfig $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct UploadFileConfig
            :name $ :: 'Option 'String
            :mime-type $ :: 'Option 'String
            :display-name $ :: 'Option 'String
            :http-options $ :: 'Option 'Dynamic
            :abort-signal $ :: 'Option 'Dynamic
          :examples $ []
          :schema $ :: 'StructDef
        'Usage $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct Usage
            :input-tokens $ :: 'Optional 'Number
            :output-tokens $ :: 'Optional 'Number
            :total-tokens $ :: 'Optional 'Number
          :examples $ []
          :schema $ :: 'Enum
        'cached-content-config->js $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn cached-content-config->js (cfg)
            let
                contents $ :contents cfg
                sys $ :system-instruction cfg
                tools-v $ :tools cfg
                tool-config $ :tool-config cfg
              js-object
                :ttl $ option->js $ :ttl cfg
                :expireTime $ option->js $ :expire-time cfg
                :displayName $ option->js $ :display-name cfg
                :contents $ option->js contents
                :systemInstruction $ option->js sys
                :tools $ option->js tools-v
                :toolConfig $ option->js tool-config
                :kmsKeyName $ option->js $ :kms-key-name cfg
                :httpOptions $ option->js $ :http-options cfg
                :abortSignal $ option->js $ :abort-signal cfg
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'CreateCachedContentConfig
            :features $ #{} :js-ffi
        'caches-create! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn caches-create! (client model cfg)
            hint-fn $ {} $ :async true
            .create
              unsafe-coerce (.-caches client) 'JsObject
              js-object (:model model)
                :config $ cached-content-config->js cfg
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost 'String 'CreateCachedContentConfig
            :features $ #{} :js-ffi
        'caches-delete! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn caches-delete! (client name cfg)
            hint-fn $ {} $ :async true
            .delete (.-caches client)
              js-object (:name name)
                :config $ request-config->js cfg
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost 'String 'RequestConfig
            :features $ #{} :js-ffi
        'caches-get! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn caches-get! (client name cfg)
            hint-fn $ {} $ :async true
            .get (.-caches client)
              js-object (:name name)
                :config $ request-config->js cfg
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost 'String 'RequestConfig
            :features $ #{} :js-ffi
        'caches-list! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn caches-list! (client cfg)
            hint-fn $ {} $ :async true
            .list (.-caches client)
              if (js-present? cfg)
                js-object $ :config $ list-config->js cfg
                , js/undefined
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost 'ListParams
            :features $ #{} :js-ffi
        'chat-get-history $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn chat-get-history (chat)
            to-calcit-data $ .getHistory chat
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'genai.sdk/ChatHost
            :features $ #{} :js-ffi
            :return $ :: 'List 'ChatHistoryTurn
        'chat-send-message! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn chat-send-message! (chat message config)
            hint-fn $ {} $ :async true
            .sendMessage chat $ js-object
              :message $ maybe-to-js-data message
              :config $ if (js-present? config) (maybe-to-js-data config) js/undefined
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/ChatHost 'Dynamic $ :: 'Optional 'GenerationConfig
            :features $ #{} :js-ffi
        'chat-send-message-stream! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn chat-send-message-stream! (chat message config)
            hint-fn $ {} $ :async true
            .sendMessageStream chat $ js-object
              :message $ maybe-to-js-data message
              :config $ if (js-present? config) (maybe-to-js-data config) js/undefined
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/ChatHost 'Dynamic $ :: 'Optional 'GenerationConfig
            :features $ #{} :js-ffi
        'chats-create $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn chats-create (client model config history)
            .create
              unsafe-coerce (.-chats client) 'JsObject
              js-object (:model model)
                :config $ if (js-present? config) (maybe-to-js-data config) js/undefined
                :history $ if (js-present? history) (maybe-to-js-data history) js/undefined
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'genai.sdk/ChatHost)
            :args $ [] 'genai.sdk/GoogleClientHost 'String (:: 'Optional 'GenerationConfig) (:: 'Optional 'List)
            :features $ #{} :js-ffi
        'content-config->js $ %{} 'CodeEntry
          :doc "|converts ContentConfig struct to JS object for SDK calls, maps fields to camelCase JS properties"
          :code $ quote $ defn content-config->js (cfg)
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
                :contents $ maybe-to-js-data contents
                :config $ js-object
                  :systemInstruction $ option->js sys
                  :thinkingConfig $ option->js thinking
                  :tools $ option->js tools-v
                  :toolConfig $ option->js tool-config
                  :responseModalities $ option->js modalities
                  :responseMimeType $ option->js mime-type
                  :cachedContent $ option->js cached-content
                  :abortSignal $ option->js signal
                  :httpOptions $ option->js http-opts
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'ContentConfig
            :features $ #{} :js-ffi
        'extract-content-parts $ %{} 'CodeEntry
          :doc "|extracts candidates[0].content.parts from a non-streaming generateContent response"
          :code $ quote $ defn extract-content-parts (result) (-> result .-candidates .-0 .-content .-parts)
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'Dynamic
            :return $ :: 'Optional 'List
        'extract-image-bytes $ %{} 'CodeEntry
          :doc "|extracts base64 imageBytes from generatedImages[0].image of a generateImages response"
          :code $ quote $ defn extract-image-bytes (response) (-> response .-generatedImages .-0 .-image .-imageBytes)
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'Dynamic
            :return $ :: 'Optional 'String
        'extract-outputs $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn extract-outputs (interaction)
            let
                raw-outputs $ .-outputs interaction
                outputs $ unsafe-coerce
                  if (js-present? raw-outputs) raw-outputs $ js-array
                  , 'JsArray
                text-out $ -> outputs $ .!find
                  fn (o & args)
                    let
                        output $ unsafe-coerce o 'genai.sdk/InteractionOutputHost
                      = (.-type output) |text
                function-outputs $ unsafe-coerce
                  -> outputs $ .!filter $ fn (o & args)
                    let
                        output $ unsafe-coerce o 'genai.sdk/InteractionOutputHost
                      = (.-type output) |function_call
                  , 'JsArray
                fn-calls $ -> function-outputs
                  .!map $ fn (o & args)
                    let
                        output $ unsafe-coerce o 'genai.sdk/InteractionOutputHost
                      %{} FunctionCallContent
                        :name $ .-name output
                        :arguments $ to-calcit-data $ .-arguments output
                        :id $ .-id output
                  , to-calcit-data
              %{} ExtractedInteractionOutput
                :text $ if (js-present? text-out)
                  let
                      output $ unsafe-coerce text-out 'genai.sdk/InteractionOutputHost
                      text-value $ .-text output
                    if (js-present? text-value) (unsafe-coerce text-value 'String) nil
                  , nil
                :function-calls fn-calls
                :interaction-id $ .-id interaction
                :status $ .-status interaction
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/InteractionResponseHost
            :features $ #{} :js-ffi
        'extract-stream-chunk $ %{} 'CodeEntry
          :doc "|extracts text and thinking? from a stream chunk, returns {:text :thinking?} map; handles optional chaining"
          :code $ quote $ defn extract-stream-chunk (chunk)
            let
                part js/chunk.candidates?.[0]?.content?.parts?.[0]
                is-thinking? $ if (js-present? part) (.-thought part) false
                text $ if (js-present? part) (.-text part) (.-text chunk)
                fallback $ or text $ -> chunk .?-promptFeedback .?-blockReason
              %{} StreamChunkOutput (:text fallback) (:thinking? is-thinking?)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'StreamChunkOutput)
            :args $ [] 'Dynamic
            :features $ #{} :js-ffi
        'extract-text $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn extract-text (result)
            let
                candidates $ result :candidates
              if (js-nullish? candidates) (Option :none)
                let
                    candidates-array $ unsafe-coerce candidates 'JsObject
                    index 0
                    candidate-value $ js-get candidates-array index
                  if (js-nullish? candidate-value) (Option :none)
                    let
                        candidate $ unsafe-coerce candidate-value 'genai.sdk/CandidateHost
                        content-value $ candidate :content
                      if (js-nullish? content-value) (Option :none)
                        let
                            content $ unsafe-coerce content-value 'genai.sdk/ContentHost
                            parts $ content :parts
                          if (js-nullish? parts) (Option :none)
                            let
                                parts-array $ unsafe-coerce parts 'JsObject
                                part-value $ js-get parts-array index
                              if (js-nullish? part-value) (Option :none)
                                let
                                    part $ unsafe-coerce part-value 'genai.sdk/PartHost
                                    text-value $ part :text
                                  if (js-nullish? text-value) (Option :none)
                                    Option :some $ unsafe-coerce text-value 'String
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'genai.sdk/GenerateResponseHost
            :features $ #{} :js-ffi
            :return $ :: 'calcit.core/Option 'String
        'files-delete! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn files-delete! (client name cfg)
            hint-fn $ {} $ :async true
            .delete (.-files client)
              js-object (:name name)
                :config $ request-config->js cfg
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost 'String 'RequestConfig
            :features $ #{} :js-ffi
        'files-get! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn files-get! (client name cfg)
            hint-fn $ {} $ :async true
            .get (.-files client)
              js-object (:name name)
                :config $ request-config->js cfg
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost 'String 'RequestConfig
            :features $ #{} :js-ffi
        'files-list! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn files-list! (client cfg)
            hint-fn $ {} $ :async true
            .list (.-files client)
              if (js-present? cfg)
                js-object $ :config $ list-config->js cfg
                , js/undefined
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost 'ListParams
            :features $ #{} :js-ffi
        'files-upload! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn files-upload! (client file cfg)
            hint-fn $ {} $ :async true
            .upload (.-files client)
              js-object (:file file)
                :config $ upload-file-config->js cfg
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost 'Dynamic 'UploadFileConfig
            :features $ #{} :js-ffi
        'generate-content! $ %{} 'CodeEntry
          :doc "|async, calls models.generateContent with ContentConfig, returns full response (non-streaming)"
          :code $ quote $ defn generate-content! (client cfg)
            hint-fn $ {} $ :async true
            .generateContent (.-models client) (content-config->js cfg)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'genai.sdk/GenerateResponseHost)
            :args $ [] 'genai.sdk/GoogleClientHost 'genai.sdk/ContentConfig
            :features $ #{} :js-ffi
        'generate-content-stream! $ %{} 'CodeEntry
          :doc "|async, calls models.generateContentStream with ContentConfig, returns stream for js-for-await"
          :code $ quote $ defn generate-content-stream! (client cfg)
            hint-fn $ {} $ :async true
            .generateContentStream (.-models client) (content-config->js cfg)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost 'ContentConfig
            :features $ #{} :js-ffi
        'generate-images! $ %{} 'CodeEntry
          :doc "|async, calls models.generateImages with ImageGenConfig, returns image generation response"
          :code $ quote $ defn generate-images! (client cfg)
            hint-fn $ {} $ :async true
            let
                model $ :model cfg
                prompt $ :prompt cfg
                signal $ :abort-signal cfg
                http-opts $ :http-options cfg
                num-images $ either (:number-of-images cfg) 1
                include-rai $ :include-rai-reason cfg
              .generateImages (.-models client)
                js-object (:model model) (:prompt prompt)
                  :config $ js-object (:numberOfImages num-images)
                    :includeRaiReason $ or include-rai js/undefined
                    :httpOptions $ or http-opts js/undefined
                    :signal $ or signal js/undefined
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost 'ImageGenConfig
            :features $ #{} :js-ffi
        'generation-config->js $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn generation-config->js (cfg)
            js-object
              :temperature $ option->js $ :temperature cfg
              :maxOutputTokens $ option->js $ :max-output-tokens cfg
              :topP $ option->js $ :top-p cfg
              :topK $ option->js $ :top-k cfg
              :candidateCount $ option->js $ :candidate-count cfg
              :stopSequences $ option->js $ :stop-sequences cfg
              :responseMimeType $ option->js $ :response-mime-type cfg
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'GenerationConfig
            :features $ #{} :js-ffi
        'inline-audio $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn inline-audio (data mime-type)
            {} $ :inline_data $ {} (:data data) (:mime_type mime-type)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'String 'String
        'input->js $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn input->js (v)
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
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'T
            :features $ #{} :js-ffi
            :generics $ [] 'T
        'interactions-cancel! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn interactions-cancel! (client id)
            hint-fn $ {} $ :async true
            .cancel (.-interactions client) id
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost 'String
            :features $ #{} :js-ffi
        'interactions-create! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn interactions-create! (client params)
            hint-fn $ {} $ :async true
            .create (.-interactions client) (params->js params)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'genai.sdk/InteractionResponseHost)
            :args $ [] 'genai.sdk/GoogleClientHost 'genai.sdk/CreateParams
            :features $ #{} :js-ffi
        'interactions-delete! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn interactions-delete! (client id)
            hint-fn $ {} $ :async true
            .delete (.-interactions client) id
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost 'String
            :features $ #{} :js-ffi
        'interactions-get! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn interactions-get! (client id)
            hint-fn $ {} $ :async true
            .get (.-interactions client) id
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'InteractionResult)
            :args $ [] 'genai.sdk/GoogleClientHost 'String
            :features $ #{} :js-ffi
        'list-config->js $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn list-config->js (cfg)
            js-object
              :httpOptions $ option->js $ :http-options cfg
              :abortSignal $ option->js $ :abort-signal cfg
              :pageSize $ option->js $ :page-size cfg
              :pageToken $ option->js $ :page-token cfg
              :filter $ option->js $ :filter cfg
              :queryBase $ option->js $ :query-base cfg
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'ListParams
            :features $ #{} :js-ffi
        'make-abort-signal $ %{} 'CodeEntry
          :doc "|creates AbortController, stores in *abort-control atom, returns signal; pass atom for external abort control"
          :code $ quote $ defn make-abort-signal (*abort-control)
            let
                abort $ new js/AbortController
              reset! *abort-control abort
              .-signal abort
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'Ref
            :features $ #{} :js-ffi
        'make-http-options $ %{} 'CodeEntry
          :doc "|creates httpOptions JS object with baseUrl for proxy endpoint"
          :code $ quote $ defn make-http-options (base-url)
            js-object $ :baseUrl base-url
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'String
            :features $ #{} :js-ffi
        'make-search-tools $ %{} 'CodeEntry
          :doc "|builds tools array with googleSearch and/or urlContext based on boolean flags; returns nil if neither"
          :code $ quote $ defn make-search-tools (search? has-url?)
            let
                t $ ->
                  js-array
                    if search? $ js-object $ :googleSearch (js-object)
                    if has-url? $ js-object $ :urlContext (js-object)
                  .!filter $ fn (x & _a) x
              if
                = 0 $ .-length t
                , nil t
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'Bool 'Bool
            :features $ #{} :js-ffi
        'make-thinking-config $ %{} 'CodeEntry
          :doc "|creates thinkingConfig JS object with thinkingBudget and includeThoughts fields"
          :code $ quote $ defn make-thinking-config (budget include-thoughts?)
            js-object (:thinkingBudget budget) (:includeThoughts include-thoughts?)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'Number 'Bool
            :features $ #{} :js-ffi
        'maybe-to-js-data $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn maybe-to-js-data (x)
            if
              or (list? x) (map? x)
              to-js-data x
              , x
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'T
            :features $ #{} :js-ffi
            :generics $ [] 'T
        'messages->contents $ %{} 'CodeEntry
          :doc "|converts Calcit messages [{:role :user/:assistant :content str}] to Gemini contents format [{role parts:[{text}]}]"
          :code $ quote $ defn messages->contents (messages)
            let
                messages0 $ if (js-present? messages) messages $ []
              to-js-data $ map messages0 $ fn (m)
                {}
                  :role $ if
                    = :assistant $ :role m
                    , |model |user
                  :parts $ [] $ {}
                    :text $ :content m
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'List
            :features $ #{} :js-ffi
        'models-compute-tokens! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn models-compute-tokens! (client model contents config)
            hint-fn $ {} $ :async true
            .computeTokens (.-models client)
              js-object (:model model)
                :contents $ maybe-to-js-data contents
                :config $ if (js-present? config) (maybe-to-js-data config) js/undefined
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost 'String 'Dynamic $ :: 'Optional 'GenerationConfig
            :features $ #{} :js-ffi
        'models-count-tokens! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn models-count-tokens! (client model contents config)
            hint-fn $ {} $ :async true
            .countTokens (.-models client)
              js-object (:model model)
                :contents $ maybe-to-js-data contents
                :config $ if (js-present? config) (maybe-to-js-data config) js/undefined
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'CountTokensResponse)
            :args $ [] 'genai.sdk/GoogleClientHost 'String 'Dynamic $ :: 'Optional 'GenerationConfig
            :features $ #{} :js-ffi
        'models-get! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn models-get! (client model cfg)
            hint-fn $ {} $ :async true
            .get (.-models client)
              js-object (:model model)
                :config $ request-config->js cfg
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost 'String 'RequestConfig
            :features $ #{} :js-ffi
        'models-list! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn models-list! (client cfg)
            hint-fn $ {} $ :async true
            .list (.-models client)
              if (js-present? cfg)
                js-object $ :config $ list-config->js cfg
                , js/undefined
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost 'ListParams
            :features $ #{} :js-ffi
        'new-client $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn new-client (api-key)
            unsafe-coerce
              new GoogleGenAI $ js-object $ :apiKey api-key
              , 'genai.sdk/GoogleClientHost
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'genai.sdk/GoogleClientHost)
            :args $ [] 'String
            :features $ #{} :js-ffi
        'new-client-with-base-url $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn new-client-with-base-url (api-key base-url)
            unsafe-coerce
              new GoogleGenAI $ js-object (:apiKey api-key)
                :httpOptions $ js-object $ :baseUrl base-url
              , 'genai.sdk/GoogleClientHost
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'genai.sdk/GoogleClientHost)
            :args $ [] 'String 'String
            :features $ #{} :js-ffi
        'new-client-with-options $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn new-client-with-options (options)
            unsafe-coerce
              new GoogleGenAI $ js-object
                :apiKey $ option->js $ :api-key options
                :vertexai $ option->js $ :vertexai options
                :project $ option->js $ :project options
                :location $ option->js $ :location options
                :apiVersion $ option->js $ :api-version options
                :httpOptions $ option->js $ :http-options options
              , 'genai.sdk/GoogleClientHost
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'genai.sdk/GoogleClientHost)
            :args $ [] 'ClientOptions
            :features $ #{} :js-ffi
        'option->js $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn option->js (value)
            match value
              (:some payload) (maybe-to-js-data payload)
              (:none) js/undefined
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] $ :: 'Option 'T
            :features $ #{} :js-ffi
            :generics $ [] 'T
        'params->js $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn params->js (p)
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
                :previous_interaction_id $ option->js prev-id
                :system_instruction $ option->js sys
                :agent $ option->js agent
                :background $ option->js background
                :store $ option->js $ :store p
                :config $ match gen-cfg
                  (:some config) (generation-config->js config)
                  (:none) js/undefined
                :tools $ option->js tools-v
                :response_modalities $ option->js response-modalities
                :response_mime_type $ option->js response-mime-type
                :response_format $ option->js response-format
                :abortSignal $ option->js signal
                :httpOptions $ option->js http-opts
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'CreateParams
            :features $ #{} :js-ffi
        'request-config->js $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn request-config->js (cfg)
            js-object
              :httpOptions $ option->js $ :http-options cfg
              :abortSignal $ option->js $ :abort-signal cfg
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'RequestConfig
            :features $ #{} :js-ffi
        'text-part $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn text-part (text)
            {} $ :text text
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'String
        'upload-file-config->js $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn upload-file-config->js (cfg)
            js-object
              :name $ option->js $ :name cfg
              :mimeType $ option->js $ :mime-type cfg
              :displayName $ option->js $ :display-name cfg
              :httpOptions $ option->js $ :http-options cfg
              :abortSignal $ option->js $ :abort-signal cfg
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'UploadFileConfig
            :features $ #{} :js-ffi
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns genai.sdk
          :require $ |@google/genai :refer $ GoogleGenAI
    'genai.test-config $ %{} 'FileEntry
      :defs $ {} $ 'main!
        %{} 'CodeEntry (:doc |)
          :code $ quote $ defn main! ()
            assert=
              {} (:model |fixture)
                :input $ [] $ {} (:type |text) (:text |hello)
                :background false
                :store false
                :config $ {} (:temperature 0) (:maxOutputTokens 12)
              match
                try-parse-json $ js-ffi.contract/expect-string |request-json $ js/JSON.stringify
                  genai.sdk/params->js $ genai.sdk/CreateParams :model |fixture :input |hello :background (Option :some false) :store (Option :some false) :generation-config $ Option :some
                    genai.sdk/GenerationConfig :temperature (Option :some 0) :max-output-tokens $ Option :some 12
                (:ok payload) payload
                (:err message) (raise message)
            assert=
              {} (:model |fixture) (:contents |hello)
                :config $ {} (:systemInstruction |system)
                  :responseModalities $ [] |TEXT
              match
                try-parse-json $ js-ffi.contract/expect-string |content-json $ js/JSON.stringify
                  genai.sdk/content-config->js $ genai.sdk/ContentConfig :model |fixture :contents |hello :system-instruction (Option :some |system) :response-modalities $ Option :some ([] |TEXT)
                (:ok payload) payload
                (:err message) (raise message)
            println |Offline-request-config-tests-passed
            , &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
            :features $ #{} :js-ffi
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns genai.test-config
          :require (genai.sdk :as sdk) (js-ffi.contract :as contract)
