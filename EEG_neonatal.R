# file EEG_neonatal.R
# copyright (C) 2021-2022 Artur Gramacki and Jaroslaw Gramacki
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 or 3 of the License
#  (at your option).
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  A copy of the GNU General Public License is available at
#  http://www.r-project.org/Licenses/


# These two libraries must by first installed.
# Install from https://bioconductor.org
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

pkgs <- c("edf", "png")
to_install = !pkgs %in% installed.packages()
if(any(to_install)) {
  install.packages(pkgs[to_install])
}

pkg <- c("rhdf5")
to_install = !pkg %in% installed.packages()
if(to_install) {
  BiocManager::install("rhdf5")
}

library(edf)
library(png)
library(rhdf5)

source("EEG_neonatal_FUNS.R")

# We assume the following directory structure is created under the 'dir':
#   |---annotations
#   |---edf
#   |---Python
#   |---R
#       |---test_files
#   |---working
#     |---acc_loss
#     |---best_models
#     |---hists
#     |---inputs
#     |---logs
#     |---results    
#     |---ROC
#     |---waveforms

# Set dir to indicating the appropriate directory for your local computer. 
# If you are working with a directory structure as shown above, do not change this variable. 
dir = "../"

# Symbols of human experts
we <- c( "A", "B", "C")

# Annotations file names, as downloaded from https://zenodo.org/record/4940267
ann.f <- c("annotations_2017_A_fixed.csv",
          "annotations_2017_B.csv",
          "annotations_2017_C.csv")

# infant IDs which have seizures 
s.IDs <- c(1,4,5,7,9,11,13,14,15,16,17,19,20,21,22,25,31,34,36,38,39,40,41,44,47,50,51,52,62,63,66,67,69,71,73,75,76,77,78,79)
# infant IDs which are seizure free
ns.IDs <- c(3,10,18,27,28,29,30,32,35,37,42,45,48,49,53,55,57,58,59,60,70,72)

timestamp()
for (i in 1:3) { 
  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 1, chunks = 1, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 1, chunks = 2, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 1, chunks = 5, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 1, chunks = 10, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 1, chunks = 20, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
  
  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 2, chunks = 1, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 2, chunks = 2, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 2, chunks = 5, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 2, chunks = 10, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 2, chunks = 20, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
  
  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 5, chunks = 1, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 5, chunks = 2, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 5, chunks = 5, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 5, chunks = 10, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 5, chunks = 20, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)

  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 10, chunks = 1, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 10, chunks = 2, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 10, chunks = 5, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 10, chunks = 10, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 10, chunks = 20, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)

  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 20, chunks = 1, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 20, chunks = 2, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 20, chunks = 5, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 20, chunks = 10, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 20, chunks = 20, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)

  # We set chunks = 10000 and this way we are sure that the maximum possible set of chunks will be selected. 
  # Our dataset simply doesn't have seizures as long as 10,000 seconds.  
  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 1, chunks = 10000, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 2, chunks = 10000, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 5, chunks = 10000, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 10, chunks = 10000, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
  out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 20, chunks = 10000, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
}
timestamp()

time_elapsed <- system.time({
  
  read_signal_lengths(1:79, dir)
  
})

options(width = 999)

ann <-
  read.csv(
    paste(dir, "annotations/", "annotations_2017_A_fixed.csv", sep = ""),
    sep = ",",
    header = TRUE,
    stringsAsFactors = F,
    check.names = FALSE,
    encoding = 'UTF-8')

head(ann, 20)

options(width = 999)

time_elapsed <- system.time({
  
  out <-  generate_samples(
    which.expert = "A",
    annotations_file = "annotations_2017_A_fixed.csv",
    seizure.IDs = s.IDs,
    non.seizure.IDs = ns.IDs,
    window = 1,
    chunks = 1,
    down.sampling.factor = 4,
    preprocessing = FALSE,
    dir = dir,
    random = FALSE,
    write.txt.files = FALSE,
    write.hdf5.files = TRUE
  )
  
})

options(width = 999)

time_elapsed <- system.time({
  
   for (i in 1:3) { 
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 1, chunks = 1, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 1, chunks = 2, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 1, chunks = 5, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 1, chunks = 10, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 1, chunks = 20, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
     
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 2, chunks = 1, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 2, chunks = 2, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 2, chunks = 5, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 2, chunks = 10, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 2, chunks = 20, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
     
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 5, chunks = 1, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 5, chunks = 2, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 5, chunks = 5, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 5, chunks = 10, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 5, chunks = 20, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
   
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 10, chunks = 1, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 10, chunks = 2, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 10, chunks = 5, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 10, chunks = 10, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 10, chunks = 20, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
   
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 20, chunks = 1, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 20, chunks = 2, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 20, chunks = 5, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 20, chunks = 10, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 20, chunks = 20, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
   
     # We set chunks = 10000 and this way we are sure that the maximum possible set of chunks will be selected. 
     # Our dataset simply doesn't have seizures as long as 10,000 seconds.  
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 1, chunks = 10000, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 2, chunks = 10000, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 5, chunks = 10000, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 10, chunks = 10000, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
     out <-  generate_samples(which.expert = we[i], annotations_file = ann.f[i], seizure.IDs = s.IDs, non.seizure.IDs = ns.IDs, window = 20, chunks = 10000, down.sampling.factor = 4, preprocessing = FALSE, dir = dir, random = FALSE, write.txt.files = FALSE, write.hdf5.files = TRUE)
   }
  
})

