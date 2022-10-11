Retrieve a summary of all opened, closed, and in progress pull requests in the last week for a given repository and print an email summary report that might be sent to a manager or Scrum-master.

To make it work:
1) Create sendgrid account, authenticate email and create apikey
2) Populate vars.env file with sendgrid apikey, email you registered at sendgrid and email you want send report to
3) build docker image with command: docker build -t pull-requests .
4) run container with env file: docker build --env-file=vars.env -t pull-requests .
