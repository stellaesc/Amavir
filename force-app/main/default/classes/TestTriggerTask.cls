/**
@description
Test Methods de la clase TaskTrigger

DATE 		AUTHOR 		DESCRIPTION
12/09/2024  MSA - LCS   Corregir tests.
10/06/2024  MSA - LCS   Añadir test cambio de etapas.
24/07/2023  MSA - LCS   Corrección de las clases test.
13/03/2023  LCS - MSA   Creación

@author Leadclic Solutions
@date 13/03/2023 
*/

@isTest 
public class TestTriggerTask {
    private static final Id accountCentroRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CentroResidencia').getRecordTypeId();
    private static final Id plazaResidenciaRTId = Schema.SObjectType.Plaza__c.getRecordTypeInfosByDeveloperName().get('Residencia').getRecordTypeId();
    private static final Id plazaCentroDiaRTId = Schema.SObjectType.Plaza__c.getRecordTypeInfosByDeveloperName().get('CentroDia').getRecordTypeId();
    private static final Id accountFamiliaRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('FamiliaAllegado').getRecordTypeId();
    private static final Id contactFamiliarRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('FamiliaAllegado').getRecordTypeId();
    private static final Id contactResidenteRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('PotencialResidente').getRecordTypeId();
    private static final Id opportunityPlazaPrivadaRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('PlazaPrivada').getRecordTypeId();
    private static final Id idQueue = [SELECT Id FROM group WHERE DeveloperName = 'SeguimientLlamada' LIMIT 1].Id;

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

        //Insertamos una cuenta para relacionar la oportunidad
        Account familia = new Account(
            Name = 'CuentaFamilia',
            RecordTypeId = accountFamiliaRTId
        );
        insert familia;

        Account familia2 = new Account(
            Name = 'CuentaFamilia2',
            RecordTypeId = accountFamiliaRTId
        );
        insert familia2;

        //Generamos un contacto como residente y dos familiares
        List <Contact> lCont2Insert = new List <Contact>();
        Contact residente = new Contact(
            RecordTypeId = contactResidenteRTId,
            AccountId = familia.Id,
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
            NumeroDocumento__c = '02796904N'
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
            Email='mailfmailiar1@test.com'
        );
        lCont2Insert.add(familiar1);

        Contact familiar2 = new Contact(
            RecordTypeId = contactFamiliarRTId,
            AccountId = familia.Id,
            IdExternoSAP__c='7777',
            FirstName='FamiliarPrueba',
            LastName='ApellidoPruebaFamiliar2Influyente',
            MailingStreet='Ancha',
            MailingPostalCode='28005',
            MailingCity='Madrid',
            MobilePhone='602275300',
            Phone='917390566',
            Email='mailfamiliar2@test.com'
        );
        lCont2Insert.add(familiar2);
        
        Contact familiar3 = new Contact(
            RecordTypeId = contactFamiliarRTId,
            AccountId = familia2.Id,
            IdExternoSAP__c='3333',
            FirstName='FamiliarPrueba',
            LastName='ApellidoPruebaFamiliar3Decisor',
            MailingStreet='Ancha',
            MailingPostalCode='28003',
            MailingCity='Madrid',
            MobilePhone='603375300',
            Phone='917390533',
            Email='mailfamiliar3@test.com'
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
            TipoPlaza__c = 'P',
            FechaIngresoPlanificado__c = Date.today(),
            MotivoIngreso__c = 'Psicogeriatría',
            DetalleMotivoIngreso__c = 'Autolisis',
            UrgenciaPercibida__c = 'Baja'
        );
        insert oportunidad;
    }

    @isTest 
    static void testErrorOk(){

        Opportunity oportunidad = [SELECT Id from Opportunity WHERE TipoPlaza__c = 'P'];
        Contact contacto = [Select Id from Contact WHERE LastName = 'ApellidoPruebaFamiliar3Decisor'];
        Task tarea = new Task();
        tarea.WhatId = oportunidad.Id;
        tarea.WhoId = contacto.Id;
        tarea.status = 'Open';
        tarea.Subject = 'test Llamada test';
        tarea.Type = 'Llamada';
        test.startTest();
        try{
        insert tarea;
        } catch(Exception e){
            Boolean expectedExceptionThrown =  (e.getMessage().contains('El contacto y la oportunidad deben estar relacionados.')) ? true : false; 
            System.AssertEquals(true, expectedExceptionThrown, e.getMessage()); 
        }
        test.stopTest(); 
    }

    @isTest 
    static void testErrorFalse(){

        Opportunity oportunidad = [SELECT Id from Opportunity WHERE TipoPlaza__c = 'P'];
        Contact contacto = [Select Id from Contact WHERE LastName = 'ApellidoPruebaFamiliar2Influyente'];
        Task tarea = new Task();
        tarea.WhatId = oportunidad.Id;
        tarea.WhoId = contacto.Id;
        tarea.status = 'Open';
        tarea.Subject = 'test Llamada test';
        tarea.Type = 'Llamada';
        test.startTest();
        insert tarea;
        test.stopTest();
        List<Task> tareas = [Select Id from TASK];
        System.assert(tareas.size()==1); 
    }

    @isTest 
    static void testUpdateOpportunity(){

        Opportunity oportunidad = [SELECT Id from Opportunity WHERE TipoPlaza__c = 'P'];
        Contact contacto = [Select Id from Contact WHERE LastName = 'ApellidoPruebaFamiliar2Influyente'];
        Task tarea = new Task();
        tarea.WhatId = oportunidad.Id;
        tarea.WhoId = contacto.Id;
        tarea.status = 'Completed';
        tarea.Subject = 'test Llamada test';
        tarea.OwnerId=idQueue;
        test.startTest();
        insert tarea;
        test.stopTest();
        List<Opportunity> opp = [Select Id FROM Opportunity WHERE StageName = 'Seguimiento llamada'];
        System.assert(opp.size()==1); 
    }
}