import pandas as pd 
from sqlalchemy import create_engine
import os
from dotenv import load_dotenv

df=pd.read_csv(r"C:\Users\sambh\Desktop\resume_projects\Loan_project\DATA\Raw_data\customers.csv")


df=df.drop_duplicates(subset="customer_id")


df["city"]=df["city"].fillna("UNKNOWN")

df["gender"] = df["gender"].str.strip().str.title()

df["join_date"] = pd.to_datetime(df["join_date"], errors="coerce",format="mixed")

median=(df[(df["age"]>=0) &  (df["age"].notnull())]["age"].median())
df.loc[df["age"] < 0, "age"] = median
df["age"]=df["age"].fillna(median)




load_dotenv()
password = os.getenv("DB_PASSWORD")

engine = create_engine(f"postgresql+pg8000://postgres:{password}@localhost:5432/loan_analysis")

df.to_sql("customers", engine, if_exists="append", index=False)
df.to_csv(r"C:\Users\sambh\Desktop\resume_projects\Loan_project\DATA\Cleaned_data\customers_clean.csv", index=False)
print(len(df), "rows loaded")