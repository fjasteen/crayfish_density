library(RMark)
library(readr)

locality <- "Middelkerke"
month <- "06"
year <- "2024"
oever <- ""
setwd(
  paste0(
    "./localities/",
    year,
    "_",
    month,
    "_",
    locality,
    oever
  )
)

CH <- import.chdata("./data/input/CH.txt")
head(CH)


crayfish_N <- nrow(CH)
catchdays_N <- nchar(CH[1, 1])
recapture_N <- sum(unlist(strsplit(as.character(CH$ch), "")) == "1")



#Prepare the data
CH.proc <- process.data(CH, model = "Closed")
#Create the design data and PIM structure
CH.ddl <- make.design.data(CH.proc)

#Define all models for closed capture recapture analysis
run.CH <- function() {
  # List of effects
  f0 <- list(formula =  ~ 1)
  f0s <-
    list(formula =  ~ 1, share = TRUE) #same parameter for p & c
  ft <- list(formula =  ~ time, share = TRUE)
  #ftb <- list(formula =  ~ time)
  #ftb2 <- list(formula =  ~ time + c, share = TRUE)
  
  ## Build model list
  m0 <-
    mark(
      CH,
      model = "Closed",
      model.parameters = list(p = f0s),
      initial = 0.1
    )# p & c constant and equal over time
  #mT <- mark(CH, model="Closed", model.parameters=list(p=fT))# p & c equal and varying over Time?
  mb <-
    mark(
      CH,
      model = "Closed",
      model.parameters = list(p = f0, c = f0),
      initial = 0.1
    )
  mt <-
    mark(
      CH,
      model = "Closed",
      model.parameters = list(p = ft),
      initial = 0.1
    ) # p & c equal and varying over time
  # p & c constant and not equal ~ behaviour
  #mtb <- mark(CH, model="Closed", model.parameters=list(p=ftb, c=ftb))# p & c varying over time and not equal
  #overparametrizes (10 parameters and 7 degrtees of freedom)
  #mtb2 <- mark(CH, model="Closed", model.parameters=list(p=ftb2))# p varies over time and is function of c (constant)
  return(collect.models())
}

#Fit models
CH.results <- run.CH()
print(CH.results)
#Results
table <- CH.results$model.table
table$row <-  rownames(table)

N_m0 <- CH.results$m0$results$derived$`N Population Size`
N_mb <- CH.results$mb$results$derived$`N Population Size`
N_mt <- CH.results$mt$results$derived$`N Population Size`



N_m0$model <- 'm0'
N_m0$model_numeric <- 1

N_mb$model <- 'mb'
N_mb$model_numeric <- 2

N_mt$model <- 'mt'
N_mt$model_numeric <- 3

# Combine all N estimates into one data frame
N_combined <- rbind(N_m0, N_mb, N_mt)

final_table = merge(table, N_combined, by.x = "row", by.y = "model_numeric")

summary_phrase <-
  paste0(
    "In totaal werden ",
    crayfish_N,
    " kreeften gevangen, tijdens ",
    catchdays_N,
    " dagen, en er waren ",
    recapture_N - crayfish_N,
    " hervangsten dit is ",
    round((recapture_N - crayfish_N) / crayfish_N * 100, 2),
    "%."
  )

output_folder <- "./data/output"
output_filename <- "output.txt"
# Volledige pad naar het output bestand
output_filepath <- file.path(output_folder, output_filename)

# Formatteer de numerieke waarden in final_table
final_table_formatted <- final_table
numeric_columns <- sapply(final_table, is.numeric)
final_table_formatted[numeric_columns] <-
  lapply(final_table[numeric_columns], function(x) {
    format(
      round(x, 2),
      nsmall = 2,
      decimal.mark = ",",
      big.mark = ""
    )
  })

# model average Nhat value
num.models = nrow(CH.results$model.table)
estimate = vector("numeric", length = num.models)
se = vector("numeric", length = num.models)
for (i in 1:num.models)
{
  # The actual model number is the row number for the model.table
  model.numbers = as.numeric(row.names(CH.results$model.table))
  # For each model extract the derived parameter valuess and their se
  x = CH.results[[model.numbers[i]]]$results$derived
  estimate[i] = x$`N Population Size`$estimate
  se[i] = x$`N Population Size`$se
}
# Call model.average using the list structure which includes estimate, weight and vcv list in this case
model_av <-
  model.average(list(
    estimate = estimate,
    weight = CH.results$model.table$weight,
    se = se
  ))

# Schrijf de geformatteerde tabel en summary phrase weg naar het output bestand
write_delim(final_table_formatted,
            output_filepath,
            delim = "\t",
            col_names = TRUE)

# Voeg de summary phrase toe
fileConn <- file(output_filepath, open = "a")
writeLines("\n", fileConn)
writeLines(summary_phrase, fileConn)
writeLines(
  paste0(
    "De densiteit na model averaging is: ",
    model_av$estimate,
    " met een standaard error van ",
    model_av$se
  ),
  fileConn
)

close(fileConn)

# Bevestiging van opslaan
cat("De tabel en samenvatting zijn weggeschreven naar",
    output_filepath)
