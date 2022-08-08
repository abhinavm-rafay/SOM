################################################
#   Populate Variables
################################################

#Step 1: Populate project and cluster information

$projectname = 'poc2'            # The name of the Rafay project that will be created. Example: devproject
$clustername = 'mkscluster2'            # The name of the EKS cluster that will be created. Example: cluster1

$clusterlocation = 'sanjose-us'
$kubernetesversion = 'v1.23.8'
$operatingsystemversion = 'Ubuntu20.04'
$nodehostname = 'tim2'
$sshipaddress = '129.146.40.219'
$sshkeyfile = 'ssh-key-2022-08-08.key'
$sshuser = 'ubuntu'

#Step 2: Define users to be created in the Rafay Org

$useremail1 = 'bob@example.com'             # Email address of the user. Example: bob@example.com
$userinfo1 = 'Bob,Doe,4089382092'              # The users information in the following format: <User First Name>,<User Last Name>, <User phone number>. Example: Bob,Doe,4089382092

$useremail2 = 'bob1@example.com'             # Email address of the user. Example: bob@example.com
$userinfo2 = 'Bob1,Doe,4089382092'              # The users information in the following format: <User First Name>,<User Last Name>, <User phone number>. Example: Bob,Doe,4089382092

#Step 3: Populate AWS S3 bucket information for an existing S3 bucket.  This location will be used to store backups

$bucketname = 'tim-eks-gitops'             # The name of the S3 bucket defined in AWS. Example: tim-eks-gitops
$bucketregion = 'us-west-2'           # The AWS region where the bucket resides. Example: us-west-2
$awsaccountnumber = '679196758854'       # The AWS account number the bucket is associated with. Example: 679196758877

################################################
#DO NOT EDIT BELOW THIS LINE
################################################

$cliconfig=$args[0]

$backuparn = 'arn:aws:iam::' + $awsaccountnumber +':role/rafay-backuprestore-role-'+ $clustername

#groups
$groupname1 = 'Project Admins'
$groupdescription1 = 'Group for Project Admins'

$groupname2 = 'Infrastructure Admins'
$groupdescription2 = 'Group for Infrastructure Admins'

#update spec files
$time = get-date -format hh:mm:ss
write-host "$time - Updating spec files with custom names" 
$specfiles = Get-ChildItem -Path .\mks\*.yaml -Recurse | select fullname -ExpandProperty fullname
foreach($specfile in $specfiles)
{
    $customspecfile = $specfile.Substring(0,$specfile.Length-5) + "_custom.yaml"
    ((Get-Content -path $specfile -Raw) -replace 'mksclustername',$clustername -replace 'poc',$projectname -replace 'clusterlocation',$clusterlocation -replace 'kubernetesversion',$kubernetesversion -replace 'operatingsystemversion',$operatingsystemversion -replace 'kubernetesversion',$kubernetesversion -replace 'operatingsystemversion',$operatingsystemversion -replace 'nodehostname',$nodehostname -replace 'sshipaddress',$sshipaddress  -replace 'sshkey',$sshkeyfile -replace 'ssh-user',$sshuser  ) | Set-Content -Path $customspecfile
}

#download and expand rctl
$time = get-date -format hh:mm:ss
write-host "$time - Downloading RCTL" 
Invoke-WebRequest -Uri "https://rafay-prod-cli.s3-us-west-2.amazonaws.com/publish/rctl-windows-amd64.zip" -OutFile ".\rctl-windows-amd64.zip"
expand-Archive -LiteralPath ".\rctl-windows-amd64.zip" -DestinationPath ".\"

#create cliconfig from secret
$cliconfig | Out-File .\cliconfig.json

#Init rctl
.\rctl config init '.\cliconfig.json'

#create project
$time = get-date -format hh:mm:ss
write-host "$time - Creating project" 
.\rctl create p $ProjectName

#create groups
$time = get-date -format hh:mm:ss
write-host "$time - Creating groups" 
.\rctl create group $groupname1 --desc $groupdescription1 
.\rctl create group $groupname2 --desc $groupdescription2

#create group association
$time = get-date -format hh:mm:ss
write-host "$time - Assigning roles to groups" 
.\rctl create groupassociation $groupname1 --associateproject $projectname --roles PROJECT_ADMIN 
.\rctl create groupassociation $groupname2 --associateproject $projectname --roles INFRA_ADMIN     

