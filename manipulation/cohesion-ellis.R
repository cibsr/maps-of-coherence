# this script imports the raw data described in this shared document 
# https://drive.google.com/file/d/10idMxy8eX8nTHr6wr2Q40x4XOP3Y5ck7/view
# and prepares a state of data used as a standard point of departure for any subsequent reproducible analytics

# Lines before the first chunk are invisible to Rmd/Rnw callers
# Run to stitch a tech report of this script (used only in RStudio)
# knitr::stitch_rmd(
#   script = "./manipulation/0-greeter.R",
#   output = "./manipulation/stitched-output/0-greeter.md"
# )
# this command is typically executed by the ./manipulation/governor.R

rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. 
# This is not called by knitr, because it's above the first chunk.
cat("\f") # clear console when working in RStudio

# ---- load-sources ------------------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.

# ---- load-packages -----------------------------------------------------------
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr) #Pipes
library(ggplot2)

# ---- declare-globals ---------------------------------------------------------
path_input <- "./data-public/raw/synthetic/synthetic.csv"

# ---- load-data ---------------------------------------------------------------
ds <- readr::read_csv(path_input)
ds %>% dplyr::glimpse(50)

# ---- tweek-data ---------------------------------------------------------------
ds <- ds %>% 
  dplyr::group_by(interval,focal_channel) %>% 
  dplyr::mutate(
   max = max(value)
   ,median = median(value)
   ,mean = mean(value)
   ,rand = rank(value)
   ,top = ifelse(rank(value)==1,TRUE, FALSE)
  ) %>% 
  dplyr::ungroup() %>% 
  # adjust the scales
  dplyr::mutate(
    region = as.factor(region)
    ,interval = as.factor(interval)
    ,channel = as.factor(channel)
  )

ds %>% dplyr::glimpse(50)

# ---- basic-graph -----------------------

d <- ds %>% 
  dplyr::filter(top)


g1 <- d %>% 
  ggplot(aes(x = interval, y = channel, color = region))+
  geom_line(aes(group=focal_channel))+
  # geom_point(aes(size = mean), shape = 21)+
  geom_point(shape = 20, size = 2)+
  # scale_y_discrete(limits = c(1:22))+
  coord_cartesian(ylim = c(1,22))+
  geom_vline(xintercept = c(3.5, 5.5), linetype = "dashed")+
  annotate(geom="text", x = 2, y = 21, label = "TASK 1")+
  annotate(geom="text", x = 4.5, y = 21, label = "REST")+
  annotate(geom="text", x = 7, y = 21, label = "TASK 2")+
  labs(title = "Functional cohesion guided by the mode")+
  theme_minimal()
g1
  
g2 <- g1 +
  facet_grid(region ~ . )
g2
  

# ---- define-utility-functions ---------------



# ---- save-to-disk ----------------------------

