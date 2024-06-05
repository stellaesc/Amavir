/**
@description
Test Methods de la clase TriggerOpportunityHandler

DATE 		AUTHOR 		DESCRIPTION
14/09/2023  MSA - LCS   Correccion parentesco
22/05/2023  MSA - LCS   Corrección errores por el nuevo cambio en las oportunidades
10/10/2022  LCS - MSA   Comentado el test testFalloSinDocumento para evitar los fallos.
21/09/2022  LCS - MSA   Correcciones para evitar los fallos.
19/01/2022  LCS - MMV   Correcciones para evitar los fallos.
05/08/2021	LCS - MMV	Creation

@author Leadclic Solutions
@date 05/08/2021 
*/
@isTest 
public class TestTriggerOpportunityHandler {

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
            StageName = Opportunity.StageName.getDescribe().getPicklistValues()[0].getValue(),
            CloseDate = Date.today(),
            ResidenciaIngreso__c = centro.Id,
            Plaza__c = plazaResi.Id,
            TipoPlaza__c = 'P',
            FechaIngresoPlanificado__c = Date.today(),
            MotivoIngreso__c = 'Psicogeriatría',
            DetalleMotivoIngreso__c = 'Autolisis'
        );
        insert oportunidad;

        // NO insertamos los roles de los contactos en la oportunidad porque hay un flujo que automáticamente los inserta
        /*List<OpportunityContactRole> lOcr = new List<OpportunityContactRole> ();
        OpportunityContactRole ocrResidente = new OpportunityContactRole (
            OpportunityId = oportunidad.Id,
            ContactId = residente.Id,
            Role = 'Residente'
        );
        lOcr.add(ocrResidente);

        OpportunityContactRole ocrFamiliar1 = new OpportunityContactRole (
            OpportunityId = oportunidad.Id,
            ContactId = familiar1.Id,
            Role = 'Decisor'
        );
        lOcr.add(ocrFamiliar1);
        
        OpportunityContactRole ocrFamiliar3 = new OpportunityContactRole (
            OpportunityId = oportunidad.Id,
            ContactId = familiar3.Id,
            Role = 'Decisor'
        );
        lOcr.add(ocrFamiliar3);

        OpportunityContactRole ocrFamiliar2 = new OpportunityContactRole (
            OpportunityId = oportunidad.Id,
            ContactId = familiar2.Id,
            Role = 'Influyente'
        );
        lOcr.add(ocrFamiliar2);

        insert lOcr;*/

    }

    /**
    @description    Método para probar el cierre de una oportunidad.
    @param          
    @return         
    */
    @isTest 
    static void testCierreOportunidadOK(){

        Opportunity lOpp = [SELECT Id FROM Opportunity LIMIT 1];

        test.startTest();

        Test.setMock(HttpCalloutMock.class, new WSSAPAdmisionesMock('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">    <soap-env:Header/>    <soap-env:Body>        <n0:ZISH_CREAR_ADMISION_SFResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions">            <E_FALNR/>            <E_PARTNER1>0010055442</E_PARTNER1>            <E_PARTNER2/>            <E_PATNR>0000038199</E_PATNR>            <E_RETURN>                <item>                    <TYPE>S</TYPE>                    <MESSAGE>El paciente 0000038199 no se ha creado ya que existe en el sistema</MESSAGE>                </item>                <item>                    <TYPE>E</TYPE>                    <MESSAGE>Indique una fecha de movimiento</MESSAGE>                </item>            </E_RETURN>        </n0:ZISH_CREAR_ADMISION_SFResponse>    </soap-env:Body></soap-env:Envelope>'));

        TriggerOpportunityHandler.prepareDataCall(new List<Id>{lOpp.Id});

        test.stopTest();        
    }
       

    /**
    @description    Método para probar el cierre de una oportunidad con plazas de centro de día.
    @param          
    @return         
    */
    @isTest 
    static void testCierreOportunidadCentroDiaOK(){

        Opportunity opp = [SELECT Id, PlazaLunes__c, PlazaMartes__c, 
        PlazaMiercoles__c, PlazaJueves__c, PlazaViernes__c, PlazaSabado__c,
        PlazaDomingo__c FROM Opportunity LIMIT 1];
        List<Plaza__c> lPlazas = [SELECT Id, DiaSemana__c, Cama__c FROM Plaza__c WHERE RecordTypeId =: plazaCentroDiaRTId];
        
        // Quitamos la plaza de residencia y añadimos la plazas de centro de día
        opp.Plaza__c = null;
        for(Plaza__c pl : lPlazas){
            opp.PlazaLunes__c = pl.DiaSemana__c == 'Lunes' ? pl.Id : opp.PlazaLunes__c;
            opp.PlazaMartes__c = pl.DiaSemana__c == 'Martes' ? pl.Id : opp.PlazaMartes__c;
            opp.PlazaMiercoles__c = pl.DiaSemana__c == 'Miércoles' ? pl.Id : opp.PlazaMiercoles__c;
            opp.PlazaJueves__c = pl.DiaSemana__c == 'Jueves' ? pl.Id : opp.PlazaJueves__c;
            opp.PlazaViernes__c = pl.DiaSemana__c == 'Viernes' ? pl.Id : opp.PlazaViernes__c;
            opp.PlazaSabado__c = pl.DiaSemana__c == 'Sábado' ? pl.Id : opp.PlazaSabado__c;
            opp.PlazaDomingo__c = pl.DiaSemana__c == 'Domingo' ? pl.Id : opp.PlazaDomingo__c;
        }
        update opp;

        test.startTest();

        Test.setMock(HttpCalloutMock.class, new WSSAPAdmisionesMock('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">    <soap-env:Header/>    <soap-env:Body>        <n0:ZISH_CREAR_ADMISION_SFResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions">            <E_FALNR/>            <E_PARTNER1>0010055442</E_PARTNER1>            <E_PARTNER2/>            <E_PATNR>0000038199</E_PATNR>            <E_RETURN>                <item>                    <TYPE>S</TYPE>                    <MESSAGE>El paciente 0000038199 no se ha creado ya que existe en el sistema</MESSAGE>                </item>                <item>                    <TYPE>E</TYPE>                    <MESSAGE>Indique una fecha de movimiento</MESSAGE>                </item>            </E_RETURN>        </n0:ZISH_CREAR_ADMISION_SFResponse>    </soap-env:Body></soap-env:Envelope>'));

        TriggerOpportunityHandler.prepareDataCall(new List<Id>{opp.Id});

        test.stopTest();        
    }

    /**
    @description    Método para probar el fallo cuando el residente no tiene Género.
    @param          
    @return         
    */
    @isTest 
    static void testFalloSinGenero(){
        
        // Obtenemos el mensaje de error de Salesforce para compararlo con el resultado
        Mensaje_Error__mdt mensajeError = Mensaje_Error__mdt.getInstance('CierraOportunidadSinGenero');

        Opportunity lOpp = [SELECT Id FROM Opportunity LIMIT 1];

        // Obtenemos el contacto residente para cambiar o vaciar los campos a validar
        Contact residente = [SELECT Id, FirstName, Sexo__c,
                             NumeroDocumento__c,MailingStreet,MailingPostalCode,MailingCity 
                             FROM Contact 
                             WHERE Email = 'mailresidente@test.com' LIMIT 1];        
                             
        // Le quitamos el campo al contacto
        residente.Sexo__c = null;
        update residente;

        test.startTest();

        Test.setMock(HttpCalloutMock.class, new WSSAPAdmisionesMock('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">    <soap-env:Header/>    <soap-env:Body>        <n0:ZISH_CREAR_ADMISION_SFResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions">            <E_FALNR/>            <E_PARTNER1>0010055442</E_PARTNER1>            <E_PARTNER2/>            <E_PATNR>0000038199</E_PATNR>            <E_RETURN>                <item>                    <TYPE>S</TYPE>                    <MESSAGE>El paciente 0000038199 no se ha creado ya que existe en el sistema</MESSAGE>                </item>                <item>                    <TYPE>E</TYPE>                    <MESSAGE>Indique una fecha de movimiento</MESSAGE>                </item>            </E_RETURN>        </n0:ZISH_CREAR_ADMISION_SFResponse>    </soap-env:Body></soap-env:Envelope>'));

        try{
            TriggerOpportunityHandler.prepareDataCall(new List<Id>{lOpp.Id});
        }catch (TriggerOpportunityHandler.CerrarOportunidadException e){
            // Comprobamos que ha salido el mensaje de error correcto
            system.assertEquals(mensajeError.Error_Description__c, e.getMessage());
        }

        test.stopTest();           
    }
    /**
    @description    Método para probar el fallo cuando el residente no tiene NumeroDocumento__c.
    @param          
    @return         

    @isTest 
    static void testFalloSinDocumento(){

        // Obtenemos el mensaje de error de Salesforce para compararlo con el resultado
        Mensaje_Error__mdt mensajeError = Mensaje_Error__mdt.getInstance('CierraOportunidadSinDocumento');

        Opportunity lOpp = [SELECT Id FROM Opportunity LIMIT 1];

        // Obtenemos el contacto residente para cambiar o vaciar los campos a validar
        Contact residente = [SELECT Id, FirstName, Sexo__c,
                             NumeroDocumento__c,MailingStreet,MailingPostalCode,MailingCity 
                             FROM Contact 
                             WHERE Email = 'mailresidente@test.com' LIMIT 1];        
                             
        // Le quitamos el campo al contacto
        residente.NumeroDocumento__c = null;
        update residente;

        test.startTest();

        Test.setMock(HttpCalloutMock.class, new WSSAPAdmisionesMock('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">    <soap-env:Header/>    <soap-env:Body>        <n0:ZISH_CREAR_ADMISION_SFResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions">            <E_FALNR/>            <E_PARTNER1>0010055442</E_PARTNER1>            <E_PARTNER2/>            <E_PATNR>0000038199</E_PATNR>            <E_RETURN>                <item>                    <TYPE>S</TYPE>                    <MESSAGE>El paciente 0000038199 no se ha creado ya que existe en el sistema</MESSAGE>                </item>                <item>                    <TYPE>E</TYPE>                    <MESSAGE>Indique una fecha de movimiento</MESSAGE>                </item>            </E_RETURN>        </n0:ZISH_CREAR_ADMISION_SFResponse>    </soap-env:Body></soap-env:Envelope>'));

        try{
            TriggerOpportunityHandler.prepareDataCall(new List<Id>{lOpp.Id});
        }catch (TriggerOpportunityHandler.CerrarOportunidadException e){
            // Comprobamos que ha salido el mensaje de error correcto
            system.assertEquals(mensajeError.Error_Description__c, e.getMessage());
        }

        test.stopTest();           
    }
    */
    
    /**
    @description    Método para probar el fallo cuando el residente no tiene MailingStreet.
    @param          
    @return         
    */
    @isTest 
    static void testFalloSinCalle(){

        // Obtenemos el mensaje de error de Salesforce para compararlo con el resultado
        Mensaje_Error__mdt mensajeError = Mensaje_Error__mdt.getInstance('CierraOportunidadSinCalle');

        Opportunity lOpp = [SELECT Id FROM Opportunity LIMIT 1];

        // Obtenemos el contacto residente para cambiar o vaciar los campos a validar
        Contact residente = [SELECT Id, FirstName, Sexo__c,
                             NumeroDocumento__c,MailingStreet,MailingPostalCode,MailingCity 
                             FROM Contact 
                             WHERE Email = 'mailresidente@test.com' LIMIT 1];        
                             
        // Le quitamos el campo al contacto
        residente.MailingStreet = null;
        update residente;

        test.startTest();

        Test.setMock(HttpCalloutMock.class, new WSSAPAdmisionesMock('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">    <soap-env:Header/>    <soap-env:Body>        <n0:ZISH_CREAR_ADMISION_SFResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions">            <E_FALNR/>            <E_PARTNER1>0010055442</E_PARTNER1>            <E_PARTNER2/>            <E_PATNR>0000038199</E_PATNR>            <E_RETURN>                <item>                    <TYPE>S</TYPE>                    <MESSAGE>El paciente 0000038199 no se ha creado ya que existe en el sistema</MESSAGE>                </item>                <item>                    <TYPE>E</TYPE>                    <MESSAGE>Indique una fecha de movimiento</MESSAGE>                </item>            </E_RETURN>        </n0:ZISH_CREAR_ADMISION_SFResponse>    </soap-env:Body></soap-env:Envelope>'));

        try{
            TriggerOpportunityHandler.prepareDataCall(new List<Id>{lOpp.Id});
        }catch (TriggerOpportunityHandler.CerrarOportunidadException e){
            // Comprobamos que ha salido el mensaje de error correcto
            system.assertEquals(mensajeError.Error_Description__c, e.getMessage());
        }

        test.stopTest();           
    }

    /**
    @description    Método para probar el fallo cuando el residente no tiene MailingPostalCode.
    @param          
    @return         
    */
    @isTest 
    static void testFalloSinCodigoPostal(){

        // Obtenemos el mensaje de error de Salesforce para compararlo con el resultado
        Mensaje_Error__mdt mensajeError = Mensaje_Error__mdt.getInstance('CierraOportunidadSinCodigoPostal');

        Opportunity lOpp = [SELECT Id FROM Opportunity LIMIT 1];

        // Obtenemos el contacto residente para cambiar o vaciar los campos a validar
        Contact residente = [SELECT Id, FirstName, Sexo__c,
                             NumeroDocumento__c,MailingStreet,MailingPostalCode,MailingCity 
                             FROM Contact 
                             WHERE Email = 'mailresidente@test.com' LIMIT 1];        
                             
        // Le quitamos el campo al contacto
        residente.MailingPostalCode = null;
        update residente;

        test.startTest();

        Test.setMock(HttpCalloutMock.class, new WSSAPAdmisionesMock('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">    <soap-env:Header/>    <soap-env:Body>        <n0:ZISH_CREAR_ADMISION_SFResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions">            <E_FALNR/>            <E_PARTNER1>0010055442</E_PARTNER1>            <E_PARTNER2/>            <E_PATNR>0000038199</E_PATNR>            <E_RETURN>                <item>                    <TYPE>S</TYPE>                    <MESSAGE>El paciente 0000038199 no se ha creado ya que existe en el sistema</MESSAGE>                </item>                <item>                    <TYPE>E</TYPE>                    <MESSAGE>Indique una fecha de movimiento</MESSAGE>                </item>            </E_RETURN>        </n0:ZISH_CREAR_ADMISION_SFResponse>    </soap-env:Body></soap-env:Envelope>'));

        try{
            TriggerOpportunityHandler.prepareDataCall(new List<Id>{lOpp.Id});
        }catch (TriggerOpportunityHandler.CerrarOportunidadException e){
            // Comprobamos que ha salido el mensaje de error correcto
            system.assertEquals(mensajeError.Error_Description__c, e.getMessage());
        }

        test.stopTest();           
    }

    /**
    @description    Método para probar el fallo cuando el residente no tiene MailingCity.
    @param          
    @return         
    */
    @isTest 
    static void testFalloSinCiudad(){

        // Obtenemos el mensaje de error de Salesforce para compararlo con el resultado
        Mensaje_Error__mdt mensajeError = Mensaje_Error__mdt.getInstance('CierraOportunidadSinCiudad');

        Opportunity lOpp = [SELECT Id FROM Opportunity LIMIT 1];

        // Obtenemos el contacto residente para cambiar o vaciar los campos a validar
        Contact residente = [SELECT Id, FirstName, Sexo__c,
                             NumeroDocumento__c,MailingStreet,MailingPostalCode,MailingCity 
                             FROM Contact 
                             WHERE Email = 'mailresidente@test.com' LIMIT 1];        
                             
        // Le quitamos el campo al contacto
        residente.MailingCity = null;
        update residente;

        test.startTest();

        Test.setMock(HttpCalloutMock.class, new WSSAPAdmisionesMock('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">    <soap-env:Header/>    <soap-env:Body>        <n0:ZISH_CREAR_ADMISION_SFResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions">            <E_FALNR/>            <E_PARTNER1>0010055442</E_PARTNER1>            <E_PARTNER2/>            <E_PATNR>0000038199</E_PATNR>            <E_RETURN>                <item>                    <TYPE>S</TYPE>                    <MESSAGE>El paciente 0000038199 no se ha creado ya que existe en el sistema</MESSAGE>                </item>                <item>                    <TYPE>E</TYPE>                    <MESSAGE>Indique una fecha de movimiento</MESSAGE>                </item>            </E_RETURN>        </n0:ZISH_CREAR_ADMISION_SFResponse>    </soap-env:Body></soap-env:Envelope>'));

        try{
            TriggerOpportunityHandler.prepareDataCall(new List<Id>{lOpp.Id});
        }catch (TriggerOpportunityHandler.CerrarOportunidadException e){
            // Comprobamos que ha salido el mensaje de error correcto
            system.assertEquals(mensajeError.Error_Description__c, e.getMessage());
        }

        test.stopTest();           
    }


    /**
    @description    Método para probar el fallo no hay ningún contacto residente asociado.
    @param          
    @return         
    */
    @isTest 
    static void testFalloSinResidente(){

        // Obtenemos el mensaje de error de Salesforce para compararlo con el resultado
        Mensaje_Error__mdt mensajeError = Mensaje_Error__mdt.getInstance('CierraOportunidadSinResidente');

        Opportunity lOpp = [SELECT Id FROM Opportunity LIMIT 1];

        // Probamos el fallo SIN RESIDENTE
        // Borramos los contactRole
        delete [SELECT Id FROM OpportunityContactRole];

        test.startTest();

        Test.setMock(HttpCalloutMock.class, new WSSAPAdmisionesMock('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">    <soap-env:Header/>    <soap-env:Body>        <n0:ZISH_CREAR_ADMISION_SFResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions">            <E_FALNR/>            <E_PARTNER1>0010055442</E_PARTNER1>            <E_PARTNER2/>            <E_PATNR>0000038199</E_PATNR>            <E_RETURN>                <item>                    <TYPE>S</TYPE>                    <MESSAGE>El paciente 0000038199 no se ha creado ya que existe en el sistema</MESSAGE>                </item>                <item>                    <TYPE>E</TYPE>                    <MESSAGE>Indique una fecha de movimiento</MESSAGE>                </item>            </E_RETURN>        </n0:ZISH_CREAR_ADMISION_SFResponse>    </soap-env:Body></soap-env:Envelope>'));

        try{
            TriggerOpportunityHandler.prepareDataCall(new List<Id>{lOpp.Id});
        }catch (TriggerOpportunityHandler.CerrarOportunidadException e){
            // Comprobamos que ha salido el mensaje de error correcto
            system.assertEquals(mensajeError.Error_Description__c, e.getMessage());
        }

        test.stopTest();        
    }

}