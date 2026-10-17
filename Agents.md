脚本使用 `yarn compile`，Web 使用 `yarn compile:web`；`yarn dev` 先编译 Web 再启动 Vite，实时编译另开终端运行 `yarn watch`。

查看 Calcit 命令行工具的用法:

```bash
calcit docs agents --contract
```

查看 Respo 模块的具体用法

```bash
calcit docs read Respo-Agent.md --full --module respo.calcit
```

## LLM 执行效率优化（不重复 llms/Calcit.md）

- **先定位再修改**：先读结构/需求，再做最小变更，避免“改一处→报错→补救”式迭代。
- **缓存上下文**：记录你已经确认的定义位置与修改点，避免重复搜索相同目标。
- **优先局部替换**：只替换目标节点或小段结构，避免整段重写导致结构漂移。
- **拆分复杂改动**：把 UI 改动与逻辑改动拆开，减少单次变更影响面。
- **尽量复用已有组件/样式**：优先扩展已有样式/组件，而不是新增并重复实现。
- **检查生成代码风险点**：处理 `let`、map 结构、属性 map 的键值对等高风险结构时，先确认结构是否符合预期，再替换。
- **利用 diff 控制范围**：在多次修改后随时对比 diff，避免无关变更积累。
- **编译前自检**：对于复杂变更，先手动检查节点结构（比如嵌套列表、属性 map、函数参数形态）再编译。
- **输出稳定性优先**：避免频繁调整格式或样式细节，优先保证逻辑稳定与可读性。

## 常见错误与正确做法（结合本项目实践）

- **`let` 只保留最后一个表达式**：多个表达式需要包一层 `div`/`do`，否则前面的节点会被丢掉。
- **属性 map 必须是成对键值**：避免把 `:style` 与 `:inner-text` 写在同一个 pair 内；每个属性单独成对。
- **避免生成“可调用字符串”**：形如 `(<> ((str ...)))` 会变成调用结果，正确写法为 `<> $ str ...`。
- **列表 vs set**：`keys` 返回 set，拼接前先 `.to-list`，再 `concat`。
- **pairs 列表转 map**：不要用 `.to-map` 处理 list，改用 `pairs-map`。
- **函数调用与变量区分**：`week-start` 这类变量必须 is-leaf，避免成为单元素 list 导致被当做“函数调用”。
- **数值与单位风险**：CSS 属性如 `flex`, `font-weight`, `line-height`, `z-index` 若使用单纯数字，Respo 会自动拼接 `px` 单位。必须改为字符串形式，例如 `:flex "\"1"` 或 `:font-weight "\"300"`。
- **结构化编辑优先**：禁止文本编辑 `calcit.cirru`；使用 `calcit query/tree/edit`，经过 transaction dry-run 和 scoped revision 后写入，不恢复 compact.cirru/package.cirru。
- **性能优化准则**：对于动态生成的列表（如任务项），应将静态样式从内联 `:style` 提取到 `defstyle` 中，通过 `:class-name` 引用以提升虚拟 DOM 性能。
- **排序逻辑翻转**：翻转列表排序应直接修改 `sort` 函数所用比较器的返回分支（如将 `if ret 1 -1` 翻转为 `if ret -1 1`）。

## 入口约定（脚本 + Web 并存）

- 默认入口保留脚本能力，不要再用 Web 逻辑覆盖 `genai.main/main!` 与 `genai.main/reload!`。
- Web 功能使用独立入口：`genai.main/web-main!` 与 `genai.main/web-reload!`。
- `calcit.cirru` 的 `:entries :web` 配置 Web 入口，default entry 继续指向脚本入口。
- 构建命令约定：
  - 脚本入口：`calcit js`（node target）
  - Web 入口：`calcit --entry web js`（browser target）
- 开发时保持两条链路都可用：修 Web 不破坏脚本，修脚本不破坏 Web。
- `test-config` 是纯离线请求/响应回归入口，不能代替默认/Web 和公共 SDK 全量门禁；未全部完成时保留 draft，不发布或部署。
- 双 target 门禁：Node 检查默认可达入口及全部公共 SDK，Web 检查全部项目定义及全部公共 SDK；`fix --workflow strict --verify` 一次覆盖全部入口。不要在 Node 上强行检查 Web DOM 闭包，也不要删除 Web 全量门禁。
