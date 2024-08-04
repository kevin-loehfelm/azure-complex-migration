import json
import subprocess

# Run terraform show -json and capture the output
def get_terraform_state_json():
    result = subprocess.run(['terraform', 'show', '-json'], capture_output=True, text=True)
    if result.returncode != 0:
        raise Exception(f"Error running terraform show -json: {result.stderr}")
    return result.stdout

# Get the JSON output from terraform show -json
terraform_json = get_terraform_state_json()

# Parse the JSON
data = json.loads(terraform_json)

# Access the resources list
resources = data['values']['root_module']['resources']

# Get the total number of resources
total_resources = len(resources)

# Print the total number of resources to the console
print(f"Total Number of Resources: {total_resources}")
print("=" * 40)  # Separator for better readability

# Notify that the file writing is starting
print("Generating import.tf file...")
print("-" * 40)  # Separator for better readability

# Open the output file for writing (this will overwrite any existing file)
with open('generate_import.tf', 'w') as file:
    # Loop through each resource and write to the file and print to the console
    for index, resource in enumerate(resources):
        resource_type = resource['type']
        resource_name = resource['name']
        resource_id = resource['values']['id']
        
        # Combine type and name into one field
        type_name = f"{resource_type}.{resource_name}"
        
        # Format and print to the console
        print(f"Resource {index + 1}:")
        print(f"  Type: {type_name}")
        print(f"  ID: {resource_id}")
        print("-" * 40)  # Separator for better readability
        
        # Write the import block to the file
        file.write("import {\n")
        file.write(f"  to = {type_name}\n")
        file.write(f"  id = \"{resource_id}\"\n")
        file.write("}\n\n")

# Notify that the file writing is complete
print("File generate_import.tf has been generated successfully.")