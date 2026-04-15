import os
import pandas as pd
import re

def clean_price(price_str):
    """Clean price strings by removing ₹ and , and converting to float"""
    if pd.isna(price_str):
        return None
    # Remove ₹, commas, and any whitespace
    cleaned = re.sub(r'[₹,]', '', str(price_str)).strip()
    try:
        return float(cleaned)
    except ValueError:
        return None

def clean_ratings(rating_str):
    """Clean ratings to ensure they're numeric"""
    if pd.isna(rating_str):
        return None
    try:
        return float(rating_str)
    except ValueError:
        return None

def clean_no_of_ratings(rating_count_str):
    """Clean number of ratings to ensure they're numeric"""
    if pd.isna(rating_count_str):
        return None
    # Remove commas and parentheses if present
    cleaned = re.sub(r'[(),]', '', str(rating_count_str)).strip()
    try:
        return int(cleaned)
    except ValueError:
        return None

def process_file(input_path, output_path):
    """Process a single CSV file"""
    # Read the CSV file
    df = pd.read_csv(input_path)
    
    # Clean prices
    df['actual_price'] = df['actual_price'].apply(clean_price)
    df['discount_price'] = df['discount_price'].apply(clean_price)
    
    # Replace null discounted prices with actual prices
    df['discount_price'] = df['discount_price'].fillna(df['actual_price'])
    
    # Clean ratings and number of ratings
    df['ratings'] = df['ratings'].apply(clean_ratings)
    df['no_of_ratings'] = df['no_of_ratings'].apply(clean_no_of_ratings)
    
    # Filter rows
    # 1. Remove rows with null actual_price
    df = df[df['actual_price'].notna()]
    
    # 2. Remove rows with null or non-numeric ratings/no_of_ratings
    df = df[df['ratings'].notna() & df['no_of_ratings'].notna()]
    
    # Save cleaned data
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    df.to_csv(output_path, index=False)

def main():
    # Define paths
    data_dir = 'Data'
    cleaned_dir = 'Cleaned'
    
    # Process each file in the Data directory
    for filename in os.listdir(data_dir):
        if filename.endswith('.csv'):
            input_path = os.path.join(data_dir, filename)
            output_path = os.path.join(cleaned_dir, filename)
            process_file(input_path, output_path)
            print(f"Processed {filename}")

if __name__ == '__main__':
    main()