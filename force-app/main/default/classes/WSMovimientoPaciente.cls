/** 
@description
<pre>
Servicio web RESTful que dará de alta nuevos familiares (contactos) en Salesforce según los datos recibidos</br>

FECHA       AUTOR   	    DESCRIPCION<br/>
16/01/2024  MSA - LCS       Ractivar errores de plaza ocupada.
21/11/2023  MSA - LCS       Reestructuración de la clase haciéndola por métodos..
21/11/2023  MSA - LCS       Traslados de respiro.
21/11/2023  MSA - LCS       Desactivar errores de plaza ocupada.
16/10/2023  MSA - LCS       Real SAP cambio de plaza.
24/07/2023  MSA - LCS       Real SAP ocupar plaza. Anular episodio desocupar plaza.
22/05/2023  MSA - LCS       Añadida nueva casuística de oportunidades.
20/02/2023  MSA - LCS       Añadido registro de errores.
06/02/2023  MSA - LCS       Añadido dar de alta a pacientes, solucionar pequeños errores y ahora acepta oportunidades en envío SAP con código correcto.
01/04/2021  JLQ - LCS       Quitar tipo de plaza cuando se desocupa
xx/01/2022  MMV - LCS       Corrige dos puntos de la lógica de obtención de la oporunidad a mover
29/09/2021  MMV - LCS       Ajustes para control de errores y cubrir todas las casuisticas
24/09/2021  ARM - LCS       Cambio para adaptacion a nuevo schema de payload
30/08/2021  MMV - LCS       Cambio para obtener la oportunidad en base al ContactRole del residente
22/07/2021  RF Oliveira     Se modifica para que acepte un solo registro en lugar de un array
16/07/2021	RF Oliveira     Creado
</pre>
@author Leadclic Solutions
@date 16/07/2021
*/

/*
HELP:

Movimientos empleados:

-Traslado Residencia Permanente. Método: "MovimientoRP" -> TipoMovimiento = ''
-Traslado Centro de día. Método: "MovimientoCD" -> TipoMovimiento = ''
-Anulación traslado: Se considera un traslado.  -> TipoMovimiento = ''
-Alta. Método: AltaResidente. -> TipoMovimiento = 'A'
-Estado a RealSAP. Método: "StatusToReal".  -> TipoMovimiento = 'R'
-Anulación episodio. Método: "OpportunityCancellation". -> TipoMovimiento = 'X'
-Traslado de respiro. Métodos: "Respiro2CD" y "CD2Respiro"

*/

