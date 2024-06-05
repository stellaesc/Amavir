/**
@description
Clase test de CuentasResidencia

DATE 		AUTHOR 		DESCRIPTION
21/02/2023	LCS - MSA	Creation
23/02/2023	LCS - MSA	Ultima cuenta que no se actualizaba. Ahora si.
22/05/2023  LCS - MSA	Corrección por el nuevo estado de las oportunidades.
16/01/2024  LCS - MSA	Corrección por la capacidad de clonar oportunidades.

@author Leadclic Solutions
@date 21/02/2023
*/

@isTest 
public class TestCuentasResidencia {

        private static final Id accountCentroRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CentroResidencia').getRecordTypeId();
        private static final Id plazaResidenciaRTId = Schema.SObjectType.Plaza__c.getRecordTypeInfosByDeveloperName().get('Residencia').getRecordTypeId();
        private static final Id plazaCentroDiaRTId = Schema.SObjectType.Plaza__c.getRecordTypeInfosByDeveloperName().get('CentroDia').getRecordTypeId();
        private static final Id accountFamiliaRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('FamiliaAllegado').getRecordTypeId();
        private static final Id contactFamiliarRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('FamiliaAllegado').getRecordTypeId();
        private static final Id contactResidenteRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('PotencialResidente').getRecordTypeId();
        private static final Id opportunityPlazaPrivadaRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('PlazaPrivada').getRecordTypeId();
        
    @TestSetup
    static void setup(){
        
        List<Account> NuevasCuentas = new List<Account>();
        List<Opportunity> NuevasOportunidades = new List<Opportunity>();
        List<Contact> NuevosContactos = new List<Contact>();
        List<ContentDocument> NuevosArchivos = new List<ContentDocument>();

        

    Account centro = new Account(
            Name = 'Centro de prueba',
            RecordTypeId = accountCentroRTId,
            CodigoCentroSAP__c = '2808'
        );
        insert centro;

        Account centro2 = new Account(
            Name = 'Centro de prueba2',
            RecordTypeId = accountCentroRTId,
            CodigoCentroSAP__c = '2809'
        );
        insert centro2;
        
        //Se crean 200 cuentas
        
        for(Integer i = 0; i<200;i++){
            Account Nueva = new Account();
            Nueva.Name = 'TestCuentaNueva' +i;
            NuevasCuentas.add(Nueva);
            Nueva.RecordTypeId = accountFamiliaRTId;
        }
        insert NuevasCuentas;
        
        //Se crean 400 oportunidades
        
        for(Integer i = 0; i<400;i++){
            Opportunity Nueva = new Opportunity();
            Nueva.Name = 'TestOportunidadNueva';
            if(i > 199){
            Nueva.AccountId = NuevasCuentas[i-200].Id;
            } else {
            Nueva.AccountId = NuevasCuentas[i].Id;
            }
            NuevasOportunidades.add(Nueva);
            Nueva.StageName = 'Cerrada - Éxito';
            Nueva.RealSAP__c = true;
            Nueva.FechaSalida__c = System.today() +i;
            Nueva.CloseDate = System.today();
            if(i>199){
                Nueva.ResidenciaIngreso__c = centro.Id;
            } else{
                Nueva.ResidenciaIngreso__c = centro2.Id;
            }
            
        }
        insert NuevasOportunidades;
        for(Integer i = 0; i<400;i++){
            NuevasOportunidades[i].FechaSalida__c = System.today() +i;
        }
        update NuevasOportunidades;
    }
        @isTest 
        static void rellenaCentro(){
            test.startTest();
            Database.executeBatch(new CuentasResidencia(), 200); 
            test.stopTest();
            List<Account> centro = [SELECT Id from Account where CodigoCentroSAP__c = '2808'];
            List<Account> cuentas = [SELECT Id FROM Account WHERE CentroResidenciaActual__c =: centro];
            System.assertEquals(cuentas.size(), 200);
        }
    
}