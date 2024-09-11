/**
@description
WebService para conectar familiares

DATE 		AUTHOR 		DESCRIPTION
03/09/2024	LCS - MSA	Creation

@author Leadclic Solutions
@date 03/09/2024
*/

public class ConectorFamiliares {

    private static String RESIDENTE_RT_DEVELOPERNAME = 'PotencialResidente';

    public static String prepareDataToSend(Contact familiar, String idResidente, String centro) {
        DOM.Document docReq = new DOM.Document();
            
        String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
        String urn = 'urn:sap-com:document:sap:rfc:functions';
            
        dom.XmlNode envelope = docReq.createRootElement('Envelope', soapNS, 'soapenv');
        envelope.setNamespace('urn', urn);
            
        dom.XmlNode header = envelope.addChildElement('Header', soapNS, 'soapenv');
        dom.XmlNode body = envelope.addChildElement('Body', soapNS, 'soapenv');
        dom.XmlNode zish = body.addChildElement('ZISH_CREAR_FAMILIAR_SF', urn, 'urn');
        dom.XmlNode iDatos = zish.addChildElement('I_DATOS', null, null);

        dom.XmlNode EINRI = iDatos.addChildElement('EINRI', null, null);
        dom.XmlNode PATNR = iDatos.addChildElement('PATNR', null, null);
        dom.XmlNode LNAME1 = iDatos.addChildElement('LNAME1', null, null);
        dom.XmlNode FNAME1 = iDatos.addChildElement('FNAME1', null, null);
        dom.XmlNode GSCHL = iDatos.addChildElement('GSCHL', null, null);
        dom.XmlNode RELSH = iDatos.addChildElement('RELSH', null, null);
        dom.XmlNode STREET1 = iDatos.addChildElement('STREET1', null, null);
        dom.XmlNode STREET2 = iDatos.addChildElement('STREET2', null, null);
        dom.XmlNode HOUSE_NUM = iDatos.addChildElement('HOUSE_NUM', null, null);
        dom.XmlNode POST_CODE = iDatos.addChildElement('POST_CODE', null, null);
        dom.XmlNode CITY = iDatos.addChildElement('CITY', null, null);
        dom.XmlNode TEL_NUMBER = iDatos.addChildElement('TEL_NUMBER', null, null);
        dom.XmlNode E_MAIL = iDatos.addChildElement('E_MAIL', null, null);
        
        //Obligatorios
        EINRI.addTextNode(centro);
        PATNR.addTextNode(idResidente);
        LNAME1.addTextNode(familiar.LastName);
        FNAME1.addTextNode(familiar.FirstName);
        GSCHL.addTextNode(familiar.Salutation == 'D.'? 'H' : 'M');
        RELSH.addTextNode(familiar.RecordType.DeveloperName == RESIDENTE_RT_DEVELOPERNAME? 'X' : familiar.Parentesco__c);

        //No obligatorios
        STREET1.addTextNode(familiar.MailingStreet != null ? familiar.MailingStreet.left(60) : '');
        STREET2.addTextNode(familiar.MailingStreet != null ? familiar.MailingStreet.right(familiar.MailingStreet.length()-60).left(60) : '');
        HOUSE_NUM.addTextNode('');
        POST_CODE.addTextNode(familiar.MailingPostalCode != null? familiar.MailingPostalCode : '');
        CITY.addTextNode(familiar.MailingCity != null? familiar.MailingCity : '');
        TEL_NUMBER.addTextNode(familiar.MobilePhone != null? familiar.MobilePhone : '');
        E_MAIL.addTextNode(familiar.Email != null? familiar.Email : '');

        return docReq.toXmlString().replace('<?xml version="1.0" encoding="UTF-8"?>','');
    }

    @future (callout=true)
    public static void sendContact(String body, Id idFamiliar) {   
            
            HttpResponse response = makeCallOut(body);
            // Si da un error 500 no leemos la respuesta, directamente almacenamos un error en la oportunidad
            ResponseData rData = new ResponseData();
            if(response.getStatusCode() == 200){
                // Deserializamos la respuesta para sacar la información
                rData = deserializeResponse(response);

                Contact familiar = [SELECT Id, IdExternoSAPContactos__c FROM Contact WHERE Id = :idFamiliar];
                familiar.IdExternoSAPContactos__c = rData.idFamiliar;
                update familiar;
            }else{
                rData.lType = new List<String>{fetchResponses('err500').Error_Code__c};
                rData.lMessage = new List<String>{fetchResponses('err500').Error_Description__c};
                CreateErrorLog(fetchResponses('err500').Error_Code__c, fetchResponses('err500').Error_Description__c, body);
            }
    }

    /* 
    @description Método que se realiza el callout al servicio externo y actualiza los registros en función del resultado
    @param opportunityId Id de la oportunidad a enviar
    @return void no se realiza devolución
    */

