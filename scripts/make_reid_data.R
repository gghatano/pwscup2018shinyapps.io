library(stringr)
library(readr)
library(dplyr)
dat_reid %>% 
  gather(deffence, result, -`0`) %>% 
  mutate(result_01 = str_extract(string = result, pattern = "^[01]")) %>% 
  mutate(result_01_= str_extract(string = result, pattern = "[0-9][0-9]*/[0-9][0-9]*")) %>% 
  mutate(result_reided = str_extract(string = result_01_, pattern = "^[0-9][0-9]*")) %>% 
  mutate(result_targeted = str_extract(string = result_01_, pattern = "[0-9][0-9]*$")) %>%
  rename(offence = `0`) %>% 
  select(offence, deffence, result_01, result_reided, result_targeted) -> dat_reid
colnames(dat_reid) = c("再識別", "匿名化対象", "結果", "再識別成功", "再識別試行")

dat_team = dat_A %>% select(チームID, チーム名)

dat_reid %>%
  inner_join(dat_team, by = c("再識別" = "チームID")) %>% 
  mutate(再識別 = チーム名) %>% 
  select(-チーム名) %>% 
  mutate(匿名化対象 = as.integer(匿名化対象)) %>% 
  inner_join(dat_team, by = c("匿名化対象" = "チームID")) %>% 
  mutate(匿名化対象 = チーム名) %>% 
  select(-チーム名) %>% 
  filter(再識別 !=匿名化対象) %>% 
  rename(再識別対象 = 匿名化対象) -> dat_reid
