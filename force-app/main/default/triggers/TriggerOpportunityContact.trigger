/**
@description
Trigger en OpportunityContactRole

DATE 		AUTHOR 		DESCRIPTION
03/09/2024	LCS - MSA	Creation

@author Leadclic Solutions
@date 03/09/2024
*/

trigger TriggerOpportunityContact on OpportunityContactRole (before insert, before update, after insert, after update) {

    TriggerOpportunityContactHandler claseApex = new TriggerOpportunityContactHandler();
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            claseApex.treatContactInformation(Trigger.New);
        }
    }
}