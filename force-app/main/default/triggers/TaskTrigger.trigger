/**
@description
Trigger de tareas

DATE 		AUTHOR 		DESCRIPTION
13/03/2023  LCS - MSA   Creación

@author Leadclic Solutions
@date 13/03/2023 
*/

trigger TaskTrigger on Task (before insert, before update) {

    TriggerTaskHandler ClaseApex = new TriggerTaskHandler();
    if(Trigger.isBefore){
        if(Trigger.IsUpdate){
            ClaseApex.CheckTaskOpp(Trigger.New);
        }
        if(Trigger.IsInsert){
            ClaseApex.CheckTaskOpp(Trigger.New);
        }
    }

}