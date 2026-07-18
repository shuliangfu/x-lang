// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// superopt.x — Superoptimizer beam search
//
// 模块：ir/slir
// 层级：SLIR
// Phase：Phase 4（Superoptimizer 后置到 Phase 4，前期投入产出比低）
// 职责：
//   - 热点函数触发 Superoptimizer 搜索（性能分析确定热点）
//   - beam search 算法搜索最优指令序列
//   - 搜索空间控制（指令长度上限 + cost 模型约束）
//   - 差分测试验证搜索结果（§9.2，与 C 后端 / 解释器对比）
// 依赖：./egraph / ./rules / ./cost / ../verify/diff_test
// 设计约束：
//   - Superoptimizer 前期投入产出比低，后置到 Phase 4（Lessons Learned）
//   - 搜索空间必须受限（指令长度 + cost 上限），避免不收敛
//   - 搜索结果必须通过差分测试验证，不通过则拒绝
//   - 确定性：相同输入相同搜索路径
//
// 参考文档：analysis/IR核心设计.md §5.1（Superoptimizer 集成方案）/ §11.3（Phase 4 Checklist）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 4 填充
