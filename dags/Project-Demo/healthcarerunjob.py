import airflow
from airflow import DAG
from datetime import timedelta
from airflow.utils.dates import days_ago
from airflow.operators.dagrun_operator import TriggerDagRunOperator

# Define default arguments
ARGS = {
    "owner": "Ryan Arceo",
    "start_date": days_ago(1),
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "email": ["ryanarceo@gmail.com"],
    "email_on_success": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5)
}

# Define the Run Job DAG
with DAG(
    dag_id="healthcarerunjob",
    schedule_interval="0 5 * * *",
    description="Primary Run Job DAG to trigger PySpark and BigQuery DAGs",
    default_args=ARGS,
    tags=["Run Job", "orchestration", "etl"]
) as dag:

    # Task to trigger PySpark DAG
    trigger_pyspark_dag = TriggerDagRunOperator(
        task_id="trigger_pyspark_dag",
        trigger_dag_id="pyspark_dag",
        wait_for_completion=True,
    )

    # Task to trigger BigQuery DAG
    trigger_bigquery_dag = TriggerDagRunOperator(
        task_id="trigger_bigquery_dag",
        trigger_dag_id="bigquery_dag",
        wait_for_completion=True,
    )

# Define dependencies
trigger_pyspark_dag >> trigger_bigquery_dag

#Added Comment to trigger Airflow DAG