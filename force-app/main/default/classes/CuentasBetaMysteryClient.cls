/**
@description
Clase de un solo uso que actualiza todas las cuentas de familiar Allegado  e indican su centro actual.

Ejecucción: Database.executeBatch(new CuentasResidencia(), 200); En la consola anónima.

DATE 		AUTHOR 		DESCRIPTION
21/02/2023	LCS - MSA	Creation
23/02/2023	LCS - MSA	Ultima cuenta que no se actualizaba. Ahora si.

@author Leadclic Solutions
@date 21/02/2023
*/

global class CuentasBetaMysteryClient implements Schedulable,  Database.Batchable<sObject> {

    Id IdFamiliaAllegado = [SELECT Id FROM RecordType WHERE DeveloperName = 'FamiliaAllegado' Limit 1].Id;
    Id IdPotencialResidente = [SELECT Id FROM RecordType WHERE DeveloperName = 'PotencialResidente' Limit 1].Id;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        string query = ('Select Id, Beta__c, MysteryClient__c FROM Account WHERE RecordTYPEId =: IdFamiliaAllegado');  
        return Database.getQueryLocator(query);
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new CuentasBetaMysteryClient(), 200); 
    }

    public void execute(Database.BatchableContext bc, List<Account> Cuentas){
        List<Account> Accounts2Update = new List<Account>();

        map<Id, Boolean> mIdCuenta_Beta = new map<Id, Boolean>();
        map<Id, Boolean> mIdCuenta_Mystery = new map<Id, Boolean>();

        //CUENTAS RESIDENTES, han de tener un contacto de tipo residente
        List<Contact> ListaContactos = [SELECT Id, Beta__c, MysteryClient__c, AccountId FROM Contact WHERE AccountId IN: Cuentas AND RecordTYPEId =: IdPotencialResidente];

        for (Contact contacto : ListaContactos) {
            mIdCuenta_Beta.put(contacto.AccountId, contacto.Beta__c);
            mIdCuenta_Mystery.put(contacto.AccountId, contacto.MysteryClient__c);
        }
        for(Account Cuenta : Cuentas){
            Cuenta.Beta__c = mIdCuenta_Beta.get(Cuenta.Id) == null? false : mIdCuenta_Beta.get(Cuenta.Id);
            Cuenta.MysteryClient__c = mIdCuenta_Mystery.get(Cuenta.Id) == null? false : mIdCuenta_Mystery.get(Cuenta.Id);
            Accounts2Update.add(Cuenta);
        }

        Database.SaveResult[] srList = Database.update(Accounts2Update, false);
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
        }
    }
    public void finish(Database.BatchableContext bc){
    }
}