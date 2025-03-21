# load the necessary packages
library(hexSticker) # hexSticker generator
library(magick)     # Advanced image processing
library(sysfonts)   # font selection
library(tidyverse)
library(jpeg)
# Sticker function---------------------------

# Create your first sticker------------------
img <- image_read("C:/Users/jacob/OneDrive - Université Laval/cosmo/man/figures/custom.png")

fonts_dataset <- font_files()

sticker(
  subplot = img,
  package = "cosmo-r",
  s_width = 1,
  s_height = 1,
  s_x = 1,
  s_y = 0.8,
  p_size = 28,
  h_fill = '#343b46',
  h_color = '#ac87ff',
  h_size = 1.5,
  u_size = 5,
  u_color = '#ac87ff',
  spotlight = F,
  l_y = 1,
  l_x = 1,
  l_width = 3,
  l_height = 3,
  l_alpha = 0.3,
  p_color = '#ac87ff',
  p_family = "Times"
) %>% print()