#create users
$time = get-date -format hh:mm:ss
write-host "$time - Creating users and assinging to groups" 
.\rctl create user $useremail1 --groups $groupname1 --console $userinfo1
.\rctl create user $useremail2 --groups $groupname2 --console $userinfo2

#create cluster
$time = get-date -format hh:mm:ss
write-host "$time - Provisioning cluster" 
.\rctl create cluster mks -f .\mks\cluster\cluster_spec_custom.yaml -p $projectname 

#wait until cluster is up and running
$count = 0
while(1)
{
    if($count -eq 35)
    {
        $time = get-date -format hh:mm:ss
        write-host "$time - cluster did not provision in alloted time.  Exiting."
        exit
    }
    else
    {
        [string] $clusterinfo = .\rctl get cluster $clustername -o yaml -p $ProjectName
        $status = (($clusterinfo -split "status:")[1] -split " ")[1]
        $Health = (($clusterinfo -split "health:")[1] -split " ")[1]

        if($status -eq 'READY' -and $health -eq '1')
        {
            break
        }

        sleep 60
        $time = get-date -format hh:mm:ss
        write-host "$time - Waiting for cluster to provision. (Current Status: $status - Health: $health)" 
        $count++
    }
}

#create repository
#$time = get-date -format hh:mm:ss
#write-host "$time - Creating CloudWatch repository" 
#.\rctl create repository -f .\mks\repository\repository_spec_custom.yaml  -p $projectname   

#create addon namespace
#$time = get-date -format hh:mm:ss
#write-host "$time - Creating CloudWatch namespace" 
#.\rctl create namespace -f .\mks\namespace\namespace_spec_custom.yaml -p $projectname   

#publish namespace
#$time = get-date -format hh:mm:ss
#write-host "$time - Publishing namespace" 
#.\rctl publish namespace amazon-cloudwatch -p $projectname   

#create addon
#$time = get-date -format hh:mm:ss
#write-host "$time - Creating CloudWatch Addon" 
#.\rctl create addon version -f .\mks\addon\addon_spec_custom.yaml  -p $projectname   
	
