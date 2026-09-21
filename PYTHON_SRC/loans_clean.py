
import pandas as pd 
from sqlalchemy import create_engine
import os
from dotenv import load_dotenv

df=pd.read_csv(r"C:\Users\sambh\Desktop\resume_projects\Loan_project\DATA\Raw_data\loans.csv")


df=df.drop_duplicates(subset="loan_id")

df["loan_type"]=df["loan_type"].str.strip().str.title()

df["loan_type"]=df["loan_type"].fillna("Unavailable")

df["loan_amount"] = df["loan_amount"].abs()


median = df["interest_rate"].median()
df["interest_rate"]=df["interest_rate"].fillna(median)


df["disbursed_date"]=pd.to_datetime(df["disbursed_date"],errors="coerce",format="mixed")

cust=pd.read_csv(r"C:\Users\sambh\Desktop\resume_projects\Loan_project\DATA\Raw_data\customers.csv")

orphans = ~df["customer_id"].isin(cust["customer_id"])
print(orphans.sum()) 




load_dotenv()
password = os.getenv("DB_PASSWORD")

engine = create_engine(f"postgresql+pg8000://postgres:{password}@localhost:5432/loan_analysis")

df.to_sql("loans", engine, if_exists="append", index=False)
df.to_csv(r"C:\Users\sambh\Desktop\resume_projects\Loan_project\DATA\Cleaned_data\loans_clean.csv",index=False)
print(len(df), "rows loaded")