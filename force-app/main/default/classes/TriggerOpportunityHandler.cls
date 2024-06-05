/**
@description
Clase manejadora del trigger y los flujos automáticos de Oportunidades. Contiene los métodos que realizan cada una de las funcionalidades necesarias.

DATE 		AUTHOR 		DESCRIPTION
27/11/2023  LCS - MSA   Prevenir envíar oportunidades que ya han sido enviadas (tienen Id de SAP relleno).
19/10/2023  LCS - MSA   Al enviar una oportunidad comprobar que solo se envía un residente.
14/09/2023  LCS - MSA	Al enviar una oportunidad de CD comprobar que mínimo se rellena una plaza (comentado hasta que sea requerido)
11/09/2023  LCS - MSC	Comprobar los campos Parentesco__c, email, phone y mobilePhone en caso de ser el contacto del tipo AllegadoFamilia.
21/08/2023  LCS - MSA	Añadido campo no enviar.
22/05/2023  LCS - MSA	Error de envío de 30 caracteres SAP.
02/12/2022  LCS - JLQ	Comprobación para que el id de oportunidad no se duplique.
30/11/2022  LCS - MSA	Añadidos nuevos campos y clausulas de error a la hora de enviar campos.
08/02/2022  LCS - MMV   Cambio para que si hay dos OCR del mismo contacto solo envie uno a SAP
19/01/2022  LCS - MMV   Corrección para la actualización de las plazas
05/08/2021	LCS - MMV	Creation

@author Leadclic Solutions
@date 05/08/2021 
*/
public class TriggerOpportunityHandler {

