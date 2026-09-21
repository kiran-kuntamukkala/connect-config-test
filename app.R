library(shiny)
library(DBI)
library(odbc)

ui <- fluidPage(
  h2("SQL Connection Test"),
  tableOutput("data")
)

server <- function(input, output) {
  
  output$data <- renderTable({
    
    con <- dbConnect(
      odbc(),
      Driver = "ODBC Driver 18 for SQL Server",
      Server ="pet-az-sql-psl-connect.database.windows.net",
      Database ="psl_connect",
      UID = "psl_connect_rw",
      PWD = "Indiumsoftw@re@Pet@rw8670!",
      Encrypt = "yes",
      TrustServerCertificate = "yes"
    )
    
    df <- dbGetQuery(
      con,
      "SELECT TOP 10 * FROM dbo.test"
    )
    
    dbDisconnect(con)
    
    df
  })
  
}

shinyApp(ui, server)