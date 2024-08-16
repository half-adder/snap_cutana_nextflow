#!/usr/bin/env Rscript

library("tidyverse")

# Load barcode_counts.txt as tibble
barcode_counts <- read_csv(
  "barcode_counts.txt",
  col_names = c("Sample", "Epitope", "Alpha.Idx", "Count"),
  col_types = list(
    Sample = col_character(),
    Epitope = col_character(),
    Alpha.Idx = col_character(),
    Count = col_integer()
  )
)

# Pivot Read 1 and Read 2 counts into separate columns
barcode_counts <- barcode_counts %>%
  mutate(
    Sample_Type = str_extract(Sample, "R1|R2"),
    Sample = str_extract(Sample, "(.*)_R[12]_*", group = TRUE)
  )


# Count Reads and Pivot A/B reads into their own columns
barcode_counts_wide <- barcode_counts %>%
  pivot_wider(names_from = Sample_Type, values_from = Count) %>%
  mutate(Reads = R1 + R2) %>%
  select(-R1, -R2) %>%
  pivot_wider(names_from = Alpha.Idx, values_from = Reads) %>%
  mutate(Total.Reads = B + A)

# Create a new column called "Percentage.Total" which is the
# percentage of each epitope's reads out of the total reads for the sample
barcode_counts_wide <- barcode_counts_wide %>%
  group_by(Sample) %>%
  mutate(Percentage.Total = Total.Reads / sum(Total.Reads) * 100)

# Plot the percentage of each epitope's reads out
# of the total reads for the sample as a heatmap
heatmap <- barcode_counts_wide %>%
  ggplot(aes(x = Epitope, y = Sample, fill = Percentage.Total)) +
  geom_tile() +
  geom_text(aes(label = round(Percentage.Total, 2)), color = "white", size = 4)

ggsave("heatmap.png", heatmap, width = 30, height = 10, dpi = 300)
ggsave("heatmap.pdf", heatmap, width = 30, height = 10, dpi = 300)