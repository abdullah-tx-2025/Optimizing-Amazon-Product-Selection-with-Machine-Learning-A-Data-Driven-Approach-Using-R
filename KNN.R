# Load required libraries
library(caret)
library(dplyr)
library(ROCR)

# Step 1: Define features to include
features <- c("discount_price", "actual_price", "ratings", "no_of_ratings", "sub_category")

# Step 2: Create dummy variables for both sets
dummies <- dummyVars(~ ., data = Amazon_Training[, features])

train_features <- predict(dummies, newdata = Amazon_Training[, features]) %>% as.data.frame()
test_features <- predict(dummies, newdata = Amazon_Validation[, features]) %>% as.data.frame()

# Step 3: Scale numeric features using training set
preproc <- preProcess(train_features, method = c("center", "scale"))
train_scaled <- predict(preproc, train_features)
test_scaled <- predict(preproc, test_features)

# Step 4: Add target variable
train_scaled$will_succeed <- as.factor(Amazon_Training$will_succeed)
test_scaled$will_succeed <- as.factor(Amazon_Validation$will_succeed)

# Step 5: Subsample to reduce compute load (optional but helpful)
set.seed(42)
train_sample <- train_scaled %>% sample_n(50000)
test_sample <- test_scaled %>% sample_n(15000)

# Step 6: Train KNN model
set.seed(123)
knn_model <- train(will_succeed ~ ., 
                   data = train_sample, 
                   method = "knn", 
                   tuneGrid = expand.grid(k = c(3, 5, 7)),
                   trControl = trainControl(method = "cv", number = 3))

# Step 7: Predict and evaluate
knn_preds <- predict(knn_model, newdata = test_sample)
conf_matrix_knn <- confusionMatrix(knn_preds, test_sample$will_succeed)
print(conf_matrix_knn)

# Step 8: AUC & ROC (Optional)
knn_probs <- predict(knn_model, newdata = test_sample, type = "prob")[, "1"]
knn_pred <- prediction(knn_probs, test_sample$will_succeed)
knn_perf <- performance(knn_pred, "tpr", "fpr")
knn_auc <- performance(knn_pred, "auc")@y.values[[1]]

plot(knn_perf, col = "purple", lwd = 2, main = paste("KNN ROC Curve (AUC =", round(knn_auc, 3), ")"))
abline(a = 0, b = 1, lty = 2, col = "gray")

# Get probabilities from KNN
knn_probs <- predict(knn_model, newdata = test_sample, type = "prob")[, "1"]


# Step 1: Add predicted probability to test_sample
test_sample$knn_prob <- knn_probs

# Step 2: Add row numbers for easy mapping
test_sample$row_id <- as.numeric(rownames(test_sample))

# Step 3: Find top 10 rows based on KNN probabilities
top10_knn_rows <- test_sample %>%
  arrange(desc(knn_prob)) %>%
  head(10)

# Step 4: Now use the row_id to pull full info from Amazon_Validation
top10_knn_full <- Amazon_Validation[top10_knn_rows$row_id, ]

# Optional: Add knn_prob for reference
top10_knn_full$knn_prob <- top10_knn_rows$knn_prob

# Step 5: Write to CSV
write.csv(top10_knn_full, "/Users/abdullahrafiq/Documents/UTD/Business Analytics with R/Group Project/Results/top10_knn_full.csv", row.names = FALSE)
