from pyspark.sql import SparkSession

# Create Spark session
spark = SparkSession.builder \
                    .appName("ACCTSTRUCT Ingestion") \
                    .getOrCreate()

# configure variables
BUCKET_NAME = "db-health-partners"
ACCT_BUCKET_PATH = f"gs://{BUCKET_NAME}/inputdata/acctstruct/*.csv"
BQ_TABLE = "agcp-health-partners-473103.bronze_dataset.acctstruct"
TEMP_GCS_BUCKET = f"{BUCKET_NAME}/temp/"

# read from cpt
acctstruct_df = spark.read.csv(ACCT_BUCKET_PATH, header=True)

# replace spaces with underscore
for col in acctstruct_df.columns:
    new_col = col.replace(" ", "_").lower()
    acctstruct_df = acctstruct_df.withColumnRenamed(col, new_col)

# write to bigquery
(acctstruct_df.write
            .format("bigquery")
            .option("table", BQ_TABLE)
            .option("temporaryGcsBucket", TEMP_GCS_BUCKET)
            .mode("overwrite")
            .save())