#create opa constraint templates
$time = get-date -format hh:mm:ss
write-host "$time - Creating OPA constraint Tempaltes" 
.\rctl create opaconstrainttemplate -f .\mks\opa\opaconstrainttemplates\allow-privilege-escalation-container-constraint-template_custom.yaml  -p $projectname
.\rctl create opaconstrainttemplate -f .\mks\opa\opaconstrainttemplates\allowed-repos-constraint-template_custom.yaml  -p $projectname                      
.\rctl create opaconstrainttemplate -f .\mks\opa\opaconstrainttemplates\allowed-users-constraint-template_custom.yaml  -p $projectname                         
.\rctl create opaconstrainttemplate -f .\mks\opa\opaconstrainttemplates\app-armor-constraint-template_custom.yaml  -p $projectname                             
.\rctl create opaconstrainttemplate -f .\mks\opa\opaconstrainttemplates\block-nodeport-services-constraint-template_custom.yaml  -p $projectname               
.\rctl create opaconstrainttemplate -f .\mks\opa\opaconstrainttemplates\container-limits-constraint-template_custom.yaml  -p $projectname                      
.\rctl create opaconstrainttemplate -f .\mks\opa\opaconstrainttemplates\container-resource-ratios-constraint-template_custom.yaml  -p $projectname             
.\rctl create opaconstrainttemplate -f .\mks\opa\opaconstrainttemplates\disallowed-tags-constraint-template_custom.yaml  -p $projectname                       
.\rctl create opaconstrainttemplate -f .\mks\opa\opaconstrainttemplates\flex-volumes-constraint-template_custom.yaml  -p $projectname                          
.\rctl create opaconstrainttemplate -f .\mks\opa\opaconstrainttemplates\forbidden-sysctls-constraint-template_custom.yaml  -p $projectname                     
.\rctl create opaconstrainttemplate -f .\mks\opa\opaconstrainttemplates\host-filesystem-constraint-template_custom.yaml  -p $projectname                       
.\rctl create opaconstrainttemplate -f .\mks\opa\opaconstrainttemplates\host-namespace-constraint-template_custom.yaml  -p $projectname                        
.\rctl create opaconstrainttemplate -f .\mks\opa\opaconstrainttemplates\host-network-ports-constraint-template_custom.yaml  -p $projectname                    
.\rctl create opaconstrainttemplate -f .\mks\opa\opaconstrainttemplates\https-only-constraint-template_custom.yaml  -p $projectname                            
.\rctl create opaconstrainttemplate -f .\mks\opa\opaconstrainttemplates\image-digests-constraint-template_custom.yaml  -p $projectname                         
.\rctl create opaconstrainttemplate -f .\mks\opa\opaconstrainttemplates\linux-capabilities-constraint-template_custom.yaml  -p $projectname                    
.\rctl create opaconstrainttemplate -f .\mks\opa\opaconstrainttemplates\privileged-container-constraint-template_custom.yaml  -p $projectname                  
.\rctl create opaconstrainttemplate -f .\mks\opa\opaconstrainttemplates\proc-mount-constraint-template_custom.yaml  -p $projectname                            
.\rctl create opaconstrainttemplate -f .\mks\opa\opaconstrainttemplates\read-only-root-filesystem-constraint-template_custom.yaml  -p $projectname             
.\rctl create opaconstrainttemplate -f .\mks\opa\opaconstrainttemplates\replica-limits-constraint-template_custom.yaml  -p $projectname                        
.\rctl create opaconstrainttemplate -f .\mks\opa\opaconstrainttemplates\required-annotations-constraint-template_custom.yaml  -p $projectname                  
.\rctl create opaconstrainttemplate -f .\mks\opa\opaconstrainttemplates\required-labels-constraint-template_custom.yaml  -p $projectname                       
.\rctl create opaconstrainttemplate -f .\mks\opa\opaconstrainttemplates\required-probes-constraint-template_custom.yaml  -p $projectname                       
.\rctl create opaconstrainttemplate -f .\mks\opa\opaconstrainttemplates\se-linux-constraint-template_custom.yaml  -p $projectname                              
.\rctl create opaconstrainttemplate -f .\mks\opa\opaconstrainttemplates\seccomp-constraint-template_custom.yaml  -p $projectname                               
.\rctl create opaconstrainttemplate -f .\mks\opa\opaconstrainttemplates\volume-types-constraint-template_custom.yaml  -p $projectname   

#create opa constraints
$time = get-date -format hh:mm:ss
write-host "$time - Creating OPA constraints" 
.\rctl create opaconstraint -f .\mks\opa\opaconstraints\allow-privilege-escalation-container-constraint_custom.yaml  -p $projectname  
.\rctl create opaconstraint -f .\mks\opa\opaconstraints\allowed-repos-constraint_custom.yaml  -p $projectname                         
.\rctl create opaconstraint -f .\mks\opa\opaconstraints\allowed-users-constraint_custom.yaml  -p $projectname                         
.\rctl create opaconstraint -f .\mks\opa\opaconstraints\app-armor-constraint_custom.yaml  -p $projectname                             
.\rctl create opaconstraint -f .\mks\opa\opaconstraints\block-nodeport-services-constraint_custom.yaml  -p $projectname               
.\rctl create opaconstraint -f .\mks\opa\opaconstraints\container-limits-constraint_custom.yaml  -p $projectname                      
.\rctl create opaconstraint -f .\mks\opa\opaconstraints\container-resource-ratios-constraint_custom.yaml  -p $projectname             
.\rctl create opaconstraint -f .\mks\opa\opaconstraints\disallowed-tags-constraint_custom.yaml  -p $projectname                       
.\rctl create opaconstraint -f .\mks\opa\opaconstraints\flex-volumes-constraint_custom.yaml  -p $projectname                          
.\rctl create opaconstraint -f .\mks\opa\opaconstraints\forbidden-sysctls-constraint_custom.yaml  -p $projectname                     
.\rctl create opaconstraint -f .\mks\opa\opaconstraints\host-filesystem-constraint_custom.yaml  -p $projectname                       
.\rctl create opaconstraint -f .\mks\opa\opaconstraints\host-namespace-constraint_custom.yaml  -p $projectname                        
.\rctl create opaconstraint -f .\mks\opa\opaconstraints\host-network-ports-constraint_custom.yaml  -p $projectname                    
.\rctl create opaconstraint -f .\mks\opa\opaconstraints\https-only-constraint_custom.yaml  -p $projectname                            
.\rctl create opaconstraint -f .\mks\opa\opaconstraints\image-digests-constraint_custom.yaml  -p $projectname                         
.\rctl create opaconstraint -f .\mks\opa\opaconstraints\linux-capabilities-constraint_custom.yaml  -p $projectname                    
.\rctl create opaconstraint -f .\mks\opa\opaconstraints\privileged-container-constraint_custom.yaml  -p $projectname                  
.\rctl create opaconstraint -f .\mks\opa\opaconstraints\proc-mount-constraint_custom.yaml  -p $projectname                            
.\rctl create opaconstraint -f .\mks\opa\opaconstraints\read-only-root-filesystem-constraint_custom.yaml  -p $projectname             
.\rctl create opaconstraint -f .\mks\opa\opaconstraints\replica-limits-constraint_custom.yaml  -p $projectname                        
.\rctl create opaconstraint -f .\mks\opa\opaconstraints\required-annotations-constraint_custom.yaml  -p $projectname                  
.\rctl create opaconstraint -f .\mks\opa\opaconstraints\required-labels-constraint_custom.yaml  -p $projectname                       
.\rctl create opaconstraint -f .\mks\opa\opaconstraints\required-probes-constraint_custom.yaml  -p $projectname                       
.\rctl create opaconstraint -f .\mks\opa\opaconstraints\se-linux-constraint_custom.yaml  -p $projectname                              
.\rctl create opaconstraint -f .\mks\opa\opaconstraints\seccomp-constraint_custom.yaml  -p $projectname                               
.\rctl create opaconstraint -f .\mks\opa\opaconstraints\volume-types-constraint_custom.yaml  -p $projectname     

