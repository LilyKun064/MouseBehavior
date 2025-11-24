## 📦 MouseBehavior

MouseBehavior is a lightweight R package for cleaning, standardizing, and summarizing CowLog behavioral annotation files, with a focus on Forced Swim Test (FST) data.
It modularizes every step of the workflow you previously wrote manually — including:
- checking file integrity
- cleaning and standardizing event codes
- trimming recordings to a fixed test duration
- inserting missing Stop events
- summarizing behavior durations, bouts, and per-minute segmentation
- validating summaries
- filling missing values using your lab’s rules
This package ensures fully reproducible, clean, and consistent summaries for mouse behavioral datasets.

## ✨ Features

- ✔ Clean CowLog files (time, code, class)
- ✔ Trim recordings to exact test duration
- ✔ Automatically fix missing or duplicated events
- ✔ Add missing Stop events after Start
- ✔ Compute total behavior time, bouts, first entry, and per-minute bins
- ✔ Validate output with automated consistency checks
- ✔ Apply standardized NA-filling rules
- ✔ Functions are modular, not monolithic — you can call any component directly
- ✔ 100% R-native, no dependencies beyond tidyverse components

## 📥 Installation

Install the development version from GitHub:
```r
# install.packages("remotes")
remotes::install_github("LilyKun064/MouseBehavior")

library(MouseBehavior)
```

## 📂 Package Structure

```bash
MouseBehavior/
  R/                        # individual functions (one per script)
  man/                      # documentation (auto-generated)
  inst/examples/            # example files and scripts
  DESCRIPTION               # package metadata
  NAMESPACE                 # exports (auto-generated)
  LICENSE                   # MIT license
```

## 🐭 Sample Raw CowLog File (Mouse123.csv)

This is the starting data format the package expects:
- The file name is the animal ID, e.g. 107057.csv
- The file itself contains three columns:
  - time → numeric (seconds from recording start)
  - code → behavior event
  - class → arbitrary class code from CowLog (1 = ActiveSwim, 2 = SlowPaddle, etc.)

### 📄 Sample content (Mouse123.csv)
```csv
time,code,class
1.177,Active Swim Start,1
232.478,Active Swim Stop,1
232.478,Slow Paddle Start,2
363.266276,END,0
```
This is a valid CowLog format because:
- Start event followed by matching Stop
- Next behavior begins at the exact same timestamp (allowed)
- Final event is END with class 0

## 🚀 Example Usage

Here is a full possible use-case on a folder of CowLog files:

```{r, Initialize variables}
library(MouseBehavior)
library(dplyr)

# folder for video info
dir_video_info <- "your_folder"

# output file path
dir_summary_info <- "your_path"

# total time (minutes), here using 6 minutes as an example
t <- 6

# put your behavior codes here, using forced swim test as an example here
behavior <- c("ActiveSwim", "SlowPaddle", "Float")

# your desired output file name
outputdataname <- "your_output_file_name"

# list CSV files
file_list <- list.files(
  path       = dir_video_info,
  pattern    = "\\.csv$",
  full.names = TRUE
)

```

```{r, Process files and summarise}
# Initialize the summary data frame
behavior_summary <- data.frame(MouseID = character(), stringsAsFactors = FALSE)

for (path in file_list) {
  filename <- basename(path)

  # --- Load raw data and keep only needed columns ---
  dat_raw <- read.csv(path, stringsAsFactors = FALSE)
  dat_raw <- dat_raw[, c("time", "code", "class"), drop = FALSE]

  # --- Basic structure check (replaces your "check for NO END files" columns logic) ---
  mb_check_columns(dat_raw, filename = filename)

  # --- Remove exact duplicate rows (replaces your "remove duplicated rows" loop) ---
  dat_raw <- dat_raw[!duplicated(dat_raw), , drop = FALSE]

  # --- Fix negative time jumps (replaces your "check and fix negative time difference") ---
  if (nrow(dat_raw) > 1L) {
    for (j in 2:nrow(dat_raw)) {
      if (dat_raw$time[j] < dat_raw$time[j - 1]) {
        dat_raw$time[j] <- dat_raw$time[j - 1]
        warning(paste("Time at Row", j, "was fixed in FILE:", filename))
      }
    }
  }

  # --- Check duration, trim to t minutes, enforce END row ---
  # This replaces your total_time / more_than_total_time / less_than_total_time block.
  dat_clean <- mb_check_and_trim_time(dat_raw, filename = filename, t = t)

  # --- Clean codes and add missing Stop events ---
  # Replaces your manual code cleaning + new Stop rows loop.
  dat_clean <- mb_clean_codes(dat_clean)
  dat_clean <- mb_add_missing_stops(dat_clean)

  # --- Derive MouseID from filename (same as your strsplit logic) ---
  mouse_id <- mb_mouse_id_from_path(path)

  # --- Summarise all behaviours for this file ---
  current_file <- mb_summarise_file(
    file      = dat_clean,
    behaviors = behavior,
    t         = t,
    mouse_id  = mouse_id
  )

  # --- Append row to behavior_summary ---
  behavior_summary <- dplyr::bind_rows(behavior_summary, current_file)
}

```

```{r, print summary}
print(paste("NUMBER OF FILES:", length(file_list)))
print(paste("NAME OF OUTPUT FILE:", outputdataname))
print("BEHAVIORS:")
print(behavior)

```

```{r, check the summary}
mb_check_behavior_summary(
  behavior_summary = behavior_summary,
  behaviors        = behavior,
  t                = t
)
```

```{r, fill NAs}
behavior_summary <- mb_fill_na_summary(behavior_summary)
```

```{r, write output}
output_file_path <- file.path(dir_summary_info, paste0(outputdataname, ".csv"))
write.csv(behavior_summary, file = output_file_path, row.names = FALSE)
```

This produces a clean summary table with columns like:
- total time spent on an activity: ActiveSwimTime
- the first time an activity happened: ActiveSwimEntry1
- total number of bouts a certain activity happened: ActiveSwimBouts
- time of the activity in the first minute, second minute, ...: ActiveSwimMin1 … ActiveSwimMin6
- … repeated for each behavior type

## 🧪 Example: Using One Function at a Time

Every step is modular. You can run individual functions:
```r
dat <- read.csv("Mouse123.csv")

dat <- mb_check_columns(dat)
dat <- mb_clean_codes(dat)
dat <- mb_check_and_trim_time(dat, t = 6)
dat <- mb_add_missing_stops(dat)

summary <- mb_summarise_file(dat,
                             behaviors = c("ActiveSwim", "SlowPaddle", "Float"),
                             t = 6,
                             mouse_id = "Mouse123")

summary <- mb_fill_na_summary(summary)
```

## 🐭 Why This Package Exists

FST data often contains:
- duplicated Start events
- missing Stop events
- inverted or inconsistent timestamps
- extra entries after test end
- files with fewer or more rows than expected
Previously, these required dozens of lines of manual cleanup and logic inside an Rmarkdown file.
MouseBehavior standardizes all of this into a clean, validated, reproducible workflow.

## ❗ Reporting Issues / Requests

If you find any inconsistencies or want new features, open an issue:
🔗 https://github.com/LilyKun064/MouseBehavior/issues

I welcome:
- bug reports
- requests for new behavioral metrics
- feature suggestions
- contributions

## 📝 License

This package is released under the MIT License.
