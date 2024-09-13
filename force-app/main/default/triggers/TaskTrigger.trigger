/**
@description
Trigger de tareas

DATE 		AUTHOR 		DESCRIPTION
12/09/2024  LCS - MSA   Añadir cambio de imágenes en las tareas.
10/06/2024  LCS - MSA   Añadir el cambio de etapa en las oportunidades
13/03/2023  LCS - MSA   Creación

@author Leadclic Solutions
@date 13/03/2023 
*/

trigger TaskTrigger on Task (before insert, before update) {

    TriggerTaskHandler ClaseApex = new TriggerTaskHandler();
    if(Trigger.isBefore){
        if(Trigger.IsUpdate){
            ClaseApex.CheckTaskOpp(Trigger.New);
            ClaseApex.ChangeOpportunityStage(Trigger.New);
        }
        if(Trigger.IsInsert){
            ClaseApex.changeTaskSubtype(Trigger.New);
            ClaseApex.CheckTaskOpp(Trigger.New);
            ClaseApex.ChangeOpportunityStage(Trigger.New);
        }
    }

}