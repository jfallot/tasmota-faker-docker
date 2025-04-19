#!/usr/bin/env bash

num_instances="${1:-3}"

if ! [[ "$num_instances" =~ ^[1-9][0-9]*$ ]]; then
    echo "Usage: $0 <number_of_instances>"
    echo "  <number_instances>: The number of Flask instances to spawn (1 or more)."
    exit 1
fi

declare -a flask_pids

start_flask_instance() {
    port=$((start_port + i))
    flask_command="INSTANCE=$i poetry run flask --app server run --host 0.0.0.0 --port $port"
    echo "Starting Flask instance on port $port..."
    eval "$flask_command" &
    flask_pid=$!
    echo "  PID: $flask_pid"
    flask_pids+=($flask_pid)
    sleep 0.1 #important
}

# Start the Flask instances and store their PIDs
echo "Spawning $num_instances Flask instances..."
start_port=5000
for ((i=0; i<num_instances; i++)); do
    start_flask_instance
done

echo "Flask instances started. PIDs: ${flask_pids[*]}"

# Function to kill the Flask instances
kill_flask_instances() {
    if [ ${#flask_pids[@]} -gt 0 ]; then
        echo "Killing Flask instances..."
        for pid in "${flask_pids[@]}"; do
            if ps -p "$pid" > /dev/null; then
                echo "Process with PID $pid is running. Attempting to kill it."
                kill -15 "$pid" # Use SIGTERM first (try to kill gracefully)
                sleep 1 # give it a couple of seconds to stop
                if ps -p "$pid" > /dev/null; then
                    echo "Process with PID $pid did not terminate.  Sending SIGKILL."
                    kill -9 "$pid"
                else
                    echo "Process with PID $pid terminated."
                fi
            else
                echo "Process with PID $pid is not running."
            fi
        done
        echo "Flask instances killed."
        unset flask_pids # Clear the PID array
    else
        echo "No Flask instances to kill."
    fi
}

trap 'kill_flask_instances; exit' SIGINT SIGTERM SIGQUIT EXIT

while true; do
  sleep 1
done
