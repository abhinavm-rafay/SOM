################################################
#   Populate Variables
################################################

#Step 1: Populate project and cluster information

$projectname = 'abhi-new-proj'            # The name of the Rafay project that will be deleted. Example: devproject
$clustername = 'abhi-som-cluster2'            # The name of the EKS cluster that will be deleted. Example: cluster1


#Step 2: Define users to be deleted in the Rafay Org

$useremail1 = 'anm2147@columbia.edu'             # Email address of the user. Example: bob@example.com
$useremail2 = ''             # Email address of the user. Example: bob@example.com


################################################
#DO NOT EDIT BELOW THIS LINE
################################################

$cliconfig=$args[0]

#groups
$groupname1 = 'Project Admins'
$groupname2 = 'Infrastructure Admins'

#download and expand rctl
$time = get-date -format hh:mm:ss
write-host "$time - Downloading RCTL" 
Invoke-WebRequest -Uri "https://rafay-prod-cli.s3-us-west-2.amazonaws.com/publish/rctl-windows-amd64.zip" -OutFile ".\rctl-windows-amd64.zip"
expand-Archive -LiteralPath ".\rctl-windows-amd64.zip" -DestinationPath ".\"

#create cliconfig from secret
$cliconfig | Out-File .\cliconfig.json

#Init rctl
.\rctl config init '.\cliconfig.json'


#delete cluster
$time = get-date -format hh:mm:ss
write-host "$time - Deleting Cluster" 
.\rctl delete cluster $clustername -p $projectname -y


#wait until cluster is deleted
$count = 0
while(1)
{
    if($count -eq 35)
    {
        $time = get-date -format hh:mm:ss
        write-host "$time - cluster did not delete in alloted time.  Exiting."
        exit
    }
    else
    {
        [string] $clusterinfo = .\rctl get cluster $clustername -o yaml -p $ProjectName
        $status = (($clusterinfo -split "status:")[1] -split " ")[1]

        if($clusterinfo -eq $NULL)
        {
            break
        }

        sleep 60
        $time = get-date -format hh:mm:ss
        write-host "$time - Waiting for cluster to delete. (Current Status: $status)" 
        $count++
    }
}

#delete blueprint
$time = get-date -format hh:mm:ss
write-host "$time - Delete Blueprint" 
.\rctl delete blueprint cloudwatch-blueprint -p $projectname  

#delete users
$time = get-date -format hh:mm:ss
write-host "$time - Delete Users" 
.\rctl delete user $useremail1     
.\rctl delete user $useremail2

#delete groups
$time = get-date -format hh:mm:ss
write-host "$time - Delete Groups" 
.\rctl delete group $groupname1 
.\rctl delete group $groupname2 

#delete addon
$time = get-date -format hh:mm:ss
write-host "$time - Delete Addon" 
.\rctl delete addon -p $projectname cloudwatch-addon

#delete namespace
$time = get-date -format hh:mm:ss
write-host "$time - Delete Namespace" 
.\rctl delete namespace -p $projectname amazon-cloudwatch

#delete project
$time = get-date -format hh:mm:ss
write-host "$time - Delete Project" 
.\rctl delete p $ProjectName





<#

#delete restore policy
rctl delete dp-policy restore-policy -p $projectname  

#delete backup policy
rctl delete dp-policy backup-policy -p $projectname  

#deploy data agent
#rctl deploy dp-agent backup-agent --cluster-name $clustername -p $projectname  
#sleep 30

#delete backup location persistent volumes 
rctl delete dp-location volume-backups -p $projectname  

#delete backup location control plane
rctl delete dp-location control-plane-backups -p $projectname  

#delete backup cloud credential
rctl delete credential aws backup-cloud-credential -p $projectname  

#delete opa policy
rctl delete opapolicy -p $projectname bp-psp-restricted 

