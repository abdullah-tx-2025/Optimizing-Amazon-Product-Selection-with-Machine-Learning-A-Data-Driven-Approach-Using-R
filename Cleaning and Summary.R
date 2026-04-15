library(readr)
library(dplyr)

# Optimized mode function (assumes x has no NAs)
statistical_mode <- function(x) {
  unique_x <- unique(x)
  unique_x[which.max(tabulate(match(x, unique_x)))]
}

# Read and clean the CSV file
merged_data <- read.csv("merged_data.csv", stringsAsFactors = FALSE) %>%
  filter(ratings != "Get") %>%  # Remove invalid ratings
  mutate(
    discount_price = as.numeric(gsub("[₹,]", "", discount_price)),
    actual_price = as.numeric(gsub("[₹,]", "", actual_price)),
    no_of_ratings = as.numeric(gsub(",", "", no_of_ratings)),
    ratings = as.numeric(gsub("[^0-9.]", "", ratings))
  ) %>%
  filter(!is.na(ratings) & !is.na(no_of_ratings) & !is.na(actual_price)) %>%  # Remove rows with NA
  mutate(discount_price = ifelse(is.na(discount_price), actual_price, discount_price))  # Replace NA discount price

# Save cleaned data
write.csv(merged_data, "cleaned_data.csv", row.names = FALSE)
print("Cleaned data saved to cleaned_data.csv")

# Summarize data
summary_data <- merged_data %>%
  group_by(main_category, sub_category) %>%
  summarise(
    mean_ratings = mean(ratings, na.rm = TRUE),
    sd_ratings = sd(ratings, na.rm = TRUE),
    median_ratings = median(ratings, na.rm = TRUE),
    mode_ratings = ifelse(length(ratings) > 0, statistical_mode(ratings), NA),
    mean_number_of_ratings = mean(no_of_ratings, na.rm = TRUE),
    sd_number_of_ratings = sd(no_of_ratings, na.rm = TRUE),
    median_number_of_ratings = median(no_of_ratings, na.rm = TRUE),
    mode_number_of_ratings = ifelse(length(no_of_ratings) > 0, statistical_mode(ratings), NA),
    mean_discount_price = mean(discount_price, na.rm = TRUE),
    sd_discount_price = sd(discount_price, na.rm = TRUE),
    median_discount_price = median(discount_price, na.rm = TRUE),
    mode_discount_price = ifelse(length(discount_price) > 0, statistical_mode(discount_price), NA),
    mean_actual_price = mean(actual_price, na.rm = TRUE),
    sd_actual_price = sd(actual_price, na.rm = TRUE),
    median_actual_price = median(actual_price, na.rm = TRUE),
    mode_actual_price = ifelse(length(actual_price) > 0, statistical_mode(actual_price), NA),
    number_of_orders = sum(no_of_ratings),
    total_revenue = sum(no_of_ratings * discount_price, na.rm = TRUE),
    .groups = "drop"
  )

# Save summary data
write.csv(summary_data, "summary_data.csv", row.names = FALSE)