    public static HttpResponse makeCallOut(String body) {

        // Recuperamos la condiguración con los datos de conexión
        IntegracionSAP__mdt config = [SELECT isSandbox FROM Organization].get(0).isSandbox ? IntegracionSAP__mdt.getInstance('Desarrollo') : IntegracionSAP__mdt.getInstance('Produccion');

        // Montamos la llamada con la información obtenida
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        System.debug('XXXx '+config.EndpointFamiliar__c);
        request.setEndpoint(config.EndpointFamiliar__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml');
        // Codificamoas las credenciales en base64
        String sBase64 = EncodingUtil.base64Encode(Blob.valueOf(config.UsuarioLogin__c + ':' + config.PasswordLogin__c));
        request.setHeader('Authorization', 'Basic ' + sBase64);
        request.setTimeout(120000);
        //request.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:rfc:functions">		   <soapenv:Body>			  <urn:ZISH_CREAR_ADMISION_SF>				 <I_DATOS>					<EINRI>0201</EINRI>					<VNAME>asd</VNAME>					<NNAME>qwerty</NNAME>					<GSCHL>M</GSCHL>					<DOC_NO>12345678I</DOC_NO>					<STREET>avenida de europa</STREET>					<HOUSE_NUM1>10</HOUSE_NUM1>					<POST_CODE1>28046</POST_CODE1>					<CITY1>Madrid</CITY1>					<BWART>AD</BWART> <!-- AD (centro dia) o AI (residencia) -->					<BEKAT>CRM</BEKAT> <!-- CRM o CDCRM -->					<ORGPF>0201MD0</ORGPF> <!-- Consultar excel de unidades organizativas -->					<BWIDT>2021-08-01</BWIDT> <!-- formato YYYY-MM-DD -->					<FATYP>I</FATYP> <!-- D (centro dia) o I (residencia)-->					<PRIVADO></PRIVADO>				 </I_DATOS>			  </urn:ZISH_CREAR_ADMISION_SF>		   </soapenv:Body>		</soapenv:Envelope>');
        request.setBody(body);
        System.debug('@@ Enviado: ' + request.getBody());
        
        
        HttpResponse response = http.send(request);
        System.debug('@@ Respuesta: ' + response.getBody());
        

        return response;
    }

    public static ResponseData deserializeResponse(HttpResponse response) {

        // Variables que almacenan los datos de vuelta
        String idBPResidente, idFamiliar;
        List <String> lMessage = new List <String>();
        List <String> lType = new List <String>();        

        Dom.Document doc = response.getBodyDocument();
        // Obtenemos y buscamos en el xml la información recibida
        Dom.XMLNode root = doc.getRootElement();
        for(Dom.XMLNode child : root.getChildElements()) {
            //System.debug(child.getName());
            if( child.getName() == 'Body'){
                for(Dom.XMLNode bodyChild : child.getChildElements()) {
                    //System.debug(bodyChild.getName());
                    if( bodyChild.getName() == 'ZISH_CREAR_FAMILIAR_SFResponse'){
                        for(Dom.XMLNode zishChild : bodyChild.getChildElements()) {
                            //System.debug(zishChild.getName());

                            // Almacenamos la información recibida en variables
                            idBPResidente = zishChild.getName() == 'E_PARTNER1' ? zishChild.getText() : idBPResidente;
                            idFamiliar = zishChild.getName() == 'E_PARTNER2' ? zishChild.getText() : idFamiliar;

                            // Buscamos y almacenamos los tipos y los mensaje de error
                            if( zishChild.getName() == 'E_RETURN'){
                                for(Dom.XMLNode returnChild : zishChild.getChildElements()) {
                                    for(Dom.XMLNode itemChild : returnChild.getChildElements()) {

                                        if( itemChild.getName() == 'TYPE' ){
                                            lType.add(itemChild.getText());
                                        }
                                        if( itemChild.getName() == 'MESSAGE' ){
                                            lMessage.add(itemChild.getText());
                                        }                                        
                                        //System.debug(itemChild.getName());
                                    }
                                }
                            }        
                        }
                    }
                }
            }            
        }

        // Devolvemos los datos recibidos
        ResponseData rData = new ResponseData();
        rData.idBPResidente = idBPResidente;
        rData.idFamiliar = idFamiliar;
        rData.lMessage = lMessage;
        rData.lType = lType;

        return rData;
    }

    private static Mensaje_Error__mdt fetchResponses(String errReference){
        Mensaje_Error__mdt response = Mensaje_Error__mdt.getInstance(errReference);
        Return response;
    }

    public static void CreateErrorLog(String code, String errorDescription, String body){
        RegistrosDeErrores__c ErrorGenerado = new RegistrosDeErrores__c();
        
        ErrorGenerado.CodigoError__c = 'SAP';
        ErrorGenerado.DescripcionError__c = code + ' ' + errorDescription;
        ErrorGenerado.MensajeRecibido__c = body;
        ErrorGenerado.ClaseGeneradora__c = 'ConectorFamiliares';

        insert ErrorGenerado;
    }

    private class ResponseData {
        String idBPResidente {get;set;} //No es el ID del residente
        String idFamiliar {get;set;}
        List<String> lMessage {get;set;}
        List<String> lType {get;set;}
    }
}