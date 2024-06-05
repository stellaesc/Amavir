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

global class CuentasResidencia implements Schedulable,  Database.Batchable<sObject> {

    Id IdFamiliaAllegado = [SELECT Id FROM RecordType WHERE DeveloperName = 'FamiliaAllegado' Limit 1].Id;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        string query = ('Select Id, CentroResidenciaActual__c FROM Account WHERE RecordTYPEId =: IdFamiliaAllegado');  
        return Database.getQueryLocator(query);
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new CuentasResidencia(), 200); 
    }

    public void execute(Database.BatchableContext bc, List<Account> Cuentas){
        List<Opportunity> Oportunidades = [Select Id, AccountId, ResidenciaIngreso__c, FechaSalida__c, FechaIngreso__c FROM Opportunity WHERE AccountId IN: Cuentas AND StageName = 'Cerrada - Éxito' Order By AccountId];

        Date FechaSalidaAnterior;
        Date FechaIngresoAnterior;
        Id IdCuentaAnterior;
        Id ResidenciaIngreso;

        map<Id,Id> mCuentasResidencia = new Map<Id,Id>();

        //Bucle for que mira la oportunidad anterior con el mejor caso. Si es el mejor caso, actualiza.

        for (Opportunity Oportunidad : Oportunidades){

            if(IdCuentaAnterior != Oportunidad.AccountId){
                if(IdCuentaAnterior != null){
                    mCuentasResidencia.put(IdCuentaAnterior, ResidenciaIngreso);
                }
                FechaSalidaAnterior = Oportunidad.FechaSalida__c;
                FechaIngresoAnterior = Oportunidad.FechaIngreso__c;
                IdCuentaAnterior = Oportunidad.AccountId;
                ResidenciaIngreso = Oportunidad.ResidenciaIngreso__c;
            } else {

                if((Oportunidad.FechaSalida__c == null)&&(FechaSalidaAnterior == null)){

                    if(Oportunidad.FechaIngreso__c > FechaIngresoAnterior){

                        FechaSalidaAnterior = Oportunidad.FechaSalida__c;
                        FechaIngresoAnterior = Oportunidad.FechaIngreso__c;
                        IdCuentaAnterior = Oportunidad.AccountId;
                        ResidenciaIngreso = Oportunidad.ResidenciaIngreso__c;

                    }

                }

                if((Oportunidad.FechaSalida__c == null)&&(FechaSalidaAnterior != null)){

                    FechaSalidaAnterior = Oportunidad.FechaSalida__c;
                    FechaIngresoAnterior = Oportunidad.FechaIngreso__c;
                    IdCuentaAnterior = Oportunidad.AccountId;
                    ResidenciaIngreso = Oportunidad.ResidenciaIngreso__c;

                }

                if((Oportunidad.FechaSalida__c != null)&&(FechaSalidaAnterior != null)){

                    if(Oportunidad.FechaSalida__c>FechaSalidaAnterior){
                        FechaSalidaAnterior = Oportunidad.FechaSalida__c;
                        FechaIngresoAnterior = Oportunidad.FechaIngreso__c;
                        IdCuentaAnterior = Oportunidad.AccountId;
                        ResidenciaIngreso = Oportunidad.ResidenciaIngreso__c;
                    }

                    if(Oportunidad.FechaSalida__c==FechaSalidaAnterior){
                        if(Oportunidad.FechaIngreso__c > FechaIngresoAnterior){

                            FechaSalidaAnterior = Oportunidad.FechaSalida__c;
                            FechaIngresoAnterior = Oportunidad.FechaIngreso__c;
                            IdCuentaAnterior = Oportunidad.AccountId;
                            ResidenciaIngreso = Oportunidad.ResidenciaIngreso__c;
    
                        }
                    }

                }

            }

        }

        mCuentasResidencia.put(IdCuentaAnterior, ResidenciaIngreso);

        for(Account Cuenta : Cuentas){

            Cuenta.CentroResidenciaActual__c = mCuentasResidencia.get(Cuenta.Id);
            System.debug(mCuentasResidencia.get(Cuenta.Id));
            System.debug((Cuenta.Id));

        }
        Database.SaveResult[] srList = Database.update(Cuentas, false);

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