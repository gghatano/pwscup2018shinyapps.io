# library----
library(shiny)
library(shinythemes)
library(shinydashboard)
library(markdown)
library(DT)
# ui----
shinyUI(
  dashboardPage(
    dashboardHeader(title = "PWSCUP2018"),
    ## Sidebar content
    dashboardSidebar(
      sidebarMenu(
        menuItem("About", tabName = "about", icon = icon("dashboard")),
        menuItem("予備選結果_匿名化", tabName = "round1_result", icon = icon("th")),
        menuItem("予備選結果_再識別", tabName = "round1_reid", icon = icon("th")),
        menuItem("予備選_有用性評価", tabName = "round1_utility", icon = icon("th"), 
                 badgeLabel = "Beta", badgeColor = "blue"),
        menuItem("本戦_有用性評価", tabName = "round2_utility", icon = icon("th"), 
                 badgeLabel = "Alpha", badgeColor = "red"),
        menuItem("本戦結果", tabName = "round2_result", icon = icon("th"),
                 badgeLabel = "ToBe", badgeColor = "green")
      )
    ),
    dashboardBody(
      tabItems(
        # First tab content
        tabItem(tabName = "about",
                fluidRow(
                  width = 12, 
                  includeMarkdown("about.md")
                )
        ),
        tabItem(tabName = "round1_result",
                fluidRow(
                  title = "DataTable",
                  width = 12,
                  DT::dataTableOutput("table")
                )
        ),
        tabItem(tabName = "round1_reid",
                fluidRow(
                  title = "予備選再識別結果",
                  width = 12,
                  dataTableOutput("round1_reid_table")
                )
        ),
        tabItem(tabName = "round2_result",
                "10月末に公開予定"
        ),
        tabItem(tabName = "round1_utility",
                fluidRow(
                  box(title = "Aファイル",
                      width = 6,
                      fileInput("file_U", label = NULL, buttonLabel = "Select A file")
                  ),
                  box(title = "有用性評価結果",
                      width = 6,
                      verbatimTextOutput("verba_text_U")
                  )
                ),
                fluidRow(
                  box(
                    title = "匿名加工後データ",
                    width = 12,
                    DT::dataTableOutput("table_U")
                  )
                )
        ),
        tabItem(tabName = "round2_utility",
                fluidRow(
                  box(title = "Aファイル",
                      width = 6,
                      fileInput("file_U2", label = NULL, buttonLabel = "Select A file")
                  ),
                  box(title = "有用性評価結果",
                      width = 6,
                      verbatimTextOutput("verba_text_U2")
                  )
                ),
                fluidRow(
                  box(
                    title = "匿名加工後データ",
                    width = 12,
                    DT::dataTableOutput("table_U2")
                  )
                )
        )
        
      )
    )
  )
)