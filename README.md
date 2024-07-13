# Hello and welcome to my AWS cloud resume repository, following the Cloud Resume Challenge!

I will do my best to walk you through what's in each folder

## From top to  bottom, starting from root of repo (/):

The **/__mocks__** folder contains Jest mocks for Jest JS unit testing

The **/.github/workflows** folder contains GitHub Actions workflows, and within it:

    - deploy-site-to-s3.yml:
      + (7/12/2024) Dynamically updates the API endpoint in the /github/scripts/visitorCounter.js using repo secrets
      + (before 7/12/2024, I was very lazy with documenting) validates HTML, run Jest unit testing, and sync all files in the /github folder to AWS S3

    - publish_visitorcounter_lambda.yml:
      + (7/12/2024) Run Python unittest for Python Lambda code in the /aws folder, create SAM app on AWS with Lambda code, updates the repository secret for API endpoint and calls the deploy-site-to-s3.yml workflow if necessary