import os
import subprocess
import re
import argparse
import hashlib
import json
from multiprocessing import Pool, cpu_count

def compute_md5(file_path):
    """Compute MD5 checksum of a file."""
    hash_md5 = hashlib.md5()
    try:
        with open(file_path, 'rb') as f:
            # Read the file in chunks to handle large files
            for chunk in iter(lambda: f.read(4096), b''):
                hash_md5.update(chunk)
    except FileNotFoundError:
        return None
    return hash_md5.hexdigest()

def should_process(unit_id, animation_name, input_dir, cache_dir):
    """Determine if processing is needed based on checksums."""
    # Files to check
    files_to_check = [
        os.path.join(input_dir, f"unit_anime_{unit_id}.png"),
        os.path.join(input_dir, f"unit_{animation_name}_cgs_{unit_id}.csv"),
        os.path.join(input_dir, f"unit_cgg_{unit_id}.csv")
    ]

    # Compute checksums
    current_checksums = {}
    for file_path in files_to_check:
        checksum = compute_md5(file_path)
        if checksum is None:
            return True  # If any file is missing, we need to process
        current_checksums[file_path] = checksum

    # Load cached checksums
    cache_file = os.path.join(cache_dir, f"{unit_id}_{animation_name}.json")
    if os.path.exists(cache_file):
        with open(cache_file, 'r') as f:
            cached_checksums = json.load(f)
        # Compare checksums
        if current_checksums == cached_checksums:
            return False  # No changes detected
    return True  # Changes detected or no cache exists

def update_cache(unit_id, animation_name, input_dir, cache_dir):
    """Update the cache with current checksums."""
    # Files to check
    files_to_check = [
        os.path.join(input_dir, f"unit_anime_{unit_id}.png"),
        os.path.join(input_dir, f"unit_{animation_name}_cgs_{unit_id}.csv"),
        os.path.join(input_dir, f"unit_cgg_{unit_id}.csv")
    ]

    # Compute checksums
    current_checksums = {}
    for file_path in files_to_check:
        checksum = compute_md5(file_path)
        if checksum is not None:
            current_checksums[file_path] = checksum

    # Save checksums to cache
    cache_file = os.path.join(cache_dir, f"{unit_id}_{animation_name}.json")
    with open(cache_file, 'w') as f:
        json.dump(current_checksums, f)

def process_animation(args_tuple):
    """Process a single animation."""
    (unit_id, animation_name, input_dir, output_dir, cache_dir) = args_tuple

    # Check if processing is needed
    if not should_process(unit_id, animation_name, input_dir, cache_dir):
        print(f"Skipping {unit_id} - {animation_name}: No changes detected.")
        return

    # Construct the command
    command = [
        'node', 'ffbetool.js', unit_id,
        '-a', animation_name,
        '-i', input_dir,
        '-o', output_dir
    ]

    # Run the command
    try:
        result = subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        print(f"Successfully processed {unit_id} - {animation_name}")
        # Update the cache upon successful processing
        update_cache(unit_id, animation_name, input_dir, cache_dir)
    except subprocess.CalledProcessError as e:
        print(f"Error processing {unit_id} - {animation_name}: {e.stderr.decode().strip()}")
    except Exception as e:
        print(f"An unexpected error occurred while processing {unit_id} - {animation_name}: {str(e)}")

def main():
    # Set up command-line argument parsing
    parser = argparse.ArgumentParser(description='Process unit animations with ffbetool.js')
    parser.add_argument('--input_dir', type=str, default='FF9', help='Input directory containing unit subdirectories')
    parser.add_argument('--output_dir', type=str, default='out', help='Output directory for processed files')
    parser.add_argument('--cache_dir', type=str, default='cache', help='Cache directory to store checksums')
    parser.add_argument('--parallel', type=int, default=cpu_count(), help='Number of parallel processes to use')

    args = parser.parse_args()

    # Base directory (input directory)
    base_dir = args.input_dir

    # Output directory
    output_dir = args.output_dir

    # Cache directory
    cache_dir = args.cache_dir

    # Number of parallel processes
    num_processes = args.parallel

    # Ensure output and cache directories exist
    os.makedirs(output_dir, exist_ok=True)
    os.makedirs(cache_dir, exist_ok=True)

    # Regular expression pattern for matching cgs files
    pattern = r'^unit_(.*?)_cgs_(\d+)\.csv$'

    # Prepare a list of tasks
    tasks = []
    for root, dirs, files in os.walk(base_dir):
        for filename in files:
            match = re.match(pattern, filename)
            if match:
                animation_name = match.group(1)
                unit_id = match.group(2)
                input_dir = root  # The directory containing the files

                # Append task to the list
                tasks.append((unit_id, animation_name, input_dir, output_dir, cache_dir))

    # Process animations in parallel
    with Pool(processes=num_processes) as pool:
        pool.map(process_animation, tasks)

if __name__ == '__main__':
    main()
