/**
@description
Clase test de WSReajustarOcupacion

DATE 		AUTHOR 		DESCRIPTION
16/01/2024  LCS - MSA	Creación.
14/06/2024  LCS - MSA   Corrección por cambio en VR.

@author Leadclic Solutions
@date 16/01/2024
*/

@isTest
public with sharing class TestWSReajustarOcupacion {
    
    @testSetup 
    static void setup() {

        Profile p = [SELECT Id FROM Profile WHERE Name='Administrador del sistema'];
        User u2 = new User(Alias = 'uinte', Email='newuser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='newuser@testorg.com');

        //Insertamos Cuenta de Residente en residencia
        List<Account> lAccount2Ins = new List<Account>();
        Account acctResidente = new Account(Name='CuentaResidentePrueba');
        lAccount2Ins.add(acctResidente);

        //Insertamos Cuenta de Residente en Centro de día 
        Account acctResidenteCD = new Account(Name='CuentaResidentePruebaCD');
        lAccount2Ins.add(acctResidenteCD);

        // Insertamos una residencia
        RecordType rtCentroResidenciaId = [SELECT Id FROM RecordType WHERE DeveloperName ='CentroResidencia' and SobjectType = 'Account'];
        RecordType rtOppTraslado = [SELECT Id FROM RecordType WHERE DeveloperName ='Traslado' and SobjectType = 'Opportunity'];
        Account acctResidencia = new Account(Name='CuentaResidenciaPrueba', RecordTypeId=rtCentroResidenciaId.Id, CodigoCentroSAP__c = '0201');
        lAccount2Ins.add(acctResidencia);

        insert lAccount2Ins;


        //Insertamos el contacto
        RecordType rtid = [SELECT Id FROM RecordType WHERE DeveloperName ='PotencialResidente' and SobjectType = 'Contact'];

        //Recogemos RT de Plaza
        RecordType rtPlazaResidencia = [SELECT Id FROM RecordType WHERE DeveloperName ='Residencia' and SobjectType = 'Plaza__c'];
        RecordType rtPlaza = [SELECT Id FROM RecordType WHERE DeveloperName ='CentroDia' and SobjectType = 'Plaza__c'];
        
        Contact contactResidencia = new Contact (RecordTypeId=rtid.Id,
                                        IdExternoSAP__c='88888888',
                                        AccountId=acctResidente.Id,
                                        FirstName='ResidentePrueba',
                                        LastName='ApellidoPrueba',
                                        MailingStreet='Ancha',
                                        MailingPostalCode='28005',
                                        MailingCity='Madrid',
                                        MobilePhone='945588032',
                                        Phone='916983265',
                                        Email='testmail@test.com');
        insert contactResidencia;

        Contact contactCD = new Contact (RecordTypeId=rtid.Id,
                                        IdExternoSAP__c='999999999',
                                        AccountId=acctResidenteCD.Id,
                                        FirstName='ResidentePrueba2',
                                        LastName='ApellidoPrueba2',
                                        MailingStreet='Ancha2',
                                        MailingPostalCode='28005',
                                        MailingCity='Madrid',
                                        MobilePhone='687654321',
                                        Phone='945786123',
                                        Email='testmail2@test.com');
        insert contactCD;

        // Lista para insertar las plazas
        List<Plaza__c> lPlazas = new List<Plaza__c> ();
        //Insertamos plaza origen residencia
        Plaza__c plazaResidenciaOrigen = new Plaza__c(
            Cuenta__c=acctResidencia.Id,
            Cama__C='0201001A',
            TipoPlaza__c='P',
            PlazaOcupada__c=true,
            RecordTypeId = rtPlazaResidencia.Id
        );
        lPlazas.add(plazaResidenciaOrigen);
        //Insertamos plaza destino residencia
        Plaza__c plazaResidenciaDestino = new Plaza__c(
            Cama__c='0201019A',
            PlazaOcupada__c=false,
            Cuenta__c=acctResidencia.Id,
            TipoPlaza__c='P',
            RecordTypeId = rtPlazaResidencia.Id
        );
        lPlazas.add(plazaResidenciaDestino);
        //Insertamos plazas de centros de día
        Plaza__c plazaLunes = new Plaza__c(
            Cuenta__c=acctResidencia.Id,
            Cama__c='01CDP011L',
            TipoPlaza__c='P',
            PlazaOcupada__c=true,
            RecordTypeId = rtPlaza.Id,
            DiaSemana__c = 'Lunes'
        );
        lPlazas.add(plazaLunes);
        Plaza__c plazaMartes = new Plaza__c(
            Cuenta__c=acctResidencia.Id,
            Cama__c='01CDP011M',
            TipoPlaza__c='P',
            PlazaOcupada__c=false,
            RecordTypeId = rtPlaza.Id,
            DiaSemana__c = 'Martes'
        );
        lPlazas.add(plazaMartes);
        Plaza__c plazaMiercoles = new Plaza__c(
            Cuenta__c=acctResidencia.Id,
            Cama__c='01CDP011X',
            TipoPlaza__c='P',
            PlazaOcupada__c=false,
            RecordTypeId = rtPlaza.Id,
            DiaSemana__c = 'Miércoles'
        );
        lPlazas.add(plazaMiercoles);
        Plaza__c plazaJueves = new Plaza__c(
            Cuenta__c=acctResidencia.Id,
            Cama__c='01CDP011J',
            TipoPlaza__c='P',
            PlazaOcupada__c=false,
            RecordTypeId = rtPlaza.Id,
            DiaSemana__c = 'Jueves'
        );
        lPlazas.add(plazaJueves);
        Plaza__c plazaViernes = new Plaza__c(
            Cuenta__c=acctResidencia.Id,
            Cama__c='01CDP011V',
            TipoPlaza__c='P',
            PlazaOcupada__c=false,
            RecordTypeId = rtPlaza.Id,
            DiaSemana__c = 'Viernes'
        );
        lPlazas.add(plazaViernes);
        Plaza__c plazaSabado = new Plaza__c(
            Cuenta__c=acctResidencia.Id,
            Cama__c='01CDP011S',
            TipoPlaza__c='P',
            PlazaOcupada__c=false,
            RecordTypeId = rtPlaza.Id,
            DiaSemana__c = 'Sábado'
        );
        lPlazas.add(plazaSabado);
        Plaza__c plazaDomingo = new Plaza__c(
            Cuenta__c=acctResidencia.Id,
            Cama__c='01CDP011D',
            TipoPlaza__c='P',
            PlazaOcupada__c=false,
            RecordTypeId = rtPlaza.Id,
            DiaSemana__c = 'Domingo'
        );
        lPlazas.add(plazaDomingo);
        // Otra plaza diferente para el Lunes
        Plaza__c plazaLunes2 = new Plaza__c(
            Cuenta__c=acctResidencia.Id,
            Cama__c='01CDP012L',
            TipoPlaza__c='P',
            PlazaOcupada__c=false,
            RecordTypeId = rtPlaza.Id,
            DiaSemana__c = 'Lunes'
        );
        lPlazas.add(plazaLunes2);
        insert lPlazas;

        //Insertamos Oportunidad con el IdResidente (IdExternoSAP__c) que se va a enviar en la prueba y la plaza original
        Opportunity opportunityResidencia = new Opportunity(
            Plaza__c=plazaResidenciaOrigen.Id,
            AccountId=acctResidente.Id,
            IdExternoSAP__c='88888888',
            Name='Baldomero Dominguez',
            StageName='Cerrada - Éxito',
            ResidenciaIngreso__c = acctResidencia.Id,
            CloseDate=date.parse('01/01/2018'),
            FechaIngreso__c = Date.today(),
            TipoPlaza__c = 'P',
            ResidenciaPreferencia__c = acctResidencia.Id,
            RealSAP__c = true,
            MotivoIngreso__c = 'Psicogeriatría',
            DetalleMotivoIngreso__c = 'Autolisis'
        );
        insert opportunityResidencia;
        opportunityResidencia.IdExternoSAP__c='88888888';
        update opportunityResidencia;

        //Insertamos Oportunidad con el IdResidente (IdExternoSAP__c) que se va a enviar en la prueba y la plaza original
        Opportunity opportunityCD = new Opportunity(
            AccountId=acctResidenteCD.Id,
            IdExternoSAP__c='999999999',
            Name='Baldomero Dominguez',
            StageName='Cerrada - Éxito',
            ResidenciaIngreso__c = acctResidencia.Id,
            CloseDate=date.parse('01/01/2018'),
            FechaIngreso__c = Date.today(),
            TipoPlaza__c = 'P',
            ResidenciaPreferencia__c = acctResidencia.Id,
            RealSAP__c = true,
            MotivoIngreso__c = 'Psicogeriatría',
            DetalleMotivoIngreso__c = 'Autolisis'
        );
        insert opportunityCD;
        opportunityCD.IdExternoSAP__c='999999999';
        update opportunityCD;
        
        OpportunityContactRole ocr1 = new OpportunityContactRole();
			
		ocr1.ContactId = contactCD.Id;
		ocr1.OpportunityId = opportunityCD.Id;
		ocr1.IsPrimary = FALSE;
		ocr1.Role = 'Residente';
		insert ocr1;     

    }

    /**
    @description    Método para lanzar la llamada
    @param          
    @return         
     */
    @isTest static void test() {

        Test.startTest();
            WSReajustarOcupacion.PayloadIn payload;
            payload = new WSReajustarOcupacion.PayloadIn();

            WSReajustarOcupacion.PayloadOut payloadOut;
            payloadOut = new WSReajustarOcupacion.PayloadOut();

            map<String, String> mPlazas = new map<String,String>();
            map<String, map<String, String>> mEpisodioPlazas = new map<String, map<String, String>>();

            mPlazas.put('Residencia','0201019A');
            mPlazas.put('Lunes','01CDP011M');
            mPlazas.put('Martes','');
            mPlazas.put('Miercoles','');
            mPlazas.put('Jueves','');
            mPlazas.put('Viernes','');
            mPlazas.put('Sabado','');
            mPlazas.put('Domingo','');

            mEpisodioPlazas.put('88888888', mPlazas);

            payload.Centro = '0201';
            payload.Episodios = mEpisodioPlazas;

            payloadOut = WSReajustarOcupacion.WSReajustarOcupacion(payload);
        Test.stopTest();
    }

}