# 分组柱状图-误差线-抖动点图-t检验

1. df 数据框：使用 factor 固定绘图顺序，并使用 mutate 创建新变量

2. df_test 数据框：使用 group_by 按组别进行 t 检验，并使用 mutate 创建 p.signif 列（定义 NS）

3. df_lab 数据框：合并 df 和 df_test 数据框，用于绘图

4. geom_bar() 函数绘制柱状图

5. 用 stat_summary() 函数并在里面接参数 geom=’errorbar’ 绘制误差线。

6. geom_jitter() 函数绘制抖动点图

7. geom_text() 添加 p 值信息

### 最重要的是：

码代码不易，如果你觉得我的教程对你有帮助，请小红书(号**4274585189**)关注我！！！

