# librarian allows you to load packages in a reusable way
if (!("librarian" %in% rownames(utils::installed.packages()))) {
    install.packages("librarian")
}

librarian::shelf(
     cran_repo = "https://cran.microsoft.com/", # Dallas, TX mirror
     pryr,
     rlang,
     sandwich,
     glue,
     magrittr
)

#' @title
#' Wald test of multiple hypotheses
#'
#' @description
#' Test linear and non-linear hypotheses of the coefficients of a fitted regression model.
#'
#' @details Jointly tests that the (non-linear) expressions in ... are all equal
#' to zero. Use a variable name to refer to the coefficient associated with that
#' variable, for instance \code{testnl(model, 2*age)} to test that twice the
#' coefficient associated with age is equal to zero. Separate multiple
#' expressions by commas, i.e. \code{testnl(model, 2*age, motheduc^2)}. For
#' "weird" variable names, surround in backticks (see example).
#'
#' @param model a linear model created with `lm`
#' @param ...  one or more (possibly non-linear) expressions. Variable names
#'   refer to the associated parameters of the model.
#' @param vcov. a function, matrix, or purrr-style lambda expressing the
#'   covariance of the parameters of the model. Defaults to
#'   heterskedasticity-robust regression
#'
#' @examples
#' # fit a model with interations for illustration
#' model <- lm(mpg ~ hp*disp, data = datasets::mtcars)
#'
#' # first, test that hp = disp
#' testnl(model, hp - disp)
#'
#' # then do a full f test (`hp:disp` is the interaction term)
#' testnl(model, hp, disp, `hp:disp`)
#'
#' # if you want to test the intercept, it's called (Intercept)
#' testnl(model, sqrt(`(Intercept)`))
#' @export
testnl <- function(model, ..., vcov. = ~ vcovHC(., "HC1"), coef. = coef(model)) {
    .env <- parent.frame()
    vars <- names(coef.)
    
    # plug in coef estimates into symbolic expression
    plug_in <- function(e) {
        subs <- function(x) {
            if (is.name(x) && (deparse(x) %in% vars)) {
                coef.[deparse(x)]
            } else if (is.call(x)) {
                as.call(lapply(x, subs))
            } else {
                x
            }
        }
        eval(subs(e), .env)
    }
    
    # X is the point estimate f(\betahat) (or R\betahat for linear restrictions)
    fs <- dots(...)
    X <- fs %>%
        sapply(plug_in) %>%
        matrix(nrow = 1)
    
    # extract the asymptotic variance of \betahat estimates
    V_beta <- {
        if (is_function(vcov.)) {
            vcov.(model)
        } else if (is_formula(vcov.)) {
            rlang::as_function(vcov.)(model)
        } else if (is.matrix(vcov.)) {
            vcov.
        } else if (is.null(vcov.)) {
            vcov(model)
        } else {
            stop(glue("Unsupported variance specification: {class(vcov.)}. Supported types are matrix, function, or formula"))
        }
    }
    
    # compute a q X k gradient matrix evaluated at \betahat
    grad <- sapply(vars, function(v) {
        sapply(fs, function(f) {
            plug_in(D(f, v))
        })
    }) %>% matrix(ncol = length(vars))
    
    # use delta method to get covariance matrix of f(\betahat) (or R\betahat)
    V <- grad %*% V_beta %*% t(grad)
    
    # use v \Sigma^-1 v' to get the chi-sq(q) statistic
    chisq_stat <- X %*% solve(V) %*% t(X)
    df <- length(fs)
    pval <- 1 - pchisq(chisq_stat, df)
    
    # print the output
    printf <- function(...)
        cat(sprintf(...))
    for (i in 1:length(fs)) {
        printf("(%d) %s = 0\n", i, deparse(fs[[i]]))
    }
    printf("\n\t\tchi2(%d) = %.2f\n", df, chisq_stat)
    printf("\t\tProb > chi2 = %.4f\n", pval)
}