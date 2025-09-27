from pyspark.sql import SparkSession
from pyspark.sql.functions import input_file_name, when

# Create Spark session
spark = SparkSession.builder \
                    .appName("Medical Claims Ingestion") \
                    .getOrCreate()

# configure variables
BUCKET_NAME = "db-health-partners"
CLAIMS_BUCKET_PATH = f"gs://{BUCKET_NAME}/inputdata/claims/*.csv"
BQ_TABLE = "gcp-health-partners-473103.bronze_dataset.claims"
TEMP_GCS_BUCKET = f"{BUCKET_NAME}/temp/"

# read from claims source
claims_df = spark.read.csv(CLAIMS_BUCKET_PATH, header=True)

# adding claim type source
claims_df = (claims_df
                .withColumn("datasource", 
                              when(input_file_name().contains("medc"), "hosb")
                             .when(input_file_name().contains("rx"), "hosa").otherwise("None")))

# dropping dupplicates if any
claims_df = claims_df.dropDuplicates()

# write to bigquery
(claims_df.write
            .format("bigquery")
            .option("table", BQ_TABLE)
            .option("temporaryGcsBucket", TEMP_GCS_BUCKET)
            .mode("overwrite")
            .save())