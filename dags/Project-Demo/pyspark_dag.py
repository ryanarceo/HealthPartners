# import all modules
import airflow
from airflow import DAG
from datetime import timedelta
from airflow.utils.dates import days_ago
from airflow.providers.google.cloud.operators.dataproc import (
    DataprocStartClusterOperator,
    DataprocStopClusterOperator,
    DataprocSubmitJobOperator,
)
 
# define the variables
PROJECT_ID = "avd-databricks-demo-472818"
REGION = "us-east1"
CLUSTER_NAME = "my-demo-cluster2"
COMPOSER_BUCKET = "us-central1-demo-composer-33062b8d-bucket"

GCS_JOB_FILE_1 = f"gs://{COMPOSER_BUCKET}/data/INGESTION/inputdata.py"
PYSPARK_JOB_1 = {
    "reference": {"project_id": PROJECT_ID},
    "placement": {"cluster_name": CLUSTER_NAME},
    "pyspark_job": {"main_python_file_uri": GCS_JOB_FILE_1},
}

GCS_JOB_FILE_2 = f"gs://{COMPOSER_BUCKET}/data/INGESTION/claimsprocess.py"
PYSPARK_JOB_2 = {
    "reference": {"project_id": PROJECT_ID},
    "placement": {"cluster_name": CLUSTER_NAME},
    "pyspark_job": {"main_python_file_uri": GCS_JOB_FILE_2},
}

GCS_JOB_FILE_3 = f"gs://{COMPOSER_BUCKET}/data/INGESTION/cpt_codesprocess.py"
PYSPARK_JOB_3 = {
    "reference": {"project_id": PROJECT_ID},
    "placement": {"cluster_name": CLUSTER_NAME},
    "pyspark_job": {"main_python_file_uri": GCS_JOB_FILE_3},
}


ARGS = {
    "owner": "Ryan Arceo",
    "start_date": None,
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "email": ["ryanarceo@gmail.com"],
    "email_on_success": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5)
}

# define the dag
with DAG(
    dag_id="pyspark_dag",
    schedule_interval=None,
    description="DAG to start a Dataproc cluster, run PySpark jobs, and stop the cluster",
    default_args=ARGS,
    tags=["pyspark", "dataproc", "etl"]
) as dag:
    
    # define the Tasks
    start_cluster = DataprocStartClusterOperator(
        task_id="start_cluster",
        project_id=PROJECT_ID,
        region=REGION,
        cluster_name=CLUSTER_NAME,
    )

    pyspark_task_1 = DataprocSubmitJobOperator(
        task_id="pyspark_task_1", 
        job=PYSPARK_JOB_1, 
        region=REGION, 
        project_id=PROJECT_ID
    )

    pyspark_task_2 = DataprocSubmitJobOperator(
        task_id="pyspark_task_2", 
        job=PYSPARK_JOB_2, 
        region=REGION, 
        project_id=PROJECT_ID
    )

    pyspark_task_3 = DataprocSubmitJobOperator(
        task_id="pyspark_task_3", 
        job=PYSPARK_JOB_3, 
        region=REGION, 
        project_id=PROJECT_ID
    )

    stop_cluster = DataprocStopClusterOperator(
        task_id="stop_cluster",
        project_id=PROJECT_ID,
        region=REGION,
        cluster_name=CLUSTER_NAME,
    )

# define the task dependencies
start_cluster >> pyspark_task_1 >> pyspark_task_2 >> pyspark_task_3 >> stop_cluster