# infant IDs where 1 or 2 experts annotated seizures, expert A
s12A.IDs <- c(2,8,23,33,54,68)

# infant IDs where 1 or 2 experts annotated seizures, expert B
s12B.IDs <- c(8,24,64,68,74)

# infant IDs where 1 or 2 experts annotated seizures, expert C
s12C.IDs <- c(6,12,23,26,33,43,46,54,56,61,64,65,74)

time_elapsed <- system.time({
  
   p.ID <- c(s.IDs, s12A.IDs)
   generate_eeg_waveforms(
     mode = "seizure",
     which.expert = we[1],
     annotations.file = ann.f[1],
     patient.IDs = p.ID,
     window = 10,
     down.sampling.factor = 4,
     non.seizures.chunks = 10,
     preprocessing = FALSE,
     random = FALSE,
     format = "png",
     save.to.file = TRUE,
     dir = dir
   )
   
   p.ID <- c(s.IDs, s12B.IDs)
   generate_eeg_waveforms(
     mode = "seizure",
     which.expert = we[2],
     annotations.file = ann.f[2],
     patient.IDs = p.ID,
     window = 10,
     down.sampling.factor = 4,
     non.seizures.chunks = 10,
     preprocessing = FALSE,
     random = FALSE,
     format = "png",
     save.to.file = TRUE,
     dir = dir
   )
   
   p.ID <- c(s.IDs, s12C.IDs)
   generate_eeg_waveforms(
     mode = "seizure",
     which.expert = we[3],
     annotations.file = ann.f[3],
     patient.IDs = p.ID,
     window = 10,
     down.sampling.factor = 4,
     non.seizures.chunks = 10,
     preprocessing = FALSE,
     random = FALSE,
     format = "png",
     save.to.file = TRUE,
     dir = dir
   )
  
})

out = read.csv(
  '../working/waveforms/expert_A_pat1_64Hz.csv', 
  sep = "\t", 
  blank.lines.skip = FALSE
)
out[is.na(out)] <- ""
print(out, row.names = FALSE, na.print = "" , quote = FALSE)

img <- readPNG("../working/waveforms/seizures_expert_A_pat1_no1_win10_len18_from104_to121_64Hz.png")
grid::grid.raster(img)

range <- c(104, 114)
patient <- 1
channel <- 1

out <- generate_selected_waveforms(
  patient = patient,
  down.sampling.factor = 4,
  channel = channel,
  sec.range = range,
  preprocessing = FALSE,
  dir
)

plot(out$points, type = "l", xlab = "", ylab = "", yaxt = "n", xaxt = "n", main = paste ("Patient #", patient))
ticks <- seq(1, length(out$points), length.out = 2)
axis(1, at = ticks, labels = seq(range[1], range[2], length.out = 2), main = "a")
mtext(text = out$channel.names, las = 1, adj = 0, cex = 1, side = 2, outer = FALSE, line = 3)

out <- read_channel_names(1)

# in EDF file
out$sig.names.in.edf.file

# after montage
out$sig.names.after.montage

ann <-
  read.csv(
    paste("test_files/sample_annotations.csv", sep = ""),
    sep = ",",
    header = TRUE,
    stringsAsFactors = F,
    check.names = FALSE,
    encoding = 'UTF-8'
  )
head(ann, 25)

IDs <- c(1, 2)

for (i in IDs) {
  filename <- paste("test_files/eeg", i, ".edf", sep = "")
  edf <- read.edf(filename = filename, read.annotations = FALSE, header.only = FALSE)
  
  n.sigs <- edf[["header.global"]][["n.signals"]]
  f.edf <- edf[["header.signal"]][[1]][["n.samples"]]
  len <- length(edf$signal[[1]]$data)
  # in seconds
  len.secs <- len/f.edf
  
  sig.names <- NaN
  for (s in 1:n.sigs) {
    sig.names[s] <- edf$header.signal[[s]]$label  
  }
  sig.names
  
  cat("\nEDF file: ", filename,  "\n", sep = "")
  cat (
    "  number of signals: ", n.sigs, "\n",
    "  base frequency: ", f.edf, "\n",
    "  number of samples: ", len, "\n",
    "  length in secs: ", len.secs, "\n",
    sep = "")
  cat ("  signal names: ", "\n", sep = "")
  print(sig.names)
}

for (k in IDs) {
  filename <- paste(dir, "edf/eeg", k, ".edf", sep = "")
  cat("EDF file: ", filename,  "\n", sep = "")
  out <- select_seizure_chunks(data = ann, f.edf, k) 
  print(out)
}

filename
edf[["header.signal"]][["EDF_Annotations"]][["n.samples"]]
length(edf$signal[["EDF_Annotations"]]$data)
unique(edf[["signal"]][["EDF_Annotations"]][["data"]])
plot(edf[["signal"]][["EDF_Annotations"]][["data"]], pch = 16, cex = 0.5, ylab = "")

time_elapsed <- system.time({
  
  out <-
    generate_samples(
      which.expert = "CC",
      annotations_file = ann.f[3],
      seizure.IDs = s12C.IDs,
      non.seizure.IDs = ns.IDs,
      window = 10,
      chunks = 20,
      down.sampling.factor = 4,
      preprocessing = FALSE,
      dir = dir,
      random = FALSE,
      write.txt.files = FALSE,
      write.hdf5.files = TRUE
    )
  
})
