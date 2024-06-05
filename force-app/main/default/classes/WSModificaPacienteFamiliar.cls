/** 
@description
<pre>
Servicio web RESTful que recibe los datos del paciente o familiar de SAP, actualiza el registro encontrado en Contactos de Salesforce y
devuelve el resultado de la operación con un código y una descripción

FECHA       AUTOR   	    DESCRIPCION<br/>
09/07/2021	RF Oliveira     Creado
16/07/2021  RF Oliveira     Modificaciones buenas prácticas (Custom Metadata Type,  se mueven queries fuera de bucles)
22/07/2021  RF Oliveira     Se modifica para que acepte un solo registro en lugar de un array
06/10/2021  MMV - LCS       Ajustes de las pruebas conjuntas. Cambio en los campos obligatorios
20/02/2022  MSA - LCS       Añadido registro de errores.
17/08/2023  MSA - LCS       Añadida búsqueda por email y número de teléfono
19/09/2023  MSA - LCS       Solucionado error valores en blanco teléfono y email
</pre>
@author Leadclic Solutions
@date 09/07/2021
*/
@RestResource(urlMapping='/WSModificaPacienteFamiliar/*')
global with sharing class WSModificaPacienteFamiliar {

    /**
    @description    Método principal del servicio. Recibe la información de un paciente o familiar actualizado en SAP y lo modifica en contactos de Salesforce
    @param          payload datos entrantes   
    @return         PayloadOut con los datos de resultado de la operación
     */
    @HttpPost
    global static PayloadOut updateContact(PayloadIn payload) {
        PayloadOut payloadOut = new PayloadOut();

        String varId;
        String varTipoRegistro;
        String mensajeExito;

        try{
            // Lista de bloqueos para el insert 
            Contact Contact2Update = new Contact();

            List<Contact> contactBusqueda = new List<Contact>();

            //Buscar si ya existe un registro de contacto con el id de entrada (si viene relleno el IdFamiliarSAP usamos ese, si no usamos IdResidenteSAP) en IdExternoSAP__c
            if ( !String.isBlank(payload.IdResidenteSAP ) ){
                varId = payload.IdResidenteSAP;
                varTipoRegistro = 'PotencialResidente';
                mensajeExito = 'residente'; //para modificar el mensaje de retorno según sea residente o familiar

                contactBusqueda = [SELECT Id, AccountId, RecordTypeId, RecordType.DeveloperName, IdExternoSAP__c FROM Contact WHERE IdExternoSAP__c = : varId AND RecordType.DeveloperName= : varTipoRegistro];
            }else{
                varId = payload.IdFamiliarSAP;
                varTipoRegistro = 'FamiliaAllegado';
                mensajeExito = 'familiar';

                contactBusqueda = [SELECT Id, AccountId, RecordTypeId, RecordType.DeveloperName, IdExternoSAP__c FROM Contact WHERE  IdExternoSAPContactos__c = : varId AND RecordType.DeveloperName= : varTipoRegistro];
            }

            //Buscamos un registro "PotencialResidente" cuyo IdExternoSAP__c coincida con el IdResidenteSAP de entrada

            if((contactBusqueda.size()==0) && (Payload.DocNo != '') && (Payload.TelNumber != '')){
                contactBusqueda = [SELECT Id, AccountId, RecordTypeId, RecordType.DeveloperName, IdExternoSAP__c FROM Contact WHERE NumeroDocumento__c =: payload.DocNo AND MobilePhone =: payload.TelNumber AND RecordType.DeveloperName= : varTipoRegistro];
                if(contactBusqueda.size()>0){
                    if(varTipoRegistro == 'FamiliaAllegado'){
                        contactBusqueda[0].IdExternoSAPContactos__c = varId;
                        update contactBusqueda;
                    }

                    if(varTipoRegistro == 'PotencialResidente'){
                        contactBusqueda[0].IdExternoSAP__c = varId;
                        update contactBusqueda;
                    }
                }
            }

            // Iteramos los bloques recibidos
            //for(PayloadIn pload : payload){
            PayloadIn pload = payload;

                // Objeto para hacer update del registro
                Contact auxContact = new Contact();

                // Chequeamos los campos obligatorios
                String missingField=checkMandatoryFields(pload);
                if(String.isBlank(missingField)){

                    if(contactBusqueda.size()>0){
                        //modifica los datos del registro con los que vienen de entrada.
                        //Si no se recibe el parámetro no se realizará actualización, si se recibe vacío se actualizará a NULL
                        auxContact.Id = contactBusqueda.get(0).Id;
                        if(varTipoRegistro == 'PotencialResidente'){
                            auxContact.IdExternoSAP__c = varId;
                        }
                        if(varTipoRegistro == 'FamiliaAllegado'){
                            auxContact.IdExternoSAPContactos__c = varId;
                        }
                        auxContact.FirstName = pload.Nname;
                        auxContact.LastName = pload.Vname;
                        auxContact.MailingStreet = pload.Street + ', ' + pload.Street2 + ', ' + pload.HouseNum1;
                        auxContact.MailingPostalCode = pload.PostCode1;
                        auxContact.MailingCity = pload.City1;
                        auxContact.MobilePhone = pload.TelNumber;
                        auxContact.Phone = pload.TelNumber1;
                        auxContact.Email = pload.EMail;
                        auxContact.Parentesco__c = pload.Relsh1;
                        auxContact.Birthdate = !String.isBlank(pload.Gbdat) ? Date.valueOf(pload.Gbdat) : null;
                        auxContact.Sexo__c = pload.Gschl;
                        auxContact.NumeroDocumento__c = pload.DocNo;
                        auxContact.TipoDocumento__c = pload.DocTyp;
                        Contact2Update=auxContact;
                    } else{
                        Mensaje_Error__mdt resp = fetchResponses('ContactoNoExiste');
                        payloadOut.errorCode = resp.Error_Code__c;
                        payloadOut.errorDescription = resp.Error_Description__c;
                        CreateErrorLog(resp.Error_Code__c, resp.Error_Description__c, payload);
                    }

                } else{
                    Mensaje_Error__mdt resp = fetchResponses('FaltaCampoObligatorio');
                    payloadOut.errorCode = resp.Error_Code__c;
                    payloadOut.errorDescription = resp.Error_Description__c + missingField;
                    CreateErrorLog(resp.Error_Code__c, resp.Error_Description__c + ' '+missingField, payload);
                }

            
            // Se ejecuta el update si no hay errores previos
            if( String.isBlank(payloadOut.errorCode) ){

                update Contact2Update;
                
                //Se recupera un Custom Metadata Type u otro según si se ha modificado residente o familiar
                Mensaje_Error__mdt resp = (mensajeExito=='residente') ? fetchResponses('ResidenteModificadoOK') : fetchResponses('FamiliarModificadoOK');
                
                payloadOut.errorCode = resp.Error_Code__c;
                payloadOut.errorDescription = resp.Error_Description__c;

            }

        }catch(Exception e){
            Mensaje_Error__mdt resp = fetchResponses('err500');
            payloadOut.errorCode = resp.Error_Code__c;
            payloadOut.errorDescription = e.getMessage();
            CreateErrorLog(resp.Error_Code__c, e.getMessage(), payload);
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
    
        If (String.isNotBlank(payload.IdFamiliarSAP) && String.isBlank(payload.Relsh1)){
            missingField='Relsh1';
        } else if(String.isBlank(payload.IdResidenteSAP) && String.isBlank(payload.IdFamiliarSAP)){
            missingField='IdResidenteSAP / IdFamiliarSAP';
        } else if(String.isBlank(payload.Vname)){
            missingField='Vname';
        } else if(String.isBlank(payload.Nname)){
            missingField='Nname';
        } else if(String.isBlank(payload.Gschl) && String.isNotBlank(payload.IdResidenteSAP)){
            missingField='Gschl';
        } else if(String.isBlank(payload.DocNo) && String.isNotBlank(payload.IdResidenteSAP)){
            missingField='DocNo';
        }

        return missingField;
    }

    //Wrapper Class PayloadId con la información de recibida
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
        public String Gbdat {get;set;}
        public String Gschl {get;set;}
        public String DocNo {get;set;}
        public String DocTyp {get;set;}
    }

    //Wrapper Class PayloadOut para devolver los datos del resultado de la operación
	global class PayloadOut {
        public String errorCode {get;set;}
        public String errorDescription {get;set;}
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

    public static void CreateErrorLog(String Code, String ErrorDescription, PayloadIn Payload){
        RegistrosDeErrores__c ErrorGenerado = new RegistrosDeErrores__c();
        
        ErrorGenerado.CodigoError__c = Code;
        ErrorGenerado.DescripcionError__c = ErrorDescription;
        ErrorGenerado.MensajeRecibido__c = JSON.serialize(Payload);
        ErrorGenerado.ClaseGeneradora__c = 'WSModificaPacienteFamiliar';

        insert ErrorGenerado;
    }
}