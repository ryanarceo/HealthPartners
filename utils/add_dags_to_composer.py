import argparse
import glob
import os
import tempfile
from shutil import copytree, ignore_patterns
from google.cloud import storage

def _create_file_list(directory: str, name_replacement: str) -> tuple[str, list[str]]:
    """Copies relevant files to a temporary directory and returns the list."""
    if not os.path.exists(directory):
        print(f"⚠️ Warning: Directory '{directory}' does not exist. Skipping upload.")
        return "", []  # Return empty values, so the script doesn't crash.

    temp_dir = tempfile.mkdtemp()
    files_to_ignore = ignore_patterns("__init__.py", "*_test.py")
    copytree(directory, f"{temp_dir}/", ignore=files_to_ignore, dirs_exist_ok=True)
    
    # Ensure only files are returned
    files = [f for f in glob.glob(f"{temp_dir}/**", recursive=True) if os.path.isfile(f)]
    return temp_dir, files

def upload_to_composer(directory: str, bucket_name: str, name_replacement: str) -> None:
    """Uploads DAGs or Data files to Composer's Cloud Storage bucket."""
    temp_dir, files = _create_file_list(directory, name_replacement)

    if not files:
        print(f"⚠️ No files found in '{directory}'. Skipping upload.")
        return  # Exit if no files are available.

    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)

    for file in files:
        file_gcs_path = file.replace(f"{temp_dir}/", name_replacement)
        try:
            blob = bucket.blob(file_gcs_path)
            blob.upload_from_filename(file)  # Ensure only files are uploaded
            print(f"✅ Uploaded {file} to gs://{bucket_name}/{file_gcs_path}")
        except IsADirectoryError:
            print(f"⚠️ Skipping directory: {file}")
        except FileNotFoundError:
            print(f"❌ Error: {file} not found. Ensure directory structure is correct.")
            raise

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Upload DAGs and data to Composer bucket.")
    parser.add_argument("--dags_directory", help="Path to DAGs directory.")
    parser.add_argument("--dags_bucket", help="GCS bucket name for DAGs.")
    parser.add_argument("--data_directory", help="Path to data directory.")

    args = parser.parse_args()

    print(args.dags_directory, args.dags_bucket, args.data_directory)

    if args.dags_directory and os.path.exists(args.dags_directory):
        upload_to_composer(args.dags_directory, args.dags_bucket, "dags/")
    else:
        print(f"⚠️ Skipping DAGs upload: '{args.dags_directory}' directory not found.")

    if args.data_directory and os.path.exists(args.data_directory):
        upload_to_composer(args.data_directory, args.dags_bucket, "data/")
    else:
        print(f"⚠️ Skipping Data upload: '{args.data_directory}' directory not found.")
