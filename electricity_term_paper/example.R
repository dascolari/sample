# ASSUMING model is your lm object and df is your data
library(aod)
library(sandwich)
library(magrittr)
library(tidyverse)
library(mosaic)

df <- read.csv("panel.csv")
df = df %>% filter(sector == "res")
model <- lm(lnsales ~ lnprices + lninc + heatdd + cooldd + lnlagsales + state + state*lnprices, data = df)
summary(model)

states <- unique(df$state)

# this will store the p-values
out <- diag(length(states)) %>%
        set_rownames(states) %>%
        set_colnames(states)

# helper function to figure out what index of the coefficient vector
index_of <- function(state) {
    # LOOK OUT HERE. CHECK THAT YOUR COEFFICIENTS LOOK LIKE lnprices:statetx
    coef_name <- paste0("lnprices:state", state)
    coef_index <- which(names(coef(model)) == coef_name)
    ifelse(length(coef_index), coef_index, FALSE)
}

Sigma <- vcovHC(model, type = "HC1")
# stores "omitted" variables to give you a warning
omitted <- c()

for (i in seq_along(states)) {
    for (j in seq_along(states)) {
        if (i != j) {
            state_i <- states[i]
            state_j <- states[j]
            index_i <- index_of(state_i)
            index_j <- index_of(state_j)

            # building arguments for a wald.test call
            args <- list(
                Sigma = Sigma,
                b = coef(model)
            )

            if (index_i && index_j) {
                # in this case neither state is omitted,
                # so we test that \beta_i - \beta_j = 0
                L <- matrix(0, nrow = 2, ncol = length(coef(model)))
                L[1, index_of(state_i)] <- 1
                L[2, index_of(state_j)] <- -1
                args$L <- L
            } else {
                # in this case one of them is the omitted,
                # so we just need to test the coefficient directly
                args$Terms <- if (index_i) {
                   omitted <- union(omitted, state_j)
                   index_i
                } else {
                   omitted <- union(omitted, state_i)
                   index_j
                }
            }
            p <- do.call(wald.test, args)$result$chi2["P"]
            out[i,j] <- out[j,i] <- p
        }
    }
}

warning(paste("It says the following states are omitted, FYI:", omitted))