#create opa policy
$time = get-date -format hh:mm:ss
write-host "$time - Creating OPA PSP-Restricted policy" 
.\rctl create opapolicy -f .\mks\opa\opapolicies\bp-psp-restricted_custom.yaml  -p $projectname    

#create blueprint
$time = get-date -format hh:mm:ss
write-host "$time - Creating blueprint with OPA PSP-Restricted policy" 
.\rctl create blueprint -f .\mks\blueprint\blueprint_spec_custom.yaml --v3 -p $projectname     

#create backup cloud credential
$time = get-date -format hh:mm:ss
write-host "$time - Creating backup cloud credential for S3 bucket access" 
.\rctl create credential aws backup-cloud-credential --cred-type data-backup --role-arn $backuparn -p $projectname  
sleep 10 

#create backup location control plane
$time = get-date -format hh:mm:ss
write-host "$time - Creating backup location for control plane backups" 
.\rctl create dp-location control-plane-backups --backup-type controlplanebackup --target-type amazon --region $bucketregion  --bucket-name $bucketname -p $projectname  
sleep 10 

#create backup location persistent volumes 
$time = get-date -format hh:mm:ss
write-host "$time - Creating backup location for persistent volume backups" 
.\rctl create dp-location volume-backups --backup-type volumebackup --target-type amazon --region $bucketregion --bucket-name $bucketname -p $projectname  
sleep 10 

#create data agent
$time = get-date -format hh:mm:ss
write-host "$time - Creating backup data agent" 
.\rctl create dp-agent backup-agent --cloud-credentials backup-cloud-credential -p $projectname
sleep 10 

#deploy data agent
$time = get-date -format hh:mm:ss
write-host "$time - Deploying backup data agent to cluster" 
.\rctl deploy dp-agent backup-agent --cluster-name $clustername -p $projectname  
sleep 30

#create backup policy
$time = get-date -format hh:mm:ss
write-host "$time - Creating backup policy" 
.\rctl create dp-policy backup-policy --type backup --location control-plane-backups --snapshot-location volume-backups --retention-period 720h -p $projectname  
sleep 10 

#create restore policy
$time = get-date -format hh:mm:ss
write-host "$time - Creating restore policy" 
.\rctl create dp-policy restore-policy --type restore --restore-pvs -p $projectname  
sleep 10 

#apply blueprint
sleep 30 #needed to allow blueprint to be applied after
$time = get-date -format hh:mm:ss
write-host "$time - Applying blueprint to cluster" 
.\rctl update cluster $clustername --blueprint mks-blueprint --blueprint-version v1 -p $projectname  
