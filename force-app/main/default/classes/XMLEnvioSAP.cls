public with sharing class XMLEnvioSAP {

    @InvocableMethod(label='Envio SAP Erroneo' description='Método que saca un archivo XML de todas las oportunidades que no fueron enviadas a SAP correctamente')

    public static List<String> XMLEnvioSAPMetodo() {

        List<String> CabeceraDatos = new List<String>();
        List<String> DatosEnviar = new List<String>();

        map<String, String> mEnvioDato = new map<String,String>();
        String IdOppAnterior;

        String sBirthDateYear = null;
        String sBirthDateMonth = null;
        String sBirthDateDay = null;
        String sBirthDate = null;

        String sFechaPlanificadaYear = null;
        String sFechaPlanificadaMonth = null;
        String sFechaPlanificadaDay = null;
        String sFechaPlanificada = null;

        List<OpportunityContactRole> OportunidadesSinEnviar = [SELECT Id, ContactId, Role, Contact.LastName,  OpportunityId, Contact.FirstName, Contact.Sexo__c,
        Contact.NumeroDocumento__c,Contact.MailingStreet,Contact.MailingPostalCode,Contact.MailingCity,Contact.Birthdate, Contact.MobilePhone, Contact.HomePhone,
        Contact.Email, Contact.Parentesco__c,

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

        Opportunity.ResidenciaIngreso__r.CodigoCentroSAP__c,
        Opportunity.Plaza__r.Cama__c,
        Opportunity.FechaIngresoPlanificado__c,

        Opportunity.PlazaLunes__r.Cama__c,
        Opportunity.PlazaMartes__r.Cama__c,
        Opportunity.PlazaMiercoles__r.Cama__c,
        Opportunity.PlazaJueves__r.Cama__c,
        Opportunity.PlazaViernes__r.Cama__c,
        Opportunity.PlazaSabado__r.Cama__c,
        Opportunity.PlazaDomingo__r.Cama__c,

        Opportunity.TipoPlaza__c




        FROM OpportunityContactRole
        WHERE Opportunity.StageName = 'Envío SAP' AND Opportunity.CodeSAPResponse__c != '(S, S)' AND Opportunity.IdExternoSAP__c = null
        ORDER BY OpportunityId];

        CabeceraDatos.add('EINRI');
        CabeceraDatos.add('VNAME');
        CabeceraDatos.add('NNAME');
        CabeceraDatos.add('BIRTH_NAME');
        CabeceraDatos.add('GBDAT');
        CabeceraDatos.add('GSCHL');
        CabeceraDatos.add('DOC_NO');
        CabeceraDatos.add('DOC_TYP');
        CabeceraDatos.add('STREET');
        CabeceraDatos.add('STREET2');
        CabeceraDatos.add('HOUSE_NUM1');
        CabeceraDatos.add('POST_CODE1');
        CabeceraDatos.add('CITY1');
        CabeceraDatos.add('TEL_NUMBER');
        CabeceraDatos.add('TEL_NUMBER1');
        CabeceraDatos.add('E_MAIL');
        CabeceraDatos.add('LNAME1');
        CabeceraDatos.add('FNAME1');
        CabeceraDatos.add('RELSH1');
        CabeceraDatos.add('STREET1');
        CabeceraDatos.add('STREET3');
        CabeceraDatos.add('HOUSE_NUM1_2');
        CabeceraDatos.add('POST_CODE1_2');
        CabeceraDatos.add('CITY1_2');
        CabeceraDatos.add('TEL_NUMBER2');
        CabeceraDatos.add('E_MAIL_2');
        CabeceraDatos.add('FEXNR');
        CabeceraDatos.add('LNAME2');
        CabeceraDatos.add('FNAME2');
        CabeceraDatos.add('RELSH2');
        CabeceraDatos.add('STREET4');
        CabeceraDatos.add('STREET5');
        CabeceraDatos.add('HOUSE_NUM1_3');
        CabeceraDatos.add('POST_CODE1_3');
        CabeceraDatos.add('CITY1_3');
        CabeceraDatos.add('TEL_NUMBER3');
        CabeceraDatos.add('E_MAIL_3');
        CabeceraDatos.add('BWART');
        CabeceraDatos.add('BEKAT');
        CabeceraDatos.add('ORGPF');
        CabeceraDatos.add('BWIDT');
        CabeceraDatos.add('FATYP');
        CabeceraDatos.add('KZTXT');
        CabeceraDatos.add('PRIVADO');
        CabeceraDatos.add('KZTXT1');
        CabeceraDatos.add('PLAZACDL');
        CabeceraDatos.add('PLAZACDM');
        CabeceraDatos.add('PLAZACDX');
        CabeceraDatos.add('PLAZACDJ');
        CabeceraDatos.add('PLAZACDV');
        CabeceraDatos.add('PLAZACDS');
        CabeceraDatos.add('PLAZACDD');
        CabeceraDatos.add('DBNAC');
        CabeceraDatos.add('DBNAV');
        CabeceraDatos.add('DBNAA');
        CabeceraDatos.add('DBUPN');
        CabeceraDatos.add('DBTPN');
        CabeceraDatos.add('DBFUM');
        CabeceraDatos.add('DBEAN');
        CabeceraDatos.add('DBPFM');
        CabeceraDatos.add('DBATR');
        CabeceraDatos.add('DBAYD');
        CabeceraDatos.add('DBDBN');
        CabeceraDatos.add('DBTDT');
        CabeceraDatos.add('ODCIN');
        CabeceraDatos.add('ODIVL');
        CabeceraDatos.add('ODAIJ');
        CabeceraDatos.add('ODTAIJ');
        CabeceraDatos.add('ODSDF');
        CabeceraDatos.add('ODDRI');
        CabeceraDatos.add('DMOX');
        CabeceraDatos.add('DMSJ');
        CabeceraDatos.add('DMSN');
        CabeceraDatos.add('DMAL');
        CabeceraDatos.add('DMSG');
        CabeceraDatos.add('DMPD');
        CabeceraDatos.add('DMSB');
        CabeceraDatos.add('DMIN');
        CabeceraDatos.add('EMDC');
        CabeceraDatos.add('EMAG');
        CabeceraDatos.add('EMVG');
        CabeceraDatos.add('EMRF');
        CabeceraDatos.add('EMDS');
        CabeceraDatos.add('OBS');
        
        
        for(OpportunityContactRole ocr: OportunidadesSinEnviar){
            if(ocr.OpportunityId != IdOppAnterior && IdOppAnterior != null){
                
                DatosEnviar = CrearLista(DatosEnviar, mEnvioDato);
                mEnvioDato.clear();
            }
            if(String.isBlank(mEnvioDato.get('FEXNR')) || mEnvioDato.get('FEXNR') == null){
                mEnvioDato.put('FEXNR', ocr.OpportunityId);
                mEnvioDato.put('EINRI', (ocr.Opportunity.ResidenciaIngreso__r.CodigoCentroSAP__c)); 
                mEnvioDato.put('BWART', ocr.Opportunity.Plaza__r.Cama__c != null ? 'AI'  : 'AD'); 
                mEnvioDato.put('BEKAT', ocr.Opportunity.Plaza__r.Cama__c != null ? 'CRM'  : 'CDCRM'); 
                mEnvioDato.put('ORGPF', ocr.Opportunity.Plaza__r.Cama__c != null ? ocr.Opportunity.Plaza__r.Cama__c  : ''); 
                
                // Generamos el string de la fecha con el formato yyyy-mm-dd
                sFechaPlanificadaYear = ocr.Opportunity.FechaIngresoPlanificado__c != null ? String.valueOf(ocr.Opportunity.FechaIngresoPlanificado__c.year()) : null;
                sFechaPlanificadaMonth = ocr.Opportunity.FechaIngresoPlanificado__c != null ? (String.valueOf(ocr.Opportunity.FechaIngresoPlanificado__c.month()).length() > 1 ? String.valueOf(ocr.Opportunity.FechaIngresoPlanificado__c.month()) : '0' + ocr.Opportunity.FechaIngresoPlanificado__c.month()) : null;
                sFechaPlanificadaDay = ocr.Opportunity.FechaIngresoPlanificado__c != null ? (String.valueOf(ocr.Opportunity.FechaIngresoPlanificado__c.day()).length() > 1 ? String.valueOf(ocr.Opportunity.FechaIngresoPlanificado__c.day()) : '0' + ocr.Opportunity.FechaIngresoPlanificado__c.day()) : null;
                sFechaPlanificada = ocr.Opportunity.FechaIngresoPlanificado__c != null ? sFechaPlanificadaYear + '-' + sFechaPlanificadaMonth + '-' + sFechaPlanificadaDay : '';
                mEnvioDato.put('BWIDT', sFechaPlanificada);  
                mEnvioDato.put('FATYP', ocr.Opportunity.Plaza__r.Cama__c != null ? 'I'  : 'D'); 
                mEnvioDato.put('KZTXT',''); 
                mEnvioDato.put('PRIVADO',ocr.Opportunity.TipoPlaza__c != null ? ocr.Opportunity.TipoPlaza__c : ''); 
                mEnvioDato.put('KZTXT1', '');    
                mEnvioDato.put('PlazaCDL', ocr.Opportunity.PlazaLunes__r.Cama__c != null ? ocr.Opportunity.PlazaLunes__r.Cama__c.left(ocr.Opportunity.PlazaLunes__r.Cama__c.length()-1) : '');    
                mEnvioDato.put('PlazaCDM', ocr.Opportunity.PlazaMartes__r.Cama__c != null ? ocr.Opportunity.PlazaMartes__r.Cama__c.left(ocr.Opportunity.PlazaMartes__r.Cama__c.length()-1) : '');    
                mEnvioDato.put('PlazaCDX', ocr.Opportunity.PlazaMiercoles__r.Cama__c != null ? ocr.Opportunity.PlazaMiercoles__r.Cama__c.left(ocr.Opportunity.PlazaMiercoles__r.Cama__c.length()-1) : '');    
                mEnvioDato.put('PlazaCDJ', ocr.Opportunity.PlazaJueves__r.Cama__c != null ? ocr.Opportunity.PlazaJueves__r.Cama__c.left(ocr.Opportunity.PlazaJueves__r.Cama__c.length()-1) : '');    
                mEnvioDato.put('PlazaCDV', ocr.Opportunity.PlazaViernes__r.Cama__c != null ? ocr.Opportunity.PlazaViernes__r.Cama__c.left(ocr.Opportunity.PlazaViernes__r.Cama__c.length()-1) : '');    
                mEnvioDato.put('PlazaCDS', ocr.Opportunity.PlazaSabado__r.Cama__c != null ? ocr.Opportunity.PlazaSabado__r.Cama__c.left(ocr.Opportunity.PlazaSabado__r.Cama__c.length()-1) : '');    
                mEnvioDato.put('PlazaCDD', ocr.Opportunity.PlazaDomingo__r.Cama__c != null ? ocr.Opportunity.PlazaDomingo__r.Cama__c.left(ocr.Opportunity.PlazaDomingo__r.Cama__c.length()-1) : '');    
            }
            // Controlamos cuantos ocr nos quedan por procesar para saber que ocr hay que asignar a segundo familiar con el contador y el tamaño de la lista
            if( ocr.Role == 'Residente' && String.isBlank(mEnvioDato.get('VNAME')) ){
                
                
                // Contacto Residente
                mEnvioDato.put('VNAME', ocr.Contact.LastName);  
                mEnvioDato.put('NNAME', ocr.Contact.FirstName != null ? ocr.Contact.FirstName : '');   
                //BIRTH_NAME.addTextNode(ocr.Contact.FirstName != null ? ocr.Contact.FirstName : '');
                // Generamos el string de la fecha con el formato yyyy-mm-dd
                  
                sBirthDateYear = ocr.Contact.BirthDate != null ? String.valueOf(ocr.Contact.BirthDate.year()) : null;
                sBirthDateMonth = ocr.Contact.BirthDate != null ? (String.valueOf(ocr.Contact.BirthDate.month()).length() > 1 ? String.valueOf(ocr.Contact.BirthDate.month()) : '0' + ocr.Contact.BirthDate.month()) : null;
                sBirthDateDay = ocr.Contact.BirthDate != null ? (String.valueOf(ocr.Contact.BirthDate.day()).length() > 1 ? String.valueOf(ocr.Contact.BirthDate.day()) : '0' + ocr.Contact.BirthDate.day()) : null;
                sBirthDate = ocr.Contact.BirthDate != null ? sBirthDateYear + '-' + sBirthDateMonth + '-' + sBirthDateDay : ''; 

                mEnvioDato.put('GBDAT', sBirthDate);                  
                mEnvioDato.put('GSCHL',ocr.Contact.Sexo__c != null ? ocr.Contact.Sexo__c : ''); 
                mEnvioDato.put('DOC_NO',ocr.Contact.NumeroDocumento__c != null ? ocr.Contact.NumeroDocumento__c : ''); 
                mEnvioDato.put('DOC_TYP',ocr.Contact.TipoDocumento__c != null ? ocr.Contact.TipoDocumento__c : '');  
                mEnvioDato.put('STREET',ocr.Contact.MailingStreet != null ? ocr.Contact.MailingStreet.left(60) : '');  
                mEnvioDato.put('STREET2',ocr.Contact.MailingStreet != null ? ocr.Contact.MailingStreet.right(ocr.Contact.MailingStreet.length()-60).left(60) : '');    
                mEnvioDato.put('HOUSE_NUM1','');  
                mEnvioDato.put('POST_CODE1',ocr.Contact.MailingPostalCode != null ? ocr.Contact.MailingPostalCode : '');    
                mEnvioDato.put('CITY1',ocr.Contact.MailingCity != null ? ocr.Contact.MailingCity : '');   
                mEnvioDato.put('TEL_NUMBER',ocr.Contact.MobilePhone != null ? ocr.Contact.MobilePhone : '');    
                mEnvioDato.put('TEL_NUMBER1',ocr.Contact.HomePhone != null ? ocr.Contact.HomePhone : '');  
                mEnvioDato.put('E_MAIL',ocr.Contact.Email != null ? ocr.Contact.Email : '');  

                mEnvioDato.put('DBNAC',ocr.Contact.NecesitaAyudaParaComer__c == 'Sí'? '1': ocr.Contact.NecesitaAyudaParaComer__c == 'No'? '2': '');
                mEnvioDato.put('DBNAV',ocr.Contact.NecesitaAyudaParaVestirse__c == 'Sí'? '1': ocr.Contact.NecesitaAyudaParaVestirse__c == 'No'? '2': '');
                mEnvioDato.put('DBNAA',ocr.Contact.NecesitaAyudaParaAsearse__c == 'Sí'? '1': ocr.Contact.NecesitaAyudaParaAsearse__c == 'No'? '2': '');
                mEnvioDato.put('DBUPN',ocr.Contact.UsaPanyales__c == 'Sí'? '1': ocr.Contact.UsaPanyales__c == 'No'? '2': '');
                mEnvioDato.put('DBTPN',ocr.Contact.TipoPanal__c == 'Día'? '1': ocr.Contact.TipoPanal__c == 'Noche'? '2': ocr.Contact.TipoPanal__c == 'Día y Noche'? '3':'');
                mEnvioDato.put('DBFUM',ocr.Contact.EsFumador__c == 'Sí'? '1': ocr.Contact.EsFumador__c == 'No'? '2': '');
                mEnvioDato.put('DBEAN',ocr.Contact.ExpresaAdecuadamenteSusNecesidades__c == 'Sí'? '1': ocr.Contact.ExpresaAdecuadamenteSusNecesidades__c == 'No'? '2': '');
                mEnvioDato.put('DBPFM',ocr.Contact.TieneProblemasFrecuentesDeMemoria__c == 'Sí'? '1': ocr.Contact.TieneProblemasFrecuentesDeMemoria__c == 'No'? '2': '');
                mEnvioDato.put('DBATR',ocr.Contact.EsAutonomoEnSusTraslados__c == 'Sí'? '1': ocr.Contact.EsAutonomoEnSusTraslados__c == 'No'? '2': '');

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
                    mEnvioDato.put('DBAYD',ObjetoAyuda);
                } else {
                    mEnvioDato.put('DBAYD','');
                }
                mEnvioDato.put('DBDBN',ocr.Contact.DuermeBienPaciente__c == 'Sí'? '1': ocr.Contact.DuermeBienPaciente__c == 'No'? '2': '');
                mEnvioDato.put('DBTDT',ocr.Contact.TipoDieta__c != null? ocr.Contact.TipoDieta__c:'');

                mEnvioDato.put('ODCIN',ocr.Contact.ConscienteDeSuIngresoEnElCentro__c == 'Sí'? '1': ocr.Contact.ConscienteDeSuIngresoEnElCentro__c == 'No'? '2': '');
                mEnvioDato.put('ODIVL',ocr.Contact.LoHaceVoluntariamente__c == 'Sí'? '1': ocr.Contact.LoHaceVoluntariamente__c == 'No'? '2': '');
                mEnvioDato.put('ODAIJ',ocr.Contact.SolicitudAutorizInternamJudicial__c == 'Sí'? '1': ocr.Contact.SolicitudAutorizInternamJudicial__c == 'No'? '2': '');
                mEnvioDato.put('ODTAIJ',ocr.Contact.EncargadoTramiteAutorizacionInternam__c == 'Centro'? '1': ocr.Contact.EncargadoTramiteAutorizacionInternam__c == 'Otros'? '2': '');
                mEnvioDato.put('ODSDF',ocr.Contact.SeguroDeDefuncion__c == 'Sí'? '1': ocr.Contact.SeguroDeDefuncion__c == 'No'? '2': '');
                mEnvioDato.put('ODDRI',ocr.Contact.DocumentoEntregadoRecomendacionesIngreso__c == true? '1': '2');
                
                mEnvioDato.put('DMOX',ocr.Contact.Oxigeno__c == 'Sí'? '1': ocr.Contact.Oxigeno__c == 'No'? '2': '');
                mEnvioDato.put('DMSJ',ocr.Contact.Sujeccion__c == 'Sí'? '1': ocr.Contact.Sujeccion__c == 'No'? '2': '');
                mEnvioDato.put('DMSN',ocr.Contact.SuplementoNutricional__c == 'Sí'? '1': ocr.Contact.SuplementoNutricional__c == 'No'? '2': '');
                mEnvioDato.put('DMAL',ocr.Contact.Alergias__c == 'Sí'? '1': ocr.Contact.Alergias__c == 'No'? '2': '');
                mEnvioDato.put('DMSG',ocr.Contact.SondaNasogastrica__c == 'Sí'? '1': ocr.Contact.SondaNasogastrica__c == 'No'? '2': '');
                mEnvioDato.put('DMPD',ocr.Contact.ProblemasDeDeglucion__c == 'Sí'? '1': ocr.Contact.ProblemasDeDeglucion__c == 'No'? '2': '');
                mEnvioDato.put('DMSB',ocr.Contact.SondaVesical__c == 'Sí'? '1': ocr.Contact.SondaVesical__c == 'No'? '2': '');
                mEnvioDato.put('DMIN',ocr.Contact.Incontinencia__c == 'Sí'? '1': ocr.Contact.Incontinencia__c == 'No'? '2': '');

                mEnvioDato.put('EMDC',ocr.Contact.DeterioroCognitivo__c == 'Sí'? '1': ocr.Contact.DeterioroCognitivo__c == 'No'? '2': '');
                mEnvioDato.put('EMAG',ocr.Contact.Agitacion__c == 'Sí'? '1': ocr.Contact.Agitacion__c == 'No'? '2': '');
                mEnvioDato.put('EMVG',ocr.Contact.Vagabundeo__c == 'Sí'? '1': ocr.Contact.Vagabundeo__c == 'No'? '2': '');
                mEnvioDato.put('EMRF',ocr.Contact.RiesgoDeFuga__c == 'Sí'? '1': ocr.Contact.RiesgoDeFuga__c == 'No'? '2': '');
                mEnvioDato.put('EMDS',ocr.Contact.Desorientado__c == 'Sí'? '1': ocr.Contact.Desorientado__c == 'No'? '2': '');

                mEnvioDato.put('OBS',ocr.Contact.Observaciones__c!= null? ocr.Contact.Observaciones__c: '');           
            }

            // El primer familiar esta vacio y hemos encontrado un decisor --> Primer familiar = Decisor
            if( ocr.Role == 'Decisor' && String.isBlank(mEnvioDato.get('LNAME1')) ){

                // Primer familiar
                mEnvioDato.put('LNAME1',ocr.Contact.LastName);
                mEnvioDato.put('FNAME1',ocr.Contact.FirstName != null ? ocr.Contact.FirstName : '');  
                mEnvioDato.put('RELSH1',ocr.Contact.Parentesco__c != null ? ocr.Contact.Parentesco__c : '');  
                mEnvioDato.put('STREET1',ocr.Contact.MailingStreet != null ? ocr.Contact.MailingStreet.left(60) : '');  
                mEnvioDato.put('STREET3',ocr.Contact.MailingStreet != null ? ocr.Contact.MailingStreet.right(ocr.Contact.MailingStreet.length()-60).left(60) : '');   
                mEnvioDato.put('HOUSE_NUM1_2','');  
                mEnvioDato.put('POST_CODE1_2',ocr.Contact.MailingPostalCode != null ? ocr.Contact.MailingPostalCode : '');      
                mEnvioDato.put('CITY1_2',ocr.Contact.MailingCity != null ? ocr.Contact.MailingCity : '');  
                mEnvioDato.put('TEL_NUMBER2',ocr.Contact.MobilePhone != null ? ocr.Contact.MobilePhone : '');  
                mEnvioDato.put('E_MAIL_2',ocr.Contact.Email != null ? ocr.Contact.Email : '');

            } else if( String.isBlank(mEnvioDato.get('LNAME2')) && String.isNotBlank(mEnvioDato.get('LNAME1')) ){
                // Si tenemos 2 decisores, por lo tanto el segundo decisor es el segundo familiar
                // Se ha encontrado segundo decisor Y NO ES EL MISMO QUE EL PRIMERO
                if( ocr.Role == 'Decisor'){

                    // Segundo familiar (si lo hubiera)
                    mEnvioDato.put('LNAME2',ocr.Contact.LastName);   
                    mEnvioDato.put('FNAME2',ocr.Contact.FirstName != null ? ocr.Contact.FirstName : '');  
                    mEnvioDato.put('RELSH2',ocr.Contact.Parentesco__c != null ? ocr.Contact.Parentesco__c : '');  
                    mEnvioDato.put('STREET4',ocr.Contact.MailingStreet != null ? ocr.Contact.MailingStreet.left(60) : '');  
                    mEnvioDato.put('STREET5',ocr.Contact.MailingStreet != null ? ocr.Contact.MailingStreet.right(ocr.Contact.MailingStreet.length()-60).left(60) : '');   
                    mEnvioDato.put('HOUSE_NUM1_3','');    
                    mEnvioDato.put('POST_CODE1_3',ocr.Contact.MailingPostalCode != null ? ocr.Contact.MailingPostalCode : '');      
                    mEnvioDato.put('CITY1_3',ocr.Contact.MailingCity != null ? ocr.Contact.MailingCity : '');  
                    mEnvioDato.put('TEL_NUMBER3',ocr.Contact.MobilePhone != null ? ocr.Contact.MobilePhone : '');  
                    mEnvioDato.put('E_MAIL_3',ocr.Contact.Email != null ? ocr.Contact.Email : ''); 
                    
                } else if ( ocr.Role == 'Influyente' ){
                    
                    // El segundo ocr no es decisor, pero al no haber mas se rellena con el que queda como segundo familiar
                    // Segundo familiar (si lo hubiera)
                    mEnvioDato.put('LNAME2',ocr.Contact.LastName);   
                    mEnvioDato.put('FNAME2',ocr.Contact.FirstName != null ? ocr.Contact.FirstName : '');  
                    mEnvioDato.put('RELSH2',ocr.Contact.Parentesco__c != null ? ocr.Contact.Parentesco__c : '');  
                    mEnvioDato.put('STREET4',ocr.Contact.MailingStreet != null ? ocr.Contact.MailingStreet.left(60) : '');  
                    mEnvioDato.put('STREET5',ocr.Contact.MailingStreet != null ? ocr.Contact.MailingStreet.right(ocr.Contact.MailingStreet.length()-60).left(60) : '');   
                    mEnvioDato.put('HOUSE_NUM1_3','');    
                    mEnvioDato.put('POST_CODE1_3',ocr.Contact.MailingPostalCode != null ? ocr.Contact.MailingPostalCode : '');      
                    mEnvioDato.put('CITY1_3',ocr.Contact.MailingCity != null ? ocr.Contact.MailingCity : '');  
                    mEnvioDato.put('TEL_NUMBER3',ocr.Contact.MobilePhone != null ? ocr.Contact.MobilePhone : '');  
                    mEnvioDato.put('E_MAIL_3',ocr.Contact.Email != null ? ocr.Contact.Email : '');   
                }

            }
            IdOppAnterior = ocr.OpportunityId;
        }
        DatosEnviar = CrearLista(DatosEnviar, mEnvioDato);
        mEnvioDato.clear();
        return crear(CabeceraDatos, DatosEnviar, 'Envio SAP erróneo');
    }
 

    public static List<String> crear(List<String> csvHeaders, List<String> csvRowList, String title){
        String headerRow = String.join(csvHeaders,';') + '\n';
        String concantenatedStr = headerRow;
        Integer i = 0;
        Integer rowListSize = csvRowList.size();
        //assuming the rowList is in the correct format and each object in the list is a new record
        for(String row :csvRowList){
           
            i++;
            concantenatedStr += (String)row + ((i != rowListSize) ? '\n' : '');//add new line
        }
        title += '.csv';
        return createFile(concantenatedStr, title);
    }

    public static List<String> createFile(String versionData, String title) {
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S'; //denotes it resides on Salesforce
        cv.Title = title; //title of the file
        cv.PathOnClient = title; // full path within Salesforce this can just be the name of file to be in the library
        cv.VersionData = Blob.valueOf(versionData); //file data
        insert cv;

        ContentDocument Documento = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId =: cv.Id];
        List<String> IdString = new List<String>();
        IdString.add(Documento.Id);
        return IdString;
    }

    public static List<String> CrearLista(List<String> DatosEnviar, map<String, String> mEnvioDato){
        DatosEnviar.add(
                    mEnvioDato.get('EINRI') +';'+
                    mEnvioDato.get('VNAME')+';'+
                    mEnvioDato.get('NNAME')+';'+
                    mEnvioDato.get('BIRTH_NAME')+';'+
                    mEnvioDato.get('GBDAT')+';'+
                    mEnvioDato.get('GSCHL')+';'+
                    mEnvioDato.get('DOC_NO')+';'+
                    mEnvioDato.get('DOC_TYP')+';'+
                    mEnvioDato.get('STREET')+';'+
                    mEnvioDato.get('STREET2')+';'+
                    mEnvioDato.get('HOUSE_NUM1')+';'+
                    mEnvioDato.get('POST_CODE1')+';'+
                    mEnvioDato.get('CITY1')+';'+
                    mEnvioDato.get('TEL_NUMBER')+';'+
                    mEnvioDato.get('TEL_NUMBER1')+';'+
                    mEnvioDato.get('E_MAIL')+';'+
                    mEnvioDato.get('LNAME1')+';'+
                    mEnvioDato.get('FNAME1')+';'+
                    mEnvioDato.get('RELSH1')+';'+
                    mEnvioDato.get('STREET1')+';'+
                    mEnvioDato.get('STREET3')+';'+
                    mEnvioDato.get('HOUSE_NUM1_2')+';'+
                    mEnvioDato.get('POST_CODE1_2')+';'+
                    mEnvioDato.get('CITY1_2')+';'+
                    mEnvioDato.get('TEL_NUMBER2')+';'+
                    mEnvioDato.get('E_MAIL_2')+';'+
                    mEnvioDato.get('FEXNR')+';'+
                    mEnvioDato.get('LNAME2')+';'+
                    mEnvioDato.get('FNAME2')+';'+
                    mEnvioDato.get('RELSH2')+';'+
                    mEnvioDato.get('STREET4')+';'+
                    mEnvioDato.get('STREET5')+';'+
                    mEnvioDato.get('HOUSE_NUM1_3')+';'+
                    mEnvioDato.get('POST_CODE1_3')+';'+
                    mEnvioDato.get('CITY1_3')+';'+
                    mEnvioDato.get('TEL_NUMBER3')+';'+
                    mEnvioDato.get('E_MAIL_3')+';'+
                    mEnvioDato.get('BWART')+';'+
                    mEnvioDato.get('BEKAT')+';'+
                    mEnvioDato.get('ORGPF')+';'+
                    mEnvioDato.get('BWIDT')+';'+
                    mEnvioDato.get('FATYP')+';'+
                    mEnvioDato.get('KZTXT')+';'+
                    mEnvioDato.get('PRIVADO')+';'+
                    mEnvioDato.get('KZTXT1')+';'+
                    mEnvioDato.get('PLAZACDL')+';'+
                    mEnvioDato.get('PLAZACDM')+';'+
                    mEnvioDato.get('PLAZACDX')+';'+
                    mEnvioDato.get('PLAZACDJ')+';'+
                    mEnvioDato.get('PLAZACDV')+';'+
                    mEnvioDato.get('PLAZACDS')+';'+
                    mEnvioDato.get('PLAZACDD')+';'+
                    mEnvioDato.get('DBNAC')+';'+
                    mEnvioDato.get('DBNAV')+';'+
                    mEnvioDato.get('DBNAA')+';'+
                    mEnvioDato.get('DBUPN')+';'+
                    mEnvioDato.get('DBTPN')+';'+
                    mEnvioDato.get('DBFUM')+';'+
                    mEnvioDato.get('DBEAN')+';'+
                    mEnvioDato.get('DBPFM')+';'+
                    mEnvioDato.get('DBATR')+';'+
                    mEnvioDato.get('DBAYD')+';'+
                    mEnvioDato.get('DBDBN')+';'+
                    mEnvioDato.get('DBTDT')+';'+
                    mEnvioDato.get('ODCIN')+';'+
                    mEnvioDato.get('ODIVL')+';'+
                    mEnvioDato.get('ODAIJ')+';'+
                    mEnvioDato.get('ODTAIJ')+';'+
                    mEnvioDato.get('ODSDF')+';'+
                    mEnvioDato.get('ODDRI')+';'+
                    mEnvioDato.get('DMOX')+';'+
                    mEnvioDato.get('DMSJ')+';'+
                    mEnvioDato.get('DMSN')+';'+
                    mEnvioDato.get('DMAL')+';'+
                    mEnvioDato.get('DMSG')+';'+
                    mEnvioDato.get('DMPD')+';'+
                    mEnvioDato.get('DMSB')+';'+
                    mEnvioDato.get('DMIN')+';'+
                    mEnvioDato.get('EMDC')+';'+
                    mEnvioDato.get('EMAG')+';'+
                    mEnvioDato.get('EMVG')+';'+
                    mEnvioDato.get('EMRF')+';'+
                    mEnvioDato.get('EMDS')+';'+
                    mEnvioDato.get('OBS')
                );
        return DatosEnviar;
    }
}