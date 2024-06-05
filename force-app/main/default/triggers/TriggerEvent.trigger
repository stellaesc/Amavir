/**
@description
Trigger de eventos

DATE 		AUTHOR 		DESCRIPTION
13/03/2023  LCS - MSA   Creación

@author Leadclic Solutions
@date 13/03/2023 
*/

trigger TriggerEvent on Event (before insert, before update) {

    TriggerEventHandler ClaseApex = new TriggerEventHandler();
    if(Trigger.isBefore){
        if(Trigger.IsUpdate){
            ClaseApex.CheckEventOpp(Trigger.New);
        }
        if(Trigger.IsInsert){
            ClaseApex.CheckEventOpp(Trigger.New);
        }
    }

}