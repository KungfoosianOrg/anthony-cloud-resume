# anthony-cloud-resume

Hello and welcome to my AWS cloud resume repository, following the Cloud Resume Challenge!

I will do my best to walk you through this repo



## Starting from root of repo (/):

Folder **/__mocks__** contains Jest mocks for Jest JS unit testing

Folder **/.github/workflows** contains GitHub Actions workflows, and within it:

    - inject-terraform-variables.yml:
      + (10/29/2024) Reusable workflow, for injecting values for terraform.tf and tfvars files

    - package-n-deploy-lambda.yml:
      + (10/29/2024) Reusable workflow, for packaging lambda source code and deploy to appropriate AWS Lambda ARN

    - terraform-apply-infrastructure.yml:
      + (10/29/2024) Manually called workflow with manual approval, creates the backend infrastructure on Terraform and calls other workflow to update S3 bucket, lambda source code, as needed

    - terraform-destroy-infrastructure.yml:
      + (10/19/2024) Manually called workflow with manual approval, cleans up frontend S3 bucket and Terraform infrastructure.
    
    - terraform-update-infrastructure.yml:
      + (10/29/2024) Reusable workflow, for applying/destroying the Terraform infrastructure.

    - deploy-site-to-s3.yml:
      + (10/29/2024) Added a trigger option to make this workflow into a reusable workflow, added jobs that are specific to whether the workflow was called manually, or from another workflow
      + (7/12/2024) Dynamically updates the API endpoint in the /github/scripts/visitorCounter.js using repo secrets
      + (before 7/12/2024, I was very lazy with documenting, still am...) validates HTML, run Jest unit testing, and sync all files in the /github folder to AWS S3

    - publish-slack_integration_lambda/publish-visitorcounter_lambda:
      + (10/29/2024) Reusable workflows, can also be called upon push to appropriate Lambda source code folders in **/aws**
      + (7/17/2024) Added integration for Slack webhook, added repo secrets for the integration, updated workflow to override SAM template parameters without using the samconfig.toml file
      + (7/12/2024) Run Python unittest for Python Lambda code in the /aws folder, create SAM app on AWS with Lambda code, updates the repository secret for API endpoint and calls the deploy-site-to-s3.yml workflow if necessary

Folder **/aws** contains code for Lambda function(s) of the same name:

    - sendSlackMessage: for Slack integration, use SNS to trigger Lambda to send a message to Slack webhook

    - visitorCounter: backend Lambda logic to talk to DynamoDB, updating a visitor counter that connects to front end logic, which is stored in /github/scripts 

Folder **/cypress** contains everything related to Cypress JS testing, used for E2E testings

Folder **/github** contains HTML, CSS, JS for front end website

Folder **/out** contains any file(s) created during automation processes. Currently set to ignore any files within this folder

Folder **/terraform** contains TerraForm templates for this project, and within it:
  - **modules** : folder, contains separate (reusable) modules that made up this project
  - `main.tf` : file, contains Terraform code for this static site application in AWS, combining modules from the **modules** folder
  - files, each containing: `outputs.tf` of this app, arguments `main.tf` needs to run TerraForm build (`variables.tf`), and `examples.tfvars` containing said arguments, ready to be copied, renamed, fill out with your own data, great for automation!

Folder **/tests** contains all tests for code in this repo

**/setupJest.js** sets up Jest testing


## Usage

### Running unit test(s)

From the **root (/)** of this repo:

  - Testing Javascript:
    1. Run 'npm install' to install all dependencies
    2. Run 'npm test'

  - Testing Python:
    1. Run 'pip3 install -r ./tests/requirements.txt' to install test dependencies
    2. Run 'python3 -m unittest'

### Running End-to-End (E2E) testing

From the **root (/)** of this repo:

  1. Run 'npm install' to install all dependencies
  2. Run 'npx cypress open'


### Running code

From the **root (/)** of this repo:

    - Javascript:
      1. Install Javascript
      2. Run 'npm install' to install all dependencies

    - Python:
      1. Install Python 3.x
      2. Run the code and manually install all the packages because I didn't bother to put a requirements.txt file (TODO)
