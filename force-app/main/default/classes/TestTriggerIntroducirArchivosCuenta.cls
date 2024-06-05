/**
@description
Clase Test del TriggerIntroducirArchivosCuenta

DATE 		AUTHOR 		DESCRIPTION
28/09/2022  LCS - MSA   Creación.
22/05/2023  LCS - MSA	Corrección por el nuevo estado de las oportunidades.

@author Leadclic Solutions
@date 28/09/2022 
*/

@isTest
public class TestTriggerIntroducirArchivosCuenta {
	
    @TestSetup
    static void setup(){
        
        List<Account> NuevasCuentas = new List<Account>();
        List<Opportunity> NuevasOportunidades = new List<Opportunity>();
        List<Contact> NuevosContactos = new List<Contact>();
        List<ContentDocument> NuevosArchivos = new List<ContentDocument>();
        
        //Se crean 200 cuentas
        
        for(Integer i = 0; i<200;i++){
            Account Nueva = new Account();
            Nueva.Name = 'TestCuentaNueva' +i;
            NuevasCuentas.add(Nueva);
        }
        insert NuevasCuentas;
        
        //Se crean 100 oportunidades
        
        for(Integer i = 0; i<100;i++){
            Opportunity Nueva = new Opportunity();
            Nueva.Name = 'TestOportunidadNueva';
            Nueva.AccountId = NuevasCuentas[i].Id;
            NuevasOportunidades.add(Nueva);
            Nueva.StageName = 'Cerrada - Éxito';
            Nueva.RealSAP__c = true;
            Nueva.FechaSalida__c = System.today() +i;
            Nueva.CloseDate = System.today();
        }
        insert NuevasOportunidades;
        
        //Se crea un archivo y se asocia a una cuenta
        
		ContentVersion contentVersion = new ContentVersion(
        Title          = 'a picture',
        PathOnClient   = 'Pic.jpg',
        VersionData    = Blob.valueOf('Test Content'),
      	IsMajorVersion = true);
        insert contentVersion;

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = documents[0].Id;
        cdl.LinkedEntityId = NuevasCuentas[0].Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        
        //Se crean 100 contactos
        
        for(Integer i = 100; i<200;i++){
            Contact Nueva = new Contact();
            Nueva.LastName = 'Test';
            Nueva.FirstName = 'Test';
			Nueva.AccountId = NuevasCuentas[i].Id;
            NuevosContactos.add(Nueva);
        }
        System.debug(NuevosContactos.size());
        insert NuevosContactos;
    }
    @isTest 
    static void Test(){
        
        //Se generan todas las relaciones en contactos y oportunidades
        
        Account Cuenta = [SELECT Id FROM Account WHERE Name = 'TestCuentaNueva0' LIMIT 1];
        List<Contact> Contactos = [SELECT Id FROM Contact];
        List<Opportunity> Oportunidades = [SELECT Id FROM Opportunity];
        List<ContentDocumentLink> Documentos = new List<ContentDocumentLink>();
        List<Id> IdsCuenta = new List<Id>();
        
        
        ContentDocumentLink Documento = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: Cuenta.Id LIMIT 1];
        
        for(Contact Contacto: Contactos){
            ContentDocumentLink DocumentoNuevo = new ContentDocumentLink();
            DocumentoNuevo.LinkedEntityId = Contacto.Id;
            DocumentoNuevo.ContentDocumentId = Documento.ContentDocumentId;
            Documentos.add(DocumentoNuevo);
        }
        
        for(Opportunity Oportunidad: Oportunidades){
            ContentDocumentLink DocumentoNuevo = new ContentDocumentLink();
            DocumentoNuevo.LinkedEntityId = Oportunidad.Id;
            DocumentoNuevo.ContentDocumentId = Documento.ContentDocumentId;
            Documentos.add(DocumentoNuevo);
        }
        test.startTest();
        upsert Documentos;
        test.stopTest();
        
        //Comprobamos que el número de cuentas coincide con el número de relaciones a cuenta
        
        List<Account> Cuentas = [SELECT Id FROM Account];
        for(Account CuentaUnica: Cuentas){
            IdsCuenta.add(CuentaUnica.Id);
        }
        
        Documentos = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =: IdsCuenta];
        System.assertEquals(Cuentas.size(), Documentos.size());
        
        
        	
    }
}