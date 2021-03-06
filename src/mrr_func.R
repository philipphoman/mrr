#-----------------------------------------------------------------------
# mrr_func.R
# function used throughout
#
# PH, 9/18/18
#-----------------------------------------------------------------------
#

# we use pacman for all libraries
#-----------------------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
library("pacman")
pacman::p_load(
          "plyr",
          "tidyverse",
          "png",
          "grid",
          "readxl",
          "QuantPsyc",
          "cowplot",
          "R.matlab",
          "rstan",
          "truncnorm",
          "car",
          "lm.beta",
          "tidyr",
          "ggplot2",
          "plotrix",
          "lme4",
          "lmerTest",
          "dplyr",
          "corrplot"
        )

# a few example functions
#-----------------------------------------------------------------------
parse_msd <- function(m, sd) {
	# procude string of mean and sd 
	print(paste("M = ", round(m, 2), ", SD = ", round(sd, 2),  sep=""))
}

parse_tstat <- function(tstat) {
	# Fill in pieces of t test as text
	print(paste("/t/ (", round(tstat$parameter,2), ") = ",
				round(tstat$statistic, 2), ", /P/ ", parse_vals("pval", 
				tstat$p.value), sep=""))
}

parse_rstat <- function(rstat) {
	# Fill in pieces of pearson correlation as text
	print(paste("/r/ (", round(rstat$parameter, 2), ") = ",
				round(rstat$estimate, 2), ", /P/ ", parse_vals("pval", 
				rstat$p.value), sep=""))
}

parse_lm <- function(lm, index=2, scaled=FALSE, style="beta") {
	# Fill in pieces of lm as text
	lsm <- as.data.frame(coef(summary(lm.beta(lm))))[index, ]
	if (scaled==FALSE) {
	  beta <- lm.beta::lm.beta(lm)$standardized.coefficients[index]
  } 
  else {
	  beta <- lsm$Estimate
  }

	def <- summary(lm)$df[2]
  switch(style,
         beta = {print(paste("\\beta = ",
                             round(beta, 2),
                             ", /t/ (", round(def, 2), ") = ",
                             round(lsm$"t value", 2), ", /P/ ",
                             parse_vals("pval", lsm$"Pr(>|t|)"),
                             sep=""))
         },
         ci = {print(paste("b = ",
                           round(beta, 2),
                           ", 95% CI [",
                           round(confint(lm, index)[1]),
                           "; ",
                           round(confint(lm, index)[2]),
                           "], ",
                           ", /t/ (", round(def, 2), ") = ",
                           round(lsm$"t value", 2), ", /P/ ",
                           parse_vals("pval", lsm$"Pr(>|t|)"),
                           sep=""))
         })
}

parse_fstat <- function(anovatab, index) {
	# parse data frame coming from f test
	a <- as.data.frame(anovatab)[index, ]
	print(paste("/F/ (", round(a$NumDF, 2), ", ", round(a$DenDF, 2), 
				") = ", round(a$F.value, 2), ", /P/ ", parse_vals("pval", 
				a$"Pr(>F)"), sep=""))
}

parse_chi <- function(chisq, def) {
	# Fill in pieces of chi square test as text
	pval <- pchisq(chisq, def, lower=FALSE)
	print(paste("\\chi^{2} = ",
				round(chisq, 2), ", df=", def,  
				", /P/ ", parse_vals("pval", pval), sep=""))
}

parse_table <- function(table) {
	# remove any nil by replacing NA by whitespace
	table[is.na(table)] <- ""
	return(table)
}

starsfromp <- function(pval) {
  # Parses pvalues, returns asterisks

  as <- vector(mode="character", length=length(pval))
  for (i in 1:length(pval)) {
    p <- pval[i]
    if (p < 0.1) as[i] <- "~"
    if (p < 0.05) as[i] <- "*"
    if (p < 0.01) as[i] <- "**"
    if (p < 0.001) as[i] <- "***"
  }
  return(as)
}
