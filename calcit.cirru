
{}
  :about "|Machine-generated snapshot. Do not edit directly — changes will be overwritten. Use `calcit query` to inspect and `calcit edit`/`calcit tree` to modify. Run `calcit docs agents --contract` before mutations; use `--full` for first orientation or changed contract digest. Manual edits must follow format and schema conventions, then run `calcit edit format`."
  :package |genai
  :entries $ {}
    :default $ {} (:description |) (:init-fn 'genai.main/main!) (:mode :js) (:reload-fn 'genai.main/reload!) (:target :node)
      :feature-policy $ {}
      :modules $ [] |respo.calcit/ |respo-ui.calcit/ |js-ffi/
      :type-slots $ {} $ :dispatch-op |genai.main/DispatchOp
    :test-config $ {} (:description |) (:init-fn 'genai.test-config/main!) (:mode :js) (:reload-fn 'genai.test-config/main!) (:target :node)
      :feature-policy $ {}
      :modules $ [] |respo.calcit/ |respo-ui.calcit/ |js-ffi/
      :type-slots $ {} $ :dispatch-op |genai.main/DispatchOp
    :web $ {} (:description |) (:init-fn 'genai.main/web-main!) (:mode :js) (:reload-fn 'genai.main/web-reload!) (:target :browser)
      :feature-policy $ {}
      :modules $ [] |respo.calcit/ |respo-ui.calcit/ |js-ffi/
      :type-slots $ {} $ :dispatch-op |genai.main/DispatchOp
  :files $ {}
    'genai.main $ %{} 'FileEntry
      :defs $ {}
        '*store $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defref *store
            AppState :result (Option :none) :loading? false :error-msg $ Option :none
          :examples $ []
          :schema $ :: 'Ref 'genai.main/AppState
        'AppState $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct AppState
            :result $ :: 'Option 'String
            :loading? 'Bool
            :error-msg $ :: 'Option 'String
          :examples $ []
          :schema $ :: 'StructDef
        'BrowserFileHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait BrowserFileHost (:type 'String)
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object)
          :schema $ :: 'Trait
        'DispatchOp $ %{} 'CodeEntry (:doc "|Web render dispatch 的 Enum 合同；当前回调忽略事件，代表值不发送。")
          :code $ quote $ def DispatchOp (:: :unhandled)
          :examples $ []
          :schema $ :: 'Enum
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
                Option :some $ js-ffi.contract/expect-string |GEMINI_API_KEY raw
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
                          event-first-file $ .unwrap-or (get e :event) nil
                          (:none) &unit
                          (:some file) (on-transcribe file)
              if (.some? error-msg)
                div
                  {} $ :style $ {} (:color |red) (:margin-top |10px)
                  <> $ .unwrap error-msg
              if (.some? result)
                div
                  {} $ :style $ {} (:margin-top |20px) (:padding |15px) (:border "|1px solid #eee") (:border-radius |4px) (:background-color |#f9f9f9) (:white-space |pre-wrap) (:min-height |100px)
                  <> $ .unwrap result
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Component)
            :args $ [] (:: 'Option 'String) 'Bool (:: 'Option 'String)
              :: 'Fn $ {} (:return 'Unit)
                :args $ [] 'genai.main/BrowserFileHost
                :features $ #{} :js-ffi
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
            hint-fn $ {} (:async true) (:return 'Unit)
              :args $ [] 'genai.sdk/GoogleClientHost 'genai.main/BrowserFileHost
              :features $ #{} :js-ffi
            reset! *store $ assoc (assoc @*store :loading? true) :error-msg $ Option :none
            try
              let
                  base64 $ js-await $ read-as-base64 file
                  mime-type $ .-type file
                  cfg $ sdk/ContentConfig :model |gemini-1.5-flash :contents $ []
                    {} (:role |user)
                      :parts $ [] (sdk/text-part "|请将这段音频转录为简体中文文字。") (sdk/inline-audio base64 mime-type)
                  response $ js-await $ sdk/generate-content! client cfg
                reset! *store $ assoc
                  assoc @*store :result $ sdk/extract-text response
                  , :loading? false
                , &unit
              fn (err) (js/console.error err)
                reset! *store $ assoc (assoc @*store :loading? false) :error-msg $ Option :some (str err)
                , &unit
            , &unit
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
                    key $ .unwrap api-key
                    client $ if (.some? base-url)
                      sdk/new-client-with-base-url key $ .unwrap base-url
                      sdk/new-client key
                    params $ sdk/CreateParams :model |gemini-2.5-flash :input "|Explain how AI works in a few words."
                    interaction $ js-await $ sdk/interactions-create! client params
                    result $ sdk/extract-outputs interaction
                  println |Response: $ .unwrap-or (:text result) |
                  println |Status: $ :status result
                  println |Interaction-id: $ :interaction-id result
            , &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
            :features $ #{} :js-ffi
        'read-as-base64 $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn read-as-base64 (file)
            hint-fn $ {} (:async true) (:return 'String)
              :args $ [] 'genai.main/BrowserFileHost
              :features $ #{} :js-ffi
            js-ffi.contract/expect-string |FileReader-base64 $ js-await $ new js/Promise
              fn (resolve reject)
                let
                    reader $ unsafe-coerce (new js/FileReader) 'genai.main/FileReaderHost
                  js-set reader :onload $ fn (e)
                    match
                      js-nullish->option $ .-result reader
                      (:none) (reject "|FileReader completed without a data URL")
                      (:some data-url)
                        resolve $ .unwrap $ nth (split data-url |,) 1
                  js-set reader :onerror $ fn (e) (reject e)
                  .read-as-data-url! reader file
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
            render!
              .unwrap $ respo.ffi.browser/query-selector |.app
              comp-container (:result @*store) (:loading? @*store) (:error-msg @*store)
                fn (file)
                  hint-fn $ {} (:return 'Unit)
                    :args $ [] 'genai.main/BrowserFileHost
                    :features $ #{} :js-ffi
                  let
                      api-key $ match (get-env |GEMINI_API_KEY)
                        (:some key) (Option :some key)
                        (:none) (browser-api-key)
                    match api-key
                      (:none)
                        do
                          swap! *store assoc :error-msg $ Option :some "|Missing GEMINI_API_KEY"
                          , &unit
                      (:some key)
                        do
                          handle-transcribe! (sdk/new-client key) file
                          , &unit
              fn (op) &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
            :features $ #{} :js-ffi
        'web-main! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn web-main! () (println "|Web app started.") (render-app!)
            add-watch! *store :rerender $ fn (_next _previous) (render-app!)
            , &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
            :features $ #{} :js-ffi
        'web-reload! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn web-reload! () (clear-cache!) (render-app!) (println |web-reloaded)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
            :features $ #{} :js-ffi
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns genai.main
          :require (genai.sdk :as sdk)
            respo.core :refer $ render! clear-cache! defcomp <> div button input span
            respo-ui.core :as ui
            respo.ffi.browser :as dom
            js-ffi.contract :as contract
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
            :role $ :: 'Option 'String
            :parts $ :: 'Option $ :: 'List (:: 'Map 'Tag 'Dynamic)
          :examples $ []
          :schema $ :: 'StructDef
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
          :code $ quote $ defenum ContentOutput (:text 'genai.sdk/TextContent) (:image 'genai.sdk/ImageContent) (:thought 'genai.sdk/ThoughtContent) (:function-call 'genai.sdk/FunctionCallContent) (:function-result 'genai.sdk/FunctionResultContent)
          :examples $ []
          :schema $ :: 'EnumDef
        'CountTokensResponse $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct CountTokensResponse
            :totalTokens $ :: 'Option 'Number
            :sdkHttpResponse $ :: 'Option 'Dynamic
          :examples $ []
          :schema $ :: 'StructDef
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
            :text $ :: 'Option 'String
            :function-calls $ :: 'List 'genai.sdk/FunctionCallContent
            :interaction-id 'String
            :status 'genai.sdk/InteractionStatus
          :examples $ []
          :schema $ :: 'StructDef
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
          :code $ quote $ defstruct FunctionCallContent (:id 'String) (:name 'String)
            :arguments $ :: 'Map 'Tag 'Dynamic
          :examples $ []
          :schema $ :: 'StructDef
        'FunctionResultContent $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct FunctionResultContent (:call-id 'String) (:result 'Dynamic)
            :is-error $ :: 'Option 'Bool
            :name $ :: 'Option 'String
          :examples $ []
          :schema $ :: 'StructDef
        'GenerateResponseHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait GenerateResponseHost
            :candidates $ :: 'JsNullish 'JsArray
            :text $ :: 'JsNullish 'String
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
            :data $ :: 'Option 'String
            :mime-type $ :: 'Option 'String
            :uri $ :: 'Option 'String
          :examples $ []
          :schema $ :: 'StructDef
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
          :code $ quote $ defstruct Interaction (:id 'String) (:status 'genai.sdk/InteractionStatus)
            :outputs $ :: 'Option $ :: 'List 'Dynamic
            :model $ :: 'Option 'String
            :created $ :: 'Option 'String
            :updated $ :: 'Option 'String
            :usage $ :: 'Option 'genai.sdk/Usage
          :examples $ []
          :schema $ :: 'StructDef
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
            :status 'String
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object)
          :schema $ :: 'Trait
        'InteractionResult $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct InteractionResult (:id 'String) (:status 'genai.sdk/InteractionStatus)
            :outputs $ :: 'Option $ :: 'List (:: 'Map 'Tag 'Dynamic)
            :model $ :: 'Option 'String
            :created $ :: 'Option 'String
            :updated $ :: 'Option 'String
            :role $ :: 'Option 'String
            :object $ :: 'Option 'String
            :usage $ :: 'Option 'genai.sdk/SdkUsage
          :examples $ []
          :schema $ :: 'StructDef
        'InteractionStatus $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defenum InteractionStatus (:completed) (:failed) (:in-progress) (:cancelled) (:incomplete) (:requires-action)
          :examples $ []
          :schema $ :: 'EnumDef
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
            :total_tokens $ :: 'Option 'Number
            :total_input_tokens $ :: 'Option 'Number
            :input_tokens_by_modality $ :: 'Option $ :: 'List 'Dynamic
            :total_cached_tokens $ :: 'Option 'Number
            :total_output_tokens $ :: 'Option 'Number
            :total_tool_use_tokens $ :: 'Option 'Number
            :total_thought_tokens $ :: 'Option 'Number
            :cached_tokens_by_modality $ :: 'Option $ :: 'List (:: 'Map 'Tag 'Dynamic)
            :output_tokens_by_modality $ :: 'Option $ :: 'List (:: 'Map 'Tag 'Dynamic)
            :tool_use_tokens_by_modality $ :: 'Option $ :: 'List (:: 'Map 'Tag 'Dynamic)
          :examples $ []
          :schema $ :: 'StructDef
        'StreamChunkOutput $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct StreamChunkOutput
            :text $ :: 'Option 'String
            :thinking? 'Bool
          :examples $ []
          :schema $ :: 'StructDef
        'TextContent $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct TextContent
            :text $ :: 'Option 'String
          :examples $ []
          :schema $ :: 'StructDef
        'ThoughtContent $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct ThoughtContent
            :signature $ :: 'Option 'String
            :summary $ :: 'Option $ :: 'List 'Dynamic
          :examples $ []
          :schema $ :: 'StructDef
        'Turn $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct Turn
            :role $ :: 'Option 'String
            :content 'Dynamic
          :examples $ []
          :schema $ :: 'StructDef
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
            :input-tokens $ :: 'Option 'Number
            :output-tokens $ :: 'Option 'Number
            :total-tokens $ :: 'Option 'Number
          :examples $ []
          :schema $ :: 'StructDef
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
            :args $ [] 'genai.sdk/CreateCachedContentConfig
            :features $ #{} :js-ffi
        'caches-create! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn caches-create! (client model cfg)
            hint-fn $ {} (:return 'Dynamic)
              :args $ [] 'genai.sdk/GoogleClientHost 'String $ :: 'Option 'genai.sdk/CreateCachedContentConfig
              :features $ #{} :js-ffi
              :async true
            .create (.-caches client)
              js-object (:model model)
                :config $ option-map->js cfg cached-content-config->js
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost 'String $ :: 'Option 'genai.sdk/CreateCachedContentConfig
            :features $ #{} :js-ffi
        'caches-delete! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn caches-delete! (client name cfg)
            hint-fn $ {} (:return 'Dynamic)
              :args $ [] 'genai.sdk/GoogleClientHost 'String $ :: 'Option 'genai.sdk/RequestConfig
              :features $ #{} :js-ffi
              :async true
            .delete (.-caches client)
              js-object (:name name)
                :config $ option-map->js cfg request-config->js
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost 'String $ :: 'Option 'genai.sdk/RequestConfig
            :features $ #{} :js-ffi
        'caches-get! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn caches-get! (client name cfg)
            hint-fn $ {} (:return 'Dynamic)
              :args $ [] 'genai.sdk/GoogleClientHost 'String $ :: 'Option 'genai.sdk/RequestConfig
              :features $ #{} :js-ffi
              :async true
            .get (.-caches client)
              js-object (:name name)
                :config $ option-map->js cfg request-config->js
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost 'String $ :: 'Option 'genai.sdk/RequestConfig
            :features $ #{} :js-ffi
        'caches-list! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn caches-list! (client cfg)
            hint-fn $ {} (:return 'Dynamic)
              :args $ [] 'genai.sdk/GoogleClientHost $ :: 'Option 'genai.sdk/ListParams
              :features $ #{} :js-ffi
              :async true
            .list (.-caches client)
              js-object $ :config $ option-map->js cfg list-config->js
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost $ :: 'Option 'genai.sdk/ListParams
            :features $ #{} :js-ffi
        'chat-get-history $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn chat-get-history (chat)
            decode-map-as
              map
                decode-map-as
                  tagging-edn $ to-calcit-data (.getHistory chat) true
                  :: 'List $ :: 'Map 'Tag 'Dynamic
                fn (row)
                  select-present-fields row $ [] :role :parts
              :: 'List 'genai.sdk/ChatHistoryTurn
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'genai.sdk/ChatHost
            :features $ #{} :js-ffi
            :return $ :: 'List 'genai.sdk/ChatHistoryTurn
        'chat-send-message! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn chat-send-message! (chat message config)
            hint-fn $ {} (:return 'Dynamic)
              :args $ [] 'genai.sdk/ChatHost 'Dynamic $ :: 'Option 'genai.sdk/GenerationConfig
              :features $ #{} :js-ffi
              :async true
            .sendMessage chat $ js-object
              :message $ maybe-to-js-data message
              :config $ option-map->js config generation-config->js
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/ChatHost 'Dynamic $ :: 'Option 'genai.sdk/GenerationConfig
            :features $ #{} :js-ffi
        'chat-send-message-stream! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn chat-send-message-stream! (chat message config)
            hint-fn $ {} (:return 'Dynamic)
              :args $ [] 'genai.sdk/ChatHost 'Dynamic $ :: 'Option 'genai.sdk/GenerationConfig
              :features $ #{} :js-ffi
              :async true
            .sendMessageStream chat $ js-object
              :message $ maybe-to-js-data message
              :config $ option-map->js config generation-config->js
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/ChatHost 'Dynamic $ :: 'Option 'genai.sdk/GenerationConfig
            :features $ #{} :js-ffi
        'chats-create $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn chats-create (client model config history)
            .create (.-chats client)
              js-object (:model model)
                :config $ option-map->js config generation-config->js
                :history $ option-map->js history history->js
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'genai.sdk/ChatHost)
            :args $ [] 'genai.sdk/GoogleClientHost 'String (:: 'Option 'genai.sdk/GenerationConfig)
              :: 'Option $ :: 'List 'genai.sdk/ChatHistoryTurn
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
            :args $ [] 'genai.sdk/ContentConfig
            :features $ #{} :js-ffi
        'extract-content-parts $ %{} 'CodeEntry
          :doc "|extracts candidates[0].content.parts from a non-streaming generateContent response"
          :code $ quote $ defn extract-content-parts (result)
            let
                data $ decode-map-as
                  tagging-edn $ to-calcit-data result true
                  :: 'Map 'Tag 'Dynamic
              match
                get-in data $ [] :candidates 0 :content :parts
                (:err error)
                  match error
                    (:missing) (Option :none)
                    (:shape message) (raise message)
                (:ok value)
                  if (nil? value) (Option :none)
                    Option :some $ decode-map-as value $ :: 'List (:: 'Map 'Tag 'Dynamic)
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'Dynamic
            :features $ #{} :js-ffi
            :return $ :: 'Option $ :: 'List (:: 'Map 'Tag 'Dynamic)
        'extract-image-bytes $ %{} 'CodeEntry
          :doc "|extracts base64 imageBytes from generatedImages[0].image of a generateImages response"
          :code $ quote $ defn extract-image-bytes (result)
            let
                data $ decode-map-as
                  tagging-edn $ to-calcit-data result true
                  :: 'Map 'Tag 'Dynamic
              match
                get-in data $ [] :generatedImages 0 :image :imageBytes
                (:err error)
                  match error
                    (:missing) (Option :none)
                    (:shape message) (raise message)
                (:ok value)
                  if (nil? value) (Option :none)
                    Option :some $ decode-map-as value 'String
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'Dynamic
            :features $ #{} :js-ffi
            :return $ :: 'Option 'String
        'extract-outputs $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn extract-outputs (interaction)
            let
                outputs $ .unwrap-or (:outputs interaction) ([])
                text-output $ first $ filter outputs
                  fn (output)
                    =
                      .unwrap-or (read-string-field output :type) |
                      , |text
                function-outputs $ filter outputs $ fn (output)
                  =
                    .unwrap-or (read-string-field output :type) |
                    , |function_call
                calls $ map function-outputs $ fn (output)
                  decode-map-as
                    select-present-fields output $ [] :id :name :arguments
                    , 'genai.sdk/FunctionCallContent
                text $ read-string-field
                  .unwrap-or text-output $ {}
                  , :text
              ExtractedInteractionOutput :text text :function-calls calls :interaction-id (:id interaction) :status $ :status interaction
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'genai.sdk/ExtractedInteractionOutput)
            :args $ [] 'genai.sdk/InteractionResult
        'extract-stream-chunk $ %{} 'CodeEntry
          :doc "|extracts text and thinking? from a stream chunk, returns {:text :thinking?} map; handles optional chaining"
          :code $ quote $ defn extract-stream-chunk (chunk)
            let
                data $ decode-map-as
                  tagging-edn $ to-calcit-data chunk true
                  :: 'Map 'Tag 'Dynamic
                part $ match
                  get-in data $ [] :candidates 0 :content :parts 0
                  (:err error)
                    match error
                      (:missing) (Option :none)
                      (:shape message) (raise message)
                  (:ok value)
                    if (nil? value) (Option :none)
                      Option :some $ decode-map-as value $ :: 'Map 'Tag 'Dynamic
                thinking? $ match part
                  (:none) false
                  (:some row)
                    match (get row :thought)
                      (:none) false
                      (:some value)
                        if (nil? value) false $ decode-map-as value 'Bool
                text $ match part
                  (:none)
                    js-nullish->option $ .-text chunk
                  (:some row) (read-string-field row :text)
                fallback $ match text
                  (:some value) (Option :some value)
                  (:none)
                    match (get data :promptFeedback)
                      (:none) (Option :none)
                      (:some feedback)
                        if (nil? feedback) (Option :none)
                          read-string-field
                            decode-map-as feedback $ :: 'Map 'Tag 'Dynamic
                            , :blockReason
              StreamChunkOutput :text fallback :thinking? thinking?
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'genai.sdk/StreamChunkOutput)
            :args $ [] 'genai.sdk/GenerateResponseHost
            :features $ #{} :js-ffi
        'extract-text $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn extract-text (result)
            match (extract-content-parts result)
              (:none) (Option :none)
              (:some parts)
                match (first parts)
                  (:none) (Option :none)
                  (:some part) (read-string-field part :text)
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'genai.sdk/GenerateResponseHost
            :features $ #{} :js-ffi
            :return $ :: 'Option 'String
        'files-delete! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn files-delete! (client name cfg)
            hint-fn $ {} (:return 'Dynamic)
              :args $ [] 'genai.sdk/GoogleClientHost 'String $ :: 'Option 'genai.sdk/RequestConfig
              :features $ #{} :js-ffi
              :async true
            .delete (.-files client)
              js-object (:name name)
                :config $ option-map->js cfg request-config->js
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost 'String $ :: 'Option 'genai.sdk/RequestConfig
            :features $ #{} :js-ffi
        'files-get! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn files-get! (client name cfg)
            hint-fn $ {} (:return 'Dynamic)
              :args $ [] 'genai.sdk/GoogleClientHost 'String $ :: 'Option 'genai.sdk/RequestConfig
              :features $ #{} :js-ffi
              :async true
            .get (.-files client)
              js-object (:name name)
                :config $ option-map->js cfg request-config->js
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost 'String $ :: 'Option 'genai.sdk/RequestConfig
            :features $ #{} :js-ffi
        'files-list! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn files-list! (client cfg)
            hint-fn $ {} (:return 'Dynamic)
              :args $ [] 'genai.sdk/GoogleClientHost $ :: 'Option 'genai.sdk/ListParams
              :features $ #{} :js-ffi
              :async true
            .list (.-files client)
              js-object $ :config $ option-map->js cfg list-config->js
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost $ :: 'Option 'genai.sdk/ListParams
            :features $ #{} :js-ffi
        'files-upload! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn files-upload! (client file cfg)
            hint-fn $ {} (:return 'Dynamic)
              :args $ [] 'genai.sdk/GoogleClientHost 'Dynamic $ :: 'Option 'genai.sdk/UploadFileConfig
              :features $ #{} :js-ffi
              :async true
            .upload (.-files client)
              js-object (:file file)
                :config $ option-map->js cfg upload-file-config->js
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost 'Dynamic $ :: 'Option 'genai.sdk/UploadFileConfig
            :features $ #{} :js-ffi
        'generate-content! $ %{} 'CodeEntry
          :doc "|async, calls models.generateContent with ContentConfig, returns full response (non-streaming)"
          :code $ quote $ defn generate-content! (client cfg)
            hint-fn $ {} (:return 'genai.sdk/GenerateResponseHost)
              :args $ [] 'genai.sdk/GoogleClientHost 'genai.sdk/ContentConfig
              :features $ #{} :js-ffi
              :async true
            .generateContent (.-models client) (content-config->js cfg)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'genai.sdk/GenerateResponseHost)
            :args $ [] 'genai.sdk/GoogleClientHost 'genai.sdk/ContentConfig
            :features $ #{} :js-ffi
        'generate-content-stream! $ %{} 'CodeEntry
          :doc "|async, calls models.generateContentStream with ContentConfig, returns stream for js-for-await"
          :code $ quote $ defn generate-content-stream! (client cfg)
            hint-fn $ {} (:return 'Dynamic)
              :args $ [] 'genai.sdk/GoogleClientHost 'genai.sdk/ContentConfig
              :features $ #{} :js-ffi
              :async true
            .generateContentStream (.-models client) (content-config->js cfg)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost 'genai.sdk/ContentConfig
            :features $ #{} :js-ffi
        'generate-images! $ %{} 'CodeEntry
          :doc "|async, calls models.generateImages with ImageGenConfig, returns image generation response"
          :code $ quote $ defn generate-images! (client cfg)
            hint-fn $ {} (:return 'Dynamic)
              :args $ [] 'genai.sdk/GoogleClientHost 'genai.sdk/ImageGenConfig
              :features $ #{} :js-ffi
              :async true
            let
                model $ :model cfg
                prompt $ :prompt cfg
                signal $ :abort-signal cfg
                http-opts $ :http-options cfg
                num-images $ .unwrap-or (:number-of-images cfg) 1
                include-rai $ :include-rai-reason cfg
              .generateImages (.-models client)
                js-object (:model model) (:prompt prompt)
                  :config $ js-object (:numberOfImages num-images)
                    :includeRaiReason $ option->js include-rai
                    :httpOptions $ option->js http-opts
                    :abortSignal $ option->js signal
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost 'genai.sdk/ImageGenConfig
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
            :args $ [] 'genai.sdk/GenerationConfig
            :features $ #{} :js-ffi
        'history->js $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn history->js (history)
            to-js-data $ map history $ fn (turn)
              js-object
                :role $ option->js $ :role turn
                :parts $ option->js $ :parts turn
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] $ :: 'List 'genai.sdk/ChatHistoryTurn
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
                        :text $ .unwrap $ get v :content
                      to-js-data v
                  identity v
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'T
            :features $ #{} :js-ffi
            :generics $ [] 'T
        'interactions-cancel! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn interactions-cancel! (client id)
            hint-fn $ {} (:return 'Dynamic)
              :args $ [] 'genai.sdk/GoogleClientHost 'String
              :features $ #{} :js-ffi
              :async true
            .cancel (.-interactions client) id
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost 'String
            :features $ #{} :js-ffi
        'interactions-create! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn interactions-create! (client params)
            hint-fn $ {} (:return 'genai.sdk/InteractionResult)
              :args $ [] 'genai.sdk/GoogleClientHost 'genai.sdk/CreateParams
              :features $ #{} :js-ffi
              :async true
            normalize-interaction $ js-await $ .create (.-interactions client) (params->js params)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'genai.sdk/InteractionResult)
            :args $ [] 'genai.sdk/GoogleClientHost 'genai.sdk/CreateParams
            :features $ #{} :js-ffi
        'interactions-delete! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn interactions-delete! (client id)
            hint-fn $ {} (:return 'Dynamic)
              :args $ [] 'genai.sdk/GoogleClientHost 'String
              :features $ #{} :js-ffi
              :async true
            .delete (.-interactions client) id
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost 'String
            :features $ #{} :js-ffi
        'interactions-get! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn interactions-get! (client id)
            hint-fn $ {} (:return 'genai.sdk/InteractionResult)
              :args $ [] 'genai.sdk/GoogleClientHost 'String
              :features $ #{} :js-ffi
              :async true
            normalize-interaction $ js-await $ .get (.-interactions client) id
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'genai.sdk/InteractionResult)
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
            :args $ [] 'genai.sdk/ListParams
            :features $ #{} :js-ffi
        'make-abort-signal $ %{} 'CodeEntry
          :doc "|creates AbortController, stores in *abort-control atom, returns signal; pass atom for external abort control"
          :code $ quote $ defn make-abort-signal (*abort-control)
            let
                controller $ js-ffi.shared/abort-controller-create
              reset! *abort-control controller
              js-ffi.shared/abort-signal controller
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'js-ffi.shared/AbortSignalHost)
            :args $ [] $ :: 'Ref 'Dynamic
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
                tools $ concat
                  if search?
                    [] $ {} $ :googleSearch ({})
                    []
                  if has-url?
                    [] $ {} $ :urlContext ({})
                    []
              if (empty? tools) (Option :none) (Option :some tools)
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'Bool 'Bool
            :return $ :: 'Option $ :: 'List (:: 'Map 'Tag 'Dynamic)
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
            to-js-data $ map messages $ fn (message)
              let
                  role $ decode-map-as
                    .unwrap $ get message :role
                    , 'Tag
                  text $ decode-map-as
                    .unwrap $ get message :content
                    , 'String
                {}
                  :role $ if (= role :assistant) |model |user
                  :parts $ [] $ {} (:text text)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] $ :: 'List (:: 'Map 'Tag 'Dynamic)
            :features $ #{} :js-ffi
        'models-compute-tokens! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn models-compute-tokens! (client model contents config)
            hint-fn $ {} (:return 'Dynamic)
              :args $ [] 'genai.sdk/GoogleClientHost 'String 'Dynamic $ :: 'Option 'genai.sdk/GenerationConfig
              :features $ #{} :js-ffi
              :async true
            .computeTokens (.-models client)
              js-object (:model model)
                :contents $ maybe-to-js-data contents
                :config $ option-map->js config generation-config->js
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost 'String 'Dynamic $ :: 'Option 'genai.sdk/GenerationConfig
            :features $ #{} :js-ffi
        'models-count-tokens! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn models-count-tokens! (client model contents config)
            hint-fn $ {} (:return 'genai.sdk/CountTokensResponse)
              :args $ [] 'genai.sdk/GoogleClientHost 'String 'Dynamic $ :: 'Option 'genai.sdk/GenerationConfig
              :features $ #{} :js-ffi
              :async true
            normalize-count-tokens $ js-await $ .countTokens (.-models client)
              js-object (:model model)
                :contents $ maybe-to-js-data contents
                :config $ option-map->js config generation-config->js
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'genai.sdk/CountTokensResponse)
            :args $ [] 'genai.sdk/GoogleClientHost 'String 'Dynamic $ :: 'Option 'genai.sdk/GenerationConfig
            :features $ #{} :js-ffi
        'models-get! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn models-get! (client model cfg)
            hint-fn $ {} (:return 'Dynamic)
              :args $ [] 'genai.sdk/GoogleClientHost 'String $ :: 'Option 'genai.sdk/RequestConfig
              :features $ #{} :js-ffi
              :async true
            .get (.-models client)
              js-object (:model model)
                :config $ option-map->js cfg request-config->js
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost 'String $ :: 'Option 'genai.sdk/RequestConfig
            :features $ #{} :js-ffi
        'models-list! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn models-list! (client cfg)
            hint-fn $ {} (:return 'Dynamic)
              :args $ [] 'genai.sdk/GoogleClientHost $ :: 'Option 'genai.sdk/ListParams
              :features $ #{} :js-ffi
              :async true
            .list (.-models client)
              js-object $ :config $ option-map->js cfg list-config->js
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/GoogleClientHost $ :: 'Option 'genai.sdk/ListParams
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
            :args $ [] 'genai.sdk/ClientOptions
            :features $ #{} :js-ffi
        'normalize-count-tokens $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn normalize-count-tokens (value)
            decode-map-as
              select-present-fields
                decode-map-as
                  tagging-edn $ to-calcit-data value true
                  :: 'Map 'Tag 'Dynamic
                [] :totalTokens :sdkHttpResponse
              , 'genai.sdk/CountTokensResponse
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'genai.sdk/CountTokensResponse)
            :args $ [] 'Dynamic
            :features $ #{} :js-ffi
        'normalize-interaction $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn normalize-interaction (value)
            let
                data $ decode-map-as
                  tagging-edn $ to-calcit-data value true
                  :: 'Map 'Tag 'Dynamic
                fields $ select-present-fields data $ [] :id :status :outputs :model :created :updated :role :object :usage
                status $ read-status $ decode-map-as
                  .unwrap $ get data :status
                  , 'String
                normalized $ match (get fields :usage)
                  (:none) fields
                  (:some usage)
                    assoc fields :usage $ select-present-fields
                      decode-map-as usage $ :: 'Map 'Tag 'Dynamic
                      [] :total_tokens :total_input_tokens :input_tokens_by_modality :total_cached_tokens :total_output_tokens :total_tool_use_tokens :total_thought_tokens :cached_tokens_by_modality :output_tokens_by_modality :tool_use_tokens_by_modality
              decode-map-as (assoc normalized :status status) 'genai.sdk/InteractionResult
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'genai.sdk/InteractionResult)
            :args $ [] 'Dynamic
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
        'option-map->js $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn option-map->js (value convert)
            match value
              (:some payload) (convert payload)
              (:none) js/undefined
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] (:: 'Option 'T)
              :: 'Fn $ {} (:return 'Dynamic)
                :args $ [] 'T
                :features $ #{} :js-ffi
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
            :args $ [] 'genai.sdk/CreateParams
            :features $ #{} :js-ffi
        'read-status $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn read-status (value)
            match value
              |completed $ InteractionStatus :completed
              |failed $ InteractionStatus :failed
              |in_progress $ InteractionStatus :in-progress
              |cancelled $ InteractionStatus :cancelled
              |incomplete $ InteractionStatus :incomplete
              |requires_action $ InteractionStatus :requires-action
              _ $ raise $ str |Unknown-Interaction-status: value
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'genai.sdk/InteractionStatus)
            :args $ [] 'String
        'read-string-field $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn read-string-field (data field)
            match (get data field)
              (:none) (Option :none)
              (:some value)
                if (nil? value) (Option :none)
                  Option :some $ decode-map-as value 'String
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'Map 'Tag 'Dynamic) 'Tag
            :return $ :: 'Option 'String
        'request-config->js $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn request-config->js (cfg)
            js-object
              :httpOptions $ option->js $ :http-options cfg
              :abortSignal $ option->js $ :abort-signal cfg
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'genai.sdk/RequestConfig
            :features $ #{} :js-ffi
        'select-present-fields $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn select-present-fields (data fields)
            .fold fields ({})
              fn (acc field)
                hint-fn $ {}
                  :args $ [] (:: 'Map 'Tag 'Dynamic) 'Tag
                  :return $ :: 'Map 'Tag 'Dynamic
                match (get data field)
                  (:none) acc
                  (:some value)
                    if (nil? value) acc $ assoc acc field value
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'Map 'Tag 'Dynamic) (:: 'List 'Tag)
            :return $ :: 'Map 'Tag 'Dynamic
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
            :args $ [] 'genai.sdk/UploadFileConfig
            :features $ #{} :js-ffi
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns genai.sdk
          :require
            |@google/genai :refer $ GoogleGenAI
            js-ffi.shared :as host
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
            let
                result $ genai.sdk/normalize-interaction $ js-object (:id |fixture-id) (:status |completed) (:unmodeled true)
                  :outputs $ js-array $ js-object (:type |text) (:text |:keyword)
                  :usage $ js-object (:total_tokens 0) (:total_input_tokens nil)
                    :output_tokens_by_modality $ js-array
                    :future_field true
              assert= (Option :some |:keyword)
                :text $ genai.sdk/extract-outputs result
              assert= |fixture-id $ :id result
              assert= (genai.sdk/InteractionStatus :completed) (:status result)
              assert= (Option :some 0)
                :total_tokens $ .unwrap $ :usage result
            assert= (Option :some 0)
              :totalTokens $ genai.sdk/normalize-count-tokens $ js-object (:totalTokens 0) (:cachedContentTokenCount 99)
            assert= (Option :none) (genai.sdk/make-search-tools false false)
            assert=
              [] $ {} (:role |user)
                :parts $ [] $ {} (:text |hello)
              match
                try-parse-json $ js-ffi.contract/expect-string |history-json $ js/JSON.stringify
                  genai.sdk/history->js $ [] $ genai.sdk/ChatHistoryTurn :role (Option :some |user) :parts
                    Option :some $ [] $ {} (:text |hello)
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
