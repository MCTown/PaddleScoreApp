# 数据库设计

数据库统一命名采用下划线规则
数据库为以下结构：

## <match_name>.db

> 用于存储比赛数据，比赛事件名字将作为数据库名，例如2024春季比赛.db

### athletes 表 用于存储运动员信息

[//]: # (todo 问题：初赛积分如何计算？)

| 列名   | id      | name    | team    | group  | long_distant_score | prone_paddle_score | sprint_score |
|------|---------|---------|---------|--------|--------------------|--------------------|--------------|
| 数据类型 | VARCHAR | VARCHAR | VARCHAR | STRING | INT                | INT                | INT          |

---

> 接下来三张表分别记录三次比赛的成绩，分别为：
>
> 1. 6000米长距离赛（青少年3000米）
>
> 2. 200米趴板划水赛（仅限青少年）
>
> 3. 200米竞速赛

### competitions_long_distant 表

| 列名 | id | name | time |
|----|----|------|------|

长距离比赛只有一场，所以只有一张表

> 以下为多张表

### <gruop>_<competition_type>_competitions_prone_paddle 表

| 列名 | id | name | time |
|----|----|------|------|

### <gruop>_<competition_type>_competitions_sprint 表

| 列名 | id | name | time |
|----|----|------|------|

例：若人数分配如下：

- U9 : 100人
- U12: 50人
- U15: 30人
- U18: 20人
- 高校: 155人
- 公开: 23人
- 大师: 31人
- 卡胡纳: 20人

赛程为：

- U9: 初赛 -> 1/2决赛 -> 决赛
- U12: 初赛 -> 决赛
- U15: 初赛 -> 决赛
- U18: 初赛 -> 决赛
- 高校: 初赛 -> 1/4决赛 -> 1/2决赛 -> 决赛
- 公开: 初赛 -> 决赛
- 大师: 初赛 -> 决赛
- 卡胡纳: 初赛 -> 决赛

那么将有以下表：

- U9_first_competitions_prone_paddle
- U9_1/2_competitions_prone_paddle
- U9_final_competitions_prone_paddle
- U9_first_competitions_sprint
- U9_1/2_competitions_sprint
- U9_final_competitions_sprint

---

- U12_first_competitions_prone_paddle
- U12_final_competitions_prone_paddle
- U12_first_competitions_sprint
- U12_final_competitions_sprint

---

- U15_first_competitions_prone_paddle
- U15_final_competitions_prone_paddle
- U15_first_competitions_sprint
- U15_final_competitions_sprint

---

- U18_first_competitions_prone_paddle
- U18_final_competitions_prone_paddle
- U18_first_competitions_sprint
- U18_final_competitions_sprint

---

- gaoxiao_first_competitions_sprint
- gaoxiao_1/4_competitions_sprint
- gaoxiao_1/2_competitions_sprint
- gaoxiao_final_competitions_sprint

---

- gongkai_first_competitions_sprint
- gongkai_final_competitions_sprint

---

- dashi_first_competitions_sprint
- dashi_final_competitions_sprint

---

- kahuna_first_competitions_sprint
- kahuna_final_competitions_sprint

---

每一场比赛都对应一个表