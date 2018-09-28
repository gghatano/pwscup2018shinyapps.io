library(dplyr)
library(readr)

utility = function(dat_T, dat_A){
  dat_T %>% 
    rename(X2_T = X2) %>% 
    rename(X3_T = X3) %>% 
    rename(X4_T = X4) %>% 
    rename(X5_T = X5) -> dat_T
  dat_A %>% 
    rename(X2_A = X2) %>% 
    rename(X3_A = X3) %>% 
    rename(X4_A = X4) %>% 
    rename(X5_A = X5) -> dat_A
  tryCatch({
    ## calc utility by columns
    utility_date = calc_utility_date(dat_T["X2_T"], dat_A["X2_A"])
    utility_item = calc_utility_item(dat_T["X3_T"], dat_A["X3_A"])
    utility_price = calc_utility_price(dat_T["X4_T"], dat_A["X4_A"])
    utility_amount = calc_utility_amount(dat_T["X5_T"], dat_A["X5_A"])
    
    utility_vec = c(utility_date, utility_item, utility_price, utility_amount) 
    
    ## test
    utility_vec %>% print 
    utility_vec %>% mean %>% return
  }, 
  error = function(e){
    print(e)
    return("匿名化データのどこかが不正です...")
    # return(e)
  })
  # warning = function(e){
  # })
}

## utility (date column)
calc_utility_date = function(dat_T_date, dat_A_date){
  
  delta = 1
  std = dat_T_date$X2_T %>% as.Date %>% as.integer %>% var %>% sqrt
  
  ## delete: 1, nochange: 0, others: 1 - 1/|A|
  dat_score_nodelete =
    dat_T_date %>% cbind(dat_A_date) %>% 
    #mutate(X2_A = "*") %>% 
    ##mutate(X2_A = X2_T) %>% 
    mutate(nochange_flg = (X2_T == X2_A)) %>% 
    mutate(delete_flg = (X2_A == "*")) %>% 
    filter(!(delete_flg)) 
  
  ## date deleted
  dat_score_delete =
    dat_T_date %>% cbind(dat_A_date) %>% 
    mutate(nochange_flg = (X2_T == X2_A)) %>% 
    mutate(delete_flg = (X2_A == "*")) %>% 
    filter(delete_flg) 
  dat_score_delete %>% 
    mutate(score = 1) -> dat_score_delete
  
  ## date not deleted
  dat_score_nodelete %<>% 
    mutate(X2_A = str_replace_all(X2_A, "[\\[\\]]", "")) %>% 
    mutate(low = as.integer(as.Date(str_replace(X2_A, "^([^;]+);[^;]+$","\\1")))) %>% 
    mutate(high = as.integer(as.Date(str_replace(X2_A, "^[^;]+;([^;]+)$","\\1")))) %>% 
    mutate(X2_T = as.integer(as.Date(X2_T))) %>% 
    mutate(score = ifelse(nochange_flg, 0,
                      ( 
                        (low - X2_T)**2 + (high - X2_T)**2 + (high - low)*delta
                      ) / ( 
                        2 * ( high - low + delta) * std
                      )
                   )
           ) -> dat_score_nodelete
  
  c(dat_score_nodelete$score, dat_score_delete$score) %>% mean %>% return
}

## utility(item)
calc_utility_item = function(dat_T_item, dat_A_item){
  
  ## delete: 1, nochange: 0, others: 1 - 1/|A|
  dat_score = 
    dat_T_item %>% cbind(dat_A_item) %>% 
    mutate(nochange_flg = (X3_T == X3_A)) %>% 
    mutate(delete_flg = (X3_A == "*")) %>% 
    mutate(item_num = str_count(string = X3_A, pattern = ";") + 1) %>% 
    mutate(score = ifelse(nochange_flg, 0, 
                          ifelse(delete_flg, 1, 1 - 1/(item_num))))
  
  return(mean(dat_score$score))
}

# utility(price)
calc_utility_price = function(dat_T_price, dat_A_price){
  
  delta = 0.01
  std = dat_T_price %>% var %>% as.numeric %>% sqrt
  
  dat_T_price %>% cbind(dat_A_price) %>% 
    mutate(X4_A = str_replace_all(X4_A, "[\\[\\]]", "")) %>% 
    # mutate(X4_A = "*") %>% 
    # mutate(X4_A = X4_T) %>% 
    mutate(delete_flg = (X4_A == "*")) %>% 
    mutate(nochange_flg = (X4_T == X4_A)) %>% 
    mutate(low = as.numeric(str_replace(X4_A, "^([^;]+);[^;]+$","\\1"))) %>% 
    mutate(high = as.numeric(str_replace(X4_A, "^[^;]+;([^;]+)$","\\1"))) %>% 
    mutate(score = ifelse(delete_flg, 1, 
                          ifelse(nochange_flg, 0,
                            ( 
                              (low - X4_T)**2 + (high - X4_T)**2 + (high - low)*delta
                            ) / ( 
                              2 * ( high - low + delta) * std
                            )
                          )
                   )
           ) -> dat_score
  
    
  return(mean(dat_score$score))
}

# utility (amount)
calc_utility_amount = function(dat_T_amount, dat_A_amount){
  
  delta = 1
  std = dat_T_amount %>% var %>% as.numeric %>% sqrt
  
  dat_T_amount %>% cbind(dat_A_amount) %>% 
    mutate(X5_A = str_replace_all(X5_A, "[\\[\\]]", "")) %>% 
    # mutate(X5_A = "*") %>%
    # mutate(X5_A = X5_T) %>%
    mutate(nochange_flg = (X5_A == X5_T)) %>% 
    mutate(delete_flg = (X5_A == "*")) %>% 
    mutate(low = as.numeric(str_replace(X5_A, "^([^;]+);[^;]+$","\\1"))) %>% 
    mutate(high = as.numeric(str_replace(X5_A, "^[^;]+;([^;]+)$","\\1"))) %>%
    mutate(score = ifelse(delete_flg, 1, 
                          ifelse(nochange_flg, 0, 
                            ( 
                              (low - X5_T)**2 + (high - X5_T)**2 + (high - low)*delta
                            ) / ( 
                              2 * ( high - low + delta ) * std
                            )
                          )
                    )
           )  -> dat_score
    
  return(mean(dat_score$score))
}

## test
# dat_T = read_csv("./T_round1.csv")
# dat_A = read_csv("./A_01.csv")
# 
# utility(dat_T, dat_A)

