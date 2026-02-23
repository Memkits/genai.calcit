
{} (:about "|file is generated - never edit directly; learn cr edit/tree workflows before changing") (:package |genai)
  :configs $ {} (:init-fn |genai.main/main!) (:reload-fn |genai.main/reload!) (:version |0.0.1)
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
                  params $ %{} sdk/CreateParams (:model |gemini-2.5-flash) (:input "|Explain how AI works in a few words.") (:system-instruction nil) (:previous-interaction-id nil) (:store nil) (:generation-config nil) (:tools nil) (:response-modalities nil) (:response-format nil) (:response-mime-type nil)
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
        |ContentOutput $ %{} :CodeEntry (:doc |)
          :code $ quote
            defenum ContentOutput (:text TextContent) (:image ImageContent) (:thought ThoughtContent) (:function-call FunctionCallContent) (:function-result FunctionResultContent)
          :examples $ []
        |CreateParams $ %{} :CodeEntry (:doc |)
          :code $ quote (defrecord CreateParams :model :input :system-instruction :previous-interaction-id :store :generation-config :tools :response-modalities :response-format :response-mime-type)
          :examples $ []
        |FunctionCallContent $ %{} :CodeEntry (:doc |)
          :code $ quote
            defstruct FunctionCallContent (:id :string) (:name :string) (:arguments :map)
          :examples $ []
        |FunctionResultContent $ %{} :CodeEntry (:doc |)
          :code $ quote
            defstruct FunctionResultContent (:call-id :string) (:result :any)
              :is-error $ :: :optional :bool
              :name $ :: :optional :string
          :examples $ []
        |GenerationConfig $ %{} :CodeEntry (:doc |)
          :code $ quote (defrecord GenerationConfig :temperature :max-output-tokens :top-p :top-k :candidate-count :stop-sequences :response-mime-type)
          :examples $ []
        |ImageContent $ %{} :CodeEntry (:doc |)
          :code $ quote
            defstruct ImageContent
              :data $ :: :optional :string
              :mime-type $ :: :optional :string
              :uri $ :: :optional :string
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
            defenum InteractionStatus (:completed :nil) (:failed :nil) (:in-progress :nil) (:cancelled :nil) (:incomplete :nil) (:requires-action :nil)
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
              :content :any
          :examples $ []
        |Usage $ %{} :CodeEntry (:doc |)
          :code $ quote
            defstruct Usage
              :input-tokens $ :: :optional :number
              :output-tokens $ :: :optional :number
              :total-tokens $ :: :optional :number
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
