# terraform-ci-demo

# Network
- My thoughts and decisions:
    - I have created the network to host my wordpress website.
    - I have created 2 instances a bastion and a wordpress instance but unfortunately I could not install wordpress.
        -   I created the bastion to safely ssh on to my wordpress instance.
        -   My plan was to write a bash script that installs and runs wordpress :'( 
    - I have created the instances inside a public_subnet hosted within a VPC, this has access to the internet via a        internet_gateway
    - As I am only creating the one application I decided not to break the code down into further module for reusability but I would have done this if I had more time.

# CI pipeline and GIT
- I have used CircleCi as my automated pipeline this will initialise, apply and destroy my resources in AWS.
- Github was my tool of choice for source control.


# Time management 
- I used trello to manage my tickets and time, I have experince using Azure devops but trello was my prefered choice because it is easier to set up.


# Extra 
- I have pushed half the script.sh to install wordpress but I couldn't seem to get it working.