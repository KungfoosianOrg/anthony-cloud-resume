# anthony-cloud-resume

Hello and welcome to my AWS cloud resume repository, following the Cloud Resume Challenge!

I will do my best to walk you through this repo



## From top to  bottom, starting from root of repo (/):

Folder **/__mocks__** contains Jest mocks for Jest JS unit testing

Folder **/.github/workflows** contains GitHub Actions workflows, and within it:

    - deploy-site-to-s3.yml:
      + (7/12/2024) Dynamically updates the API endpoint in the /github/scripts/visitorCounter.js using repo secrets
      + (before 7/12/2024, I was very lazy with documenting, still am...) validates HTML, run Jest unit testing, and sync all files in the /github folder to AWS S3

    - publish_visitorcounter_lambda.yml:
      + (7/17/2024) Added integration for Slack webhook, added repo secrets for the integration, updated workflow to override SAM template parameters without using the samconfig.toml file
      + (7/12/2024) Run Python unittest for Python Lambda code in the /aws folder, create SAM app on AWS with Lambda code, updates the repository secret for API endpoint and calls the deploy-site-to-s3.yml workflow if necessary

Folder **/aws** contains code for Lambda function(s) of the same name:

    - sendSlackMessage: for Slack integration, use SNS to trigger Lambda to send a message to Slack webhook

    - visitorCounter: backend Lambda logic to talk to DynamoDB, updating a visitor counter that connects to front end logic, which is stored in /github/scripts 

Folder **/cypress** contains everything related to Cypress JS testing, used for E2E testings

Folder **/github** contains HTML, CSS, JS for front end website

Folder **/terraform** contains TerraForm templates for this project, and within it:
  - **modules** : folder, contains separate (reusable) modules that made up this project
  - `main.tf` : file, contains Terraform code for this static site application in AWS, combining modules from the **modules** folder
  - files, each containing: `outputs.tf` of this app, arguments `main.tf` needs to run TerraForm build (`variables.tf`), and `examples.tfvars` containing said arguments, ready to be copied, renamed, fill out with your own data, great for automation!

Folder **/tests** contains all tests for code in this repo

**/samconfig.toml** contains default parameters for when a SAM stack is deployed

**/setupJest.js** sets up Jest testing

**/template.yaml** AWS CloudFormation template for when a SAM stack is deployed



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
