#!/bin/bash

# Function to validate input is not empty
validate_input() {
    if [ -z "$1" ]; then
        echo "Error: Input cannot be empty"
        exit 1
    fi
}

# Prompt for user's name
echo "Please enter your name (no spaces):"
read name

# Validate input
validate_input "$name"

# Create main application directory
main_dir="submission_reminder_$name"
mkdir -p "$main_dir"/{app,modules,assets,config}

# Create and populate reminder.sh in app directory
cat > "$main_dir/app/reminder.sh" << 'EOL'
#!/bin/bash

# Source environment variables and helper functions
source ./config/config.env
source ./modules/functions.sh

# Path to the submissions file
submissions_file="./assets/submissions.txt"

# Print remaining time and run the reminder function
echo "Assignment: $ASSIGNMENT"
echo "Days remaining to submit: $DAYS_REMAINING days"
echo "--------------------------------------------"

check_submissions $submissions_file
EOL

# Create and populate functions.sh in modules directory
cat > "$main_dir/modules/functions.sh" << 'EOL'
#!/bin/bash

# Function to read submissions file and output students who have not submitted
function check_submissions {
    local submissions_file=$1
    echo "Checking submissions in $submissions_file"

    while IFS=, read -r student assignment status; do
        student=$(echo "$student" | xargs)
        assignment=$(echo "$assignment" | xargs)
        status=$(echo "$status" | xargs)

        if [[ "$assignment" == "$ASSIGNMENT" && "$status" == "not submitted" ]]; then
            echo "Reminder: $student has not submitted the $ASSIGNMENT assignment!"
        fi
    done < <(tail -n +2 "$submissions_file") # Skip the header
}
EOL

# Create and populate submissions.txt in assets directory
cat > "$main_dir/assets/submissions.txt" << 'EOL'
student, assignment, submission status
Chinemerem, Shell Navigation, not submitted
Chiagoziem, Git, submitted
Divine, Shell Navigation, not submitted
Anissa, Shell Basics, submitted
John, Linux Basics, not submitted
Alice, Shell Navigation, submitted
Mark, Git, not submitted
Grace, Bash Scripting, submitted
Peter, Version Control, not submitted
EOL

# Create and populate config.env in config directory
cat > "$main_dir/config/config.env" << 'EOL'
# Current assignment to check
ASSIGNMENT="Shell Navigation"

# Days remaining for submission
DAYS_REMAINING=2
EOL

# Create a placeholder for startup.sh
cat > "$main_dir/startup.sh" << 'EOL'
#!/bin/bash
# Startup script for submission_reminder_app
echo "Starting the submission reminder app..."
cd app
./reminder.sh
EOL

# Make scripts executable
chmod +x "$main_dir/app/reminder.sh"
chmod +x "$main_dir/modules/functions.sh"
chmod +x "$main_dir/startup.sh"


# Display the created directory structure
echo -e "\nCreated directory structure:"
echo "$main_dir/"
echo "├── app/"
echo "│   └── reminder.sh"
echo "├── modules/"
echo "│   └── functions.sh"
echo "├── assets/"
echo "│   └── submissions.txt"
echo "├── config/"
echo "│   └── config.env"
echo "├── startup.sh"

echo -e "\nEnvironment setup complete! You can now run ./startup.sh to start the application."

