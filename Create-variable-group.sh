#!/bin/bash

# Set variables for the target project and JSON file
target_project=$1
json_file=$2

# Text formatting
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print section headers
print_section() {
    echo -e "\n${BOLD}=== $1 ===${NC}\n"
}

# Read and process the JSON file
if [ ! -f "$json_file" ]; then
    echo -e "${RED}Error: JSON file not found: $json_file${NC}"
    exit 1
fi

# Read group details
group=$(jq -c '.' "$json_file")
group_name=$(echo "$group" | jq -r '.name')
description=$(echo "$group" | jq -r '.description')

# Print group details
print_section "Variable Group Details"
echo -e "${BOLD}Group Name:${NC} $group_name"
echo -e "${BOLD}Description:${NC} $description"

# Process variables
print_section "Variables to be Created"
echo -e "${BOLD}Format:${NC} NAME = VALUE\n"

# Initialize variables string
variables_string=""
variable_count=0
while IFS= read -r line; do
    key=$(echo "$line" | jq -r '.key')
    value=$(echo "$line" | jq -r '.value.value')
    # Add to variables string
    if [ -n "$variables_string" ]; then
        variables_string+=" "
    fi
    # Display variable information
    echo -e "${BOLD}$key${NC} = $value"
    variables_string+="$key=\"$value\""
    ((variable_count++))
done < <(echo "$group" | jq -c '.variables | to_entries[]')
echo -e "\n${BOLD}Total variables:${NC} $variable_count"

# Construct the create command
create_command="az pipelines variable-group create"
create_command+=" --project \"$target_project\""
create_command+=" --name \"$group_name\""
create_command+=" --description \"$description\""
create_command+=" --variables $variables_string"

# Show the command
print_section "Generated Azure CLI Command"
echo "$create_command"

# Confirm before proceeding
print_section "Confirmation"
read -p "Do you want to proceed with creating the variable group? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "\n${YELLOW}Operation cancelled by user${NC}"
    exit 1
fi

# Execute the command
print_section "Creating Variable Group"
if eval "$create_command"; then
    echo -e "\n${GREEN}Variable group '$group_name' created successfully!${NC}"
else
    echo -e "\n${RED}Error creating variable group${NC}"
    exit 1
fi

# Verify the creation
print_section "Verification"
echo "Listing variable group details..."
az pipelines variable-group list \
    --project "$target_project" \
    --query "[?name=='$group_name']" \
    --output table
echo -e "\n${GREEN}Script completed successfully!${NC}"