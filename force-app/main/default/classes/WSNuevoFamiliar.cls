/** 
@description
<pre>
Servicio web RESTful que dará de alta nuevos familiares (contactos) en Salesforce según los datos recibidos</br>

FECHA       AUTOR   	    DESCRIPCION<br/>
01/07/2021	RF Oliveira     Creado
16/07/2021  RF Oliveira     Modificaciones buenas prácticas (Custom Metadata Type, Se mueven queries fuera de bucles)
22/07/2021  RF Oliveira     Se modifica para que acepte un solo registro en lugar de un array
22/04/2024  LCS-MSA         Se ha añadido el id de contactos
</pre>
@author Leadclic Solutions
@date 01/07/2021
*/

@RestResource(urlMapping='/WSNuevoFamiliar/*')
global with sharing class WSNuevoFamiliar {
    
    /**
    @description    Método principal del servicio. Recibe la información de un familiar creado en SAP y lo da de alta en Salesforce como contacto de familiar
    @param          payload datos entrantes   
    @return         PayloadOut con los datos de resultado de la operación
     */
    @HttpPost
    global static PayloadOut insertContact(PayloadIn payload) {
            PayloadOut payloadOut = new PayloadOut();

            System.debug('@@PayloadIn: ' + payload);

            try{
                // Lista de bloqueos para el insert 
                Contact Contact2Insert = new Contact();
                
                //Se obtiene el Id del tipo de registro "FamiliaAllegado"
                RecordType rtIdFamiliar = [SELECT Id FROM RecordType WHERE DeveloperName ='FamiliaAllegado' and SobjectType = 'Contact'];

                //Buscamos un registro "PotencialResidente" cuyo IdExternoSAP__c coincida con el IdResidenteSAP de entrada
                Contact[] contactResident = [SELECT Id, AccountId, RecordTypeId, RecordType.DeveloperName FROM Contact WHERE IdExternoSAP__c = : payload.IdResidenteSAP AND RecordType.DeveloperName='PotencialResidente' LIMIT 1];

                //Buscamos si existe un registro "FamiliaAllegado" cuyo IdExternoSAP__c coincida con el IdFamiliarSAP de entrada
                Contact[] contactFamily = [SELECT Id, AccountId, RecordTypeId, RecordType.DeveloperName FROM Contact WHERE IdExternoSAPContactos__c = : payload.IdFamiliarSAP AND RecordType.DeveloperName='FamiliaAllegado' LIMIT 1];

                PayloadIn pload= payload;
                    // Objeto para hacer insert del registro
                    Contact auxContact = new Contact();

                    // Chequeamos los campos obligatorios
                    String missingField=checkMandatoryFields(pload);

                    if(String.isBlank(missingField)){

                        //Chequeamos si el IdResidenteSAP (IdExternoSAP__c) existe y el RecordType es "PotencialResidente"
                        if(contactResident.size()>0){
                            
                            //Chequeamos si ya existe un contacto con el mismo IdFamiliarSAP (IdExternoSAP__c) y si el RecordType es "FamiliaAllegado"
                            if(contactFamily.size()>0){
                                //Para devolver el nombre de la familia cuando el familiar ya está asociado a otro residente de otra familia
                                String accountId = contactFamily.get(0).AccountId;
                                Account[] nombreFamilia = [SELECT Name FROM Account WHERE Id = : accountId LIMIT 1];
                                String familia = nombreFamilia.get(0).Name;
                                
                                //Si ya existe contacto con el mismo IdFamiliarSAP (IdExternoSAP__c), chequeamos si está asociado a la misma cuenta que el residente encontrado
                                if(contactResident.get(0).AccountId == contactFamily.get(0).AccountId){
                                    Mensaje_Error__mdt resp = fetchResponses('FamiliarYaExiste');
                                    payloadOut.errorCode = resp.Error_Code__c;
                                    payloadOut.errorDescription = resp.Error_Description__c;

                                //Si ya existe contacto con el mismo IdFamiliarSAP (IdExternoSAP__c) pero está asociado a otra cuenta distinta, devuelve error
                                } else if(contactResident.get(0).AccountId != contactFamily.get(0).AccountId){

                                    //Familiar ya está asociado a otra familia
                                    Mensaje_Error__mdt resp = fetchResponses('FamiliarAsociadoAOtraFamilia');
                                    payloadOut.errorCode = resp.Error_Code__c;
                                    payloadOut.errorDescription = resp.Error_Description__c + familia;
                                }

                            } else {
                                // Generamos el registro de Contact y asignamos los valores que de los parámetros haciendo los ajustes y transformaciones necesarias
                                auxContact.IdExternoSAPContactos__c = pload.IdFamiliarSAP;
                                auxContact.FirstName = pload.Nname;
                                auxContact.LastName = pload.Vname;
                                auxContact.MailingStreet = pload.Street + ', ' + pload.Street2 + ', ' + pload.HouseNum1;
                                auxContact.MailingPostalCode = pload.PostCode1;
                                auxContact.MailingCity = pload.City1;
                                auxContact.MobilePhone = pload.TelNumber;
                                auxContact.Phone = pload.TelNumber1;
                                auxContact.Email = pload.EMail;
                                auxContact.Parentesco__c = pload.Relsh1;
                                auxContact.AccountId = contactResident.get(0).AccountId;
                                auxContact.RecordTypeId = rtIdFamiliar.Id;

                                Contact2Insert=auxContact;
                            }
                        //Si no existe el residente enviado (IdResidenteSAP) se devuelve error
                        } else{
                            Mensaje_Error__mdt resp = fetchResponses('ResidenteNoExiste');
                            payloadOut.errorCode = resp.Error_Code__c;
                            payloadOut.errorDescription = resp.Error_Description__c;
                        }

                    } else{
                        //Faltan campos obligatorios
                        Mensaje_Error__mdt resp = fetchResponses('FaltaCampoObligatorio');
                        payloadOut.errorCode = resp.Error_Code__c;
                        payloadOut.errorDescription = resp.Error_Description__c + missingField;
                    }

                // Se ejecuta el insert si no hay errores previos
                if( String.isBlank(payloadOut.errorCode) ){

                    insert Contact2Insert;        
                
                    Mensaje_Error__mdt resp = fetchResponses('NuevoFamiliarCreadoOK');
                    payloadOut.errorCode = resp.Error_Code__c;
                    payloadOut.errorDescription = resp.Error_Description__c;
                    payloadOut.IdContactoSF = Contact2Insert.Id;
                }

            }catch (Exception e){
                Mensaje_Error__mdt resp = fetchResponses('err500');
                payloadOut.errorCode = resp.Error_Code__c;
                payloadOut.errorDescription = e.getMessage();
            }

            return payloadOut;
    }

    /**
	@description	Comprueba si se han recibido los campos obligatorios
	@param 			payload datos entrantes
	@return			String missingField con el nombre del primer campo obligatorio que falta
	*/  
    private static String checkMandatoryFields (PayloadIn payload){
        String missingField='';
    
        If (String.isBlank(payload.IdResidenteSAP)){
            missingField='IdResidenteSAP';
        } else if(String.isBlank(payload.IdFamiliarSAP)){
            missingField='IdFamiliarSAP';
        } else if(String.isBlank(payload.Vname)){
            missingField='Vname';
        } else if(String.isBlank(payload.Nname)){
            missingField='Nname';
        } else if(String.isBlank(payload.Relsh1)){
            missingField='Relsh1';
        } else if(String.isBlank(payload.TelNumber) && String.isBlank(payload.EMail)){
            missingField='TelNumber / EMail';
        }

        return missingField;
    }

    //Wrapper Class PayloadIn con la información de recibida
	global class PayloadIn {
        public String IdResidenteSAP {get;set;}
        public String IdFamiliarSAP {get;set;}
        public String Vname {get;set;}
        public String Nname {get;set;}
        public String Street {get;set;}
        public String Street2 {get;set;}
        public String HouseNum1 {get;set;}
        public String PostCode1 {get;set;}
        public String City1 {get;set;}
        public String TelNumber {get;set;}
        public String TelNumber1 {get;set;}
        public String EMail {get;set;}
        public String Relsh1 {get;set;}
    }

    //Wrapper Class PayloadOut para devolver los datos del resultado de la operación
	global class PayloadOut {
        public String errorCode {get;set;}
        public String errorDescription {get;set;}
        public String IdContactoSF {get;set;}   
	}

    /**
	@description	Método para recuperar los códigos y mensajes de respuesta
	@param 			String errReference nombre del Custom Metadata Type que se quiere recuperar
	@return			Mensaje_Error__mdt con los campos de la respuesta
	*/ 
    public static Mensaje_Error__mdt fetchResponses(String errReference){
        Mensaje_Error__mdt response = Mensaje_Error__mdt.getInstance(errReference);
        Return response;
    }

}