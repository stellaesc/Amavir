/**
@description
Handler de la clase TaskTrigger

DATE 		AUTHOR 		DESCRIPTION
12/09/2024  LCS - MSA   Añadir cambio de imágenes en las tareas.
20/06/2024  LCS - MSA   Las oportunidades de plaza publica y de traslado no sufren el cambio de etapa
10/06/2024  LCS - MSA   Añadir el cambio de etapa en las oportunidades
04/05/2023  LCS - MSA   Buscar si el contacto y la oportunidad están relacionados pero no por la misma cuenta,
                        sino por el AccountContactRelation.
13/03/2023  LCS - MSA   Creación

@author Leadclic Solutions
@date 13/03/2023 
*/

public class TriggerTaskHandler {

    private static final string PLAZA_PUBLICA_DEVELOPER_NAME_RT = 'PlazaPublica';
    private static final string TRASLADO_DEVELOPER_NAME_RT = 'Traslado';

        /* 
    @description Método que se ejecuta desde el trigger y comprueba los Ids relacionados de la Tarea.
                Si es un contacto y una oportunidad que no están relacionados dará un error.
    @param TriggerNew Lista de tareas.
    @return void no se realiza devolución
    */  

    public void CheckTaskOpp(List<Task> Tareas) {

        map<Id,Id> mOppsContacts = new map<Id,Id>();
        map<Id,Id> mContsAccount = new map<Id,Id>();
        List<Id> ListaOps = new list<Id>();
        List<Id> ListaContactos = new list<id>();
        List<Id> ListaCuentas = new list<id>();

        //Creamos los mapas y las listas descartando cuando ambos no están rellenos y no son ni contactos ni oportunidades

        for(Task tarea : Tareas){

            if(tarea.WhoId == null || tarea.WhatId == null){

            } else {
                String IdOpp = tarea.WhatId;
                String IdCont = tarea.WhoId;

                

                if(IdOpp.startsWith('006')&&(IdCont.startsWith('003'))){

                    mOppsContacts.put(tarea.WhatId,tarea.WhoId);
                    ListaOps.add(tarea.WhatId);
                    ListaContactos.add(tarea.WhoId);

                }
            }

        }

        //Buscamos los contactos y oportunidades en base a los anteriores Ids

        List<Opportunity> ListaOportunidades = [SELECT Id, AccountId FROM Opportunity WHERE Id IN : ListaOps];

        for(Opportunity oportunidad: ListaOportunidades){

            ListaCuentas.add(oportunidad.AccountId);

        }

        List<AccountContactRelation> ListaRelaciones = [SELECT Id FROM AccountContactRelation WHERE AccountId IN : ListaCuentas and ContactId IN: ListaContactos];
        if((ListaRelaciones.size() == 0) &&(ListaOps.size()>0)&&(ListaContactos.size()>0)){

                Tareas[0].addError('El contacto y la oportunidad deben estar relacionados.');

            }

    }

    /* 
    @description Método que cambia el estado de la oportunidad si hay una tarea de tipo llamada
    @param TriggerNew Lista de tareas.
    @return void no se realiza devolución
    */  

    public void ChangeOpportunityStage(List<task> listTask){

        List<String> listOppsLlamadaId = new List<String>();

        for(Task singleTask : listTask){

            //Comprobamos que se ha rellenado con una oportunidad, la tarea está completada
            //Y la tarea es de tipo llamada
            if((singleTask.WhatId != null) && (singleTask.Status == 'Completed') && 
            (((singleTask.Subject.contains('Llamada')) || (singleTask.Type.contains('Llamada'))))){
                String idOpp = singleTask.WhatId;
                if(idOpp.startsWith('006')){
                    listOppsLlamadaId.add(idOpp);
                }
            }
        }

        List<Opportunity> oppsRelatedToTask = [SELECT Id, StageName, RecordType.DeveloperName from Opportunity WHERE Id = :listOppsLlamadaId];
        
        for(Opportunity oppRelatedToTask : oppsRelatedToTask){
            if((oppRelatedToTask.StageName == 'Nueva Contactado') && 
            (oppRelatedToTask.RecordType.DeveloperName != PLAZA_PUBLICA_DEVELOPER_NAME_RT) && 
            (oppRelatedToTask.RecordType.DeveloperName != TRASLADO_DEVELOPER_NAME_RT)){
                oppRelatedToTask.StageName = 'Seguimiento llamada';
            }
        }

        if(oppsRelatedToTask.size() > 0){
            update oppsRelatedToTask;
        }
    }

    /* 
    @description Método que cambia subtipo de tarea a llamada si la tarea es de llamada
    @param TriggerNew Lista tareas.
    @return void no se realiza devolución
    */ 

    public void changeTaskSubtype(List<task> listTask){
        for(Task singleTask : listTask){
            if(((singleTask.Subject.contains('Llamada')) || (singleTask.Type.contains('Llamada')))){
                singleTask.TaskSubtype = 'Call';
            }
        }
    }
}