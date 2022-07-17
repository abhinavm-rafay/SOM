# Description 
Rafay designs and publishes reference designs for the various “standard operating models” currently supported by the Rafay Kubernetes Operations Platform. This reference design captures one of the “deployment option reference design’s” for the Rafay “Standard Operating Model”. 

# SOM Option 
This reference design is based on Amazon EKS and automation is based on GitHub Actions. The workflow will automatically provisions an Amazon EKS cluster using a declarative cluster specification. The EKS cluster is then bootstrapped with a cluster blueprint

### Isolation 
A new project (name provided by user) will be created in your Rafay Org. Only users authorized to access this project will have access based on specified roles. 

### Role based Access



### Zero Trust Access
- 

### Disaster Recovery
A Backup Policy will be automatically configured and enabled for the EKS cluster spanning both the control plane and all persistent volumes. All backups will be performed to an AWS S3 bucket (name provided by user).  
- An IAM Roles for Service Accounts (IRSA) based credential will be automatically created to provide secure access to the S3 bucket for performing ongoing backups and restore actions. 

### Governance and Compliance



---

# Customization 
This is a reference design that bottles up "best practices" from our solution architects. It is designed to serve as afoundation for customers to "Get Started". Customers are expected to customize and personalize the standard operating model to suit their specific requirements. 


# Steps 

## Step 1: Fork Git Repo 

- Fork the Git repository: https://github.com/RafaySystems/SOM

## Step 2: Enable GitHub Actions 

- The forked actions are not automatically enabled. 
- Go to “Actions” on the forked repo and click “I understand my workflows, go ahead and enable them”

Step 3: Create Secret 

- In the forked repo, go to Settings -> secrets->Actions
- Click “New repository secret” and enter the name “rafaysecret”
- Go to the Rafay console as an Org Admin, My Tools -> Download CLI Config
- Use a text editor to open the downloaded JSON file and copy the JSON from the file and paste it into the “Value” section on the GitHub Action Secrets page
- Click “Add Secret”

Step 4: Specify Variables 

- In the forked repo, edit the file “Provision.ps1”
- In the “Populate Variables” section, follow the steps to populate the needed values (i.e. name of the Rafay Project, name of the EKS cluster, AWS region where you would like the cluster provisioned) 
- Once the values are populated, commit the file updates.
- Once committed, go to Actions.  You will see the workflow running.

Step 4: Run Automation 

- Click the workflow -> build to see the output of the workflow
- You will see the GitHub Actions based “SOM” automation provision the resources one by one. 
- Login into your Rafay Org using a web browser to see the resources being created
