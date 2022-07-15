#delete cluster
rctl delete cluster $clustername -p $projectname -y

#delete blueprint
rctl delete blueprint cloudwatch-blueprint -p $projectname  

#delete users
rctl delete user $useremail1     
rctl delete user $useremail2


#delete groups
rctl delete group $groupname1 
rctl delete group $groupname2 

#delete addon
rctl delete addon -p $projectname cloudwatch-addon

#delete namespace
rctl delete namespace -p $projectname amazon-cloudwatch

#delete project
rctl delete p $ProjectName





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