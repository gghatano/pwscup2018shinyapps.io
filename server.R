options(shiny.maxRequestSize = 1000*1024^2)
# library----
library(shiny)
library(shinythemes)
library(dplyr)

shinyServer(
  function(input, output) {
    dat_A = read_csv("./round1_result_anonymize.csv")
    dat_reid = read_csv("round1_result_reid.csv")
    dat_T = read_csv("./T_round1.csv")
    dat_T2 = read_csv("./T_round2.csv")
    
    ## round1 anonymize result
    output$table = renderDataTable({
      # dat_A = read_csv("./round1_result_anonymize.csv")
      dat_A %>% return
    }, options = list(pageLength = 14))
    
    ## round1 reid result
    output$round1_reid_table = renderDataTable({
      # source("./scripts/make_reid_data.R")
      # dat_reid = read_csv("round1_result_reid.csv")
      dat_reid %>% return
    }, options = list(pageLength = 13))
    
    ## utility
    output$table_U = renderDataTable({
      file_U = input$file_U
      if(is.null(file_U)){
        return(NULL)
      }
      dat_U = read_csv(file_U$datapath, col_names = FALSE)
      
      source("./scripts/utility.R")
      output$verba_text_U = renderText({
        dat_T = read_csv("./T_round1.csv")
        result = utility(dat_T, dat_U)
        return(format(result, digits = 20))
      })
      
      dat_U %>% return
    })
    output$table_T = renderDataTable({
      
      dat_T %>% return
    })
    
    ## utility round2
    output$table_U2 = renderDataTable({
      file_U2 = input$file_U2
      if(is.null(file_U2)){
        return(NULL)
      }
      dat_U2 = read_csv(file_U2$datapath, col_names = FALSE)
      
      source("./scripts/utility.R")
      output$verba_text_U2 = renderText({
        dat_T2 = read_csv("./T_round2.csv")
        result = utility(dat_T2, dat_U2)
        return(format(result, digits = 20))
      })
      
      dat_U2 %>% return
    })
    
    output$verba_text_U = renderText({
      "予備選のAファイルをアップロードしてください"
    })
    output$verba_text_U2 = renderText({
      "本戦のAファイルをアップロードしてください"
    })
  }
)