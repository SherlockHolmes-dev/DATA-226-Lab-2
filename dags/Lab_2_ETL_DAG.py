from airflow import DAG
from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook
from airflow.decorators import task
from airflow.utils.dates import days_ago
from datetime import timedelta

# Define default_args for the DAG
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': days_ago(1),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# Define Snowflake connection ID
snowflake_conn_id = 'snowflake_conn'

# Define the DAG
with DAG(
    'load_citibike_trip_data_with_timestamp',
    default_args=default_args,
    description='Load Citibike trip data from S3 to Snowflake with load_timestamp and drop membership_type',
    schedule_interval=None,  # Set a schedule if needed
    catchup=False,
) as dag:

    # Step 1: Create or replace the table in Snowflake
    @task
    def create_table():
        snowflake_hook = SnowflakeHook(snowflake_conn_id=snowflake_conn_id)
        conn = snowflake_hook.get_conn()  # Get the Snowflake connection
        cursor = conn.cursor()  # Create a cursor for the connection
        
        try:
            cursor.execute("BEGIN;")  # Start the transaction

            # Create table SQL with load_timestamp field
            sql = """
            CREATE OR REPLACE TABLE dev.raw_data.trip_data (
                tripduration INT,
                starttime TIMESTAMP,
                stoptime TIMESTAMP,
                start_station_id INT,
                start_station_name STRING,
                start_station_latitude FLOAT,
                start_station_longitude FLOAT,
                end_station_id INT,
                end_station_name STRING,
                end_station_latitude FLOAT,
                end_station_longitude FLOAT,
                bikeid INT,
                membership_type STRING,
                usertype STRING,
                birth_year INT,
                gender INT,
                load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
            );
            """
            cursor.execute(sql)

            cursor.execute("COMMIT;")  # Commit the transaction
        except Exception as e:
            cursor.execute("ROLLBACK;")  # Rollback the transaction in case of failure
            raise e
        finally:
            cursor.close()  # Close the cursor

    # Step 2: Create or replace the stage in Snowflake
    @task
    def create_stage():
        snowflake_hook = SnowflakeHook(snowflake_conn_id=snowflake_conn_id)
        conn = snowflake_hook.get_conn()
        cursor = conn.cursor()
        
        try:
            cursor.execute("BEGIN;")  # Start the transaction

            # Create stage SQL
            sql = """
            CREATE OR REPLACE STAGE dev.raw_data.trip_stage
            URL='s3://snowflake-workshop-lab/citibike-trips-csv';
            """
            cursor.execute(sql)

            cursor.execute("COMMIT;")  # Commit the transaction
        except Exception as e:
            cursor.execute("ROLLBACK;")  # Rollback the transaction in case of failure
            raise e
        finally:
            cursor.close()

    # Step 3: Create or replace the file format in Snowflake
    @task
    def create_file_format():
        snowflake_hook = SnowflakeHook(snowflake_conn_id=snowflake_conn_id)
        conn = snowflake_hook.get_conn()
        cursor = conn.cursor()
        
        try:
            cursor.execute("BEGIN;")  # Start the transaction

            # Create file format SQL
            sql = """
            CREATE OR REPLACE FILE FORMAT dev.raw_data.trip_file_format
            TYPE = 'CSV'
            COMPRESSION = 'AUTO'
            FIELD_DELIMITER = ','
            RECORD_DELIMITER = '\\n'
            SKIP_HEADER = 0
            FIELD_OPTIONALLY_ENCLOSED_BY = '\\042'
            TRIM_SPACE = FALSE
            ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
            ESCAPE = 'NONE'
            ESCAPE_UNENCLOSED_FIELD = '\\134'
            DATE_FORMAT = 'AUTO'
            TIMESTAMP_FORMAT = 'AUTO'
            NULL_IF = ('');
            """
            cursor.execute(sql)

            cursor.execute("COMMIT;")  # Commit the transaction
        except Exception as e:
            cursor.execute("ROLLBACK;")  # Rollback the transaction in case of failure
            raise e
        finally:
            cursor.close()

    # Step 4: Copy the data from the stage into the table, with CURRENT_TIMESTAMP() for load_timestamp
    @task
    def copy_data():
        snowflake_hook = SnowflakeHook(snowflake_conn_id=snowflake_conn_id)
        conn = snowflake_hook.get_conn()
        cursor = conn.cursor()
        
        try:
            cursor.execute("BEGIN;")  # Start the transaction

            # Copy data from the stage into the table, adding CURRENT_TIMESTAMP() for load_timestamp
            sql = """
            COPY INTO dev.raw_data.trip_data (
                tripduration,
                starttime,
                stoptime,
                start_station_id,
                start_station_name,
                start_station_latitude,
                start_station_longitude,
                end_station_id,
                end_station_name,
                end_station_latitude,
                end_station_longitude,
                bikeid,
                membership_type,
                usertype,
                birth_year,
                gender,
                load_timestamp
            )
            FROM (
                SELECT
                    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16,
                    CURRENT_TIMESTAMP()
                FROM @dev.raw_data.trip_stage
            )
            FILE_FORMAT = (FORMAT_NAME = dev.raw_data.trip_file_format);
            """
            cursor.execute(sql)

            cursor.execute("COMMIT;")  # Commit the transaction
        except Exception as e:
            cursor.execute("ROLLBACK;")  # Rollback the transaction in case of failure
            raise e
        finally:
            cursor.close()

    # Step 5: Drop the 'membership_type' column after the data is loaded
    @task
    def drop_membership_type_column():
        snowflake_hook = SnowflakeHook(snowflake_conn_id=snowflake_conn_id)
        conn = snowflake_hook.get_conn()
        cursor = conn.cursor()

        try:
            cursor.execute("BEGIN;")  # Start the transaction

            # Drop the membership_type column from the table
            sql = """
            ALTER TABLE dev.raw_data.trip_data DROP COLUMN membership_type;
            """
            cursor.execute(sql)

            cursor.execute("COMMIT;")  # Commit the transaction
        except Exception as e:
            cursor.execute("ROLLBACK;")  # Rollback the transaction in case of failure
            raise e
        finally:
            cursor.close()

    # Set the task dependencies
    create_table() >> create_stage() >> create_file_format() >> copy_data() >> drop_membership_type_column()
