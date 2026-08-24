# moonbit-sse 项目说明

- 项目名称：MoonBit 可搜索加密索引与隐私检索参考实现
- GitHub：https://github.com/shen-E/moonbit-sse
- 语言：MoonBit；许可证：Apache-2.0
- 项目性质：原创 MoonBit 实现，不包含复制的第三方源代码

## 项目定位

面向 MoonBit 开发者提供可运行、可测试的隐私检索基础组件参考实现，
覆盖加密原语、搜索令牌、动态倒排索引、ORAM 数据结构和两方信息论 PIR。
项目重点是清晰的包边界、跨后端构建、标准测试向量和可复现示例。

## 交付范围

1. `crypto`：SHA-2/3、HMAC、PBKDF2、AES、ChaCha20、PRG/PRP。
2. `trapdoor`：密钥派生、搜索/更新令牌、联合查询和令牌辅助工具。
3. `inverted_index`：静态/动态索引、布尔/范围/短语查询和压缩。
4. `oram`：Path/Square-Root/Recursive ORAM 结构与访问轨迹实验器。
5. `pir`：两服务器信息论 PIR、批量检索和矩阵查询辅助结构。
6. `engine`：内存文档搜索示例、索引生命周期和快照完整性检查。

## 边界说明

这是未经独立密码学审计的参考实现，不宣称形式化安全证明、生产级
数据库 durability/ACID、零泄露访问模式或生产性能。示例引擎使用
确定性样例密钥派生和未认证 AES-CTR，仅用于演示；真实部署需要经过
审查的 AEAD、随机 nonce、完整性保护、威胁模型和安全评估。
