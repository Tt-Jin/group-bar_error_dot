library(tidyverse)
library(reshape2)
library(rstatix)

#读入数据
data  = readxl::read_xlsx("data.xlsx")

#根据group、Day15合并数值列：
#使用factor固定绘图顺序,并使用mutate创建新变量
df <- melt(data, id=c('group','Day15')) %>%
  rename("Relative_mRNA_levels"=value) %>%
  mutate(group = factor(group, levels=c("ubq-1", "ubq-2", "ubl-1", "usp-14")),
         Day15 = factor(Day15, levels = c("Wild-type", "eat-2(ad1116)", "daf-2(e1370)"))) -> df

##组内差异显著性
df %>% 
  group_by(group) %>% 
  t_test(Relative_mRNA_levels ~ Day15,
         ref.group = "Wild-type") %>% 
  mutate(p = round(p, 4),
         p.signif = case_when(p < 0.05 ~ "",
                              .default = " (NS)")) -> df_test

df %>% 
  group_by(group, Day15) %>% 
  slice_max(Relative_mRNA_levels, with_ties = FALSE) %>% 
  left_join(df_test,
            join_by(group==group, Day15==group2)) %>% 
  mutate(group = factor(group, levels=c("ubq-1", "ubq-2", "ubl-1", "usp-14")),
         Day15 = factor(Day15, levels = c("Wild-type", "eat-2(ad1116)", "daf-2(e1370)")))-> df_lab



##作图
#pal = c("#010101", "#ff2604", "#02f702") #Nature文章的颜色
pal = c("#323232", "#f68f26", "#18999f")

ggplot(data = df ,
       aes(x=group, y=Relative_mRNA_levels)) +
  geom_bar(aes(fill=Day15),
           stat = "summary", fun="mean", color="black",
           position = position_dodge2(padding = 0.25), width = 0.8) +
  stat_summary(aes(group=Day15),
               geom = "errorbar",fun.data = "mean_se",
               width=0.25, position = position_dodge(width = 0.8)) +
  geom_jitter(aes(color=Day15),
              position = position_jitterdodge(jitter.width = 0.15), 
              shape=21, fill="white", size=2, stroke=1.5) +
  geom_text(data = df_lab,
            aes(x=group, y=Relative_mRNA_levels + 0.5, 
                group=Day15,label=str_c("P = ", p, p.signif)),
            position = position_dodge(width = 0.8),
            angle=90, size=6) +
  scale_fill_manual(values = pal) +
  scale_color_manual(values = c("black", "black", "black"),
                     guide = "none") +
  scale_y_continuous(limits = c(0, 3),
                     expand = c(0, 0),
                     breaks = seq(0, 2.5, 0.5)) +
  guides(y = guide_axis(cap = "upper")) +
  theme_classic() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_text(color = 'black',size = 20),
        axis.ticks = element_line(linewidth = 1.5, color='black'),
        axis.text.x = element_text(color = 'black',size = 18,face = "italic"),
        axis.text.y = element_text(color = 'black',size = 18),
        legend.title = element_text(color = 'black',size = 18),
        legend.text = element_text(color = 'black',size = 16),
        legend.justification  = "top",
        legend.location = "plot",
        legend.key.height = unit(0.5, "mm"),
        legend.key.width = unit(9, "mm"),
        legend.key.spacing.y = unit(4, "mm"),
        legend.key = element_rect(linewidth = 0.5, color="black"),
        strip.background = element_rect(color = NA),
        panel.spacing = unit(0, "mm"))

ggsave("bar-groups-error-dot.png", width = 9, height = 6, dpi = 600)
ggsave("bar-groups-error-dot.pdf", width = 9, height = 6)
