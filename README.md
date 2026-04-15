# Optimizing-Amazon-Product-Selection-with-Machine-Learning-A-Data-Driven-Approach-Using-R
# Introduction
In today’s saturated e-commerce landscape, Amazon sellers face a critical question: Which products should I stock to maximize revenue and minimize risk? With over a million product listings across hundreds of subcategories, selecting a winning product mix isn’t just difficult—it’s make-or-break for small businesses and individual sellers.

Launching an online store on Amazon comes with uncertainty. Sellers often rely on trends, intuition, or anecdotal recommendations. However, without a structured approach or access to historical sales data, this guesswork leads to poor inventory decisions, unsold stock, and lower search rankings. Our goal was to use predictive analytics to clarify this process. Could we identify product features that correlate strongly with success? Could we help sellers optimize their portfolio before investing in inventory?

To address this challenge, we combined domain understanding, structured data processing, and machine learning.The result? A working prototype that predicts whether a product is likely to fall within the top 10% of revenue-generating items, based on features like pricing, ratings, and customer feedback. Here’s how we did it.

# Data Collection and Preparation
We sourced our data from a public dataset on Kaggle, scraped from Amazon India listings and spanning 139 subcategories. After merging the individual category files, we built a master dataset of over 360,000 product listings, each with the following key attributes:

Product name
Sub-category
Discounted price
Actual price
Average customer rating
Number of ratings
Best seller rank (when available)

# Cleaning & Transformation
Our data preparation involved several steps:

Removed currency symbols and comma formatting from price fields
Converted strings to numeric formats for ratings and review counts
Excluded incomplete records and replaced missing discounted prices with actual prices (where applicable)
Created dummy variables for sub-categories
Standardized numeric fields to ensure model compatibility

# Target Variable Creation
Since we lacked actual sales data, we created a proxy for revenue as:

Estimated Revenue = discounted_price × number_of_ratings × ratings

We normalized this value using min-max scaling and labeled the top 10% as successful (1) and the rest as unsuccessful (0). This binary classification became the target variable: will_succeed.

# Modeling Approach
We employed three supervised classification algorithms to predict will_succeed:

Logistic Regression
CART (Classification and Regression Trees)
K-Nearest Neighbors (KNN)

Each model was trained and evaluated using the same feature set: price, ratings, number of ratings, and sub-category. The data was split into a training set (217,691 rows) and a validation set (145,050 rows). For KNN, we used a 50,000-row training sample and 15,000-row validation sample due to computational constraints.

# Model Performance
1. Logistic Regression
This model served as our baseline. It offered transparency by identifying which features most influenced product success.

Accuracy: 95.48%
Sensitivity: 98.72%
Specificity: 65.87%
AUC: ~0.91

While it performed well, the model struggled to balance false positives and false negatives.

2. CART (Tuned)
CART delivered the best overall performance, with intuitive decision paths and high accuracy after tuning the complexity parameter (cp) using 5-fold cross-validation.

Accuracy: 99%
Sensitivity: 99.53%
Specificity: 94.16%
AUC: 0.989

Its visual decision tree provided valuable business insights into which combinations of features drive product success.

3. K-Nearest Neighbors
Despite solid performance, KNN was computationally heavy and less interpretable. It's more suitable when explainability is not a priority.

Accuracy: 95.57%
AUC: 0.927
Sensitivity: 98.27%
Specificity: 71.24%

# Visual Insights
We supplemented our metrics with ROC curves to visualize model discrimination:

CART’s ROC showed strong area under the curve and excellent balance across thresholds
KNN’s ROC performed well but fell short of CART
Logistic Regression’s ROC highlighted its strength in identifying successful products but its limitation in specificity

We also plotted the CART decision tree to reveal dominant decision paths—such as how a moderately priced product with 4.2+ stars and >100 reviews had a high success likelihood.

# Practical Application
Using the final models, we extracted the top 10 most promising products for sellers to consider—based on predicted success probability. Interestingly, while there was overlap across models (e.g., SSDs, home appliances, and kitchen electronics), each model also surfaced unique products.

This confirms the complementary nature of different algorithms and their value in triangulating decisions.

# Limitations
Every model has trade-offs, and ours were no exception:

No access to actual sales data; our revenue proxy may not fully reflect conversion behavior
Seasonality and stock availability were not included
Model bias from scraped data and categorical imbalance (only 10% labeled successful)
KNN’s scalability was a limiting factor

Despite these, the results were robust enough to demonstrate strong predictive capability.

# Future Directions
To evolve this project into a real-world tool, we envision:

Integrating actual transaction data
Incorporating marketing metrics (e.g., impressions, click-through rate)
Using NLP to extract features from product descriptions
Deploying a web-based dashboard for sellers to upload products and receive success probabilities in real-time

# Reflections
This project was more than just an academic exercise. It reaffirmed how data science can bridge the gap between entrepreneurial instinct and strategic decision-making. By grounding decisions in evidence, sellers can build smarter, leaner, and more competitive online stores.

As emerging data professionals, this experience sharpened both our technical skills and our business judgment. Special thanks to my teammates, Sameer Bansal and Abdullah Rafiq, whose collaboration throughout—from cleaning 139 CSV files to tuning CART hyperparameters—was instrumental in bringing this idea to life.

# Conclusion
In a hyper-competitive e-commerce landscape, guesswork is expensive. Our project shows that even with limited data, structured analytics and machine learning can provide powerful decision support.

With further development, this framework could be a game-changer for new Amazon sellers looking to build profitable stores—one product at a time.
