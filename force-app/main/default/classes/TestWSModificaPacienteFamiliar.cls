/**
@description
<pre>
Clase que se encarga de realizar el Testing de la clase WSNuevoFamiliar.<br/>

FECHA       AUTOR   	    DESCRIPCION<br/>
09/07/2021	RF Oliveira     Creado
22/07/2021  RF Oliveira     Se modifica para que acepte un solo registro en lugar de un array
</pre>
@author Leadclic Solutions
@date 06/07/2021
*/
@isTest 
public with sharing class TestWSModificaPacienteFamiliar {

    /**
    @description    Método para probar una modificación de contacto residente correcta.
    @param          
    @return         
     */
    @isTest static void TestModificaPacienteOK() {

            //Insertamos la cuenta a la que se asociará el residente y su familiar
            Account acct = new Account(Name='CuentaPrueba');
            insert acct;

            //Insertamos un nuevo contacto residente que se va a modificar
            RecordType rtid = [SELECT Id FROM RecordType WHERE DeveloperName ='PotencialResidente' and SobjectType = 'Contact'];

            Contact contact = new Contact(RecordTypeId=rtid.Id,
                                            AccountId=acct.Id,
                                            IdExternoSAP__c='999999999',
                                            FirstName='ResidentePrueba',
                                            LastName='ApellidoPrueba',
                                            MailingStreet='Ancha',
                                            MailingPostalCode='28005',
                                            MailingCity='Madrid',
                                            MobilePhone='602275300',
                                            Phone='917390566',
                                            Email='testmail@test.com');
            insert contact;

        Test.startTest();

            //Se modifica el residente creado anteriormente
            WSModificaPacienteFamiliar.PayloadIn payload;
            payload = new WSModificaPacienteFamiliar.PayloadIn();
            payload.IdResidenteSAP = '999999999';
            payload.Nname = 'NombreResidente';
            payload.Vname = 'ApellidoResidente';
            payload.Street = 'Europa';
            payload.Street2 = 'portal 28';
            payload.HouseNum1 = '1';
            payload.PostCode1 = '28050';
            //payload.City1 = 'Madrid'; //No se envía campo para verificar que no se modifique campo MailingCity
            payload.TelNumber = '616689365';
            payload.TelNumber1 = ''; //Se deja vacío para verificar que actualice el campo Phone del contacto a null
            payload.EMail = 'emailPrueba@prueba.com';
            payload.Relsh1 = 'Hermano/a'; //B-Hermano/a, C-Cuñado/a, G-Matrimonio, H-Pareja de hecho, K-Hijo/a, L-Compañero/a, N-Nieto/a, O-Tío/a, P-Padre/Madre, Q-Sobrino/a, R-NUERA, U-Institución, V-Tutor/a, W-Amistad, X-Otros, Y-Yerno
            payload.Gbdat = '01/01/1980'; //Formato correcto: dd/mm/yyyy
            payload.Gschl = 'Hombre'; //Hombre, Mujer
            payload.DocNo = '98653217M';
            payload.DocTyp = 'NIE'; //Pasaporte, NIE, NIF
            WSModificaPacienteFamiliar.updateContact(payload);

        Test.stopTest();
    }

    /**
    @description    Método para probar una modificación de contacto familiar correcto.
    @param          
    @return         
     */
    @isTest static void TestModificaFamiliarOK() {

        //Insertamos la cuenta a la que se asociará el familiar
        Account acct = new Account(Name='CuentaPrueba');
        insert acct;

        //Insertamos un nuevo contacto familiar que se va a modificar
        RecordType rtidfam = [SELECT Id FROM RecordType WHERE DeveloperName ='FamiliaAllegado' and SobjectType = 'Contact'];

        Contact familiar = new Contact(RecordTypeId=rtidfam.Id,
                                        AccountId=acct.Id,
                                        IdExternoSAP__c='1234567890',
                                        FirstName='ResidentePrueba',
                                        LastName='ApellidoPrueba',
                                        MailingStreet='Ancha',
                                        MailingPostalCode='28005',
                                        MailingCity='Madrid',
                                        MobilePhone='602275300',
                                        Phone='917390566',
                                        Email='testmail@test.com');
        insert familiar;

        Test.startTest();
        
            //Se modifica el familiar creado anteriormente
            WSModificaPacienteFamiliar.PayloadIn payload;
            payload = new WSModificaPacienteFamiliar.PayloadIn();
            payload.IdFamiliarSAP = '1234567890';
            payload.Nname = 'NombreFamiliar';
            payload.Vname = 'ApellidoFamiliar';
            payload.Street = 'Europa';
            payload.Street2 = 'portal 28';
            payload.HouseNum1 = '1';
            payload.PostCode1 = '28050';
            //payload.City1 = 'Madrid'; //No se envía campo para verificar que no se modifique campo MailingCity
            payload.TelNumber = '616689365';
            payload.TelNumber1 = ''; //Se deja vacío para verificar que actualice el campo Phone del contacto a null
            payload.EMail = 'emailPrueba@prueba.com';
            payload.Relsh1 = 'Hermano/a'; //B-Hermano/a, C-Cuñado/a, G-Matrimonio, H-Pareja de hecho, K-Hijo/a, L-Compañero/a, N-Nieto/a, O-Tío/a, P-Padre/Madre, Q-Sobrino/a, R-NUERA, U-Institución, V-Tutor/a, W-Amistad, X-Otros, Y-Yerno
            //payload.Gbdat = '01/01/1980'; //Formato correcto: dd/mm/yyyy
            payload.Gschl = 'Mujer'; //Hombre, Mujer
            payload.DocNo = '98653217M';
            payload.DocTyp = 'NIE'; //Pasaporte, NIE, NIF
            WSModificaPacienteFamiliar.updateContact(payload);

        Test.stopTest();
    }

    /**
    @description    Método para probar caso de modificación de familiar sin informar todos los campos obligatorios. Se espera un error "10: Faltan campos obligatorios"
    @param          
    @return         
     */
    @isTest static void TestFaltanCamposObligatorios() {
        
        Test.startTest();
        WSModificaPacienteFamiliar.PayloadIn payload;
            payload = new WSModificaPacienteFamiliar.PayloadIn();
            payload.IdFamiliarSAP = '1234567890';          
            WSModificaPacienteFamiliar.updateContact(payload);
        Test.stopTest();
    }

    /**
    @description    Método para probar caso de modificación de familiar en el que no se encuentra el residente. Se espera un error "4: No se encuentra el contacto para actualizar"
    @param          
    @return         
     */
    @isTest static void TestNoExisteContacto() {
        Test.startTest();
            //Se trata de modificar un paciente que no existe en la base de datos
            WSModificaPacienteFamiliar.PayloadIn payload;
            payload = new WSModificaPacienteFamiliar.PayloadIn();
            payload.IdFamiliarSAP = '1234567890';
            payload.Nname = 'NombrePrueba';
            payload.Vname = 'ApellidoPrueba';
            payload.Street = 'Europa';
            payload.Street2 = 'portal 28';
            payload.HouseNum1 = '1';
            payload.PostCode1 = '28050';
            payload.City1 = 'Madrid';
            payload.TelNumber = '616689365';
            payload.TelNumber1 = '';
            payload.EMail = 'emailPrueba@prueba.com';
            payload.Relsh1 = 'Hermano/a'; //B-Hermano/a, C-Cuñado/a, G-Matrimonio, H-Pareja de hecho, K-Hijo/a, L-Compañero/a, N-Nieto/a, O-Tío/a, P-Padre/Madre, Q-Sobrino/a, R-NUERA, U-Institución, V-Tutor/a, W-Amistad, X-Otros, Y-Yerno
            //payload.Gbdat = '01/01/1980'; //Formato correcto: dd/mm/yyyy
            payload.Gbdat = '1980-01-01';
            payload.Gschl = 'Mujer'; //Hombre, Mujer
            payload.DocNo = '98653217M';
            payload.DocTyp = 'NIE'; //Pasaporte, NIE, NIF
            WSModificaPacienteFamiliar.updateContact(payload);

        Test.stopTest();
    }
    
}