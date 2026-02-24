
{} (:about "|file is generated - never edit directly; learn cr edit/tree workflows before changing") (:package |genai)
  :configs $ {} (:init-fn |genai.main/main!) (:reload-fn |genai.main/reload!) (:version |0.0.2)
    :modules $ [] |lilac/ |memof/
  :entries $ {}
  :files $ {}
    |genai.main $ %{} :FileEntry
      :defs $ {}
        |main! $ %{} :CodeEntry (:doc |)
          :code $ quote
            defn main! () (hint-fn async)
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
        |reload! $ %{} :CodeEntry (:doc |)
          :code $ quote
            defn reload! () $ println |reloaded
          :examples $ []
      :ns $ %{} :CodeEntry (:doc |)
        :code $ quote
          ns genai.main $ :require (genai.sdk :as sdk) (|node:process :default js-process)
        :examples $ []
    |genai.sdk $ %{} :FileEntry
      :defs $ {}
        |ContentConfig $ %{} :CodeEntry (:doc "|config struct for generateContent/generateContentStream, fields: model contents system-instruction thinking-config tools response-modalities response-mime-type abort-signal http-options")
          :code $ quote
            defstruct ContentConfig (:model :string) (:contents :dynamic)
              :system-instruction $ :: :optional :string
              :thinking-config $ :: :optional :dynamic
              :tools $ :: :optional :list
              :response-modalities $ :: :optional :list
              :response-mime-type $ :: :optional :string
              :abort-signal $ :: :optional :dynamic
              :http-options $ :: :optional :dynamic
          :examples $ []
        |ContentOutput $ %{} :CodeEntry (:doc |)
          :code $ quote
            defenum ContentOutput (:text TextContent) (:image ImageContent) (:thought ThoughtContent) (:function-call FunctionCallContent) (:function-result FunctionResultContent)
          :examples $ []
        |CreateParams $ %{} :CodeEntry (:doc |)
          :code $ quote
            defstruct CreateParams (:model :string) (:input :dynamic)
              :system-instruction $ :: :optional :string
              :previous-interaction-id $ :: :optional :string
              :store $ :: :optional :bool
              :generation-config $ :: :optional GenerationConfig
              :tools $ :: :optional :list
              :response-modalities $ :: :optional :list
              :response-format $ :: :optional :dynamic
              :response-mime-type $ :: :optional :string
          :examples $ []
        |FunctionCallContent $ %{} :CodeEntry (:doc |)
          :code $ quote
            defstruct FunctionCallContent (:id :string) (:name :string) (:arguments :map)
          :examples $ []
        |FunctionResultContent $ %{} :CodeEntry (:doc |)
          :code $ quote
            defstruct FunctionResultContent (:call-id :string) (:result :dynamic)
              :is-error $ :: :optional :bool
              :name $ :: :optional :string
          :examples $ []
        |GenerationConfig $ %{} :CodeEntry (:doc |)
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
        |ImageContent $ %{} :CodeEntry (:doc |)
          :code $ quote
            defstruct ImageContent
              :data $ :: :optional :string
              :mime-type $ :: :optional :string
              :uri $ :: :optional :string
          :examples $ []
        |ImageGenConfig $ %{} :CodeEntry (:doc "|config struct for generateImages, fields: model prompt number-of-images include-rai-reason abort-signal http-options")
          :code $ quote
            defstruct ImageGenConfig (:model :string) (:prompt :string)
              :number-of-images $ :: :optional :number
              :include-rai-reason $ :: :optional :bool
              :abort-signal $ :: :optional :dynamic
              :http-options $ :: :optional :dynamic
          :examples $ []
        |Interaction $ %{} :CodeEntry (:doc |)
          :code $ quote
            defstruct Interaction (:id :string) (:status InteractionStatus)
              :outputs $ :: :optional :list
              :model $ :: :optional :string
              :created $ :: :optional :string
              :updated $ :: :optional :string
              :usage $ :: :optional Usage
          :examples $ []
        |InteractionStatus $ %{} :CodeEntry (:doc |)
          :code $ quote
            defenum InteractionStatus (:completed :dynamic) (:failed :dynamic) (:in-progress :dynamic) (:cancelled :dynamic) (:incomplete :dynamic) (:requires-action :dynamic)
          :examples $ []
        |TextContent $ %{} :CodeEntry (:doc |)
          :code $ quote
            defstruct TextContent $ :text (:: :optional :string)
          :examples $ []
        |ThoughtContent $ %{} :CodeEntry (:doc |)
          :code $ quote
            defstruct ThoughtContent
              :signature $ :: :optional :string
              :summary $ :: :optional :list
          :examples $ []
        |Turn $ %{} :CodeEntry (:doc |)
          :code $ quote
            defstruct Turn
              :role $ :: :optional :string
              :content :dynamic
          :examples $ []
        |Usage $ %{} :CodeEntry (:doc |)
          :code $ quote
            defstruct Usage
              :input-tokens $ :: :optional :number
              :output-tokens $ :: :optional :number
              :total-tokens $ :: :optional :number
          :examples $ []
        |content-config->js $ %{} :CodeEntry (:doc "|converts ContentConfig struct to JS object for SDK calls, maps fields to camelCase JS properties")
          :code $ quote
            defn content-config->js (cfg)
              let
                  model $ :model cfg
                  contents $ :contents cfg
                  sys $ :system-instruction cfg
                  thinking $ :thinking-config cfg
                  tools-v $ :tools cfg
                  modalities $ :response-modalities cfg
                  mime-type $ :response-mime-type cfg
                  signal $ :abort-signal cfg
                  http-opts $ :http-options cfg
                js-object (:model model) (:contents contents)
                  :systemInstruction $ or sys js/undefined
                  :config $ js-object
                    :thinkingConfig $ or thinking js/undefined
                    :tools $ if (some? tools-v) (to-js-data tools-v) js/undefined
                    :responseModalities $ or modalities js/undefined
                    :responseMimeType $ or mime-type js/undefined
                    :abortSignal $ or signal js/undefined
                    :httpOptions $ or http-opts js/undefined
          :examples $ []
        |extract-content-parts $ %{} :CodeEntry (:doc "|extracts candidates[0].content.parts from a non-streaming generateContent response")
          :code $ quote
            defn extract-content-parts (result) (-> result .-candidates .-0 .-content .-parts)
          :examples $ []
        |extract-image-bytes $ %{} :CodeEntry (:doc "|extracts base64 imageBytes from generatedImages[0].image of a generateImages response")
          :code $ quote
            defn extract-image-bytes (response) (-> response .-generatedImages .-0 .-image .-imageBytes)
          :examples $ []
        |extract-outputs $ %{} :CodeEntry (:doc |)
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
        |extract-stream-chunk $ %{} :CodeEntry (:doc "|extracts text and thinking? from a stream chunk, returns {:text :thinking?} map; handles optional chaining")
          :code $ quote
            defn extract-stream-chunk (chunk)
              let
                  part js/chunk.candidates?.[0]?.content?.parts?.[0]
                  is-thinking? $ if (some? part) (.-thought part) false
                  text $ if (some? part) (.-text part) (.-text chunk)
                  fallback $ or text (-> chunk .?-promptFeedback .?-blockReason)
                {} (:text fallback) (:thinking? is-thinking?)
          :examples $ []
        |generate-content! $ %{} :CodeEntry (:doc "|async, calls models.generateContent with ContentConfig, returns full response (non-streaming)")
          :code $ quote
            defn generate-content! (client cfg) (hint-fn async)
              .!generateContent (.-models client) (content-config->js cfg)
          :examples $ []
        |generate-content-stream! $ %{} :CodeEntry (:doc "|async, calls models.generateContentStream with ContentConfig, returns stream for js-for-await")
          :code $ quote
            defn generate-content-stream! (client cfg) (hint-fn async)
              .!generateContentStream (.-models client) (content-config->js cfg)
          :examples $ []
        |generate-images! $ %{} :CodeEntry (:doc "|async, calls models.generateImages with ImageGenConfig, returns image generation response")
          :code $ quote
            defn generate-images! (client cfg) (hint-fn async)
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
        |input->js $ %{} :CodeEntry (:doc |)
          :code $ quote
            defn input->js (v)
              if (string? v)
                js-array $ js-object (:type |text) (:text v)
                if (map? v)
                  js-object (:type |text)
                    :text $ :content v
                  v
          :examples $ []
        |interactions-cancel! $ %{} :CodeEntry (:doc |)
          :code $ quote
            defn interactions-cancel! (client id) (hint-fn async)
              .!cancel (.-interactions client) id
          :examples $ []
        |interactions-create! $ %{} :CodeEntry (:doc |)
          :code $ quote
            defn interactions-create! (client params) (hint-fn async)
              .!create (.-interactions client) (params->js params)
          :examples $ []
        |interactions-delete! $ %{} :CodeEntry (:doc |)
          :code $ quote
            defn interactions-delete! (client id) (hint-fn async)
              .!delete (.-interactions client) id
          :examples $ []
        |interactions-get! $ %{} :CodeEntry (:doc |)
          :code $ quote
            defn interactions-get! (client id) (hint-fn async)
              .!get (.-interactions client) id
          :examples $ []
        |make-abort-signal $ %{} :CodeEntry (:doc "|creates AbortController, stores in *abort-control atom, returns signal; pass atom for external abort control")
          :code $ quote
            defn make-abort-signal (*abort-control)
              let
                  abort $ new js/AbortController
                reset! *abort-control abort
                .-signal abort
          :examples $ []
        |make-http-options $ %{} :CodeEntry (:doc "|creates httpOptions JS object with baseUrl for proxy endpoint")
          :code $ quote
            defn make-http-options (base-url)
              js-object $ :baseUrl base-url
          :examples $ []
        |make-search-tools $ %{} :CodeEntry (:doc "|builds tools array with googleSearch and/or urlContext based on boolean flags; returns nil if neither")
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
        |make-thinking-config $ %{} :CodeEntry (:doc "|creates thinkingConfig JS object with thinkingBudget and includeThoughts fields")
          :code $ quote
            defn make-thinking-config (budget include-thoughts?)
              js-object (:thinkingBudget budget) (:includeThoughts include-thoughts?)
          :examples $ []
        |messages->contents $ %{} :CodeEntry (:doc "|converts Calcit messages [{:role :user/:assistant :content str}] to Gemini contents format [{role parts:[{text}]}]")
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
        |new-client $ %{} :CodeEntry (:doc |)
          :code $ quote
            defn new-client (api-key)
              new GoogleGenAI $ js-object (:apiKey api-key)
          :examples $ []
        |new-client-with-base-url $ %{} :CodeEntry (:doc |)
          :code $ quote
            defn new-client-with-base-url (api-key base-url)
              new GoogleGenAI $ js-object (:apiKey api-key)
                :httpOptions $ js-object (:baseUrl base-url)
          :examples $ []
        |params->js $ %{} :CodeEntry (:doc |)
          :code $ quote
            defn params->js (p)
              let
                  model $ :model p
                  input $ :input p
                  prev-id $ :previous-interaction-id p
                  sys $ :system-instruction p
                  gen-cfg $ :generation-config p
                  tools-v $ :tools p
                js-object (:model model)
                  :input $ input->js input
                  :previous_interaction_id $ or prev-id js/undefined
                  :system_instruction $ or sys js/undefined
                  :store $ or (:store p) js/undefined
                  :config $ if (some? gen-cfg)
                    js-object
                      :temperature $ or (:temperature gen-cfg) js/undefined
                      :maxOutputTokens $ or (:max-output-tokens gen-cfg) js/undefined
                      :topP $ or (:top-p gen-cfg) js/undefined
                      :topK $ or (:top-k gen-cfg) js/undefined
                    , js/undefined
                  :tools $ if (some? tools-v) (to-js-data tools-v) js/undefined
          :examples $ []
      :ns $ %{} :CodeEntry (:doc |)
        :code $ quote
          ns genai.sdk $ :require
            |@google/genai :refer $ GoogleGenAI
        :examples $ []