    /* 
    @description Método que se ejecuta desde el flujo OpportunityClosedWon y prepara la llamada para el callout
    @param opportunityId Id de la oportunidad a enviar
    @return void no se realiza devolución
    */
    @InvocableMethod( label='Call2SAP' description='Make a call to SAP' category='Callout' )
    public static void prepareDataCall( List<Id> lOpportunityId ) {        

        system.debug('@@ OpportunityId: ' + lOpportunityId[0]);
        
        // Validamos que las oportunidades tienen un contacto con función de residente, esto debe ser obligatorio
        // Obtenemos los OCR de función Residente de esas oportunidades
        Map<Id, OpportunityContactRole> mOppIdOcr = new Map<Id, OpportunityContactRole>();
        for(OpportunityContactRole ocr: [SELECT Id, ContactId, OpportunityId, Contact.FirstName, Contact.Sexo__c,
                                             Contact.NumeroDocumento__c,Contact.MailingStreet,Contact.MailingPostalCode,Contact.MailingCity,Contact.Birthdate,

                                             Contact.NecesitaAyudaParaComer__c,
                                             Contact.NecesitaAyudaParaVestirse__c,
                                             Contact.NecesitaAyudaParaAsearse__c,
                                             Contact.UsaPanyales__c,
                                             Contact.TipoPanal__c,
                                             Contact.EsFumador__c,
                                             Contact.ExpresaAdecuadamenteSusNecesidades__c,
                                             Contact.TieneProblemasFrecuentesDeMemoria__c,
                                             Contact.EsAutonomoEnSusTraslados__c,
                                             Contact.ObjetoAyuda__c,
                                             Contact.DuermeBienPaciente__c,
                                             Contact.TipoDieta__c,

                                             Contact.ConscienteDeSuIngresoEnElCentro__c,
                                             Contact.LoHaceVoluntariamente__c,
                                             Contact.SolicitudAutorizInternamJudicial__c,
                                             Contact.EncargadoTramiteAutorizacionInternam__c,
                                             Contact.SeguroDeDefuncion__c,
                                             Contact.DocumentoEntregadoRecomendacionesIngreso__c,

                                             Contact.Oxigeno__c,
                                             Contact.Sujeccion__c,
                                             Contact.SuplementoNutricional__c,
                                             Contact.Alergias__c,
                                             Contact.SondaNasogastrica__c ,
                                             Contact.ProblemasDeDeglucion__c ,
                                             Contact.SondaVesical__c,
                                             Contact.Incontinencia__c,

                                             Contact.DeterioroCognitivo__c ,
                                             Contact.Agitacion__c,
                                             Contact.Vagabundeo__c ,
                                             Contact.RiesgoDeFuga__c,
                                             Contact.Desorientado__c,

                                             Contact.Observaciones__c,

                                             Contact.TipoDocumento__c,

                                             Opportunity.NoEnviar__c,

                                             Opportunity.ProductoInteres__c,

                                             Opportunity.PlazaLunes__c ,
                                             Opportunity.PlazaMartes__c ,
                                             Opportunity.PlazaMiercoles__c ,
                                             Opportunity.PlazaJueves__c ,
                                             Opportunity.PlazaViernes__c ,
                                             Opportunity.PlazaSabado__c ,
                                             Opportunity.PlazaDomingo__c,
                                             
                                             Opportunity.ResidenciaIngreso__r.TrabajarSAP__c,
                                             Opportunity.ResidenciaIngreso__r.CodigoCentroSAP__c,
                                             Contact.LastName

                                             FROM OpportunityContactRole
                                             WHERE OpportunityId IN: lOpportunityId
                                             AND Role = 'Residente' ]){                                                
            // Metemos en el set los Ids de las oportunidades que tienen residente
            mOppIdOcr.put(ocr.OpportunityId, ocr);
        }

        if([SELECT Id FROM OpportunityContactRole WHERE OpportunityId IN: lOpportunityId AND Role = 'Residente' ].size() > 1){
            throw new CerrarOportunidadException(fetchResponses('CierraOportunidadesConMasUnResidente').Error_Description__c);
        }

        // Para cada oportunidad cerrada lanzamos una llamada 
        for(Id oppId: lOpportunityId){ 

            // Si para alguna oportunidad no hubiera contacto devolvemos un error
            if( !mOppIdOcr.containsKey(oppId) ){
                throw new CerrarOportunidadException(fetchResponses('CierraOportunidadSinResidente').Error_Description__c);
            }else{
                // Si existe un registro pero le falta algún dato devolvemos un error
                OpportunityContactRole ocrAux = mOppIdOcr.get(oppId);
                if( String.isBlank(ocrAux.Contact.FirstName) ){
                    throw new CerrarOportunidadException(fetchResponses('CierraOportunidadSinNombre').Error_Description__c);
                }                
                if( String.isBlank(ocrAux.Contact.Sexo__c) ){
                    throw new CerrarOportunidadException(fetchResponses('CierraOportunidadSinGenero').Error_Description__c);
                }
                if( String.isBlank(ocrAux.Contact.NumeroDocumento__c) ){
                    throw new CerrarOportunidadException(fetchResponses('CierraOportunidadSinDocumento').Error_Description__c);
                }
                if( String.isBlank(ocrAux.Contact.MailingStreet) ){
                    throw new CerrarOportunidadException(fetchResponses('CierraOportunidadSinCalle').Error_Description__c);
                }
                if( String.isBlank(ocrAux.Contact.MailingPostalCode) ){
                    throw new CerrarOportunidadException(fetchResponses('CierraOportunidadSinCodigoPostal').Error_Description__c);
                }
                if( String.isBlank(ocrAux.Contact.MailingCity) ){
                    throw new CerrarOportunidadException(fetchResponses('CierraOportunidadSinCiudad').Error_Description__c);
                }
                if( ocrAux.Contact.Birthdate == null || String.isBlank(ocrAux.Contact.Birthdate.format()) ){
                    throw new CerrarOportunidadException(fetchResponses('CierraOportunidadSinFechaDeNacimiento').Error_Description__c);
                }
                if( ocrAux.Contact.Oxigeno__c == null ){
                    throw new CerrarOportunidadException(fetchResponses('ContactoDebeTenerOxigeno').Error_Description__c);
                }
                if( ocrAux.Contact.SuplementoNutricional__c == null ){
                    throw new CerrarOportunidadException(fetchResponses('ContactoDebeTenerSN').Error_Description__c);
                }
                if( ocrAux.Contact.SondaNasogastrica__c == null ){
                    throw new CerrarOportunidadException(fetchResponses('ContactoDebeTenerSNas').Error_Description__c);
                }
                if( ocrAux.Contact.SondaVesical__c == null ){
                    throw new CerrarOportunidadException(fetchResponses('ContactoDebeTenerSV').Error_Description__c);
                }
                if( ocrAux.Contact.Sujeccion__c == null ){
                    throw new CerrarOportunidadException(fetchResponses('ContactoDebeTenerSuj').Error_Description__c);
                }
                if( ocrAux.Contact.Alergias__c == null ){
                    throw new CerrarOportunidadException(fetchResponses('ContactoDebeTenerAler').Error_Description__c);
                }
                if( ocrAux.Contact.ProblemasDeDeglucion__c == null ){
                    throw new CerrarOportunidadException(fetchResponses('ContactoDebeTenerPD').Error_Description__c);
                }
                if( ocrAux.Contact.Incontinencia__c == null ){
                    throw new CerrarOportunidadException(fetchResponses('ContactoDebeTenerInc').Error_Description__c);
                }
                if( ocrAux.Contact.Agitacion__c == null ){
                    throw new CerrarOportunidadException(fetchResponses('ContactoDebeTenerAgit').Error_Description__c);
                }
                if( ocrAux.Contact.Vagabundeo__c == null ){
                    throw new CerrarOportunidadException(fetchResponses('ContactoDebeTenerVag').Error_Description__c);
                }
                if( ocrAux.Contact.RiesgoDeFuga__c == null ){
                    throw new CerrarOportunidadException(fetchResponses('ContactoDebeTenerRF').Error_Description__c);
                }
                if( ocrAux.Contact.Desorientado__c == null ){
                    throw new CerrarOportunidadException(fetchResponses('ContactoDebeTenerDes').Error_Description__c);
                }

                //DNI
                if(ocrAux.Contact.TipoDocumento__c== '01'){
                    if( CheckDNI(integer.valueof(ocrAux.Contact.NumeroDocumento__c.substring(0,8))) != ocrAux.Contact.NumeroDocumento__c.substring(8,9)){
                        throw new CerrarOportunidadException('La letra del DNI '+ocrAux.Contact.NumeroDocumento__c+' debe de ser una: '+CheckDNI(integer.valueof(ocrAux.Contact.NumeroDocumento__c.substring(0,8))));
                    }
                }

                /*
                if((ocrAux.Opportunity.ProductoInteres__c == 'Centro día/ SED') || (ocrAux.Opportunity.ProductoInteres__c == 'Centro de día de respiro')){

                    if(
                    ocrAux.Opportunity.PlazaLunes__c == null &&
                    ocrAux.Opportunity.PlazaMartes__c == null &&
                    ocrAux.Opportunity.PlazaMiercoles__c == null &&
                    ocrAux.Opportunity.PlazaJueves__c == null &&
                    ocrAux.Opportunity.PlazaViernes__c == null &&
                    ocrAux.Opportunity.PlazaSabado__c == null &&
                    ocrAux.Opportunity.PlazaDomingo__c == null
                    ){
                        throw new CerrarOportunidadException(fetchResponses('MinimoUnaPlazaCD').Error_Description__c);
                    }
                }
                */

                for(OpportunityContactRole ocr: [SELECT Id, ContactId, OpportunityId, Contact.FirstName, Contact.LastName,
                                                Contact.Parentesco__c, Contact.Email, Contact.MobilePhone,  Contact.Phone,
                                                Contact.RecordType.DeveloperName
                                            
                                             FROM OpportunityContactRole
                                             WHERE OpportunityId IN: lOpportunityId]){
                        
                        if(ocr.Contact.LastName.length()>30){
                            throw new CerrarOportunidadException('El contacto: ' + ocr.Contact.FirstName + ' ' + ocr.Contact.LastName + ' tiene un apellido superior a 30 caracteres superando así los límites de SAP');
                        }
                        if(ocr.Contact.RecordType.DeveloperName == 'FamiliaAllegado') {
                            if(ocr.Contact.Parentesco__c == null) {
                                throw new CerrarOportunidadException('El contacto: ' + ocr.Contact.FirstName + ' ' + ocr.Contact.LastName + ' debe tener un parentesco asignado para envíarse a SAP');
                            }
                            if (ocr.Contact.Email == null && ocr.Contact.MobilePhone == null && ocr.Contact.Phone == null){
                                throw new CerrarOportunidadException('El contacto: ' + ocr.Contact.FirstName + ' ' + ocr.Contact.LastName + ' no tiene ningun dato de contacto relleno, debe tener un campo mínimo relleno (Móvil, Teléfono o Correo electrónico) para su envío a SAP');
                            }
                        }
                    }

                if((ocrAux.Contact.TipoDieta__c != null)&&(ocrAux.Contact.TipoDieta__c.length()>30)){
                    throw new CerrarOportunidadException('El valor tipo de dieta del contacto ' + ocrAux.Contact.FirstName + ' ' + ocrAux.Contact.LastName + ' es superior a 30 caracteres');
                }

                //Este error ha de ir el último, ya que es el que nos indica si se ha de enviar o no a SAP
                if(ocrAux.Opportunity.ResidenciaIngreso__r.TrabajarSAP__c){
                    throw new CerrarOportunidadException('El centro ' + ocrAux.Opportunity.ResidenciaIngreso__r.CodigoCentroSAP__c + ' solo trabaja en SAP. Si se empieza a trabajar en Salesforce contacte con su administrador para que se sincronicen los episodios, los residentes y las plazas');
                }
            }
            

        }     

        // Para cada oportunidad cerrada lanzamos una llamada 
        for(Id oppId: lOpportunityId){ 
            OpportunityContactRole ocrAux = mOppIdOcr.get(oppId);
            // Si para alguna oportunidad no hubiera contacto devolvemos un error
            // Realizamos dentro de un método futuro la obtención de datos, la llamada y el tratamiento de datos de respuesta
            if(!ocrAux.Opportunity.NoEnviar__c){
                CallOutSAP(oppId);
            }
        }              
    }    
    
