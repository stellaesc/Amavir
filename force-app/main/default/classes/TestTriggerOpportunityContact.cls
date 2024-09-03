/**
@description
Clase test de TriggerOpportunityContactHandler

DATE 		AUTHOR 		DESCRIPTION
03/09/2024	LCS - MSA	Creation

@author Leadclic Solutions
@date 03/09/2024
*/

@isTest
public with sharing class TestTriggerOpportunityContact {
    // Obtenemos los Identificador de los tipos de registros necesarios
    private static final Id accountCentroRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CentroResidencia').getRecordTypeId();
    private static final Id plazaResidenciaRTId = Schema.SObjectType.Plaza__c.getRecordTypeInfosByDeveloperName().get('Residencia').getRecordTypeId();
    private static final Id plazaCentroDiaRTId = Schema.SObjectType.Plaza__c.getRecordTypeInfosByDeveloperName().get('CentroDia').getRecordTypeId();
    private static final Id accountFamiliaRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('FamiliaAllegado').getRecordTypeId();
    private static final Id contactFamiliarRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('FamiliaAllegado').getRecordTypeId();
    private static final Id contactResidenteRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('PotencialResidente').getRecordTypeId();
    private static final Id opportunityPlazaPrivadaRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('PlazaPrivada').getRecordTypeId();

    @TestSetup
    static void setup(){        

        // Damos de alta un centro
        Account centro = new Account(
            Name = 'Centro de prueba',
            RecordTypeId = accountCentroRTId,
            CodigoCentroSAP__c = '2808'
        );
        insert centro;

        // Creamos una plaza para ese centro
        List<Plaza__c> lPlazas = new List<Plaza__c>();
        Plaza__c plazaResi = new Plaza__c (
            Name = '2808H0101',
            RecordTypeId = plazaResidenciaRTId,
            Cama__c = '2808H0101',
            Cuenta__c = centro.Id
        );
        lPlazas.add(plazaResi);
        // Creamos plazas de centro de día para ese centro        
        Plaza__c plazaCDLunes = new Plaza__c (
            Name = '2808CDC0101L',
            RecordTypeId = plazaCentroDiaRTId,
            Cama__c = '2808CDC0101L',
            Cuenta__c = centro.Id,
            DiaSemana__c = 'Lunes'
        );
        lPlazas.add(plazaCDLunes);
        Plaza__c plazaCDMartes = new Plaza__c (
            Name = '2808CDC0101M',
            RecordTypeId = plazaCentroDiaRTId,
            Cama__c = '2808CDC0101M',
            Cuenta__c = centro.Id,
            DiaSemana__c = 'Martes'
        );
        lPlazas.add(plazaCDMartes);
        Plaza__c plazaCDMiercoles = new Plaza__c (
            Name = '2808CDC0101X',
            RecordTypeId = plazaCentroDiaRTId,
            Cama__c = '2808CDC0101X',
            Cuenta__c = centro.Id,
            DiaSemana__c = 'Miércoles'
        );
        lPlazas.add(plazaCDMiercoles);
        Plaza__c plazaCDJueves = new Plaza__c (
            Name = '2808CDC0101J',
            RecordTypeId = plazaCentroDiaRTId,
            Cama__c = '2808CDC0101J',
            Cuenta__c = centro.Id,
            DiaSemana__c = 'Jueves'
        );
        lPlazas.add(plazaCDJueves);
        Plaza__c plazaCDViernes = new Plaza__c (
            Name = '2808CDC0101V',
            RecordTypeId = plazaCentroDiaRTId,
            Cama__c = '2808CDC0101V',
            Cuenta__c = centro.Id,
            DiaSemana__c = 'Viernes'
        );
        lPlazas.add(plazaCDViernes);
        Plaza__c plazaCDSabado = new Plaza__c (
            Name = '2808CDC0101S',
            RecordTypeId = plazaCentroDiaRTId,
            Cama__c = '2808CDC0101S',
            Cuenta__c = centro.Id,
            DiaSemana__c = 'Sábado'
        );
        lPlazas.add(plazaCDSabado);
        Plaza__c plazaCDDomingo = new Plaza__c (
            Name = '2808CDC0101D',
            RecordTypeId = plazaCentroDiaRTId,
            Cama__c = '2808CDC0101D',
            Cuenta__c = centro.Id,
            DiaSemana__c = 'Domingo'
        );
        lPlazas.add(plazaCDDomingo);
        insert lPlazas;

        //Insertamos una cuenta para relacionar la oportunidad
        Account familia = new Account(
            Name = 'CuentaFamilia',
            RecordTypeId = accountFamiliaRTId
        );
        insert familia;

        //Generamos un contacto como residente y dos familiares
        List <Contact> lCont2Insert = new List <Contact>();
        Contact residente = new Contact(
            RecordTypeId = contactResidenteRTId,
            AccountId = familia.Id,
            Birthdate = Date.Today()-1,
            IdExternoSAP__c='9999',
            FirstName='ResidentePrueba',
            LastName='ApellidoPruebaResidente',
            MailingStreet='Ancha',
            MailingPostalCode='28005',
            MailingCity='Madrid',
            MobilePhone='602275300',
            Phone='917390566',
            Email='mailresidente@test.com',
            Sexo__c = '2',
            TipoDocumento__c = '01',
            NumeroDocumento__c = '02796904N',
            Oxigeno__c = 'NS/NC',
            SuplementoNutricional__c = 'NS/NC',
            SondaNasogastrica__c = 'NS/NC',
            SondaVesical__c = 'NS/NC',
            Sujeccion__c = 'NS/NC',
            Alergias__c = 'NS/NC',
            ProblemasDeDeglucion__c = 'NS/NC',
            Incontinencia__c = 'NS/NC',
            Agitacion__c = 'NS/NC',
            Vagabundeo__c = 'NS/NC',
            RiesgoDeFuga__c = 'NS/NC',
            Desorientado__c = 'NS/NC'
        );
        lCont2Insert.add(residente);
        
        Contact familiar1 = new Contact(
            RecordTypeId = contactFamiliarRTId,
            AccountId = familia.Id,
            IdExternoSAP__c='8888',
            FirstName='FamiliarPrueba',
            LastName='ApellidoPruebafamiliar1Decisor',
            MailingStreet='Ancha',
            MailingPostalCode='28005',
            MailingCity='Madrid',
            MobilePhone='602275300',
            Phone='917390566',
            Email='mailfmailiar1@test.com',
            Parentesco__c = 'K'
        );
        lCont2Insert.add(familiar1);

        Contact familiar2 = new Contact(
            RecordTypeId = contactFamiliarRTId,
            AccountId = familia.Id,
            IdExternoSAP__c='7777',
            FirstName='FamiliarPrueba',
            LastName='ApellidoFamiliar2Influyente',
            MailingStreet='Ancha',
            MailingPostalCode='28005',
            MailingCity='Madrid',
            MobilePhone='602275300',
            Phone='917390566',
            Email='mailfamiliar2@test.com',
            Parentesco__c = 'K'
        );
        lCont2Insert.add(familiar2);
        
        Contact familiar3 = new Contact(
            RecordTypeId = contactFamiliarRTId,
            AccountId = familia.Id,
            IdExternoSAP__c='3333',
            FirstName='FamiliarPrueba',
            LastName='ApellidoPruebaFamiliar3Decisor',
            MailingStreet='Ancha',
            MailingPostalCode='28003',
            MailingCity='Madrid',
            MobilePhone='603375300',
            Phone='917390533',
            Email='mailfamiliar3@test.com',
            Parentesco__c = 'K'
        );
        lCont2Insert.add(familiar3);

        // Insertamos los contactos
        insert lCont2Insert;

        // Insertamos una oportunidad
        Opportunity oportunidad = new Opportunity(
            AccountId = familia.Id,
            Name = 'Oportunidad de prueba',
            RecordTypeId = opportunityPlazaPrivadaRTId,
            StageName = 'Nueva Contactado',
            CloseDate = Date.today(),
            ResidenciaIngreso__c = centro.Id,
            Plaza__c = plazaResi.Id,
            TipoPlaza__c = 'P',
            FechaIngreso__c = Date.today(),
            MotivoIngreso__c = 'Psicogeriatría',
            DetalleMotivoIngreso__c = 'Autolisis',
            IdExternoSAP__c = '2222'
        );
        insert oportunidad;

        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = residente.Id;
        ocr.OpportunityId = oportunidad.Id;
        ocr.Role = 'Residente';
        insert ocr;

        oportunidad.IdExternoSAP__c = '2222';
        oportunidad.StageName = 'Cerrada - Éxito';
        oportunidad.CodeSAPResponse__c  = '(S, S)';
        oportunidad.RealSAP__c = true;
        update oportunidad;
    }

    @isTest 
    static void testEnvioFamiliar(){

        Opportunity lOpp = [SELECT Id, FechaSalida__c FROM Opportunity LIMIT 1];
        Account familia = [SELECT Id FROM Account WHERE RecordTypeId =: accountFamiliaRTId LIMIT 1];

        test.startTest();

        Test.setMock(HttpCalloutMock.class, new WSSAPAdmisionesMock('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"> <soap-env:Header/> <soap-env:Body> <n0:ZISH_CREAR_FAMILIAR_SFResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions"> <E_PARTNER1></E_PARTNER1> <E_PARTNER2>0010055443</E_PARTNER2> <E_RETURN> <TYPE>S</TYPE> <MESSAGE>El familiar se ha creado en el sistema</MESSAGE> </E_RETURN> </n0:ZISH_CREAR_FAMILIAR_SFResponse> </soap-env:Body> </soap-env:Envelope>'));

        Contact familiar3 = new Contact(
            RecordTypeId = contactFamiliarRTId,
            AccountId = familia.Id,
            FirstName='FamiliarPrueba',
            LastName='ApellidoPruebaFamiliar3Decisor',
            MailingStreet='Ancha',
            MailingPostalCode='28003',
            MailingCity='Madrid',
            MobilePhone='603375120',
            Phone='917312533',
            Email='mailfamiliar4@test.com',
            Parentesco__c = 'K'
        );

        insert familiar3;

        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = familiar3.Id;
        ocr.OpportunityId = lOpp.Id;
        insert ocr;

        test.stopTest();
        
        Contact LastFamiliar = [SELECT Id, IdExternoSAPContactos__c FROM Contact WHERE Email = 'mailfamiliar4@test.com'];

        System.assertEquals(LastFamiliar.IdExternoSAPContactos__c, '0010055443', 'El familiar no se ha creado correctamente');
    }
}