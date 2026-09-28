library(AzureAuth)
library(AzureKeyVault)
library(shiny)
library(DBI)
library(odbc)

# Connect to Azure Key Vault using Managed Identity
vault <- key_vault(
  url = "https://pet-dev-azure-kv.vault.azure.net",
  as_managed_identity = TRUE
)

# Retrieve secrets
db_server   <- vault$secrets$get("psl-connect-rw-server")$value
db_name     <- vault$secrets$get("psl-connect-rw-database")$value
db_user     <- vault$secrets$get("psl-connect-rw-username")$value
db_password <- vault$secrets$get("psl-connect-rw-password")$value

ui <- fluidPage(
  h2("SQL Connection Test"),
  tableOutput("data")
)

server <- function(input, output, session) {
  
  output$data <- renderTable({
    
    con <- dbConnect(
      odbc(),
      Driver = "ODBC Driver 18 for SQL Server",
      Server = db_server,
      Database = db_name,
      UID = db_user,
      PWD = db_password,
      Encrypt = "yes",
      TrustServerCertificate = "yes"
    )
    
    on.exit(dbDisconnect(con))
    
    dbGetQuery(
      con,
      "SELECT TOP 10 * FROM dbo.test"
    )
  })
}

shinyApp(ui, server)