@RestResource(urlMapping='/WSMovimientoPaciente/*')
global with sharing class WSMovimientoPaciente {

    /**
    @description    Método principal del servicio. Recibe la información de un movimiento de paciente de una plaza a otra (del mismo o diferente centro)
    @param          payload datos entrantes   
    @return         PayloadOut con los datos de resultado de la operación
     */
    @HttpPost
    global static PayloadOut WSMovimientoPaciente(PayloadIn payload) {
        System.debug('@@PayloadIn: ' + payload);

        WrapperMetodos auxiliares = new WrapperMetodos();

        try{
            // Chequeamos los campos obligatorios
            String missingField=checkMandatoryFields(payload);
            if(String.isBlank(missingField)){

                // Mapa donde obtenemos las plazas que deben ser modificadas ( Origen/Destino <--> plazasCD )
                Map<String,plazasCD> plazasCD = new Map<String, plazasCD>();
                plazasCD = getPlazasPayload(payload);

                // Map de Plazas de origen por dia con los Ids para obtener las plazas de origen ( O(Origen)diaDeLaSemana <--> Id de plaza ) || ( D(Destino)diaDeLaSemana <--> Id de plaza )
                Map<String,String> mapPlazasIds = new Map<String,String>();
                if(plazasCD.get('Origen')!=null){
                    PlazasCD plazasOrig = plazasCD.get('Origen');
                    if( String.isNotBlank(plazasOrig.Lunes) ){
                        mapPlazasIds.put('OLunes', plazasOrig.Lunes +'L');
                    }
                    if( String.isNotBlank(plazasOrig.Martes) ){
                        mapPlazasIds.put('OMartes', plazasOrig.Martes +'M');
                    }
                    if( String.isNotBlank(plazasOrig.Miercoles) ){
                        mapPlazasIds.put('OMiercoles', plazasOrig.Miercoles+'X');
                    }
                    if( String.isNotBlank(plazasOrig.Jueves) ){
                        mapPlazasIds.put('OJueves', plazasOrig.Jueves+'J');
                    }
                    if( String.isNotBlank(plazasOrig.Viernes) ){
                        mapPlazasIds.put('OViernes', plazasOrig.Viernes+'V');
                    }
                    if( String.isNotBlank(plazasOrig.Sabado) ){
                        mapPlazasIds.put('OSabado', plazasOrig.Sabado+'S');
                    }
                    if( String.isNotBlank(plazasOrig.Domingo) ){
                        mapPlazasIds.put('ODomingo', plazasOrig.Domingo+'D');
                    }
                }
                if(plazasCD.get('Destino')!=null){
                    PlazasCD plazasDesti = plazasCD.get('Destino');
                    if( String.isNotBlank(plazasDesti.Lunes) ){
                        mapPlazasIds.put('DLunes', plazasDesti.Lunes +'L');
                    }
                    if( String.isNotBlank(plazasDesti.Martes) ){
                        mapPlazasIds.put('DMartes', plazasDesti.Martes + 'M'); 
                    }
                    if( String.isNotBlank(plazasDesti.Miercoles) ){
                        mapPlazasIds.put('DMiercoles', plazasDesti.Miercoles + 'X');
                    }
                    if( String.isNotBlank(plazasDesti.Jueves) ){
                        mapPlazasIds.put('DJueves', plazasDesti.Jueves + 'J');
                    }
                    if( String.isNotBlank(plazasDesti.Viernes) ){
                        mapPlazasIds.put('DViernes', plazasDesti.Viernes + 'V');
                    }
                    if( String.isNotBlank(plazasDesti.Sabado) ){
                        mapPlazasIds.put('DSabado', plazasDesti.Sabado + 'S');
                    }
                    if( String.isNotBlank(plazasDesti.Domingo) ){
                        mapPlazasIds.put('DDomingo', plazasDesti.Domingo + 'D');
                    }                
                }

                // Si no tenemos plazas de destino y si tenemos de origen, se trata de una desocupacion por lo que tenemos que marcar la oportunidad con fecha salida de hoy
                if( (mapPlazasIds.get('OLunes')!=null || mapPlazasIds.get('OMartes')!=null || mapPlazasIds.get('OMiercoles')!=null || mapPlazasIds.get('OJueves')!=null || mapPlazasIds.get('OViernes')!=null || mapPlazasIds.get('OSabado')!=null || mapPlazasIds.get('ODomingo')!=null) && (mapPlazasIds.get('DLunes')==null && mapPlazasIds.get('DMartes')==null && mapPlazasIds.get('DMiercoles')==null && mapPlazasIds.get('DJueves')==null && mapPlazasIds.get('DViernes')==null && mapPlazasIds.get('DSabado')==null && mapPlazasIds.get('DDomingo')==null)){
                    auxiliares.auxOpportunity.FechaSalida__c = ((payload.FechaAlta == null)||(String.isBlank(payload.FechaAlta)))? date.today(): ConversionFecha(payload.FechaAlta);
                }

                //Se obtiene registros de la plaza de origen, destino, oportunidad cerrada activa y registro "PotencialResidente" cuyo IdExternoSAP__c coincida con el IdResidenteSAP de entrada
                Plaza__c[] plazaOrigen=new List<Plaza__c>();
                if(String.isNotBlank(payload.OrgOrigen)){            
                    plazaOrigen = [SELECT Id, TipoPlaza__c, Cama__c, PlazaOcupada__c FROM Plaza__c WHERE Cama__c = : payload.OrgOrigen LIMIT 1];
                }

                Plaza__c[] plazaDestino=new List<Plaza__c>();
                if(String.isNotBlank(payload.OrgDestino)){
                    plazaDestino = [SELECT Id, TipoPlaza__c, Cama__c, PlazaOcupada__c FROM Plaza__c WHERE Cama__c = : payload.OrgDestino LIMIT 1];
                }

                Contact[] contactResident = [SELECT Id, AccountId, RecordTypeId, RecordType.DeveloperName FROM Contact WHERE IdExternoSAP__c = : payload.IdResidenteSAP AND RecordType.DeveloperName='PotencialResidente' LIMIT 1];

                //Si falla el contacto lo buscamos por DNI y teléfono
                
                if(contactResident.size() == 0){
                    contactResident = [SELECT Id, IdExternoSAP__c, AccountId, RecordTypeId, RecordType.DeveloperName FROM Contact WHERE NumeroDocumento__c =: payload.DNI AND MobilePhone =: payload.Movil AND RecordType.DeveloperName='PotencialResidente' LIMIT 1];
                    if(contactResident.size()>0){
                        contactResident[0].IdExternoSAP__c = payload.IdResidenteSAP;
                        update contactResident;
                    }
                }

                //Buscar si ya existe un residente en contactos con ese identificador IdResidenteSAP (IdExternoSAP__c)
                if(contactResident.size()>0){
                    List<Opportunity> OpportunidadesTraslado = [SELECT Id, StageName, MotivoPerdida__c FROM Opportunity WHERE AccountId = : contactResident.get(0).AccountId AND RecordType.DeveloperName='Traslado' AND IsClosed = false];
                    // Buscamos en la tabla ContactRole los registros en los que exista este contacto con role de Residente
                    List<OpportunityContactRole> lOpportunityContactRole = [SELECT Id, OpportunityId, Role, ContactId 
                                                                            FROM OpportunityContactRole 
                                                                            WHERE Contact.IdExternoSAP__c =: payload.IdResidenteSAP 
                                                                            AND Role = 'Residente' 
                                                                            AND Opportunity.IdExternoSAP__c =: payload.IdEpisodioSAP
                                                                            AND (Opportunity.StageName = 'Cerrada - Éxito' OR (Opportunity.StageName = 'Envío SAP' AND (Opportunity.CodeSAPResponse__c = '(S, S)' OR Opportunity.CodeSAPResponse__c = '(S, E, S)'))) LIMIT 1];
                    

                    Opportunity[] closedActiveOpportunity = lOpportunityContactRole.isEmpty() ? new Opportunity[]{} : 
                                                            [SELECT Plaza__c, RealSAP__c, TipoPlaza__c,PlazaLunes__c,PlazaMartes__c,PlazaMiercoles__c,PlazaJueves__c, PlazaViernes__c, PlazaSabado__c, PlazaDomingo__c FROM Opportunity 
                                                            WHERE Id =: lOpportunityContactRole[0].OpportunityId LIMIT 1];

                    // Si encontramos la oportunidad seguimos, si no devolvemos un error. 
                    if( !closedActiveOpportunity.isEmpty() ){

                        if(mapPlazasIds.values().size()>0){
                            auxiliares = MovimientoCD(auxiliares, mapPlazasIds, payload, closedActiveOpportunity[0]);
                        }                    

                        //Si se informan orgOrigen y orgDestino pero no se encuentran, se devuelve error
                        if(String.isNotBlank(payload.OrgOrigen) && (plazaOrigen.size()<1)){
                            Mensaje_Error__mdt resp = fetchResponses('OrgOrigenNoExiste');
                            auxiliares.payloadOut.errorCode = resp.Error_Code__c;
                            auxiliares.payloadOut.errorDescription = resp.Error_Description__c;
                            CreateErrorLog(resp.Error_Code__c, resp.Error_Description__c, payload);
                        }else if(String.isNotBlank(payload.OrgDestino) && (plazaDestino.size()<1)){
                            Mensaje_Error__mdt resp = fetchResponses('OrgDestinoNoExiste');
                            auxiliares.payloadOut.errorCode = resp.Error_Code__c;
                            auxiliares.payloadOut.errorDescription = resp.Error_Description__c;
                            CreateErrorLog(resp.Error_Code__c, resp.Error_Description__c, payload);
                        } else {                        
                            auxiliares = MovimientoRP(auxiliares, plazaDestino, payload, closedActiveOpportunity[0]);
                                

                                //Cambiar status a Real
                                if((closedActiveOpportunity[0].RealSAP__c == false)&&(payload.TipoMovimiento == 'R'))
                                    { 
                                        auxiliares = StatusToReal(auxiliares, payload, mapPlazasIds, plazaDestino);
                                    }

                                //Si hay cambio de categoría (vienen informadas CategoriaOrigen y CategoríaDestino), Cambiar la plaza Destino y la oportunidad cerrada activa con la nueva categoría
                                if(String.isNotBlank(payload.CategoriaOrigen) && String.isNotBlank(payload.CategoriaDestino)){
                                    auxiliares.auxPlazaDestino.TipoPlaza__c = payload.CategoriaDestino;
                                    auxiliares.auxPlazaDestino.Id = plazaDestino.get(0).Id;
                                    auxiliares.auxOpportunity.TipoPlaza__c = payload.CategoriaDestino;
                                }

                                //Si hay una anulación de episodio la plaza se desocupa
                                if(payload.TipoMovimiento == 'X'){

                                    auxiliares = OpportunityCancellation(auxiliares, payload);
                                }

                        //Si hay desocupación de plaza (solo viene informada la plaza de origen), rellenar el Fecha de salida de oportunidad con fecha actual y marcar como desocupada.
                            if((payload.TipoMovimiento == 'A')){

                                Date FechaDeAlta = ((payload.FechaAlta == null)||(String.isBlank(payload.FechaAlta)))? date.today(): ConversionFecha(payload.FechaAlta);

                                auxiliares = AltaResidente(auxiliares, payload, OpportunidadesTraslado, FechaDeAlta);

                            }
                           
                            //Traslado de Respiro a CD, solo vienen indicadas las plazas de CD, se produce el movimiento de CD correspondiente
                            if((payload.TipoMovimiento == 'CD')){
                                Respiro2CD(auxiliares, payload);
                            }

                            //Traslado de CD a Respiro, solo viene informada la plaza de residente y se mantiene la de CD
                            if((payload.TipoMovimiento == 'TR')){
                                CD2Respiro(auxiliares, payload, plazaDestino);
                            }
                    }

                        // Se ejecuta las DMLs si no hay errores previos
                        if(String.isBlank(auxiliares.payloadOut.errorCode)){

                                if(closedActiveOpportunity.size() > 0){
                                    auxiliares.auxOpportunity.Id = closedActiveOpportunity.get(0).Id;
                                    auxiliares.auxContact.Id = contactResident.get(0).Id;
                                    update auxiliares.auxOpportunity;
                                    update auxiliares.auxContact;
                                    update auxiliares.OpportunidadesTraslado;
                                }

                                if (plazaOrigen.size() > 0){
                                    auxiliares.auxPlazaOrigen.Id = plazaOrigen.get(0).Id;
                                    update auxiliares.auxPlazaOrigen;
                                }
                                if(plazaDestino.size() > 0){
                                    update auxiliares.auxPlazaDestino;
                                }
                                if(auxiliares.mPlazasUPD.size() > 0){
                                    update auxiliares.mPlazasUPD.values();
                                }

                            
                
                            Mensaje_Error__mdt resp = fetchResponses('PlazasActualizadas');
                            auxiliares.payloadOut.errorCode = resp.Error_Code__c;
                            auxiliares.payloadOut.errorDescription = resp.Error_Description__c;
                        }
                        if(!String.isBlank(auxiliares.payloadOut.errorCode) && (payload.TipoMovimiento == 'R')){
                            if(closedActiveOpportunity.size() > 0){
                                auxiliares.auxOpportunity.Id = closedActiveOpportunity.get(0).Id;
                                update auxiliares.auxOpportunity;
                            }
                        }

                    }else{
                        Mensaje_Error__mdt resp = fetchResponses('OportunidadNoEncontrada');
                        auxiliares.payloadOut.errorCode = resp.Error_Code__c;
                        auxiliares.payloadOut.errorDescription = resp.Error_Description__c;
                        CreateErrorLog(resp.Error_Code__c, resp.Error_Description__c, payload);
                    }
            
                    //Si no existe el residente enviado (IdResidenteSAP) se devuelve error
                } else{
                    Mensaje_Error__mdt resp = fetchResponses('ResidenteNoExiste');
                    auxiliares.payloadOut.errorCode = resp.Error_Code__c;
                    auxiliares.payloadOut.errorDescription = resp.Error_Description__c;
                    CreateErrorLog(resp.Error_Code__c, resp.Error_Description__c, payload);
                } 

            } else{
                //Faltan campos obligatorios
                Mensaje_Error__mdt resp = fetchResponses('FaltaCampoObligatorio');
                auxiliares.payloadOut.errorCode = resp.Error_Code__c;
                auxiliares.payloadOut.errorDescription = resp.Error_Description__c + missingField;
                CreateErrorLog(resp.Error_Code__c, resp.Error_Description__c, payload);
            }               

        }catch(Exception e){
            Mensaje_Error__mdt resp = fetchResponses('err500');
            auxiliares.payloadOut.errorCode = resp.Error_Code__c;
            auxiliares.payloadOut.errorDescription = e.getMessage();
            CreateErrorLog(resp.Error_Code__c, e.getMessage(), payload);
        }

        return auxiliares.payloadOut;

    }

    /**
	@description	Comprueba si se han recibido los campos obligatorios
	@param 			payload datos entrantes
	@return			String missingField con el nombre del primer campo obligatorio que falta
	*/  
    private static String checkMandatoryFields (PayloadIn payload){
        String missingFields='';
    
        if (String.isBlank(payload.Einri)){
            missingFields+=' Einri';
        }
        if(String.isBlank(payload.IdResidenteSAP)){
            missingFields+=' IdResidenteSAP';
        }
        if(String.isBlank(payload.IdEpisodioSAP)){
            missingFields+=' IdEpisodioSAP';
        }

        return missingFields;
    }

    /**
	@description	Comprueba si hay plazas origen/destino en centro de Dia (Payload)
	@param 			payload datos entrantes
	@return			Map Origen/Destino, plazasCD
	*/  
    private static Map<String,plazasCD> getPlazasPayload (PayloadIn payload){
        Map<String,plazasCD> mapCentroPlazas = new Map<String,plazasCD>();
        PlazasCD plazasOrigen = new PlazasCD();
        PlazasCD plazasDestino = new PlazasCD();

        if(payload.PlazasCDOrigen!=null){
            
            if(payload.PlazasCDOrigen.Lunes!=null){
                plazasOrigen.Lunes = payload.PlazasCDOrigen.Lunes;
            }
            if(payload.PlazasCDOrigen.Martes!=null){
                plazasOrigen.Martes = payload.PlazasCDOrigen.Martes;
            }
            if(payload.PlazasCDOrigen.Miercoles!=null){
                plazasOrigen.Miercoles = payload.PlazasCDOrigen.Miercoles;
            }
            if(payload.PlazasCDOrigen.Jueves!=null){
                plazasOrigen.Jueves = payload.PlazasCDOrigen.Jueves;
            }
            if(payload.PlazasCDOrigen.Viernes!=null){
                plazasOrigen.Viernes = payload.PlazasCDOrigen.Viernes;
            }
            if(payload.PlazasCDOrigen.Sabado!=null){
                plazasOrigen.Sabado =  payload.PlazasCDOrigen.Sabado;
            }
            if(payload.PlazasCDOrigen.Domingo!=null){
                plazasOrigen.Domingo = payload.PlazasCDOrigen.Domingo;
            }
        }
        mapCentroPlazas.put('Origen', plazasOrigen);
        
        if(payload.PlazasCDDestino!=null){
            
            if(payload.PlazasCDDestino.Lunes!=null){
                plazasDestino.Lunes = payload.PlazasCDDestino.Lunes;
            }
            if(payload.PlazasCDDestino.Martes!=null){
                plazasDestino.Martes = payload.PlazasCDDestino.Martes;
            }
            if(payload.PlazasCDDestino.Miercoles!=null){
                plazasDestino.Miercoles = payload.PlazasCDDestino.Miercoles;
            }
            if(payload.PlazasCDDestino.Jueves!=null){
                plazasDestino.Jueves = payload.PlazasCDDestino.Jueves;
            }
            if(payload.PlazasCDDestino.Viernes!=null){
                plazasDestino.Viernes = payload.PlazasCDDestino.Viernes;
            }
            if(payload.PlazasCDDestino.Sabado!=null){
                plazasDestino.Sabado = payload.PlazasCDDestino.Sabado;
            }
            if(payload.PlazasCDDestino.Domingo!=null){
                plazasDestino.Domingo = payload.PlazasCDDestino.Domingo;
            }
        }
        mapCentroPlazas.put('Destino', plazasDestino);
        
        return mapCentroPlazas;
    }

    public static date ConversionFecha(String FechaSAP){

        String anyo = FechaSAP.mid(0,4);
        String mes = FechaSAP.mid(4,2);
        String dia = FechaSAP.mid(6,2);
        return date.parse(dia+'/'+mes+'/'+anyo);
    }

    //Wrapper Class PayloadId con la información de recibida
	global class PayloadIn {
        public String IdResidenteSAP {get;set;}
        public String Einri {get;set;}
        public String OrgOrigen {get;set;}
        public String OrgDestino {get;set;}
        public String CategoriaOrigen {get;set;}
        public String CategoriaDestino {get;set;}
        public plazasCD PlazasCDOrigen;
        public plazasCD PlazasCDDestino;
        public String Motivo {get;set;}
        public String Causaalta {get;set;}
        public String TipoMovimiento {get;set;} //A: alta, X: anulación, R: Real
        public String IdEpisodioSAP {get;set;}
        public String FechaAlta {get;set;}
        public String DNI {get;set;}
        public String Movil {get;set;}
    }

    //Wrapper Class PayloadOut para devolver los datos del resultado de la operación
	global class PayloadOut {
        public String errorCode {get;set;}
        public String errorDescription {get;set;}
	}

    //Wrapper Class Plazas Centro de dia
    global class plazasCD {
        public String Lunes {get;set;}
        public String Martes {get;set;}
        public String Miercoles {get;set;}
        public String Jueves {get;set;}
        public String Viernes {get;set;}
        public String Sabado {get;set;}
        public String Domingo {get;set;}
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

    /**
	@description	Método para generar errores una vez se haya dado un error
	@param 			String code codigo de error
    @param 			String ErrorDescription descripcion del error
    @param 			PayloadIn Payload datos de entrada
	@return			Mensaje_Error__mdt con los campos de la respuesta
	*/ 
    public static void CreateErrorLog(String Code, String ErrorDescription, PayloadIn Payload){
        RegistrosDeErrores__c ErrorGenerado = new RegistrosDeErrores__c();
        
        ErrorGenerado.CodigoError__c = Code;
        ErrorGenerado.DescripcionError__c = ErrorDescription;
        ErrorGenerado.MensajeRecibido__c = JSON.serialize(Payload);
        ErrorGenerado.ClaseGeneradora__c = 'WSMovimientoPaciente';

        insert ErrorGenerado;
    }

    //Wrapper Class auxiliar para dividir la clase en metodos

    global class WrapperMetodos{
        Plaza__c auxPlazaOrigen = new Plaza__c();
        Plaza__c auxPlazaDestino = new Plaza__c();
        Plaza__c auxPlazaCD = new Plaza__c();

        Opportunity auxOpportunity = new Opportunity();
        Contact auxContact = new Contact();

        List<Opportunity> OpportunidadesTraslado = new List<Opportunity>(); //Oportunidades de Traslado a cerrar

        Map<Id,Plaza__c> mPlazasUPD = new Map<Id,Plaza__c>(); //Plazas a actualizar CD

        PayloadOut payloadOut = new payloadOut();
    }

    public static WrapperMetodos Respiro2CD(WrapperMetodos auxiliares, PayloadIn payload){
        auxiliares.auxPlazaOrigen.PlazaOcupada__c = false;
        auxiliares.auxOpportunity.Plaza__c = null;
        auxiliares.auxOpportunity.ProductoInteres__c = 'Centro día/ SED';

        return auxiliares;
    }

    public static WrapperMetodos CD2Respiro(WrapperMetodos auxiliares, PayloadIn payload, List<Plaza__c> plazaDestino){
        //busca la oportunidad cerrada activa de ese contacto y reemplazar la plaza de la oportunidad por el id de la nueva plaza
        auxiliares.auxOpportunity.Plaza__c =  plazaDestino.get(0).Id;
        auxiliares.auxPlazaDestino.Id = plazaDestino.get(0).Id; 
        auxiliares.auxPlazaDestino.PlazaOcupada__c = true;
        auxiliares.auxOpportunity.ProductoInteres__c = 'Estancia de respiro';

        return auxiliares;
    }

    /**
	@description	Método que se ejecuta cuando viene un alta
	@param 			WrapperMetodos auxiliares, los auxiliares a actualizar
    @param          PayloadIn payload, mensaje de entrada
    @param          List<Opportunity> OpportunidadesTraslado, se quieren cerrar tambien las oportunidades de traslado
    @param          Date FechaDeAlta, fecha del alta
	@return			Mensaje_Error__mdt con los campos de la respuesta
	*/ 
    public static WrapperMetodos AltaResidente(WrapperMetodos auxiliares, PayloadIn payload, List<Opportunity> OpportunidadesTraslado, Date FechaDeAlta){

        if(String.isBlank(payload.Causaalta)){
            Mensaje_Error__mdt resp = fetchResponses('AltaSinMotivo');
            auxiliares.payloadOut.errorCode = resp.Error_Code__c;
            auxiliares.payloadOut.errorDescription = resp.Error_Description__c;
            CreateErrorLog(resp.Error_Code__c, resp.Error_Description__c, payload);
        } else {
            auxiliares.auxOpportunity.FechaSalida__c = FechaDeAlta;
            auxiliares.auxPlazaOrigen.PlazaOcupada__c = false;
            auxiliares.auxPlazaOrigen.TipoPlaza__c = null;
            auxiliares.auxContact.FechaBaja__c = FechaDeAlta;
        }

        if(payload.Causaalta == 'F'){
            auxiliares.auxContact.EstadoContacto__c = 'Baja';
            auxiliares.auxContact.CausaBaja__c = 'Descontento';
            for(Opportunity Traslado : OpportunidadesTraslado){
                Traslado.StageName = 'Cerrada - Perdida';
                Traslado.TipoPerdida__c = 'Alta';
                Traslado.MotivoPerdida__c = 'Descontento';
            }
            
            auxiliares.auxOpportunity.TipoPerdida__c = 'Alta';
            auxiliares.auxOpportunity.MotivoPerdida__c = 'Descontento';
        }

        if(payload.Causaalta == 'H'){
            auxiliares.auxContact.EstadoContacto__c = 'Baja';
            auxiliares.auxContact.CausaBaja__c = 'Trasl otro Amav';

            auxiliares.auxOpportunity.TipoPerdida__c = 'Alta';
            auxiliares.auxOpportunity.MotivoPerdida__c = 'Trasl otro Amav';
        }

        if(payload.Causaalta == 'I'){
            auxiliares.auxContact.EstadoContacto__c = 'Baja';
            auxiliares.auxContact.CausaBaja__c = 'Inadaptación';
            for(Opportunity Traslado : OpportunidadesTraslado){
                Traslado.StageName = 'Cerrada - Perdida';
                Traslado.TipoPerdida__c = 'Alta';
                Traslado.MotivoPerdida__c = 'Inadaptación';
            }
            
            auxiliares.auxOpportunity.TipoPerdida__c = 'Alta';
            auxiliares.auxOpportunity.MotivoPerdida__c = 'Inadaptación';
        }

        if(payload.Causaalta == 'J'){
            auxiliares.auxContact.EstadoContacto__c = 'Baja';
            auxiliares.auxContact.CausaBaja__c = 'Hospitalización Larga Duración';
            for(Opportunity Traslado : OpportunidadesTraslado){
                Traslado.StageName = 'Cerrada - Perdida';
                Traslado.TipoPerdida__c = 'Alta';
                Traslado.MotivoPerdida__c = 'Hospital LargaE';
            }   
            
            auxiliares.auxOpportunity.TipoPerdida__c = 'Alta';
            auxiliares.auxOpportunity.MotivoPerdida__c = 'Hospital LargaE';
        }

        if(payload.Causaalta == 'L'){
            auxiliares.auxContact.EstadoContacto__c = 'Baja';
            auxiliares.auxContact.CausaBaja__c = 'Concesión Plaza Pública No Amavir';
            for(Opportunity Traslado : OpportunidadesTraslado){
                Traslado.StageName = 'Cerrada - Perdida';
                Traslado.TipoPerdida__c = 'Alta';
                Traslado.MotivoPerdida__c = 'Conc. púb Otros';
            } 
            
            auxiliares.auxOpportunity.TipoPerdida__c = 'Alta';
            auxiliares.auxOpportunity.MotivoPerdida__c = 'Conc. púb Otros'; 
        }

        if(payload.Causaalta == 'M'){
            auxiliares.auxContact.EstadoContacto__c = 'Baja';
            auxiliares.auxContact.CausaBaja__c = 'Conc. púb Amavir';

            auxiliares.auxOpportunity.TipoPerdida__c = 'Alta';
            auxiliares.auxOpportunity.MotivoPerdida__c = 'Conc. púb Amavir'; 
        }

        if(payload.Causaalta == 'O'){
            auxiliares.auxContact.EstadoContacto__c = 'Baja';
            auxiliares.auxContact.CausaBaja__c = 'Fin E. Temporal Respiro';
            for(Opportunity Traslado : OpportunidadesTraslado){
                Traslado.StageName = 'Cerrada - Perdida';
                Traslado.TipoPerdida__c = 'Alta';
                Traslado.MotivoPerdida__c = 'Fin Es TempResp';
            } 
            
            auxiliares.auxOpportunity.TipoPerdida__c = 'Alta';
            auxiliares.auxOpportunity.MotivoPerdida__c = 'Fin Es TempResp';
        }

        if(payload.Causaalta == 'P'){
            auxiliares.auxContact.EstadoContacto__c = 'Baja';
            auxiliares.auxContact.CausaBaja__c = 'Fin E. Temporal Rehabilitación';
            for(Opportunity Traslado : OpportunidadesTraslado){
                Traslado.StageName = 'Cerrada - Perdida';
                Traslado.TipoPerdida__c = 'Alta';
                Traslado.MotivoPerdida__c = 'Fin Es TempReha';
            } 
            
            auxiliares.auxOpportunity.TipoPerdida__c = 'Alta';
            auxiliares.auxOpportunity.MotivoPerdida__c = 'Fin Es TempReha';
        }

        if(payload.Causaalta == 'Q'){
            auxiliares.auxContact.EstadoContacto__c = 'Baja';
            auxiliares.auxContact.CausaBaja__c = 'Trasl Domicilio';
            for(Opportunity Traslado : OpportunidadesTraslado){
                Traslado.StageName = 'Cerrada - Perdida';
                Traslado.TipoPerdida__c = 'Alta';
                Traslado.MotivoPerdida__c = 'Trasl Domicilio';
            } 
            
            auxiliares.auxOpportunity.TipoPerdida__c = 'Alta';
            auxiliares.auxOpportunity.MotivoPerdida__c = 'Trasl Domicilio';
        }

        if(payload.Causaalta == 'T'){
            auxiliares.auxContact.EstadoContacto__c = 'Fallecido';
            auxiliares.auxContact.FechaBaja__c = null;
            auxiliares.auxContact.FechaFallecimiento__c = FechaDeAlta;
            auxiliares.auxContact.CausaBaja__c = 'Exitus Hospital';
            for(Opportunity Traslado : OpportunidadesTraslado){
                Traslado.StageName = 'Cerrada - Perdida';
                Traslado.TipoPerdida__c = 'Alta';
                Traslado.MotivoPerdida__c = 'Exitus Hospital';
            } 
            
            auxiliares.auxOpportunity.TipoPerdida__c = 'Alta';
            auxiliares.auxOpportunity.MotivoPerdida__c = 'Exitus Hospital';
        }

        if(payload.Causaalta == 'U'){
            auxiliares.auxContact.EstadoContacto__c = 'Baja';
            auxiliares.auxContact.CausaBaja__c = 'Resid competenc';
            for(Opportunity Traslado : OpportunidadesTraslado){
                Traslado.StageName = 'Cerrada - Perdida';
                Traslado.TipoPerdida__c = 'Alta';
                Traslado.MotivoPerdida__c = 'Resid competenc';
            } 
            
            auxiliares.auxOpportunity.TipoPerdida__c = 'Alta';
            auxiliares.auxOpportunity.MotivoPerdida__c = 'Resid competenc';
        }

        if(payload.Causaalta == 'V'){
            auxiliares.auxContact.EstadoContacto__c = 'Fallecido';
            auxiliares.auxContact.CausaBaja__c = 'Exitus en Resid';
            auxiliares.auxContact.FechaBaja__c = null;
            auxiliares.auxContact.FechaFallecimiento__c = FechaDeAlta;
            for(Opportunity Traslado : OpportunidadesTraslado){
                Traslado.StageName = 'Cerrada - Perdida';
                Traslado.TipoPerdida__c = 'Alta';
                Traslado.MotivoPerdida__c = 'Exitus en Resid';
            }  
            
            auxiliares.auxOpportunity.TipoPerdida__c = 'Alta';
            auxiliares.auxOpportunity.MotivoPerdida__c = 'Exitus en Resid';
        }

        if(payload.Causaalta == 'W'){
            auxiliares.auxContact.EstadoContacto__c = 'Baja';
            auxiliares.auxContact.CausaBaja__c = 'Motivos Económicos';
            for(Opportunity Traslado : OpportunidadesTraslado){
                Traslado.StageName = 'Cerrada - Perdida';
                Traslado.TipoPerdida__c = 'Alta';
                Traslado.MotivoPerdida__c = 'Mot. Económicos';
            } 
            
            auxiliares.auxOpportunity.TipoPerdida__c = 'Alta';
            auxiliares.auxOpportunity.MotivoPerdida__c = 'Mot. Económicos'; 
        }

        if(payload.Causaalta == 'X'){
            auxiliares.auxContact.EstadoContacto__c = 'Baja';
            auxiliares.auxContact.CausaBaja__c = 'Renuncia Volunt';
            for(Opportunity Traslado : OpportunidadesTraslado){
                Traslado.StageName = 'Cerrada - Perdida';
                Traslado.TipoPerdida__c = 'Alta';
                Traslado.MotivoPerdida__c = 'Renuncia Volunt';
            }
            
            auxiliares.auxOpportunity.TipoPerdida__c = 'Alta';
            auxiliares.auxOpportunity.MotivoPerdida__c = 'Renuncia Volunt';
        }

        if(payload.Causaalta == 'Y'){
            auxiliares.auxContact.EstadoContacto__c = 'Baja';
            auxiliares.auxContact.CausaBaja__c = 'Trasp CD a Resi';

            auxiliares.auxOpportunity.TipoPerdida__c = 'Alta';
            auxiliares.auxOpportunity.MotivoPerdida__c = 'Trasp CD a Resi';
        }
        return auxiliares;
    }

    /**
	@description	Método que se ejecuta cuando se cambia el status a Real en SAP
	@param 			WrapperMetodos auxiliares, los auxiliares a actualizar
    @param          PayloadIn payload, mensaje de entrada
    @param          Plazas necesarias para la operacion
	@return			WrapperMetodos auxiliares, los auxiliares a actualizar
	*/ 

    public static WrapperMetodos StatusToReal(WrapperMetodos auxiliares, PayloadIn payload, Map<String,String> mapPlazasIds, List<Plaza__c> plazaDestino){

        auxiliares.auxOpportunity.RealSAP__c = true;
        auxiliares.auxOpportunity.StageName = 'Cerrada - Éxito';

        for(Plaza__c plaza : [SELECT Id, TipoPlaza__c, Cama__c, PlazaOcupada__c FROM Plaza__c WHERE Cama__c IN:mapPlazasIds.values() ]){
            if(mapPlazasIds.get('DLunes')!=null){
                auxiliares.auxOpportunity.PlazaLunes__c = plaza.Id;
                plaza.PlazaOcupada__c = true;
                plaza.Id = plaza.Id;
                auxiliares.mPlazasUPD.put(plaza.Id,plaza);
            }
            if(mapPlazasIds.get('DMartes')!=null){
                auxiliares.auxOpportunity.PlazaMartes__c = plaza.Id;
                plaza.PlazaOcupada__c = true;
                plaza.Id = plaza.Id;
                auxiliares.mPlazasUPD.put(plaza.Id,plaza);
            }
            if(mapPlazasIds.get('DMiercoles')!=null){
                auxiliares.auxOpportunity.PlazaMiercoles__c = plaza.Id;
                plaza.PlazaOcupada__c = true;
                plaza.Id = plaza.Id;
                auxiliares.mPlazasUPD.put(plaza.Id,plaza);
            }
            if(mapPlazasIds.get('DJueves')!=null){
                auxiliares.auxOpportunity.PlazaJueves__c = plaza.Id;
                plaza.PlazaOcupada__c = true;
                plaza.Id = plaza.Id;
                auxiliares.mPlazasUPD.put(plaza.Id,plaza);
            }
            if(mapPlazasIds.get('DViernes')!=null){
                auxiliares.auxOpportunity.PlazaViernes__c = plaza.Id;
                plaza.PlazaOcupada__c = true;
                plaza.Id = plaza.Id;
                auxiliares.mPlazasUPD.put(plaza.Id,plaza);
            }
            if(mapPlazasIds.get('DSabado')!=null){
                auxiliares.auxOpportunity.PlazaSabado__c = plaza.Id;
                plaza.PlazaOcupada__c = true;
                plaza.Id = plaza.Id;
                auxiliares.mPlazasUPD.put(plaza.Id,plaza);
            }
            if(mapPlazasIds.get('DDomingo')!=null){
                auxiliares.auxOpportunity.PlazaDomingo__c = plaza.Id;
                plaza.PlazaOcupada__c = true;
                plaza.Id = plaza.Id;
                auxiliares.mPlazasUPD.put(plaza.Id,plaza);
            }
        }
        if((!String.isBlank(payload.OrgDestino)) && (payload.OrgDestino != null)){

            auxiliares.auxOpportunity.Plaza__c =  plazaDestino.get(0).Id;
            auxiliares.auxPlazaDestino.PlazaOcupada__c = true;

            if((!String.isBlank(payload.OrgOrigen)) && (payload.OrgOrigen != null)&&(payload.OrgDestino != payload.OrgOrigen)){
                auxiliares.auxPlazaOrigen.PlazaOcupada__c = false;
            }
        }
        return auxiliares;
    }

    /**
	@description	Método que se ejecuta cuando hay un movimiento de CD
	@param 			WrapperMetodos auxiliares, los auxiliares a actualizar
    @param          PayloadIn payload, mensaje de entrada
    @param          Plazas necesarias para la operacion
	@return			WrapperMetodos auxiliares, los auxiliares a actualizar
	*/ 
    public static WrapperMetodos MovimientoCD(WrapperMetodos auxiliares, Map<String,String> mapPlazasIds, PayloadIn payload, Opportunity actualOpp){
        for(Plaza__c plaza : [SELECT Id, TipoPlaza__c, Cama__c, PlazaOcupada__c FROM Plaza__c WHERE Cama__c IN:mapPlazasIds.values() ]){

            // Buscamos las plazas de Origen
            if(mapPlazasIds.get('OLunes')!=null && mapPlazasIds.get('OLunes') == plaza.Cama__c){
                auxiliares.auxOpportunity.PlazaLunes__c = null;
                plaza.PlazaOcupada__c = false;
                plaza.Id = plaza.Id;
                auxiliares.mPlazasUPD.put(plaza.Id,plaza);
            }
            if(mapPlazasIds.get('OMartes')!=null && mapPlazasIds.get('OMartes') == plaza.Cama__c){
                auxiliares.auxOpportunity.PlazaMartes__c =null;
                plaza.PlazaOcupada__c = false;
                plaza.Id = plaza.Id;
                auxiliares.mPlazasUPD.put(plaza.Id,plaza);
            }
            if(mapPlazasIds.get('OMiercoles')!=null && mapPlazasIds.get('OMiercoles') == plaza.Cama__c){
                auxiliares.auxOpportunity.PlazaMiercoles__c = null;
                plaza.PlazaOcupada__c = false;
                plaza.Id = plaza.Id;
                auxiliares.mPlazasUPD.put(plaza.Id,plaza);
            }
            if(mapPlazasIds.get('OJueves')!=null && mapPlazasIds.get('OJueves') == plaza.Cama__c){
                auxiliares.auxOpportunity.PlazaJueves__c = null;
                plaza.PlazaOcupada__c = false;
                plaza.Id = plaza.Id;
                auxiliares.mPlazasUPD.put(plaza.Id,plaza);
            }
            if(mapPlazasIds.get('OViernes')!=null && mapPlazasIds.get('OViernes') == plaza.Cama__c){
                auxiliares.auxOpportunity.PlazaViernes__c = null;
                plaza.PlazaOcupada__c = false;
                plaza.Id = plaza.Id;
                auxiliares.mPlazasUPD.put(plaza.Id,plaza);
            }
            if(mapPlazasIds.get('OSabado')!=null && mapPlazasIds.get('OSabado') == plaza.Cama__c){
                auxiliares.auxOpportunity.PlazaSabado__c = null;
                plaza.PlazaOcupada__c = false;
                plaza.Id = plaza.Id;
                auxiliares.mPlazasUPD.put(plaza.Id,plaza);
            }
            if(mapPlazasIds.get('ODomingo')!=null && mapPlazasIds.get('ODomingo') == plaza.Cama__c){
                auxiliares.auxOpportunity.PlazaDomingo__c = null;
                plaza.PlazaOcupada__c = false;
                plaza.Id = plaza.Id;
                auxiliares.mPlazasUPD.put(plaza.Id,plaza);
            }
            // Buscamos las plazas de Destino
            if(mapPlazasIds.get('DLunes')!=null && mapPlazasIds.get('DLunes') == plaza.Cama__c 
            //&& plaza.PlazaOcupada__c ==false
            ){
                auxiliares.auxOpportunity.PlazaLunes__c = plaza.Id;
                plaza.PlazaOcupada__c = true;
                plaza.Id = plaza.Id;
                auxiliares.mPlazasUPD.put(plaza.Id,plaza);

                //Si se trata de una anulación de alta
                auxiliares.auxOpportunity.FechaSalida__c = null;
                auxiliares.auxOpportunity.TipoPerdida__c = null;
                auxiliares.auxOpportunity.MotivoPerdida__c = null;
                auxiliares.auxContact.FechaBaja__c = null;
                auxiliares.auxContact.CausaBaja__c = null;
                auxiliares.auxContact.EstadoContacto__c = null;

            } 
            
            else if(mapPlazasIds.get('DLunes')!=null && mapPlazasIds.get('DLunes') == plaza.Cama__c && plaza.PlazaOcupada__c ==true) {
                Mensaje_Error__mdt resp = fetchResponses('PlazaOcupada');
                auxiliares.payloadOut.errorCode = resp.Error_Code__c;
                auxiliares.payloadOut.errorDescription = resp.Error_Description__c;
                CreateErrorLog(resp.Error_Code__c, resp.Error_Description__c + '. La plaza ocupada es: '+ payload.PlazasCDDestino.Lunes + ' Lunes', payload);
            } 
            
            if(mapPlazasIds.get('DMartes')!=null && mapPlazasIds.get('DMartes') == plaza.Cama__c 
            //&& plaza.PlazaOcupada__c ==false
            ){
                auxiliares.auxOpportunity.PlazaMartes__c = plaza.Id;
                plaza.PlazaOcupada__c = true;
                plaza.Id = plaza.Id;
                auxiliares.mPlazasUPD.put(plaza.Id,plaza);

                //Si se trata de una anulación de alta
                auxiliares.auxOpportunity.FechaSalida__c = null;
                auxiliares.auxOpportunity.TipoPerdida__c = null;
                auxiliares.auxOpportunity.MotivoPerdida__c = null;
                auxiliares.auxContact.FechaBaja__c = null;
                auxiliares.auxContact.CausaBaja__c = null;
                auxiliares.auxContact.EstadoContacto__c = null;

            } 
            
            else if(mapPlazasIds.get('DMartes')!=null && mapPlazasIds.get('DMartes') == plaza.Cama__c && plaza.PlazaOcupada__c ==true) {
                Mensaje_Error__mdt resp = fetchResponses('PlazaOcupada');
                auxiliares.payloadOut.errorCode = resp.Error_Code__c;
                auxiliares.payloadOut.errorDescription = resp.Error_Description__c;
                CreateErrorLog(resp.Error_Code__c, resp.Error_Description__c + '. La plaza ocupada es: '+ payload.PlazasCDDestino.Martes + ' Martes', payload);
            } 
            
            if(mapPlazasIds.get('DMiercoles')!=null && mapPlazasIds.get('DMiercoles') == plaza.Cama__c 
            //&& plaza.PlazaOcupada__c ==false
            ){
                auxiliares.auxOpportunity.PlazaMiercoles__c = plaza.Id;
                plaza.PlazaOcupada__c = true;
                plaza.Id = plaza.Id;
                auxiliares.mPlazasUPD.put(plaza.Id,plaza);

                //Si se trata de una anulación de alta
                auxiliares.auxOpportunity.FechaSalida__c = null;
                auxiliares.auxOpportunity.TipoPerdida__c = null;
                auxiliares.auxOpportunity.MotivoPerdida__c = null;
                auxiliares.auxContact.FechaBaja__c = null;
                auxiliares.auxContact.CausaBaja__c = null;
                auxiliares.auxContact.EstadoContacto__c = null;

            } 
            
            else if(mapPlazasIds.get('DMiercoles')!=null && mapPlazasIds.get('DMiercoles') == plaza.Cama__c && plaza.PlazaOcupada__c ==true) {
                Mensaje_Error__mdt resp = fetchResponses('PlazaOcupada');
                auxiliares.payloadOut.errorCode = resp.Error_Code__c;
                auxiliares.payloadOut.errorDescription = resp.Error_Description__c;
                CreateErrorLog(resp.Error_Code__c, resp.Error_Description__c + '. La plaza ocupada es: '+ payload.PlazasCDDestino.Miercoles + ' Miércoles', payload);
            } 
            
            if(mapPlazasIds.get('DJueves')!=null && mapPlazasIds.get('DJueves') == plaza.Cama__c 
            //&& plaza.PlazaOcupada__c ==false
            ){
                auxiliares.auxOpportunity.PlazaJueves__c = plaza.Id;
                plaza.PlazaOcupada__c = true;
                plaza.Id = plaza.Id;
                auxiliares.mPlazasUPD.put(plaza.Id,plaza);

                //Si se trata de una anulación de alta
                auxiliares.auxOpportunity.FechaSalida__c = null;
                auxiliares.auxOpportunity.TipoPerdida__c = null;
                auxiliares.auxOpportunity.MotivoPerdida__c = null;
                auxiliares.auxContact.FechaBaja__c = null;
                auxiliares.auxContact.CausaBaja__c = null;
                auxiliares.auxContact.EstadoContacto__c = null;

            } 
            
            else if(mapPlazasIds.get('DJueves')!=null && mapPlazasIds.get('DJueves') == plaza.Cama__c && plaza.PlazaOcupada__c ==true) {
                Mensaje_Error__mdt resp = fetchResponses('PlazaOcupada');
                auxiliares.payloadOut.errorCode = resp.Error_Code__c;
                auxiliares.payloadOut.errorDescription = resp.Error_Description__c;
                CreateErrorLog(resp.Error_Code__c, resp.Error_Description__c + '. La plaza ocupada es: '+ payload.PlazasCDDestino.Jueves + ' Jueves', payload);
            }
            
            if(mapPlazasIds.get('DViernes')!=null && mapPlazasIds.get('DViernes') == plaza.Cama__c 
            //&& plaza.PlazaOcupada__c ==false
            ){
                auxiliares.auxOpportunity.PlazaViernes__c = plaza.Id;
                plaza.PlazaOcupada__c = true;
                plaza.Id = plaza.Id;
                auxiliares.mPlazasUPD.put(plaza.Id,plaza);

                //Si se trata de una anulación de alta
                auxiliares.auxOpportunity.FechaSalida__c = null;
                auxiliares.auxOpportunity.TipoPerdida__c = null;
                auxiliares.auxOpportunity.MotivoPerdida__c = null;
                auxiliares.auxContact.FechaBaja__c = null;
                auxiliares.auxContact.CausaBaja__c = null;
                auxiliares.auxContact.EstadoContacto__c = null;

            }
            
            else if(mapPlazasIds.get('DViernes')!=null && mapPlazasIds.get('DViernes') == plaza.Cama__c && plaza.PlazaOcupada__c ==true) {
                Mensaje_Error__mdt resp = fetchResponses('PlazaOcupada');
                auxiliares.payloadOut.errorCode = resp.Error_Code__c;
                auxiliares.payloadOut.errorDescription = resp.Error_Description__c;
                CreateErrorLog(resp.Error_Code__c, resp.Error_Description__c + '. La plaza ocupada es: '+ payload.PlazasCDDestino.Viernes + ' Viernes', payload);
            } 
            
            if(mapPlazasIds.get('DSabado')!=null && mapPlazasIds.get('DSabado') == plaza.Cama__c 
            //&& plaza.PlazaOcupada__c ==false
            ){
                auxiliares.auxOpportunity.PlazaSabado__c = plaza.Id;
                plaza.PlazaOcupada__c = true;
                plaza.Id = plaza.Id;
                auxiliares.mPlazasUPD.put(plaza.Id,plaza);

                //Si se trata de una anulación de alta
                auxiliares.auxOpportunity.FechaSalida__c = null;
                auxiliares.auxOpportunity.TipoPerdida__c = null;
                auxiliares.auxOpportunity.MotivoPerdida__c = null;
                auxiliares.auxContact.FechaBaja__c = null;
                auxiliares.auxContact.CausaBaja__c = null;
                auxiliares.auxContact.EstadoContacto__c = null;

            } 
            
            else if(mapPlazasIds.get('DSabado')!=null && mapPlazasIds.get('DSabado') == plaza.Cama__c && plaza.PlazaOcupada__c ==true) {
                Mensaje_Error__mdt resp = fetchResponses('PlazaOcupada');
                auxiliares.payloadOut.errorCode = resp.Error_Code__c;
                auxiliares.payloadOut.errorDescription = resp.Error_Description__c;
                CreateErrorLog(resp.Error_Code__c, resp.Error_Description__c + '. La plaza ocupada es: '+ payload.PlazasCDDestino.Sabado + ' Sabado', payload);
            }
            
            if(mapPlazasIds.get('DDomingo')!=null && mapPlazasIds.get('DDomingo') == plaza.Cama__c 
            //&& plaza.PlazaOcupada__c ==false
            ){
                auxiliares.auxOpportunity.PlazaDomingo__c = plaza.Id;
                plaza.PlazaOcupada__c = true;
                plaza.Id = plaza.Id;
                auxiliares.mPlazasUPD.put(plaza.Id,plaza);

                //Si se trata de una anulación de alta
                auxiliares.auxOpportunity.FechaSalida__c = null;
                auxiliares.auxOpportunity.TipoPerdida__c = null;
                auxiliares.auxOpportunity.MotivoPerdida__c = null;
                auxiliares.auxContact.FechaBaja__c = null;
                auxiliares.auxContact.CausaBaja__c = null;
                auxiliares.auxContact.EstadoContacto__c = null;
                
            } 
            
            else if(mapPlazasIds.get('DDomingo')!=null && mapPlazasIds.get('DDomingo') == plaza.Cama__c && plaza.PlazaOcupada__c ==true) {
                Mensaje_Error__mdt resp = fetchResponses('PlazaOcupada');
                auxiliares.payloadOut.errorCode = resp.Error_Code__c;
                auxiliares.payloadOut.errorDescription = resp.Error_Description__c;
                CreateErrorLog(resp.Error_Code__c, resp.Error_Description__c + '. La plaza ocupada es: '+ payload.PlazasCDDestino.Domingo + ' Domingo', payload);
            }
            
        }

        return auxiliares;
    }

    /**
	@description	Método que se ejecuta hay un movimiento en RP
	@param 			WrapperMetodos auxiliares, los auxiliares a actualizar
    @param          PayloadIn payload, mensaje de entrada
    @param          Plazas necesarias para la operacion
	@return			WrapperMetodos auxiliares, los auxiliares a actualizar
	*/ 
    
    public static WrapperMetodos MovimientoRP (WrapperMetodos auxiliares, List<Plaza__c> plazaDestino, PayloadIn payload, Opportunity actualOpp){

        //Si hay cambio de plaza (se informan orgOrigen y orgDestino) --> plazasCD.get('Origen')!=null && plazasCD.get('Destino')!=null
        if(String.isNotBlank(payload.OrgOrigen) && String.isNotBlank(payload.OrgDestino) && payload.OrgOrigen != payload.OrgDestino){
                                    
            //Validar que la nueva plaza no esté ocupada (y que sea cambio de plaza)
            if(plazaDestino.size()>0){
                
                if((plazaDestino.get(0).PlazaOcupada__c == true) && (plazaDestino.get(0).Id != actualOpp.Plaza__c)){
                    Mensaje_Error__mdt resp = fetchResponses('PlazaOcupada');
                    auxiliares.payloadOut.errorCode = resp.Error_Code__c;
                    auxiliares.payloadOut.errorDescription = resp.Error_Description__c;
                    CreateErrorLog(resp.Error_Code__c, resp.Error_Description__c + '. La plaza ocupada es: ' + payload.OrgDestino, payload);
                } else{
                    
                    //busca la oportunidad cerrada activa de ese contacto y reemplazar la plaza de la oportunidad por el id de la nueva plaza
                    auxiliares.auxOpportunity.Plaza__c =  plazaDestino.get(0).Id;
                    auxiliares.auxPlazaDestino.Id = plazaDestino.get(0).Id;
                    //Marcar la antigua plaza como desocupada
                    auxiliares.auxPlazaOrigen.PlazaOcupada__c = false;
                    auxiliares.auxPlazaDestino.PlazaOcupada__c = true;

                    //Si se trata de una anulación de alta
                    auxiliares.auxOpportunity.FechaSalida__c = null;
                    auxiliares.auxOpportunity.TipoPerdida__c = null;
                    auxiliares.auxOpportunity.MotivoPerdida__c = null;
                    auxiliares.auxContact.FechaBaja__c = null;
                    auxiliares.auxContact.CausaBaja__c = null;
                    auxiliares.auxContact.EstadoContacto__c = null;
                    //Si no se informa la categoría, se pone la misma que tenía la plaza de origen
                    if (String.isBlank(payload.CategoriaDestino)) {
                        auxiliares.auxOpportunity.TipoPlaza__c = auxiliares.auxPlazaOrigen.TipoPlaza__c;
                        auxiliares.auxPlazaDestino.TipoPlaza__c = auxiliares.auxPlazaOrigen.TipoPlaza__c;
                    }else{
                        auxiliares.auxOpportunity.TipoPlaza__c = payload.CategoriaDestino;
                        auxiliares.auxPlazaDestino.TipoPlaza__c = payload.CategoriaDestino;
                    }
                }
            }
        }

        //Si viene informada plaza de Destino y no de origen se rellena la plaza

        if(String.isBlank(payload.OrgOrigen) && String.isNotBlank(payload.OrgDestino) && payload.OrgOrigen != payload.OrgDestino){
            //Validar que la nueva plaza no esté ocupada (y que sea cambio de plaza)
            if(plazaDestino.size()>0){
                
                if((plazaDestino.get(0).PlazaOcupada__c == true) && (plazaDestino.get(0).Id != actualOpp.Plaza__c)){
                    Mensaje_Error__mdt resp = fetchResponses('PlazaOcupada');
                    auxiliares.payloadOut.errorCode = resp.Error_Code__c;
                    auxiliares.payloadOut.errorDescription = resp.Error_Description__c;
                    CreateErrorLog(resp.Error_Code__c, resp.Error_Description__c + '. La plaza ocupada es: ' + payload.OrgDestino, payload);
                } else{
                    
                    //busca la oportunidad cerrada activa de ese contacto y reemplazar la plaza de la oportunidad por el id de la nueva plaza
                    auxiliares.auxOpportunity.Plaza__c =  plazaDestino.get(0).Id;
                    auxiliares.auxPlazaDestino.Id = plazaDestino.get(0).Id;
                    auxiliares.auxPlazaDestino.PlazaOcupada__c = true;

                    //Si se trata de una anulación de alta
                    auxiliares.auxOpportunity.FechaSalida__c = null;
                    auxiliares.auxOpportunity.TipoPerdida__c = null;
                    auxiliares.auxOpportunity.MotivoPerdida__c = null;
                    auxiliares.auxContact.FechaBaja__c = null;
                    auxiliares.auxContact.CausaBaja__c = null;
                    auxiliares.auxContact.EstadoContacto__c = null;
                    //Si no se informa la categoría, se pone la misma que tenía la plaza de origen
                    if (String.isBlank(payload.CategoriaDestino)) {
                        auxiliares.auxOpportunity.TipoPlaza__c = auxiliares.auxPlazaOrigen.TipoPlaza__c;
                        auxiliares.auxPlazaDestino.TipoPlaza__c = auxiliares.auxPlazaOrigen.TipoPlaza__c;
                    }else{
                        auxiliares.auxOpportunity.TipoPlaza__c = payload.CategoriaDestino;
                        auxiliares.auxPlazaDestino.TipoPlaza__c = payload.CategoriaDestino;
                    }
                }
            }
        }
        return auxiliares;
    }

    /**
	@description	Método que se ejecuta hay una anulación de episodio
	@param 			WrapperMetodos auxiliares, los auxiliares a actualizar
	@return			WrapperMetodos auxiliares, los auxiliares a actualizar
	*/ 
    
    public static WrapperMetodos OpportunityCancellation (WrapperMetodos auxiliares, PayloadIn payload){

        if(String.isNotBlank(payload.OrgOrigen)){

            auxiliares.auxPlazaOrigen.PlazaOcupada__c = false;
            auxiliares.auxPlazaOrigen.TipoPlaza__c = null;
        }

        auxiliares.auxOpportunity.StageName = 'Cerrada - Perdida';
        auxiliares.auxOpportunity.MotivoPerdida__c = 'Episodio anulado en SAP';
        auxiliares.auxOpportunity.TipoPerdida__c = 'Otros';

        return auxiliares;
    }
}