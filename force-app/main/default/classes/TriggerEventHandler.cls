/**
@description
Handler de la clase TriggerEvent

DATE 		AUTHOR 		DESCRIPTION

04/05/2023  LCS - MSA   Buscar si el contacto y la oportunidad están relacionados pero no por la misma cuenta,
                        sino por el AccountContactRelation.
13/03/2023  LCS - MSA   Creación

@author Leadclic Solutions
@date 13/03/2023 
*/

public class TriggerEventHandler {

    /* 
    @description Método que se ejecuta desde el trigger y comprueba los Ids relacionados del Evento.
                Si es un contacto y una oportunidad que no están relacionados dará un error.
    @param TriggerNew Lista de relaciones entre registros y archivos.
    @return void no se realiza devolución
    */  
    public void CheckEventOpp(List<Event> Eventos) {

        map<Id,Id> mOppsContacts = new map<Id,Id>();
        map<Id,Id> mContsAccount = new map<Id,Id>();
        List<Id> ListaOps = new list<Id>();
        List<Id> ListaContactos = new list<id>();
        List<Id> ListaCuentas = new list<id>();

        //Creamos los mapas y las listas descartando cuando ambos no están rellenos y no son ni contactos ni oportunidades

        for(Event Evento : Eventos){

            if(Evento.WhoId == null || Evento.WhatId == null){

            } else {
                String IdOpp = Evento.WhatId;
                String IdCont = Evento.WhoId;

                

                if(IdOpp.startsWith('006')&&(IdCont.startsWith('003'))){

                    mOppsContacts.put(Evento.WhatId,Evento.WhoId);
                    ListaOps.add(Evento.WhatId);
                    ListaContactos.add(Evento.WhoId);

                }
            }

        }


        List<Opportunity> ListaOportunidades = [SELECT Id, AccountId FROM Opportunity WHERE Id IN : ListaOps];

        for(Opportunity oportunidad: ListaOportunidades){

            ListaCuentas.add(oportunidad.AccountId);

        }

        List<AccountContactRelation> ListaRelaciones = [SELECT Id FROM AccountContactRelation WHERE AccountId IN : ListaCuentas and ContactId IN: ListaContactos];
        if((ListaRelaciones.size() == 0) &&(ListaOps.size()>0)&&(ListaContactos.size()>0)){
        
                Eventos[0].addError('El contacto y la oportunidad deben estar relacionados.');
        
            }

    }
}