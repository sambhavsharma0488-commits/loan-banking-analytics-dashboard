import pandas as pd 
from sqlalchemy import create_engine
import os
from dotenv import load_dotenv

df=pd.read_csv(r"C:\Users\sambh\Desktop\resume_projects\Loan_project\DATA\Raw_data\transactions.csv")

df=df.drop_duplicates(subset="txn_id")

df["txn_date"]=pd.to_datetime(df["txn_date"],errors="coerce",format="mixed")


df["txn_amount"]=df["txn_amount"].fillna(df["txn_amount"].median())

df["txn_type"]=df["txn_type"].str.strip().str.title()

df["product"]=df["product"].fillna("Unavailable")



cust=pd.read_csv(r"C:\Users\sambh\Desktop\resume_projects\Loan_project\DATA\Raw_data\customers.csv")

orphans = df["customer_id"].isin(cust["customer_id"])
print(orphans.sum()) 


load_dotenv()
password = os.getenv("DB_PASSWORD")

engine = create_engine(f"postgresql+pg8000://postgres:{password}@localhost:5432/loan_analysis")

df.to_sql("transactions", engine, if_exists="append", index=False)

df.to_csv(r"C:\Users\sambh\Desktop\resume_projects\Loan_project\DATA\Cleaned_data\transactions_clean.csv",index=False)

print(len(df), "rows loaded")