    /* 
    @description Método que se realiza el callout al servicio externo y actualiza los registros en función del resultado
    @param opportunityId Id de la oportunidad a enviar
    @return void no se realiza devolución
    */
    @future(callout=true)
    public static void CallOutSAP(Id oppId) {

        // Declaración de variables
        Contact residenteUpd = null;
        Contact familiar1Upd = null;
        Contact familiar2Upd = null;
        List<Contact> lCont2Upd = new List<Contact>();
        String sFechaPlanificadaYear = null;
        String sFechaPlanificadaMonth = null;
        String sFechaPlanificadaDay = null;
        String sFechaPlanificada = null;
        String sBirthDateYear = null;
        String sBirthDateMonth = null;
        String sBirthDateDay = null;
        String sBirthDate = null;
        List<Plaza__c> lPlazas2Upd = new List<Plaza__c>();
        Plaza__c auxPlaza = new Plaza__c();

        // A partir del Identificador de la oportunidad buscamos los datos en Salesforce
        List<Opportunity> lOpp = [SELECT ResidenciaIngreso__r.CodigoCentroSAP__c, Account.Type, 
                                  Plaza__r.Cama__c, FechaIngreso__c, TipoPlaza__c,
                                  PlazaLunes__r.Cama__c, PlazaMartes__r.Cama__c, PlazaMiercoles__r.Cama__c,
                                  PlazaJueves__r.Cama__c, PlazaViernes__r.Cama__c, PlazaSabado__r.Cama__c,
                                  PlazaDomingo__r.Cama__c, Plaza__c, PlazaLunes__c, PlazaMartes__c, 
                                  PlazaMiercoles__c, PlazaJueves__c, PlazaViernes__c, PlazaSabado__c,
                                  PlazaDomingo__c, ProductoInteres__c
                                  FROM Opportunity WHERE Id =: oppId];

        // Bucamos los contactos relacionados con la oportunidad
        List<OpportunityContactRole> lOcr = [SELECT OpportunityId, Opportunity.IdExternoSAP__c, ContactId, Role, Contact.LastName, Contact.FirstName,
                                             Contact.BirthDate, Contact.Sexo__c, Contact.NumeroDocumento__c, Contact.TipoDocumento__c,
                                             Contact.MailingStreet,Contact.MailingPostalCode,Contact.MailingCity,Contact.MobilePhone,
                                             Contact.HomePhone,Contact.Email, Contact.Parentesco__c,

                                             Contact.NecesitaAyudaParaComer__c,
                                             Contact.NecesitaAyudaParaVestirse__c,
                                             Contact.NecesitaAyudaParaAsearse__c,
                                             Contact.UsaPanyales__c,
                                             Contact.TipoPanal__c,
                                             Contact.EsFumador__c,
                                             Contact.ExpresaAdecuadamenteSusNecesidades__c,
                                             Contact.TieneProblemasFrecuentesDeMemoria__c,
                                             Contact.EsAutonomoEnSusTraslados__c,
                                             Contact.ObjetoAyuda__c,
                                             Contact.DuermeBienPaciente__c,
                                             Contact.TipoDieta__c,

                                             Contact.ConscienteDeSuIngresoEnElCentro__c,
                                             Contact.LoHaceVoluntariamente__c,
                                             Contact.SolicitudAutorizInternamJudicial__c,
                                             Contact.EncargadoTramiteAutorizacionInternam__c,
                                             Contact.SeguroDeDefuncion__c,
                                             Contact.DocumentoEntregadoRecomendacionesIngreso__c,

                                             Contact.Oxigeno__c,
                                             Contact.Sujeccion__c,
                                             Contact.SuplementoNutricional__c,
                                             Contact.Alergias__c,
                                             Contact.SondaNasogastrica__c ,
                                             Contact.ProblemasDeDeglucion__c ,
                                             Contact.SondaVesical__c,
                                             Contact.Incontinencia__c,

                                             Contact.DeterioroCognitivo__c ,
                                             Contact.Agitacion__c,
                                             Contact.Vagabundeo__c ,
                                             Contact.RiesgoDeFuga__c,
                                             Contact.Desorientado__c,

                                             Contact.Observaciones__c

                                             FROM OpportunityContactRole WHERE OpportunityId =: oppId];

        if((locr[0].Opportunity.IdExternoSAP__c == '') || (locr[0].Opportunity.IdExternoSAP__c == null)){

            // Generamos el paquete XML para enviar
            DOM.Document docReq = new DOM.Document();
            
            String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
            String urn = 'urn:sap-com:document:sap:rfc:functions';
            
            dom.XmlNode envelope = docReq.createRootElement('Envelope', soapNS, 'soapenv');
            envelope.setNamespace('urn', urn);
            
            dom.XmlNode header = envelope.addChildElement('Header', soapNS, 'soapenv');
            dom.XmlNode body = envelope.addChildElement('Body', soapNS, 'soapenv');
            dom.XmlNode zish = body.addChildElement('ZISH_CREAR_ADMISION_SF', urn, 'urn');
            dom.XmlNode iDatos = zish.addChildElement('I_DATOS', null, null);   

            // Añadimos los parámetros con sus valores al esquema XML
            dom.XmlNode EINRI = iDatos.addChildElement('EINRI', null, null).addTextNode(lOpp[0].ResidenciaIngreso__r.CodigoCentroSAP__c); 
            dom.XmlNode VNAME = iDatos.addChildElement('VNAME', null, null);  
            dom.XmlNode NNAME = iDatos.addChildElement('NNAME', null, null);  
            dom.XmlNode BIRTH_NAME = iDatos.addChildElement('BIRTH_NAME', null, null);  
            dom.XmlNode GBDAT = iDatos.addChildElement('GBDAT', null, null); 
            
            dom.XmlNode GSCHL = iDatos.addChildElement('GSCHL', null, null); 
            dom.XmlNode DOC_NO = iDatos.addChildElement('DOC_NO', null, null); 
            dom.XmlNode DOC_TYP = iDatos.addChildElement('DOC_TYP', null, null);  
            dom.XmlNode STREET = iDatos.addChildElement('STREET', null, null);  
            dom.XmlNode STREET2 = iDatos.addChildElement('STREET2', null, null);    
            dom.XmlNode HOUSE_NUM1 = iDatos.addChildElement('HOUSE_NUM1', null, null);  
            dom.XmlNode POST_CODE1 = iDatos.addChildElement('POST_CODE1', null, null);
            dom.XmlNode CITY1 = iDatos.addChildElement('CITY1', null, null);
            dom.XmlNode TEL_NUMBER = iDatos.addChildElement('TEL_NUMBER', null, null);
            dom.XmlNode TEL_NUMBER1 = iDatos.addChildElement('TEL_NUMBER1', null, null);
            dom.XmlNode E_MAIL = iDatos.addChildElement('E_MAIL', null, null);
        
            dom.XmlNode LNAME1 = iDatos.addChildElement('LNAME1', null, null);
            dom.XmlNode FNAME1 = iDatos.addChildElement('FNAME1', null, null);
            dom.XmlNode RELSH1 = iDatos.addChildElement('RELSH1', null, null);
            dom.XmlNode STREET1 = iDatos.addChildElement('STREET1', null, null);
            dom.XmlNode STREET3 = iDatos.addChildElement('STREET3', null, null);
            dom.XmlNode HOUSE_NUM1_2 = iDatos.addChildElement('HOUSE_NUM1_2', null, null);  
            dom.XmlNode POST_CODE1_2 = iDatos.addChildElement('POST_CODE1_2', null, null);
            dom.XmlNode CITY1_2 = iDatos.addChildElement('CITY1_2', null, null);
            dom.XmlNode TEL_NUMBER2 = iDatos.addChildElement('TEL_NUMBER2', null, null);
            dom.XmlNode E_MAIL_2 = iDatos.addChildElement('E_MAIL_2', null, null);
            dom.XmlNode FEXNR = iDatos.addChildElement('FEXNR', null, null);

            dom.XmlNode LNAME2 = iDatos.addChildElement('LNAME2', null, null);
            dom.XmlNode FNAME2 = iDatos.addChildElement('FNAME2', null, null);
            dom.XmlNode RELSH2 = iDatos.addChildElement('RELSH2', null, null);
            dom.XmlNode STREET4 = iDatos.addChildElement('STREET4', null, null);
            dom.XmlNode STREET5 = iDatos.addChildElement('STREET5', null, null);
            dom.XmlNode HOUSE_NUM1_3 = iDatos.addChildElement('HOUSE_NUM1_3', null, null);  
            dom.XmlNode POST_CODE1_3 = iDatos.addChildElement('POST_CODE1_3', null, null);
            dom.XmlNode CITY1_3 = iDatos.addChildElement('CITY1_3', null, null);
            dom.XmlNode TEL_NUMBER3 = iDatos.addChildElement('TEL_NUMBER3', null, null);
            dom.XmlNode E_MAIL_3 = iDatos.addChildElement('E_MAIL_3', null, null);

            dom.XmlNode BWART = iDatos.addChildElement('BWART', null, null).addTextNode(
                lOpp[0].ProductoInteres__c == 'Residencia permanente'? 'AI':
                lOpp[0].ProductoInteres__c == 'Estancia temporal'? 'AT':
                lOpp[0].ProductoInteres__c == 'Centro día/ SED'? 'AD':
                lOpp[0].ProductoInteres__c == 'Estancia de respiro'? 'AT':
                lOpp[0].ProductoInteres__c == 'Centro de día de respiro'? 'AL':
                lOpp[0].ProductoInteres__c == 'Estancia nocturna'? 'AT':
                lOpp[0].ProductoInteres__c == 'Apartamento'? 'AI':
                lOpp[0].ProductoInteres__c == 'Centro de día de media jornada'? 'AD':
                'AD'); 
            dom.XmlNode BEKAT = iDatos.addChildElement('BEKAT', null, null).addTextNode(lOpp[0].Plaza__r.Cama__c != null ? 'CRM'  : 'CDCRM'); 
            dom.XmlNode ORGPF = iDatos.addChildElement('ORGPF', null, null).addTextNode(lOpp[0].Plaza__r.Cama__c != null ? lOpp[0].Plaza__r.Cama__c  : ''); 
            
            // Generamos el string de la fecha con el formato yyyy-mm-dd
            sFechaPlanificadaYear = lOpp[0].FechaIngreso__c != null ? String.valueOf(lOpp[0].FechaIngreso__c.year()) : null;
            sFechaPlanificadaMonth = lOpp[0].FechaIngreso__c != null ? (String.valueOf(lOpp[0].FechaIngreso__c.month()).length() > 1 ? String.valueOf(lOpp[0].FechaIngreso__c.month()) : '0' + lOpp[0].FechaIngreso__c.month()) : null;
            sFechaPlanificadaDay = lOpp[0].FechaIngreso__c != null ? (String.valueOf(lOpp[0].FechaIngreso__c.day()).length() > 1 ? String.valueOf(lOpp[0].FechaIngreso__c.day()) : '0' + lOpp[0].FechaIngreso__c.day()) : null;
            sFechaPlanificada = lOpp[0].FechaIngreso__c != null ? sFechaPlanificadaYear + '-' + sFechaPlanificadaMonth + '-' + sFechaPlanificadaDay : '';
            dom.XmlNode BWIDT = iDatos.addChildElement('BWIDT', null, null).addTextNode(sFechaPlanificada);  
            dom.XmlNode FATYP = iDatos.addChildElement('FATYP', null, null).addTextNode(lOpp[0].Plaza__r.Cama__c != null ? 'I'  : 'D'); 
            dom.XmlNode KZTXT = iDatos.addChildElement('KZTXT', null, null); 
            dom.XmlNode PRIVADO = iDatos.addChildElement('PRIVADO', null, null).addTextNode(lOpp[0].TipoPlaza__c != null ? lOpp[0].TipoPlaza__c : ''); 
            dom.XmlNode KZTXT1 = iDatos.addChildElement('KZTXT1', null, null);    
            dom.XmlNode PlazaCDL = iDatos.addChildElement('PLAZACDL', null, null).addTextNode(lOpp[0].PlazaLunes__r.Cama__c != null ? lOpp[0].PlazaLunes__r.Cama__c.left(lOpp[0].PlazaLunes__r.Cama__c.length()-1) : '');    
            dom.XmlNode PlazaCDM = iDatos.addChildElement('PLAZACDM', null, null).addTextNode(lOpp[0].PlazaMartes__r.Cama__c != null ? lOpp[0].PlazaMartes__r.Cama__c.left(lOpp[0].PlazaMartes__r.Cama__c.length()-1) : '');    
            dom.XmlNode PlazaCDX = iDatos.addChildElement('PLAZACDX', null, null).addTextNode(lOpp[0].PlazaMiercoles__r.Cama__c != null ? lOpp[0].PlazaMiercoles__r.Cama__c.left(lOpp[0].PlazaMiercoles__r.Cama__c.length()-1) : '');    
            dom.XmlNode PlazaCDJ = iDatos.addChildElement('PLAZACDJ', null, null).addTextNode(lOpp[0].PlazaJueves__r.Cama__c != null ? lOpp[0].PlazaJueves__r.Cama__c.left(lOpp[0].PlazaJueves__r.Cama__c.length()-1) : '');    
            dom.XmlNode PlazaCDV = iDatos.addChildElement('PLAZACDV', null, null).addTextNode(lOpp[0].PlazaViernes__r.Cama__c != null ? lOpp[0].PlazaViernes__r.Cama__c.left(lOpp[0].PlazaViernes__r.Cama__c.length()-1) : '');    
            dom.XmlNode PlazaCDS = iDatos.addChildElement('PLAZACDS', null, null).addTextNode(lOpp[0].PlazaSabado__r.Cama__c != null ? lOpp[0].PlazaSabado__r.Cama__c.left(lOpp[0].PlazaSabado__r.Cama__c.length()-1) : '');    
            dom.XmlNode PlazaCDD = iDatos.addChildElement('PLAZACDD', null, null).addTextNode(lOpp[0].PlazaDomingo__r.Cama__c != null ? lOpp[0].PlazaDomingo__r.Cama__c.left(lOpp[0].PlazaDomingo__r.Cama__c.length()-1) : '');    

            dom.XmlNode DBNAC = iDatos.addChildElement('DBNAC', null, null);
            dom.XmlNode DBNAV = iDatos.addChildElement('DBNAV', null, null);
            dom.XmlNode DBNAA = iDatos.addChildElement('DBNAA', null, null);
            dom.XmlNode DBUPN = iDatos.addChildElement('DBUPN', null, null);
            dom.XmlNode DBTPN = iDatos.addChildElement('DBTPN', null, null);
            dom.XmlNode DBFUM = iDatos.addChildElement('DBFUM', null, null);
            dom.XmlNode DBEAN = iDatos.addChildElement('DBEAN', null, null);
            dom.XmlNode DBPFM = iDatos.addChildElement('DBPFM', null, null);
            dom.XmlNode DBATR = iDatos.addChildElement('DBATR', null, null);
            dom.XmlNode DBAYD = iDatos.addChildElement('DBAYD', null, null);
            dom.XmlNode DBDBN = iDatos.addChildElement('DBDBN', null, null);
            dom.XmlNode DBTDT = iDatos.addChildElement('DBTDT', null, null);

            dom.XmlNode ODCIN = iDatos.addChildElement('ODCIN', null, null);
            dom.XmlNode ODIVL = iDatos.addChildElement('ODIVL', null, null);
            dom.XmlNode ODAIJ = iDatos.addChildElement('ODAIJ', null, null);
            dom.XmlNode ODTAIJ = iDatos.addChildElement('ODTAIJ', null, null);
            dom.XmlNode ODSDF = iDatos.addChildElement('ODSDF', null, null);
            dom.XmlNode ODDRI = iDatos.addChildElement('ODDRI', null, null);

            dom.XmlNode DMOX = iDatos.addChildElement('DMOX', null, null);
            dom.XmlNode DMSJ = iDatos.addChildElement('DMSJ', null, null);
            dom.XmlNode DMSN = iDatos.addChildElement('DMSN', null, null);
            dom.XmlNode DMAL = iDatos.addChildElement('DMAL', null, null);
            dom.XmlNode DMSG = iDatos.addChildElement('DMSG', null, null);
            dom.XmlNode DMPD = iDatos.addChildElement('DMPD', null, null);
            dom.XmlNode DMSB = iDatos.addChildElement('DMSB', null, null);
            dom.XmlNode DMIN = iDatos.addChildElement('DMIN', null, null);

            dom.XmlNode EMDC = iDatos.addChildElement('EMDC', null, null);
            dom.XmlNode EMAG = iDatos.addChildElement('EMAG', null, null);
            dom.XmlNode EMVG = iDatos.addChildElement('EMVG', null, null);
            dom.XmlNode EMRF = iDatos.addChildElement('EMRF', null, null);
            dom.XmlNode EMDS = iDatos.addChildElement('EMDS', null, null);

            dom.XmlNode OBS = iDatos.addChildElement('OBS', null, null);

            Integer counter = 1;
            Map<String, Id> mapRoleContactId = new Map<String,Id>();
            
            // IF LNAME1 == NULL --> NO SE HA RELLENADO PRIMER FAMILIAR
            //      OCR DECISOR ====> PRIMER FAMILIAR
            // IF LNAME2 == NULL --> NO SE HA RELLENADO SEGUNDO FAMILIAR
            //      OCR DECISOR2 EXISTE ==> SEGUNDO FAMILIAR
            //      OCR DECISOR2 NO EXISTE ==> INFLUYENTE ==> SEGUNDO FAMILIAR

            // Asignamos los parámetros de los contactos relacionados
            for(OpportunityContactRole ocr : lOcr){
                //comprobación para que el id de oportunidad se rellene solo una vez
                if(String.isBlank(FEXNR.getText()) ){
                    FEXNR.addTextNode(ocr.OpportunityId);
                }
                // Controlamos cuantos ocr nos quedan por procesar para saber que ocr hay que asignar a segundo familiar con el contador y el tamaño de la lista
                if( ocr.Role == 'Residente' && String.isBlank(VNAME.getText()) ){
                    
                    mapRoleContactId.put('Residente', ocr.ContactId);
                    
                    // Contacto Residente
                    VNAME.addTextNode(ocr.Contact.LastName);  
                    NNAME.addTextNode(ocr.Contact.FirstName != null ? ocr.Contact.FirstName : '');   
                    //BIRTH_NAME.addTextNode(ocr.Contact.FirstName != null ? ocr.Contact.FirstName : '');
                    // Generamos el string de la fecha con el formato yyyy-mm-dd  
                    sBirthDateYear = ocr.Contact.BirthDate != null ? String.valueOf(ocr.Contact.BirthDate.year()) : null;
                    sBirthDateMonth = ocr.Contact.BirthDate != null ? (String.valueOf(ocr.Contact.BirthDate.month()).length() > 1 ? String.valueOf(ocr.Contact.BirthDate.month()) : '0' + ocr.Contact.BirthDate.month()) : null;
                    sBirthDateDay = ocr.Contact.BirthDate != null ? (String.valueOf(ocr.Contact.BirthDate.day()).length() > 1 ? String.valueOf(ocr.Contact.BirthDate.day()) : '0' + ocr.Contact.BirthDate.day()) : null;
                    sBirthDate = ocr.Contact.BirthDate != null ? sBirthDateYear + '-' + sBirthDateMonth + '-' + sBirthDateDay : ''; 
                    GBDAT.addTextNode(sBirthDate);                  
                    GSCHL.addTextNode(ocr.Contact.Sexo__c != null ? ocr.Contact.Sexo__c : ''); 
                    DOC_NO.addTextNode(ocr.Contact.NumeroDocumento__c != null ? ocr.Contact.NumeroDocumento__c : ''); 
                    DOC_TYP.addTextNode(ocr.Contact.TipoDocumento__c != null ? ocr.Contact.TipoDocumento__c : '');  
                    STREET.addTextNode(ocr.Contact.MailingStreet != null ? ocr.Contact.MailingStreet.left(60) : '');  
                    STREET2.addTextNode(ocr.Contact.MailingStreet != null ? ocr.Contact.MailingStreet.right(ocr.Contact.MailingStreet.length()-60).left(60) : '');    
                    HOUSE_NUM1.addTextNode('');  
                    POST_CODE1.addTextNode(ocr.Contact.MailingPostalCode != null ? ocr.Contact.MailingPostalCode : '');    
                    CITY1.addTextNode(ocr.Contact.MailingCity != null ? ocr.Contact.MailingCity : '');   
                    TEL_NUMBER.addTextNode(ocr.Contact.MobilePhone != null ? ocr.Contact.MobilePhone : '');    
                    TEL_NUMBER1.addTextNode(ocr.Contact.HomePhone != null ? ocr.Contact.HomePhone : '');  
                    E_MAIL.addTextNode(ocr.Contact.Email != null ? ocr.Contact.Email : '');  

                    DBNAC.addTextNode(ocr.Contact.NecesitaAyudaParaComer__c == 'Sí'? '1': ocr.Contact.NecesitaAyudaParaComer__c == 'No'? '2': '');
                    DBNAV.addTextNode(ocr.Contact.NecesitaAyudaParaVestirse__c == 'Sí'? '1': ocr.Contact.NecesitaAyudaParaVestirse__c == 'No'? '2': '');
                    DBNAA.addTextNode(ocr.Contact.NecesitaAyudaParaAsearse__c == 'Sí'? '1': ocr.Contact.NecesitaAyudaParaAsearse__c == 'No'? '2': '');
                    DBUPN.addTextNode(ocr.Contact.UsaPanyales__c == 'Sí'? '1': ocr.Contact.UsaPanyales__c == 'No'? '2': '');
                    DBTPN.addTextNode(ocr.Contact.TipoPanal__c == 'Día'? '1': ocr.Contact.TipoPanal__c == 'Noche'? '2': ocr.Contact.TipoPanal__c == 'Día y Noche'? '3':'');
                    DBFUM.addTextNode(ocr.Contact.EsFumador__c == 'Sí'? '1': ocr.Contact.EsFumador__c == 'No'? '2': '');
                    DBEAN.addTextNode(ocr.Contact.ExpresaAdecuadamenteSusNecesidades__c == 'Sí'? '1': ocr.Contact.ExpresaAdecuadamenteSusNecesidades__c == 'No'? '2': '');
                    DBPFM.addTextNode(ocr.Contact.TieneProblemasFrecuentesDeMemoria__c == 'Sí'? '1': ocr.Contact.TieneProblemasFrecuentesDeMemoria__c == 'No'? '2': '');
                    DBATR.addTextNode(ocr.Contact.EsAutonomoEnSusTraslados__c == 'Sí'? '1': ocr.Contact.EsAutonomoEnSusTraslados__c == 'No'? '2': '');

                if(ocr.Contact.ObjetoAyuda__c != null){
                        String ObjetoAyuda='';
                        if(ocr.Contact.ObjetoAyuda__c.contains('Muletas')){
                            ObjetoAyuda+='A';
                        }
                        if(ocr.Contact.ObjetoAyuda__c.contains('Silla Ruedas')){
                            ObjetoAyuda+='B';
                        }
                        if(ocr.Contact.ObjetoAyuda__c.contains('Andador')){
                            ObjetoAyuda+='C';
                        }
                        if(ocr.Contact.ObjetoAyuda__c.contains('Silla Motor')){
                            ObjetoAyuda+='D';
                        }
                        DBAYD.addTextNode(ObjetoAyuda);
                    }
                    DBDBN.addTextNode(ocr.Contact.DuermeBienPaciente__c == 'Sí'? '1': ocr.Contact.DuermeBienPaciente__c == 'No'? '2': '');
                    DBTDT.addTextNode(ocr.Contact.TipoDieta__c != null? ocr.Contact.TipoDieta__c:'');

                    ODCIN.addTextNode(ocr.Contact.ConscienteDeSuIngresoEnElCentro__c == 'Sí'? '1': ocr.Contact.ConscienteDeSuIngresoEnElCentro__c == 'No'? '2': '');
                    ODIVL.addTextNode(ocr.Contact.LoHaceVoluntariamente__c == 'Sí'? '1': ocr.Contact.LoHaceVoluntariamente__c == 'No'? '2': '');
                    ODAIJ.addTextNode(ocr.Contact.SolicitudAutorizInternamJudicial__c == 'Sí'? '1': ocr.Contact.SolicitudAutorizInternamJudicial__c == 'No'? '2': '');
                    ODTAIJ.addTextNode(ocr.Contact.EncargadoTramiteAutorizacionInternam__c == 'Centro'? '1': ocr.Contact.EncargadoTramiteAutorizacionInternam__c == 'Otros'? '2': '');
                    ODSDF.addTextNode(ocr.Contact.SeguroDeDefuncion__c == 'Sí'? '1': ocr.Contact.SeguroDeDefuncion__c == 'No'? '2': '');
                    ODDRI.addTextNode(ocr.Contact.DocumentoEntregadoRecomendacionesIngreso__c == true? '1': '2');
                    
                    DMOX.addTextNode(ocr.Contact.Oxigeno__c == 'Sí'? '1': ocr.Contact.Oxigeno__c == 'No'? '2': '');
                    DMSJ.addTextNode(ocr.Contact.Sujeccion__c == 'Sí'? '1': ocr.Contact.Sujeccion__c == 'No'? '2': '');
                    DMSN.addTextNode(ocr.Contact.SuplementoNutricional__c == 'Sí'? '1': ocr.Contact.SuplementoNutricional__c == 'No'? '2': '');
                    DMAL.addTextNode(ocr.Contact.Alergias__c == 'Sí'? '1': ocr.Contact.Alergias__c == 'No'? '2': '');
                    DMSG.addTextNode(ocr.Contact.SondaNasogastrica__c == 'Sí'? '1': ocr.Contact.SondaNasogastrica__c == 'No'? '2': '');
                    DMPD.addTextNode(ocr.Contact.ProblemasDeDeglucion__c == 'Sí'? '1': ocr.Contact.ProblemasDeDeglucion__c == 'No'? '2': '');
                    DMSB.addTextNode(ocr.Contact.SondaVesical__c == 'Sí'? '1': ocr.Contact.SondaVesical__c == 'No'? '2': '');
                    DMIN.addTextNode(ocr.Contact.Incontinencia__c == 'Sí'? '1': ocr.Contact.Incontinencia__c == 'No'? '2': '');

                    EMDC.addTextNode(ocr.Contact.DeterioroCognitivo__c == 'Sí'? '1': ocr.Contact.DeterioroCognitivo__c == 'No'? '2': '');
                    EMAG.addTextNode(ocr.Contact.Agitacion__c == 'Sí'? '1': ocr.Contact.Agitacion__c == 'No'? '2': '');
                    EMVG.addTextNode(ocr.Contact.Vagabundeo__c == 'Sí'? '1': ocr.Contact.Vagabundeo__c == 'No'? '2': '');
                    EMRF.addTextNode(ocr.Contact.RiesgoDeFuga__c == 'Sí'? '1': ocr.Contact.RiesgoDeFuga__c == 'No'? '2': '');
                    EMDS.addTextNode(ocr.Contact.Desorientado__c == 'Sí'? '1': ocr.Contact.Desorientado__c == 'No'? '2': '');

                    OBS.addTextNode(ocr.Contact.Observaciones__c!= null? ocr.Contact.Observaciones__c: '');           
                }

                // El primer familiar esta vacio y hemos encontrado un decisor --> Primer familiar = Decisor
                if( ocr.Role == 'Decisor' && String.isBlank(LNAME1.getText()) ){
                    mapRoleContactId.put('Familiar1', ocr.ContactId);

                    // Primer familiar
                    LNAME1.addTextNode(ocr.Contact.LastName);
                    FNAME1.addTextNode(ocr.Contact.FirstName != null ? ocr.Contact.FirstName : '');  
                    RELSH1.addTextNode(ocr.Contact.Parentesco__c != null ? ocr.Contact.Parentesco__c : '');  
                    STREET1.addTextNode(ocr.Contact.MailingStreet != null ? ocr.Contact.MailingStreet.left(60) : '');  
                    STREET3.addTextNode(ocr.Contact.MailingStreet != null ? ocr.Contact.MailingStreet.right(ocr.Contact.MailingStreet.length()-60).left(60) : '');   
                    HOUSE_NUM1_2.addTextNode('');  
                    POST_CODE1_2.addTextNode(ocr.Contact.MailingPostalCode != null ? ocr.Contact.MailingPostalCode : '');      
                    CITY1_2.addTextNode(ocr.Contact.MailingCity != null ? ocr.Contact.MailingCity : '');  
                    TEL_NUMBER2.addTextNode(ocr.Contact.MobilePhone != null ? ocr.Contact.MobilePhone : '');  
                    E_MAIL_2.addTextNode(ocr.Contact.Email != null ? ocr.Contact.Email : '');

                } else if( String.isBlank(LNAME2.getText()) && String.isNotBlank(LNAME1.getText()) ){
                    // Si tenemos 2 decisores, por lo tanto el segundo decisor es el segundo familiar
                    // Se ha encontrado segundo decisor Y NO ES EL MISMO QUE EL PRIMERO
                    if( ocr.Role == 'Decisor' && mapRoleContactId.get('Familiar1') != ocr.ContactId){
                        mapRoleContactId.put('Familiar2', ocr.ContactId);

                        // Segundo familiar (si lo hubiera)
                        LNAME2.addTextNode(ocr.Contact.LastName);   
                        FNAME2.addTextNode(ocr.Contact.FirstName != null ? ocr.Contact.FirstName : '');  
                        RELSH2.addTextNode(ocr.Contact.Parentesco__c != null ? ocr.Contact.Parentesco__c : '');  
                        STREET4.addTextNode(ocr.Contact.MailingStreet != null ? ocr.Contact.MailingStreet.left(60) : '');  
                        STREET5.addTextNode(ocr.Contact.MailingStreet != null ? ocr.Contact.MailingStreet.right(ocr.Contact.MailingStreet.length()-60).left(60) : '');   
                        HOUSE_NUM1_3.addTextNode('');    
                        POST_CODE1_3.addTextNode(ocr.Contact.MailingPostalCode != null ? ocr.Contact.MailingPostalCode : '');      
                        CITY1_3.addTextNode(ocr.Contact.MailingCity != null ? ocr.Contact.MailingCity : '');  
                        TEL_NUMBER3.addTextNode(ocr.Contact.MobilePhone != null ? ocr.Contact.MobilePhone : '');  
                        E_MAIL_3.addTextNode(ocr.Contact.Email != null ? ocr.Contact.Email : ''); 
                        
                    } else if ( ocr.Role == 'Influyente' && counter == lOcr.size() ){
                        mapRoleContactId.put('Familiar2', ocr.ContactId);
                        
                        // El segundo ocr no es decisor, pero al no haber mas se rellena con el que queda como segundo familiar
                        // Segundo familiar (si lo hubiera)
                        LNAME2.addTextNode(ocr.Contact.LastName);   
                        FNAME2.addTextNode(ocr.Contact.FirstName != null ? ocr.Contact.FirstName : '');  
                        RELSH2.addTextNode(ocr.Contact.Parentesco__c != null ? ocr.Contact.Parentesco__c : '');  
                        STREET4.addTextNode(ocr.Contact.MailingStreet != null ? ocr.Contact.MailingStreet.left(60) : '');  
                        STREET5.addTextNode(ocr.Contact.MailingStreet != null ? ocr.Contact.MailingStreet.right(ocr.Contact.MailingStreet.length()-60).left(60) : '');   
                        HOUSE_NUM1_3.addTextNode('');    
                        POST_CODE1_3.addTextNode(ocr.Contact.MailingPostalCode != null ? ocr.Contact.MailingPostalCode : '');      
                        CITY1_3.addTextNode(ocr.Contact.MailingCity != null ? ocr.Contact.MailingCity : '');  
                        TEL_NUMBER3.addTextNode(ocr.Contact.MobilePhone != null ? ocr.Contact.MobilePhone : '');  
                        E_MAIL_3.addTextNode(ocr.Contact.Email != null ? ocr.Contact.Email : '');   
                    }

                }
                counter++;
            }
            

            // Mandamos el paquete XML para realiar la llamada al servicio
            HttpResponse response = makeCallOut(docReq);   
            
            // Si da un error 500 no leemos la respuesta, directamente almacenamos un error en la oportunidad
            ResponseData rData = new ResponseData();
            if(response.getStatusCode() == 200){
                // Deserializamos la respuesta para sacar la información
                rData = deserializeResponse(response);
            }else{
                rData.lType = new List<String>{fetchResponses('err500').Error_Code__c};
                rData.lMessage = new List<String>{fetchResponses('err500').Error_Description__c};
                CreateErrorLog(fetchResponses('err500').Error_Code__c, fetchResponses('err500').Error_Description__c, docReq);
            }        

            // Actualizamos los contactos afectados y la oportunidad
            Opportunity oppUpd = new Opportunity(
                Id = oppId,
                IdExternoSAP__c = rData.idEpisodio,
                CodeSAPResponse__c = rData.lType.toString(),
                MessageSAPResponse__c = rData.lMessage.toString()            
            );        
            
            if((rData.lType.toString() != '(S,S)')&&(rData.lType.toString() != '(S,E,S)'))
            {
                CreateErrorLog(rData.lType.toString(), rData.lMessage.toString(), docReq);
            }

            if(mapRoleContactId.get('Residente')!=null){
                residenteUpd = new Contact(
                Id = mapRoleContactId.get('Residente'),
                IdExternoSAP__c = rData.idResidente
                );
                lCont2Upd.add(residenteUpd);
            } 
            
            if(mapRoleContactId.get('Familiar1')!=null){
                familiar1Upd = new Contact(
                    Id = mapRoleContactId.get('Familiar1'),
                    IdExternoSAPContactos__c = rData.idFamiliar1
                );
                lCont2Upd.add(familiar1Upd);                
            } 
            
            if(mapRoleContactId.get('Familiar2')!=null){
                familiar2Upd = new Contact(
                    Id = mapRoleContactId.get('Familiar2'),
                    IdExternoSAPContactos__c = rData.idFamiliar2
                );
                lCont2Upd.add(familiar2Upd);
            }

            
            // Actualizamos las plazas de Centro de día a ocupada y si es de residencia también para establecer el tipo de plaza (pública o privada) en función del tipo de plaza definido en la oportunidad
            if( lOpp[0].Plaza__c != null ){
                auxPlaza = new Plaza__c(
                    Id = lOpp[0].Plaza__c,
                    TipoPlaza__c = lOpp[0].TipoPlaza__c,
                    PlazaOcupada__c = true
                );
                lPlazas2Upd.add(auxPlaza);
            }
            if( lOpp[0].PlazaLunes__c != null ){
                auxPlaza = new Plaza__c(
                    Id = lOpp[0].PlazaLunes__c,
                    PlazaOcupada__c = true
                );
                lPlazas2Upd.add(auxPlaza);
            }
            if( lOpp[0].PlazaMartes__c != null ){
                auxPlaza = new Plaza__c(
                    Id = lOpp[0].PlazaMartes__c,
                    PlazaOcupada__c = true
                );
                lPlazas2Upd.add(auxPlaza);
            }
            if( lOpp[0].PlazaMiercoles__c != null ){
                auxPlaza = new Plaza__c(
                    Id = lOpp[0].PlazaMiercoles__c,
                    PlazaOcupada__c = true
                );
                lPlazas2Upd.add(auxPlaza);
            }
            if( lOpp[0].PlazaJueves__c != null ){
                auxPlaza = new Plaza__c(
                    Id = lOpp[0].PlazaJueves__c,
                    PlazaOcupada__c = true
                );
                lPlazas2Upd.add(auxPlaza);
            }
            if( lOpp[0].PlazaViernes__c != null ){
                auxPlaza = new Plaza__c(
                    Id = lOpp[0].PlazaViernes__c,
                    PlazaOcupada__c = true
                );
                lPlazas2Upd.add(auxPlaza);
            }
            if( lOpp[0].PlazaSabado__c != null ){
                auxPlaza = new Plaza__c(
                    Id = lOpp[0].PlazaSabado__c,
                    PlazaOcupada__c = true
                );
                lPlazas2Upd.add(auxPlaza);
            }
            if( lOpp[0].PlazaDomingo__c != null ){
                auxPlaza = new Plaza__c(
                    Id = lOpp[0].PlazaDomingo__c,
                    PlazaOcupada__c = true
                );
                lPlazas2Upd.add(auxPlaza);
            }
            update lPlazas2Upd;

            // Actualizamos los registros
            update lCont2Upd;
            update oppUpd;  
        }       

    }
/* 
    @description Método que se realiza el callout al servicio externo y actualiza los registros en función del resultado
    @param opportunityId Id de la oportunidad a enviar
    @return void no se realiza devolución
    */
    public static HttpResponse makeCallOut(Dom.Document docReq) {

        // Recuperamos la condiguración con los datos de conexión
        IntegracionSAP__mdt config = [SELECT isSandbox FROM Organization].get(0).isSandbox ? IntegracionSAP__mdt.getInstance('Desarrollo') : IntegracionSAP__mdt.getInstance('Produccion');

        // Montamos la llamada con la información obtenida
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        System.debug('XXXx '+config.Endpoint__c);
        request.setEndpoint(config.Endpoint__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml');
        // Codificamoas las credenciales en base64
        String sBase64 = EncodingUtil.base64Encode(Blob.valueOf(config.UsuarioLogin__c + ':' + config.PasswordLogin__c));
        request.setHeader('Authorization', 'Basic ' + sBase64);
        request.setTimeout(120000);
        //request.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:rfc:functions">		   <soapenv:Body>			  <urn:ZISH_CREAR_ADMISION_SF>				 <I_DATOS>					<EINRI>0201</EINRI>					<VNAME>asd</VNAME>					<NNAME>qwerty</NNAME>					<GSCHL>M</GSCHL>					<DOC_NO>12345678I</DOC_NO>					<STREET>avenida de europa</STREET>					<HOUSE_NUM1>10</HOUSE_NUM1>					<POST_CODE1>28046</POST_CODE1>					<CITY1>Madrid</CITY1>					<BWART>AD</BWART> <!-- AD (centro dia) o AI (residencia) -->					<BEKAT>CRM</BEKAT> <!-- CRM o CDCRM -->					<ORGPF>0201MD0</ORGPF> <!-- Consultar excel de unidades organizativas -->					<BWIDT>2021-08-01</BWIDT> <!-- formato YYYY-MM-DD -->					<FATYP>I</FATYP> <!-- D (centro dia) o I (residencia)-->					<PRIVADO></PRIVADO>				 </I_DATOS>			  </urn:ZISH_CREAR_ADMISION_SF>		   </soapenv:Body>		</soapenv:Envelope>');
        request.setBody(docReq.toXmlString().replace('<?xml version="1.0" encoding="UTF-8"?>',''));
        System.debug('@@ Enviado: ' + request.getBody());
        HttpResponse response = http.send(request);
        System.debug('@@ Respuesta: ' + response.getBody());

        return response;
    }

    /* 
    @description Método que recibe la respuesta y la deserializa para obtener la información
    @param opportunityId Id de la oportunidad a enviar
    @return void no se realiza devolución
    */
    public static ResponseData deserializeResponse(HttpResponse response) {

        // Variables que almacenan los datos de vuelta
        String idResidente, idEpisodio, idFamiliar1, idFamiliar2;
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
                    if( bodyChild.getName() == 'ZISH_CREAR_ADMISION_SFResponse'){
                        for(Dom.XMLNode zishChild : bodyChild.getChildElements()) {
                            //System.debug(zishChild.getName());

                            // Almacenamos la información recibida en variables
                            idResidente = zishChild.getName() == 'E_PATNR' ? zishChild.getText() : idResidente;
                            idEpisodio = zishChild.getName() == 'E_FALNR' ? zishChild.getText() : idEpisodio;
                            idFamiliar1 = zishChild.getName() == 'E_PARTNER1' ? zishChild.getText() : idFamiliar1;
                            idFamiliar2 = zishChild.getName() == 'E_PARTNER2' ? zishChild.getText() : idFamiliar2;

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
        rData.idResidente = idResidente;
        rData.idEpisodio = idEpisodio;
        rData.idFamiliar1 = idFamiliar1;
        rData.idFamiliar2 = idFamiliar2;
        rData.lMessage = lMessage;
        rData.lType = lType;

        return rData;
    }


    /* 
    @description Clase wrapper para almacenar los datos recibidos de respuesta    
    */
    private class ResponseData {
        String idResidente {get;set;}
        String idEpisodio {get;set;}
        String idFamiliar1 {get;set;}
        String idFamiliar2 {get;set;}
        List<String> lMessage {get;set;}
        List<String> lType {get;set;}
    }


    /* 
    @description Método que se realiza el callout al servicio externo y actualiza los registros en función del resultado
    @param opportunityId Id de la oportunidad a enviar
    @return void no se realiza devolución
    */
    /*@future(callout=true)
    public static void makeCallOutSOAP(Id oppId) {

        system.debug('@@ makecallout');        

        // Recibimos el Id de la oportunidad a enviar

        // Recuperamos todos los datos necesarios para enviar a SAP

        // Montamos la llamada con la información obtenida
        sapComDocumentSapRfcFunctions.ZISH_ST_ADMISION wrapperData = new sapComDocumentSapRfcFunctions.ZISH_ST_ADMISION();
        

        // Llamamos al método futuro que realiza la llamada
        sapComDocumentSapRfcFunctions.zbind_adm zbind = new sapComDocumentSapRfcFunctions.zbind_adm();
        sapComDocumentSapRfcFunctions.ZISH_CREAR_ADMISION_SFResponse_element response = zbind.ZISH_CREAR_ADMISION_SF(wrapperData);

        system.debug('@@Response: ');
        system.debug('E_FALNR: ' + response.E_FALNR);
        system.debug('E_PARTNER1: ' + response.E_PARTNER1);
        system.debug('E_FALNR: ' + response.E_PARTNER2);
        system.debug('E_FALNR: ' + response.E_PATNR);
        system.debug('E_FALNR: ' + response.E_RETURN);

        // Recibimos el paquete con la info y hacemos la llamada al servicio

        // Recibimos el resultado y actualizamos la oportunidad para meter los datos en los campos
       
    }*/

    /**
	@description	Método para recuperar los códigos y mensajes de respuesta
	@param 			String errReference nombre del Custom Metadata Type que se quiere recuperar
	@return			Mensaje_Error__mdt con los campos de la respuesta
	*/ 
    private static Mensaje_Error__mdt fetchResponses(String errReference){
        Mensaje_Error__mdt response = Mensaje_Error__mdt.getInstance(errReference);
        Return response;
    }

    public class CerrarOportunidadException extends Exception {}
    
    /* 
    @description Método que calcula la letra del DNI en base al número que entre.
    @param numeroDNI número del DNI
    @return string, letra del DNI
    */

    public static string CheckDNI (integer numeroDNI){
        integer i = math.mod(numeroDNI,23);
        return i == 0? 'T': i == 1? 'R': i == 2? 'W': i == 3? 'A': i == 4? 'G': i == 5? 'M': i == 6? 'Y': i == 7? 'F': i == 8? 'P': i == 9? 'D': i == 10? 'X': i == 11? 'B': i == 12? 'N': i == 13? 'J': i == 14? 'Z': i == 15? 'S': i == 16? 'Q': i == 17? 'V': i == 18? 'H': i == 19? 'L': i == 20? 'C': i == 21? 'K': i == 22? 'E':'ERROR';
    }

    public static void CreateErrorLog(String Code, String ErrorDescription, Dom.Document docReq){
        RegistrosDeErrores__c ErrorGenerado = new RegistrosDeErrores__c();
        
        ErrorGenerado.CodigoError__c = 'SAP';
        ErrorGenerado.DescripcionError__c = Code + ' ' + ErrorDescription;
        ErrorGenerado.MensajeRecibido__c = docReq.toXmlString();
        ErrorGenerado.ClaseGeneradora__c = 'TriggerOpportunityHandler';

        insert ErrorGenerado;
    }

}