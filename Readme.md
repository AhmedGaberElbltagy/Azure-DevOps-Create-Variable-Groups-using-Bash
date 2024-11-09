# you may face a challenge whill creating new projects in azure devOps that you need to add the variable groups into your new project while its exists in a old project : 

- To resolve this, I developed a script that accepts two arguments: "target-project" and "source project variables in JSON format."

- This script automates the creation of variable groups for you.

# Variable Group Transfer Script

This script efficiently transfers variable groups from a specific Azure DevOps project to a new project, simplifying the setup process for new environments.

## Prerequisites

- Ensure you have the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed.
- Log in to Azure CLI and set the appropriate organization and project.

## Steps

### 1. Configure Azure Login

Use the following command to log in to Azure DevOps:

```bash
az login --allow-no-subscriptions
