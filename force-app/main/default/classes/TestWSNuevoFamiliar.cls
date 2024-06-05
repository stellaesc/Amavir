/**
@description
<pre>
Clase que se encarga de realizar el Testing de la clase WSNuevoFamiliar.<br/>

FECHA       AUTOR   	    DESCRIPCION<br/>
06/07/2021	RF Oliveira     Creado
22/07/2021  RF Oliveira     Se modifica para que acepte un solo registro en lugar de un array
</pre>
@author Leadclic Solutions
@date 06/07/2021
*/
@isTest
public with sharing class TestWSNuevoFamiliar {
    
    /**
    @description    Método para probar una inserción de familiar correcta del servicio.
    @param          
    @return         
     */
    @isTest static void testWSNuevoFamiliarOK() {

        //Insertamos la cuenta a la que se asociará el residente y su familiar
        Account acct = new Account(Name='CuentaPrueba');
        insert acct;

        //Insertamos un nuevo contacto residente al que se le asociará un nuevo familiar
        RecordType rtid = [SELECT Id FROM RecordType WHERE DeveloperName ='PotencialResidente' and SobjectType = 'Contact'];

        Contact contact = new Contact(RecordTypeId=rtid.Id,
                                        AccountId=acct.Id,
                                        IdExternoSAP__c='999999999',
                                        FirstName='ResidentePrueba',
                                        LastName='ApellidoPrueba',
                                        MailingStreet='Ancha',
                                        MailingPostalCode='28005',
                                        MailingCity='Madrid',
                                        MobilePhone='945588032',
                                        Phone='916983265',
                                        Email='testmail@test.com');
        insert contact;

        Test.startTest();

        WSNuevoFamiliar.PayloadIn payload;
            payload = new WSNuevoFamiliar.PayloadIn();
            payload.IdFamiliarSAP = '1234567890';
            payload.IdResidenteSAP = '999999999';
            payload.Nname = 'NombreCont';
            payload.Vname = 'ApellidoCont';
            payload.Street = 'Europa';
            payload.Street2 = 'portal 28';
            payload.HouseNum1 = '1';
            payload.PostCode1 = '28050';
            payload.City1 = 'Madrid';
            payload.TelNumber = '616689365';
            payload.TelNumber1 = '916832784';
            payload.EMail = 'emailPrueba@prueba.com';
            payload.Relsh1 = 'Hermano/a'; //B-Hermano/a, C-Cuñado/a, G-Matrimonio, H-Pareja de hecho, K-Hijo/a, L-Compañero/a, N-Nieto/a, O-Tío/a, P-Padre/Madre, Q-Sobrino/a, R-NUERA, U-Institución, V-Tutor/a, W-Amistad, X-Otros, Y-Yerno
            WSNuevoFamiliar.insertContact(payload);
         Test.stopTest();
    }

    /**
    @description    Método para probar caso de inserción de familiar sin informar todos los campos obligatorios. Se espera un error "10: Faltan campos obligatorios"
    @param          
    @return         
     */
    @isTest static void testWSNuevoFamiliarFaltanCamposObligatorios() {
        
		Test.startTest();
            WSNuevoFamiliar.PayloadIn payload;
            payload = new WSNuevoFamiliar.PayloadIn();
            payload.IdFamiliarSAP = '1234567890';          
            WSNuevoFamiliar.insertContact(payload);
		Test.stopTest();
    }

    /**
    @description    Método para probar caso de inserción de familiar sin exista el residente al que se quiere asociar. Se espera error "1: No existe residente para asociar"
    @param          
    @return         
     */
    @isTest static void testWSNuevoFamiliarNoExisteResidente() {
        
        Test.startTest();

        WSNuevoFamiliar.PayloadIn payload;
            payload = new WSNuevoFamiliar.PayloadIn();
            payload.IdFamiliarSAP = '1234567890';
            payload.IdResidenteSAP = '999999999';
            payload.Nname = 'NombreCont';
            payload.Vname = 'ApellidoCont';
            payload.Street = 'Europa';
            payload.Street2 = 'portal 28';
            payload.HouseNum1 = '1';
            payload.PostCode1 = '28050';
            payload.City1 = 'Madrid';
            payload.TelNumber = '616689365';
            payload.TelNumber1 = '916832784';
            payload.EMail = 'emailPrueba@prueba.com';
            payload.Relsh1 = 'Hermano/a'; //B-Hermano/a, C-Cuñado/a, G-Matrimonio, H-Pareja de hecho, K-Hijo/a, L-Compañero/a, N-Nieto/a, O-Tío/a, P-Padre/Madre, Q-Sobrino/a, R-NUERA, U-Institución, V-Tutor/a, W-Amistad, X-Otros, Y-Yerno
            WSNuevoFamiliar.insertContact(payload);
        Test.stopTest();
    }

    /**
    @description    Método para probar caso de inserción de familiar a una cuenta que ya tiene familiar asociado. Se espera error "2: Ya existe el familiar"
    @param          
    @return         
     */
    @isTest static void testWSNuevoFamiliarAsociadoCuentaResidente() {

        //Insertamos la cuenta a la que se asociará el residente y su familiar
        Account acct = new Account(Name='CuentaPrueba');
        insert acct;
        
        //Insertamos un nuevo contacto residente al que se pretende asociar nuevo familiar
        RecordType rtidres = [SELECT Id FROM RecordType WHERE DeveloperName ='PotencialResidente' and SobjectType = 'Contact'];

        Contact residente = new Contact(RecordTypeId=rtidres.Id,
                                        AccountId=acct.Id,
                                        IdExternoSAP__c='5555555555',
                                        FirstName='ResidentePrueba',
                                        LastName='ApellidoPrueba',
                                        MailingStreet='Ancha',
                                        MailingPostalCode='28005',
                                        MailingCity='Madrid',
                                        MobilePhone='602275300',
                                        Phone='917390566',
                                        Email='testmail@test.com');

        insert residente;

        //Insertamos un nuevo contacto familiar para el residente anterior
        RecordType rtidfam = [SELECT Id FROM RecordType WHERE DeveloperName ='FamiliaAllegado' and SobjectType = 'Contact'];

        Contact familiar = new Contact(RecordTypeId=rtidfam.Id,
                                        AccountId=acct.Id,
                                        IdExternoSAP__c='222222222',
                                        FirstName='ResidentePrueba2',
                                        LastName='ApellidoPrueba2',
                                        MailingStreet='Ancha2',
                                        MailingPostalCode='28005',
                                        MailingCity='Madrid',
                                        MobilePhone='602275302',
                                        Phone='917390562',
                                        Email='testmail2@test.com');

        insert familiar;

        Test.startTest();

        WSNuevoFamiliar.PayloadIn payload;
            payload = new WSNuevoFamiliar.PayloadIn();
            payload.IdFamiliarSAP = '222222222';
            payload.IdResidenteSAP = '5555555555';
            payload.Nname = 'NombreCont';
            payload.Vname = 'ApellidoCont';
            payload.Street = 'Europa';
            payload.Street2 = 'portal 28';
            payload.HouseNum1 = '1';
            payload.PostCode1 = '28050';
            payload.City1 = 'Madrid';
            payload.TelNumber = '616689365';
            payload.TelNumber1 = '916832784';
            payload.EMail = 'emailPrueba@prueba.com';
            payload.Relsh1 = 'Hermano/a'; //B-Hermano/a, C-Cuñado/a, G-Matrimonio, H-Pareja de hecho, K-Hijo/a, L-Compañero/a, N-Nieto/a, O-Tío/a, P-Padre/Madre, Q-Sobrino/a, R-NUERA, U-Institución, V-Tutor/a, W-Amistad, X-Otros, Y-Yerno
            WSNuevoFamiliar.insertContact(payload);
         Test.stopTest();
    }
    
    /**
    @description    Método para probar caso de inserción de familiar que ya ha sido asociado a otra cuenta. Se espera error "3: Ya existe el familiar, pero está asociado a otra familia <nombreFamilia>"
    @param          
    @return         
     */
    @isTest static void testWSNuevoFamiliarAsociadoCuentaDistinta() {

        //Insertamos la cuenta a la que se asociará el residente
        Account acctres = new Account(Name='CuentaPruebaResidente');
        insert acctres;
        
        //Insertamos un nuevo contacto residente al que se pretende asociar nuevo familiar
        RecordType rtidres = [SELECT Id FROM RecordType WHERE DeveloperName ='PotencialResidente' and SobjectType = 'Contact'];

        Contact residente = new Contact(RecordTypeId=rtidres.Id,
                                        AccountId=acctres.Id,
                                        IdExternoSAP__c='985698569',
                                        FirstName='ResidentePrueba',
                                        LastName='ApellidoPrueba',
                                        MailingStreet='Ancha',
                                        MailingPostalCode='28005',
                                        MailingCity='Madrid',
                                        MobilePhone='602275300',
                                        Phone='917390566',
                                        Email='testmail@test.com');

        insert residente;

        //Insertamos la cuenta que se asociará al familiar
        Account acctfam = new Account(Name='CuentaPruebaFamiliar');
        insert acctfam;

        //Insertamos un nuevo contacto familiar asociado a otra cuenta
        RecordType rtidfam = [SELECT Id FROM RecordType WHERE DeveloperName ='FamiliaAllegado' and SobjectType = 'Contact'];

        Contact familiar = new Contact(RecordTypeId=rtidfam.Id,
                                        AccountId=acctfam.Id,
                                        IdExternoSAP__c='120120236',
                                        FirstName='ResidentePrueba2',
                                        LastName='ApellidoPrueba2',
                                        MailingStreet='Ancha2',
                                        MailingPostalCode='28005',
                                        MailingCity='Madrid',
                                        MobilePhone='602275302',
                                        Phone='917390562',
                                        Email='testmail2@test.com');

        insert familiar;

        Test.startTest();

        WSNuevoFamiliar.PayloadIn payload;
            payload = new WSNuevoFamiliar.PayloadIn();
            payload.IdFamiliarSAP = '120120236';
            payload.IdResidenteSAP = '985698569';
            payload.Nname = 'NombreCont';
            payload.Vname = 'ApellidoCont';
            payload.Street = 'Europa';
            payload.Street2 = 'portal 28';
            payload.HouseNum1 = '1';
            payload.PostCode1 = '28050';
            payload.City1 = 'Madrid';
            payload.TelNumber = '616689365';
            payload.TelNumber1 = '916832784';
            payload.EMail = 'emailPrueba@prueba.com';
            payload.Relsh1 = 'Hermano/a'; //B-Hermano/a, C-Cuñado/a, G-Matrimonio, H-Pareja de hecho, K-Hijo/a, L-Compañero/a, N-Nieto/a, O-Tío/a, P-Padre/Madre, Q-Sobrino/a, R-NUERA, U-Institución, V-Tutor/a, W-Amistad, X-Otros, Y-Yerno
            WSNuevoFamiliar.insertContact(payload);
         Test.stopTest();
    }
}