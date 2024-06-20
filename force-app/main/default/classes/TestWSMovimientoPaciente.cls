/**
@description
<pre>
Clase que se encarga de realizar el Testing de la clase WSMovimientoPaciente.<br/>

FECHA       AUTOR   	    DESCRIPCION<br/>
19/07/2021	RF Oliveira     Creado
22/07/2021  RF Oliveira     Se modifica para que acepte un solo registro en lugar de un array
30/08/2021  MMV - LCS       Cambio para añadir los Contact Roles
28/09/2021  ARM - LCS       Cambio para añadir las plazas de los centros de dia
19/01/2022  MMV - LCS       Correcciones para pasar los test
25/01/2022  MMV - LCS       Correción para incorporar el tipo de registro de las plazas
21/09/2022  MSA - LCS       Añadido OpportunityContactRole que relaciona contactos y oportunidades.
22/05/2023  MSA - LCS       Corrección de las clases test.
24/07/2023  MSA - LCS       Corrección de las clases test.
16/01/2024  MSA - LCS	    Corrección por la capacidad de clonar oportunidades.
14/06/2024  MSA - LCS       Corrección por cambio en VR.
</pre>
@author Leadclic Solutions
@date 19/07/2021
*/
@isTest
public with sharing class TestWSMovimientoPaciente {

    @testSetup static void setup() {

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
        Account acctResidencia = new Account(Name='CuentaResidenciaPrueba', RecordTypeId=rtCentroResidenciaId.Id);
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
    @description    Método para probar un cambio de plaza y categoría.
    @param          
    @return         
     */
    @isTest static void testCambioPlazaYCategoriaOK() {
        
        Test.startTest();
            WSMovimientoPaciente.PayloadIn payload;
            payload = new WSMovimientoPaciente.PayloadIn();
            payload.IdResidenteSAP = '88888888';
            payload.Einri = '0201';
            payload.OrgOrigen = '0201001A';
            payload.OrgDestino = '0201019A';
            payload.CategoriaOrigen = 'P';
            payload.CategoriaDestino = 'C';
            payload.IdEpisodioSAP = '999999999';
            WSMovimientoPaciente.WSMovimientoPaciente(payload);
        Test.stopTest();
    }

        /**
    @description    Método para probar un cambio de plaza
    @param          
    @return         
     */
    @isTest static void testCambioPlazaOK() {
        
        Test.startTest();
            WSMovimientoPaciente.PayloadIn payload;
            payload = new WSMovimientoPaciente.PayloadIn();
            payload.IdResidenteSAP = '88888888';
            payload.Einri = '0201';
            payload.OrgOrigen = '0201001A';
            payload.OrgDestino = '0201019A';
            payload.CategoriaDestino = 'C';
            payload.Causaalta='01';
            payload.IdEpisodioSAP = '999999999';
            WSMovimientoPaciente.WSMovimientoPaciente(payload);            
        Test.stopTest();            
    }

    /**
    @description    Método para probar un cambio de plaza
    @param          
    @return         
     */
    @isTest static void testCambioPlazaSinCategoriaDestinoOK() {
        
        Test.startTest();
            WSMovimientoPaciente.PayloadIn payload;
            payload = new WSMovimientoPaciente.PayloadIn();
            payload.IdResidenteSAP = '88888888';
            payload.Einri = '0201';
            payload.OrgOrigen = '0201001A';
            payload.OrgDestino = '0201019A';
            //payload.CategoriaDestino = 'C';
            payload.IdEpisodioSAP = '999999999';
            WSMovimientoPaciente.WSMovimientoPaciente(payload);            
        Test.stopTest();

        // Llamamos de nuevo para verificar que la plaza ya está ocupada
        WSMovimientoPaciente.WSMovimientoPaciente(payload);            
    }

    /**
    @description    Método para probar un cambio de categoría de un residente.
    @param          
    @return         
     */
    @isTest static void testCambioCategoriaOK() {        

        Test.startTest();
            WSMovimientoPaciente.PayloadIn payload;
            payload = new WSMovimientoPaciente.PayloadIn();
            payload.IdResidenteSAP = '88888888';
            payload.Einri = '0201';
            payload.OrgDestino = '0201019A';
            payload.CategoriaOrigen = 'P';
            payload.CategoriaDestino = 'C';
            payload.IdEpisodioSAP = '999999999';
            WSMovimientoPaciente.WSMovimientoPaciente(payload);
        Test.stopTest();

    }

    //Desocupación de plaza
    @isTest static void testDesocupacionPlazaOK() {
        
        Test.startTest();
            WSMovimientoPaciente.PayloadIn payload;
            payload = new WSMovimientoPaciente.PayloadIn();
            payload.IdResidenteSAP = '88888888';
            payload.Einri = '0201';
            payload.OrgOrigen = '0201019A';
            payload.IdEpisodioSAP = '999999999';
            WSMovimientoPaciente.WSMovimientoPaciente(payload);
        Test.stopTest();

    }
    

    //Desocupación de plaza centro de Dia OK
    @isTest static void testDesocupacionPlazaCDOK() {
        
        Test.startTest();
        WSMovimientoPaciente.PayloadIn payload;
        WSMovimientoPaciente.plazasCD plazasOrigen = new WSMovimientoPaciente.plazasCD();
        plazasOrigen.Lunes='01CDP011';
        plazasOrigen.Martes='01CDP011';
        plazasOrigen.Miercoles='01CDP011';
        plazasOrigen.Jueves='01CDP011';
        plazasOrigen.Viernes='01CDP011';
        plazasOrigen.Sabado='01CDP011';
        plazasOrigen.Domingo='01CDP011';

        WSMovimientoPaciente.plazasCD plazasDestino = new WSMovimientoPaciente.plazasCD();
        plazasDestino.Lunes='';
        plazasDestino.Martes='';
        plazasDestino.Miercoles='';
        plazasDestino.Jueves='';
        plazasDestino.Viernes='';
        plazasDestino.Sabado='';
        plazasDestino.Domingo='';

        payload = new WSMovimientoPaciente.PayloadIn();
        payload.PlazasCDOrigen = plazasOrigen;
        payload.PlazasCDDestino = plazasDestino;

        payload.IdResidenteSAP = '999999999';
        payload.Einri = '0201';
        payload.IdEpisodioSAP = '999999999';
        WSMovimientoPaciente.WSMovimientoPaciente(payload);
        Test.stopTest();
            
        // Comprobaciones de los resultados
        Opportunity opp = [SELECT Id, PlazaLunes__c FROM Opportunity WHERE IdExternoSAP__c='999999999' LIMIT 1];
        Plaza__c plaza = [SELECT Id,PlazaOcupada__c FROM Plaza__c WHERE Cama__c =:'01CDP011L' LIMIT 1];
        System.assertEquals(null, opp.PlazaLunes__c); // El campo de la oportunidad está vacío
        System.assertEquals(false,plaza.PlazaOcupada__c); // La plaza del Lunes está desocupada

    }

    // Ocupación de plaza centro de Dia OK
    @isTest static void testOcupacionPlazaCDOK() {   
        
        Test.startTest();
            WSMovimientoPaciente.PayloadIn payload;
            payload = new WSMovimientoPaciente.PayloadIn();
            WSMovimientoPaciente.plazasCD plazasOrigen  = new WSMovimientoPaciente.plazasCD();
            plazasOrigen.Lunes='';
            plazasOrigen.Martes='';
            plazasOrigen.Miercoles='';
            plazasOrigen.Jueves='';
            plazasOrigen.Viernes='';
            plazasOrigen.Sabado='';
            plazasOrigen.Domingo='';

            WSMovimientoPaciente.plazasCD plazasDestino  = new WSMovimientoPaciente.plazasCD();
            plazasDestino.Lunes='';
            plazasDestino.Martes='01CDP011';
            plazasDestino.Miercoles='01CDP011';
            plazasDestino.Jueves='01CDP011';
            plazasDestino.Viernes='01CDP011';
            plazasDestino.Sabado='01CDP011';
            plazasDestino.Domingo='01CDP011';

            payload.PlazasCDOrigen = plazasOrigen;
            payload.PlazasCDDestino = plazasDestino;
            payload.IdResidenteSAP = '999999999';
            payload.Einri = '0201';
            payload.IdEpisodioSAP = '999999999';
            WSMovimientoPaciente.WSMovimientoPaciente(payload);
        Test.stopTest();   
        
        // Comprobaciones de los resultados
        Opportunity opp = [SELECT Id, PlazaMartes__c FROM Opportunity WHERE IdExternoSAP__c='999999999' LIMIT 1];  
        Plaza__c plaza = [SELECT Id,PlazaOcupada__c FROM Plaza__c WHERE Cama__c =:'01CDP011M' LIMIT 1];
        System.assertEquals(plaza.Id, opp.PlazaMartes__c); // El campo de la oportunida está relleno con la plaza
        System.assertEquals(true, plaza.PlazaOcupada__c);  // La plaza del Martes está ocupada


        // Volvemos a llamar para que todas las plazas estén ocupadas
        payload.PlazasCDDestino.Lunes = '01CDP011';
        WSMovimientoPaciente.WSMovimientoPaciente(payload);
    }
    
    // Ocupaciones de plazas centro de Dia OK
    @isTest static void testCambioPlazasCDOK() {     
       
        
        Test.startTest();
            WSMovimientoPaciente.PayloadIn payload;
            payload = new WSMovimientoPaciente.PayloadIn();
            WSMovimientoPaciente.plazasCD plazasOrigen  = new WSMovimientoPaciente.plazasCD();
            plazasOrigen.Lunes='01CDP011';
            plazasOrigen.Martes='01CDP011';
            plazasOrigen.Miercoles='';
            plazasOrigen.Jueves='';
            plazasOrigen.Viernes='';
            plazasOrigen.Sabado='01CDP011';
            plazasOrigen.Domingo='';

            WSMovimientoPaciente.plazasCD plazasDestino  = new WSMovimientoPaciente.plazasCD();
            plazasDestino.Lunes='01CDP012';
            plazasDestino.Martes='01CDP011';
            plazasDestino.Miercoles='01CDP011';
            plazasDestino.Jueves='';
            plazasDestino.Viernes='';
            plazasDestino.Sabado='';
            plazasDestino.Domingo='01CDP011';

            payload.PlazasCDOrigen = plazasOrigen;
            payload.PlazasCDDestino = plazasDestino;
            payload.IdResidenteSAP = '999999999';
            payload.Einri = '0201';
            payload.IdEpisodioSAP = '999999999';
            WSMovimientoPaciente.WSMovimientoPaciente(payload);
        Test.stopTest();
        
        // Comprobación de los resultados
        Opportunity opp = [SELECT Id, PlazaLunes__c,PlazaMartes__c,PlazaSabado__c,PlazaMiercoles__c,PlazaDomingo__c FROM Opportunity WHERE IdExternoSAP__c='999999999' LIMIT 1];
        
        Plaza__c plazaLunesOrigen = [SELECT Id,PlazaOcupada__c FROM Plaza__c WHERE Cama__c =:'01CDP011L' LIMIT 1];
        System.assertEquals(false, plazaLunesOrigen.PlazaOcupada__c);        
        
        Plaza__c plazaMartes = [SELECT Id,PlazaOcupada__c FROM Plaza__c WHERE Cama__c =:'01CDP011M' LIMIT 1];
        System.assertEquals(true, plazaMartes.PlazaOcupada__c);
        System.assertEquals(plazaMartes.Id, opp.PlazaMartes__c);
        
        Plaza__c plazaSabado = [SELECT Id,PlazaOcupada__c FROM Plaza__c WHERE Cama__c =:'01CDP011S' LIMIT 1];
        System.assertEquals(false, plazaSabado.PlazaOcupada__c);
        System.assertEquals(null, opp.PlazaSabado__c);

        Plaza__c plazaLunesDestino = [SELECT Id,PlazaOcupada__c FROM Plaza__c WHERE Cama__c =:'01CDP012L' LIMIT 1];
        System.assertEquals(true, plazaLunesDestino.PlazaOcupada__c);
        System.assertEquals(plazaLunesDestino.Id, opp.PlazaLunes__c);
        
        Plaza__c plazaMiercoles = [SELECT Id,PlazaOcupada__c FROM Plaza__c WHERE Cama__c =:'01CDP011X' LIMIT 1];
        System.assertEquals(true, plazaMiercoles.PlazaOcupada__c);
        System.assertEquals(opp.PlazaMiercoles__c, plazaMiercoles.Id);
    
        Plaza__c plazaDomingo = [SELECT Id,PlazaOcupada__c FROM Plaza__c WHERE Cama__c =:'01CDP011D' LIMIT 1];
        System.assertEquals(true, plazaDomingo.PlazaOcupada__c);
        System.assertEquals(opp.PlazaDomingo__c, plazaDomingo.Id);
    }

    
   
    //Faltan campos obligatorios
    @isTest static void testFaltanCamposObligatorios() {
        Test.startTest();
            WSMovimientoPaciente.PayloadIn payload;
            payload = new WSMovimientoPaciente.PayloadIn();
            payload.Einri = '0201';
            payload.IdResidenteSAP = null;
            WSMovimientoPaciente.WSMovimientoPaciente(payload);

            payload = new WSMovimientoPaciente.PayloadIn();            
            payload.IdResidenteSAP = '1234';
            payload.Einri = null;
            payload.IdEpisodioSAP = '999999999';
            WSMovimientoPaciente.WSMovimientoPaciente(payload);            
        Test.stopTest();

    }

    //Nueva plaza ocupada
    @isTest static void testNuevaPlazaOcupada() {        

        Test.startTest();
            WSMovimientoPaciente.PayloadIn payload;
            payload = new WSMovimientoPaciente.PayloadIn();
            payload.IdResidenteSAP = '88888888';
            payload.Einri = '0201';
            payload.OrgOrigen = '0201001A';
            payload.OrgDestino = '0201019A';
            payload.CategoriaOrigen = 'P';
            payload.CategoriaDestino = 'P';
            payload.IdEpisodioSAP = '999999999';
            WSMovimientoPaciente.WSMovimientoPaciente(payload);
        Test.stopTest();
    }

    //residente no existe
    @isTest static void testResidenteOportunidadNoExiste() {

        Account accFamilia = [SELECT Id FROM Account WHERE Name = 'CuentaResidentePrueba'];
        // Tipo de registro de contacto Residente
        RecordType rtid = [SELECT Id FROM RecordType WHERE DeveloperName ='PotencialResidente' and SobjectType = 'Contact'];


        Contact residenteSinOpp = new Contact(
            RecordTypeId=rtid.Id,
            IdExternoSAP__c='sinOpp',
            AccountId=accFamilia.Id,
            FirstName='ResidentePrueba3',
            LastName='ApellidoPrueba3',
            MailingStreet='Ancha3',
            MailingPostalCode='28005',
            MailingCity='Madrid',
            MobilePhone='945588037',
            Phone='916983266',
            Email='testmail3@test.com'
        );
        insert residenteSinOpp;
        
        Test.startTest();
            WSMovimientoPaciente.PayloadIn payload;
            payload = new WSMovimientoPaciente.PayloadIn();
            payload.IdResidenteSAP = 'noexiste';
            payload.Einri = '0201';
            payload.OrgOrigen = '0201001A';
            payload.IdEpisodioSAP = '999999999';
            WSMovimientoPaciente.WSMovimientoPaciente(payload);

            // Llamamos con el residente sin Opp
            payload.IdResidenteSAP = 'sinOpp';
            payload.Einri = '0201';
            payload.OrgOrigen = '0201001A';
            payload.IdEpisodioSAP = '999999999';
            WSMovimientoPaciente.WSMovimientoPaciente(payload);
        Test.stopTest();
    }

    //orgOrigen no existe
    @isTest static void testOrgOrigenNoExiste() {             
    
        Test.startTest();
            WSMovimientoPaciente.PayloadIn payload;
            payload = new WSMovimientoPaciente.PayloadIn();
            payload.IdResidenteSAP = '88888888';
            payload.Einri = '0201';
            payload.OrgOrigen = '0000000Z';
            payload.OrgDestino = '0201019A';
            payload.CategoriaDestino = 'C';
            payload.IdEpisodioSAP = '999999999';
            WSMovimientoPaciente.WSMovimientoPaciente(payload);
        Test.stopTest();
    }

    //orgDestino no existe
    @isTest static void testOrgDestinoNoExiste() {
       
        Test.startTest();
            WSMovimientoPaciente.PayloadIn payload;
            payload = new WSMovimientoPaciente.PayloadIn();
            payload.IdResidenteSAP = '88888888';
            payload.Einri = '0201';
            payload.OrgOrigen = '0201019A';
            payload.OrgDestino = '0000000Z';
            payload.CategoriaDestino = 'C';
            payload.IdEpisodioSAP = '999999999';
            WSMovimientoPaciente.WSMovimientoPaciente(payload);
        Test.stopTest();
    }

    @isTest static void altaF() {
       
        User u2 = [SELECT Id from USER WHERE Alias = 'uinte' limit 1];
        System.runAs(u2) {
        Test.startTest();
            WSMovimientoPaciente.PayloadIn payload;
            payload = new WSMovimientoPaciente.PayloadIn();
            payload.IdResidenteSAP = '999999999';
            payload.Einri = '0201';
            payload.OrgOrigen = '0201019A';
            payload.OrgDestino = '';
            payload.CategoriaDestino = '';
            payload.IdEpisodioSAP = '999999999';
            payload.TipoMovimiento = 'A';
            payload.Causaalta = 'F';
            WSMovimientoPaciente.WSMovimientoPaciente(payload);
        Test.stopTest();
        }

        Opportunity opp = [SELECT Id, FechaSalida__c, PlazaMartes__c, PlazaSabado__c,PlazaMiercoles__c,PlazaDomingo__c FROM Opportunity WHERE IdExternoSAP__c='999999999' LIMIT 1];
        contact cont = [SELECT Id, CausaBaja__c FROM Contact WHERE IdExternoSAP__c = '999999999'];
        System.assert(opp.FechaSalida__c != null);
        System.assert(cont.CausaBaja__c == 'Descontento');
    }

    @isTest static void altaH() {
       
        User u2 = [SELECT Id from USER WHERE Alias = 'uinte' limit 1];
        System.runAs(u2) {
        Test.startTest();
            WSMovimientoPaciente.PayloadIn payload;
            payload = new WSMovimientoPaciente.PayloadIn();
            payload.IdResidenteSAP = '999999999';
            payload.Einri = '0201';
            payload.OrgOrigen = '0201019A';
            payload.OrgDestino = '';
            payload.CategoriaDestino = '';
            payload.IdEpisodioSAP = '999999999';
            payload.TipoMovimiento = 'A';
            payload.Causaalta = 'H';
            WSMovimientoPaciente.WSMovimientoPaciente(payload);
        Test.stopTest();
        }

        Opportunity opp = [SELECT Id, FechaSalida__c, PlazaMartes__c, PlazaSabado__c,PlazaMiercoles__c,PlazaDomingo__c FROM Opportunity WHERE IdExternoSAP__c='999999999' LIMIT 1];
        contact cont = [SELECT Id, CausaBaja__c FROM Contact WHERE IdExternoSAP__c = '999999999'];
        System.assert(opp.FechaSalida__c != null);
        System.assert(cont.CausaBaja__c == 'Trasl otro Amav');
    }

    @isTest static void altaI() {
       
        User u2 = [SELECT Id from USER WHERE Alias = 'uinte' limit 1];
        System.runAs(u2) {
        Test.startTest();
            WSMovimientoPaciente.PayloadIn payload;
            payload = new WSMovimientoPaciente.PayloadIn();
            payload.IdResidenteSAP = '999999999';
            payload.Einri = '0201';
            payload.OrgOrigen = '0201019A';
            payload.OrgDestino = '';
            payload.CategoriaDestino = '';
            payload.IdEpisodioSAP = '999999999';
            payload.TipoMovimiento = 'A';
            payload.Causaalta = 'I';
            WSMovimientoPaciente.WSMovimientoPaciente(payload);
        Test.stopTest();
        }

        Opportunity opp = [SELECT Id, FechaSalida__c, PlazaMartes__c, PlazaSabado__c,PlazaMiercoles__c,PlazaDomingo__c FROM Opportunity WHERE IdExternoSAP__c='999999999' LIMIT 1];
        contact cont = [SELECT Id, CausaBaja__c FROM Contact WHERE IdExternoSAP__c = '999999999'];
        System.assert(opp.FechaSalida__c != null);
        System.assert(cont.CausaBaja__c == 'Inadaptación');
    }

    @isTest static void altaJ() {
       
        User u2 = [SELECT Id from USER WHERE Alias = 'uinte' limit 1];
        System.runAs(u2) {
        Test.startTest();
            WSMovimientoPaciente.PayloadIn payload;
            payload = new WSMovimientoPaciente.PayloadIn();
            payload.IdResidenteSAP = '999999999';
            payload.Einri = '0201';
            payload.OrgOrigen = '0201019A';
            payload.OrgDestino = '';
            payload.CategoriaDestino = '';
            payload.IdEpisodioSAP = '999999999';
            payload.TipoMovimiento = 'A';
            payload.Causaalta = 'J';
            WSMovimientoPaciente.WSMovimientoPaciente(payload);
        Test.stopTest();
        }

        Opportunity opp = [SELECT Id, FechaSalida__c, PlazaMartes__c, PlazaSabado__c,PlazaMiercoles__c,PlazaDomingo__c FROM Opportunity WHERE IdExternoSAP__c='999999999' LIMIT 1];
        contact cont = [SELECT Id, CausaBaja__c FROM Contact WHERE IdExternoSAP__c = '999999999'];
        System.assert(opp.FechaSalida__c != null);
        System.assert(cont.CausaBaja__c == 'Hospitalización Larga Duración');
    }

    @isTest static void altaL() {
       
        User u2 = [SELECT Id from USER WHERE Alias = 'uinte' limit 1];
        System.runAs(u2) {
        Test.startTest();
            WSMovimientoPaciente.PayloadIn payload;
            payload = new WSMovimientoPaciente.PayloadIn();
            payload.IdResidenteSAP = '999999999';
            payload.Einri = '0201';
            payload.OrgOrigen = '0201019A';
            payload.OrgDestino = '';
            payload.CategoriaDestino = '';
            payload.IdEpisodioSAP = '999999999';
            payload.TipoMovimiento = 'A';
            payload.Causaalta = 'L';
            WSMovimientoPaciente.WSMovimientoPaciente(payload);
        Test.stopTest();
        }

        Opportunity opp = [SELECT Id, FechaSalida__c, PlazaMartes__c, PlazaSabado__c,PlazaMiercoles__c,PlazaDomingo__c FROM Opportunity WHERE IdExternoSAP__c='999999999' LIMIT 1];
        contact cont = [SELECT Id, CausaBaja__c FROM Contact WHERE IdExternoSAP__c = '999999999'];
        System.assert(opp.FechaSalida__c != null);
        System.assert(cont.CausaBaja__c == 'Concesión Plaza Pública No Amavir');
    }

    @isTest static void altaM() {
       
        User u2 = [SELECT Id from USER WHERE Alias = 'uinte' limit 1];
        System.runAs(u2) {
        Test.startTest();
            WSMovimientoPaciente.PayloadIn payload;
            payload = new WSMovimientoPaciente.PayloadIn();
            payload.IdResidenteSAP = '999999999';
            payload.Einri = '0201';
            payload.OrgOrigen = '0201019A';
            payload.OrgDestino = '';
            payload.CategoriaDestino = '';
            payload.IdEpisodioSAP = '999999999';
            payload.TipoMovimiento = 'A';
            payload.Causaalta = 'M';
            WSMovimientoPaciente.WSMovimientoPaciente(payload);
        Test.stopTest();
        }

        Opportunity opp = [SELECT Id, FechaSalida__c, PlazaMartes__c, PlazaSabado__c,PlazaMiercoles__c,PlazaDomingo__c FROM Opportunity WHERE IdExternoSAP__c='999999999' LIMIT 1];
        contact cont = [SELECT Id, CausaBaja__c FROM Contact WHERE IdExternoSAP__c = '999999999'];
        System.assert(opp.FechaSalida__c != null);
        System.assert(cont.CausaBaja__c == 'Conc. púb Amavir');
    }

    @isTest static void altaO() {
       
        User u2 = [SELECT Id from USER WHERE Alias = 'uinte' limit 1];
        System.runAs(u2) {
        Test.startTest();
            WSMovimientoPaciente.PayloadIn payload;
            payload = new WSMovimientoPaciente.PayloadIn();
            payload.IdResidenteSAP = '999999999';
            payload.Einri = '0201';
            payload.OrgOrigen = '0201019A';
            payload.OrgDestino = '';
            payload.CategoriaDestino = '';
            payload.IdEpisodioSAP = '999999999';
            payload.TipoMovimiento = 'A';
            payload.Causaalta = 'O';
            WSMovimientoPaciente.WSMovimientoPaciente(payload);
        Test.stopTest();
        }

        Opportunity opp = [SELECT Id, FechaSalida__c, PlazaMartes__c, PlazaSabado__c,PlazaMiercoles__c,PlazaDomingo__c FROM Opportunity WHERE IdExternoSAP__c='999999999' LIMIT 1];
        contact cont = [SELECT Id, CausaBaja__c FROM Contact WHERE IdExternoSAP__c = '999999999'];
        System.assert(opp.FechaSalida__c != null);
        System.assert(cont.CausaBaja__c == 'Fin E. Temporal Respiro');
    }

    @isTest static void altaP() {
       
        User u2 = [SELECT Id from USER WHERE Alias = 'uinte' limit 1];
        System.runAs(u2) {
        Test.startTest();
            WSMovimientoPaciente.PayloadIn payload;
            payload = new WSMovimientoPaciente.PayloadIn();
            payload.IdResidenteSAP = '999999999';
            payload.Einri = '0201';
            payload.OrgOrigen = '0201019A';
            payload.OrgDestino = '';
            payload.CategoriaDestino = '';
            payload.IdEpisodioSAP = '999999999';
            payload.TipoMovimiento = 'A';
            payload.Causaalta = 'P';
            WSMovimientoPaciente.WSMovimientoPaciente(payload);
        Test.stopTest();
        }

        Opportunity opp = [SELECT Id, FechaSalida__c, PlazaMartes__c, PlazaSabado__c,PlazaMiercoles__c,PlazaDomingo__c FROM Opportunity WHERE IdExternoSAP__c='999999999' LIMIT 1];
        contact cont = [SELECT Id, CausaBaja__c FROM Contact WHERE IdExternoSAP__c = '999999999'];
        System.assert(opp.FechaSalida__c != null);
        System.assert(cont.CausaBaja__c == 'Fin E. Temporal Rehabilitación');
    }

    @isTest static void altaQ() {
       
        User u2 = [SELECT Id from USER WHERE Alias = 'uinte' limit 1];
        System.runAs(u2) {
        Test.startTest();
            WSMovimientoPaciente.PayloadIn payload;
            payload = new WSMovimientoPaciente.PayloadIn();
            payload.IdResidenteSAP = '999999999';
            payload.Einri = '0201';
            payload.OrgOrigen = '0201019A';
            payload.OrgDestino = '';
            payload.CategoriaDestino = '';
            payload.IdEpisodioSAP = '999999999';
            payload.TipoMovimiento = 'A';
            payload.Causaalta = 'Q';
            WSMovimientoPaciente.WSMovimientoPaciente(payload);
        Test.stopTest();
        }

        Opportunity opp = [SELECT Id, FechaSalida__c, PlazaMartes__c, PlazaSabado__c,PlazaMiercoles__c,PlazaDomingo__c FROM Opportunity WHERE IdExternoSAP__c='999999999' LIMIT 1];
        contact cont = [SELECT Id, CausaBaja__c FROM Contact WHERE IdExternoSAP__c = '999999999'];
        System.assert(opp.FechaSalida__c != null);
        System.assert(cont.CausaBaja__c == 'Trasl Domicilio');
    }

    @isTest static void altaT() {
       
        User u2 = [SELECT Id from USER WHERE Alias = 'uinte' limit 1];
        System.runAs(u2) {
        Test.startTest();
            WSMovimientoPaciente.PayloadIn payload;
            payload = new WSMovimientoPaciente.PayloadIn();
            payload.IdResidenteSAP = '999999999';
            payload.Einri = '0201';
            payload.OrgOrigen = '0201019A';
            payload.OrgDestino = '';
            payload.CategoriaDestino = '';
            payload.IdEpisodioSAP = '999999999';
            payload.TipoMovimiento = 'A';
            payload.Causaalta = 'T';
            WSMovimientoPaciente.WSMovimientoPaciente(payload);
        Test.stopTest();
        }

        Opportunity opp = [SELECT Id, FechaSalida__c, PlazaMartes__c, PlazaSabado__c,PlazaMiercoles__c,PlazaDomingo__c FROM Opportunity WHERE IdExternoSAP__c='999999999' LIMIT 1];
        contact cont = [SELECT Id, CausaBaja__c FROM Contact WHERE IdExternoSAP__c = '999999999'];
        System.assert(opp.FechaSalida__c != null);
        System.assert(cont.CausaBaja__c == 'Exitus Hospital');
    }

    @isTest static void altaU() {
       
        User u2 = [SELECT Id from USER WHERE Alias = 'uinte' limit 1];
        System.runAs(u2) {
        Test.startTest();
            WSMovimientoPaciente.PayloadIn payload;
            payload = new WSMovimientoPaciente.PayloadIn();
            payload.IdResidenteSAP = '999999999';
            payload.Einri = '0201';
            payload.OrgOrigen = '0201019A';
            payload.OrgDestino = '';
            payload.CategoriaDestino = '';
            payload.IdEpisodioSAP = '999999999';
            payload.TipoMovimiento = 'A';
            payload.Causaalta = 'U';
            WSMovimientoPaciente.WSMovimientoPaciente(payload);
        Test.stopTest();
        }

        Opportunity opp = [SELECT Id, FechaSalida__c, PlazaMartes__c, PlazaSabado__c,PlazaMiercoles__c,PlazaDomingo__c FROM Opportunity WHERE IdExternoSAP__c='999999999' LIMIT 1];
        contact cont = [SELECT Id, CausaBaja__c FROM Contact WHERE IdExternoSAP__c = '999999999'];
        System.assert(opp.FechaSalida__c != null);
        System.assert(cont.CausaBaja__c == 'Resid competenc');
    }

    @isTest static void altaV() {
       
        User u2 = [SELECT Id from USER WHERE Alias = 'uinte' limit 1];
        System.runAs(u2) {
        Test.startTest();
            WSMovimientoPaciente.PayloadIn payload;
            payload = new WSMovimientoPaciente.PayloadIn();
            payload.IdResidenteSAP = '999999999';
            payload.Einri = '0201';
            payload.OrgOrigen = '0201019A';
            payload.OrgDestino = '';
            payload.CategoriaDestino = '';
            payload.IdEpisodioSAP = '999999999';
            payload.TipoMovimiento = 'A';
            payload.Causaalta = 'V';
            WSMovimientoPaciente.WSMovimientoPaciente(payload);
        Test.stopTest();
        }

        Opportunity opp = [SELECT Id, FechaSalida__c, PlazaMartes__c, PlazaSabado__c,PlazaMiercoles__c,PlazaDomingo__c FROM Opportunity WHERE IdExternoSAP__c='999999999' LIMIT 1];
        contact cont = [SELECT Id, CausaBaja__c FROM Contact WHERE IdExternoSAP__c = '999999999'];
        System.assert(opp.FechaSalida__c != null);
        System.assert(cont.CausaBaja__c == 'Exitus en Resid');
    }

    @isTest static void altaW() {
       
        User u2 = [SELECT Id from USER WHERE Alias = 'uinte' limit 1];
        System.runAs(u2) {
        Test.startTest();
            WSMovimientoPaciente.PayloadIn payload;
            payload = new WSMovimientoPaciente.PayloadIn();
            payload.IdResidenteSAP = '999999999';
            payload.Einri = '0201';
            payload.OrgOrigen = '0201019A';
            payload.OrgDestino = '';
            payload.CategoriaDestino = '';
            payload.IdEpisodioSAP = '999999999';
            payload.TipoMovimiento = 'A';
            payload.Causaalta = 'W';
            WSMovimientoPaciente.WSMovimientoPaciente(payload);
        Test.stopTest();
        }

        Opportunity opp = [SELECT Id, FechaSalida__c, PlazaMartes__c, PlazaSabado__c,PlazaMiercoles__c,PlazaDomingo__c FROM Opportunity WHERE IdExternoSAP__c='999999999' LIMIT 1];
        contact cont = [SELECT Id, CausaBaja__c FROM Contact WHERE IdExternoSAP__c = '999999999'];
        System.assert(opp.FechaSalida__c != null);
        System.assert(cont.CausaBaja__c == 'Motivos Económicos');
    }

    @isTest static void altaX() {
        User u2 = [SELECT Id from USER WHERE Alias = 'uinte' limit 1];
        System.runAs(u2) {
        Test.startTest();
            WSMovimientoPaciente.PayloadIn payload;
            payload = new WSMovimientoPaciente.PayloadIn();
            payload.IdResidenteSAP = '999999999';
            payload.Einri = '0201';
            payload.OrgOrigen = '0201019A';
            payload.OrgDestino = '';
            payload.CategoriaDestino = '';
            payload.IdEpisodioSAP = '999999999';
            payload.TipoMovimiento = 'A';
            payload.Causaalta = 'X';
            WSMovimientoPaciente.WSMovimientoPaciente(payload);
        Test.stopTest();
        }

        Opportunity opp = [SELECT Id, FechaSalida__c, PlazaMartes__c, PlazaSabado__c,PlazaMiercoles__c,PlazaDomingo__c FROM Opportunity WHERE IdExternoSAP__c='999999999' LIMIT 1];
        contact cont = [SELECT Id, CausaBaja__c FROM Contact WHERE IdExternoSAP__c = '999999999'];
        System.assert(opp.FechaSalida__c != null);
        System.assert(cont.CausaBaja__c == 'Renuncia Volunt');
    }

    @isTest static void altaY() {
       
        User u2 = [SELECT Id from USER WHERE Alias = 'uinte' limit 1];
        System.runAs(u2) {
        Test.startTest();
            WSMovimientoPaciente.PayloadIn payload;
            payload = new WSMovimientoPaciente.PayloadIn();
            payload.IdResidenteSAP = '999999999';
            payload.Einri = '0201';
            payload.OrgOrigen = '0201019A';
            payload.OrgDestino = '';
            payload.CategoriaDestino = '';
            payload.IdEpisodioSAP = '999999999';
            payload.TipoMovimiento = 'A';
            payload.Causaalta = 'Y';
            WSMovimientoPaciente.WSMovimientoPaciente(payload);
        Test.stopTest();
        }

        Opportunity opp = [SELECT Id, FechaSalida__c, PlazaMartes__c, PlazaSabado__c,PlazaMiercoles__c,PlazaDomingo__c FROM Opportunity WHERE IdExternoSAP__c='999999999' LIMIT 1];
        contact cont = [SELECT Id, CausaBaja__c FROM Contact WHERE IdExternoSAP__c = '999999999'];
        System.assert(opp.FechaSalida__c != null);
        System.assert(cont.CausaBaja__c == 'Trasp CD a Resi');
    }

}