rctl delete opaconstraint -p $projectname allow-privilege-escalation-container-custom 
rctl delete opaconstraint -p $projectname allowed-repos-custom                        
rctl delete opaconstraint -p $projectname allowed-users-custom                        
rctl delete opaconstraint -p $projectname app-armor-custom                            
rctl delete opaconstraint -p $projectname block-nodeport-services-custom              
rctl delete opaconstraint -p $projectname container-limits-custom                     
rctl delete opaconstraint -p $projectname container-resource-ratios-custom            
rctl delete opaconstraint -p $projectname disallowed-tags-custom                      
rctl delete opaconstraint -p $projectname flex-volumes-custom                         
rctl delete opaconstraint -p $projectname forbidden-sysctls-custom                    
rctl delete opaconstraint -p $projectname host-filesystem-custom                      
rctl delete opaconstraint -p $projectname host-namespace-custom                       
rctl delete opaconstraint -p $projectname host-network-ports-custom                   
rctl delete opaconstraint -p $projectname https-only-custom                           
rctl delete opaconstraint -p $projectname image-digests-custom                        
rctl delete opaconstraint -p $projectname linux-capabilities-custom                   
rctl delete opaconstraint -p $projectname privileged-container-custom                 
rctl delete opaconstraint -p $projectname proc-mount-custom                           
rctl delete opaconstraint -p $projectname read-only-root-filesystem-custom            
rctl delete opaconstraint -p $projectname replica-limits-custom                       
rctl delete opaconstraint -p $projectname required-annotations-custom                 
rctl delete opaconstraint -p $projectname required-labels-custom                      
rctl delete opaconstraint -p $projectname required-probes-custom                      
rctl delete opaconstraint -p $projectname se-linux-custom                             
rctl delete opaconstraint -p $projectname seccomp-custom                              
rctl delete opaconstraint -p $projectname volume-types-custom   


rctl delete opaconstrainttemplate -p $projectname allow-privilege-escalation-container-custom 
rctl delete opaconstrainttemplate -p $projectname allowed-repos-custom                      
rctl delete opaconstrainttemplate -p $projectname allowed-users-custom                         
rctl delete opaconstrainttemplate -p $projectname app-armor-custom                             
rctl delete opaconstrainttemplate -p $projectname block-nodeport-services-custom               
rctl delete opaconstrainttemplate -p $projectname container-limits-custom                      
rctl delete opaconstrainttemplate -p $projectname container-resource-ratios-custom             
rctl delete opaconstrainttemplate -p $projectname disallowed-tags-custom                       
rctl delete opaconstrainttemplate -p $projectname flex-volumes-custom                          
rctl delete opaconstrainttemplate -p $projectname forbidden-sysctls-custom                     
rctl delete opaconstrainttemplate -p $projectname host-filesystem-custom                       
rctl delete opaconstrainttemplate -p $projectname host-namespace-custom                        
rctl delete opaconstrainttemplate -p $projectname host-network-ports-custom                    
rctl delete opaconstrainttemplate -p $projectname https-only-custom                            
rctl delete opaconstrainttemplate -p $projectname image-digests-custom                         
rctl delete opaconstrainttemplate -p $projectname linux-capabilities-custom                    
rctl delete opaconstrainttemplate -p $projectname privileged-container-custom                  
rctl delete opaconstrainttemplate -p $projectname proc-mount-custom                            
rctl delete opaconstrainttemplate -p $projectname read-only-root-filesystem-custom             
rctl delete opaconstrainttemplate -p $projectname replica-limits-custom                        
rctl delete opaconstrainttemplate -p $projectname required-annotations-custom                  
rctl delete opaconstrainttemplate -p $projectname required-labels-custom                       
rctl delete opaconstrainttemplate -p $projectname required-probes-custom                       
rctl delete opaconstrainttemplate -p $projectname se-linux-custom                              
rctl delete opaconstrainttemplate -p $projectname seccomp-custom                               
rctl delete opaconstrainttemplate -p $projectname volume-types-custom   

#>
