#-----------------------------------------------------------------------
# mrr_func.R
# function used throughout
#
# PH, 9/18/18
#-----------------------------------------------------------------------
#
source("mrr_load.R")
system("touch ../output/R/mrr_do.Rout")

# code goes here ...
# Histogramms
hist(dat$y[dat$group=="X"], col="blue")
hist(dat$y[dat$group=="Y"], col="blue")

# 2. Compute linear model, adjusted for  age
#-----------------------------------------------------------------------
lmfit <- lm(y ~ group + age, data=dat)

# 3. Visualize residuals to check model assumptions
#-----------------------------------------------------------------------
plot(density(resid(lmfit)))

# 4. Print coefficients
#-----------------------------------------------------------------------
summary(lmfit)

