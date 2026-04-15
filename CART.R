# Load necessary libraries
library(rpart)
library(rpart.plot)
library(caret)
library(ROCR)

# Step 1: Make sure will_succeed is a factor (required for classification trees)
Amazon_Training$will_succeed <- as.factor(Amazon_Training$will_succeed)
Amazon_Validation$will_succeed <- as.factor(Amazon_Validation$will_succeed)

# Step 2: Train CART model using rpart
cart_model <- rpart(will_succeed ~ discount_price + actual_price + ratings + 
                      no_of_ratings + sub_category,
                    data = Amazon_Training,
                    method = "class",      # classification mode
                    control = rpart.control(cp = 0.01))  # cp = complexity parameter

# Step 3: Visualize the tree
rpart.plot(cart_model, type = 2, extra = 104, fallen.leaves = TRUE,
           main = "CART Decision Tree")

# Step 4: Predict on validation set
cart_preds <- predict(cart_model, newdata = Amazon_Validation, type = "class")

# Step 5: Evaluate performance
conf_matrix_cart <- confusionMatrix(cart_preds, Amazon_Validation$will_succeed)
print(conf_matrix_cart)

#------------OPTIONAL------------
set.seed(123)
cart_tuned <- train(will_succeed ~ discount_price + actual_price + ratings + 
                      no_of_ratings + sub_category,
                    data = Amazon_Training,
                    method = "rpart",
                    trControl = trainControl(method = "cv", number = 5),
                    tuneLength = 10)

# Best model
print(cart_tuned$bestTune)
plot(cart_tuned)

# Re-train CART model using best cp
final_cart_model <- rpart(will_succeed ~ discount_price + actual_price + ratings + 
                            no_of_ratings + sub_category,
                          data = Amazon_Training,
                          method = "class",
                          control = rpart.control(cp = 0.004317869))

# Predict on validation data
final_cart_preds <- predict(final_cart_model, newdata = Amazon_Validation, type = "class")

# Evaluate performance
conf_matrix_final_cart <- confusionMatrix(final_cart_preds, Amazon_Validation$will_succeed)
print(conf_matrix_final_cart)

# Optional: Plot the final tree
rpart.plot(final_cart_model, type = 2, extra = 104, fallen.leaves = TRUE,
           main = "Final Tuned CART Tree")

#Plotting ROC/AUC
# Step 1: Get predicted probabilities (for class "1")
cart_prob_preds <- predict(final_cart_model, newdata = Amazon_Validation, type = "prob")[, "1"]

# Step 2: Prepare prediction and performance objects
cart_pred <- prediction(cart_prob_preds, Amazon_Validation$will_succeed)
cart_perf <- performance(cart_pred, "tpr", "fpr")
cart_auc <- performance(cart_pred, "auc")@y.values[[1]]

# Step 3: Plot ROC Curve
plot(cart_perf, col = "darkgreen", lwd = 2, main = paste("CART ROC Curve (AUC =", round(cart_auc, 3), ")"))
abline(a = 0, b = 1, lty = 2, col = "gray")

# Get probabilities from CART
cart_probs <- predict(final_cart_model, newdata = Amazon_Validation, type = "prob")[, "1"]

Amazon_Validation$cart_prob <- cart_probs

top10_cart <- Amazon_Validation %>%
  arrange(desc(cart_prob)) %>%
  head(10)

print(top10_cart)
write.csv(top10_cart, "/Users/abdullahrafiq/Documents/UTD/Business Analytics with R/Group Project/Results/top10_cart.csv", row.names = FALSE)

