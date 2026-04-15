# Load required libraries
library(dplyr)
library(caret)
library(ROCR)

# Step 1: Compute revenue
Amazon_Training <- Amazon_Training %>%
  mutate(revenue = discount_price * no_of_ratings * ratings)

Amazon_Validation <- Amazon_Validation %>%
  mutate(revenue = discount_price * no_of_ratings * ratings)

# Step 2: Normalize revenue using training min and max
min_rev <- min(Amazon_Training$revenue, na.rm = TRUE)
max_rev <- max(Amazon_Training$revenue, na.rm = TRUE)

Amazon_Training <- Amazon_Training %>%
  mutate(norm_revenue = (revenue - min_rev) / (max_rev - min_rev))

Amazon_Validation <- Amazon_Validation %>%
  mutate(norm_revenue = (revenue - min_rev) / (max_rev - min_rev))

# Step 3: Create will_succeed column using top 10% revenue in training data
threshold <- quantile(Amazon_Training$norm_revenue, 0.90, na.rm = TRUE)

Amazon_Training <- Amazon_Training %>%
  mutate(will_succeed = ifelse(norm_revenue >= threshold, 1, 0))

Amazon_Validation <- Amazon_Validation %>%
  mutate(will_succeed = ifelse(norm_revenue >= threshold, 1, 0))

# Step 4: Create dummy variables using caret::dummyVars
# Define the variables to include in the model
vars_for_model <- c("discount_price", "actual_price", "ratings", "no_of_ratings", "sub_category")

# Set up dummy variable transformer (trained on training data)
dummies <- dummyVars(~ ., data = Amazon_Training[, vars_for_model])

# Apply transformation to both datasets
train_data <- predict(dummies, newdata = Amazon_Training[, vars_for_model]) %>% as.data.frame()
train_data$will_succeed <- Amazon_Training$will_succeed

test_data <- predict(dummies, newdata = Amazon_Validation[, vars_for_model]) %>% as.data.frame()
test_data$will_succeed <- Amazon_Validation$will_succeed

# Step 5: Fit logistic regression model
logit_model <- glm(will_succeed ~ ., data = train_data, family = binomial)

# Step 6: Predict on validation data
pred_probs <- predict(logit_model, newdata = test_data, type = "response")
pred_classes <- ifelse(pred_probs > 0.5, 1, 0)

# Step 7: Evaluation
conf_matrix <- confusionMatrix(as.factor(pred_classes), as.factor(test_data$will_succeed))
print(conf_matrix)

# Step 8: ROC Curve and AUC
pred <- prediction(pred_probs, test_data$will_succeed)
perf <- performance(pred, "tpr", "fpr")
auc <- performance(pred, "auc")@y.values[[1]]
plot(perf, col = "blue", main = paste("ROC Curve (AUC =", round(auc, 3), ")"))
abline(a = 0, b = 1, lty = 2, col = "gray")


# Add probabilities back to validation data
Amazon_Validation$logistic_prob <- pred_probs

# Select top 10 products
top10_logistic <- Amazon_Validation %>%
  arrange(desc(logistic_prob)) %>%
  head(10)

write.csv(top10_logistic, "/Users/abdullahrafiq/Documents/UTD/Business Analytics with R/Group Project/Results/top10logistic.csv", row.names = FALSE)

