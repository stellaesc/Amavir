/** 
@description
<pre>
Servicio web RESTful que actualizará la ocupación mediante un Batch Apex</br>

FECHA       AUTOR   	    DESCRIPCION<br/>
16/01/2024	MSA - LCS       Creado
</pre>
@author Leadclic Solutions
@date 7/11/2023
*/
@RestResource(urlMapping='/WSReajustarOcupacion/*')
global with sharing class WSReajustarOcupacion implements Schedulable,  Database.Batchable<sObject>{

    private PayloadIn payload_global;
    private Set<String> Episodios;

    public WSReajustarOcupacion(PayloadIn payload) {
        payload_global = payload;
        Episodios = payload.Episodios.keySet();
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {

        Account Centro = [SELECT Id FROM Account WHERE CodigoCentroSAP__c =: payload_global.Centro limit 1];
        List<Plaza__c> ListaPlazas = [SELECT Name, Id, Cama__c, PlazaOcupada__c FROM Plaza__c WHERE Cuenta__c =: Centro.Id];

        map<String, Id> mCamaId = new map<String, Id>();

        for(Plaza__c plaza : ListaPlazas){
            plaza.PlazaOcupada__c = false;
            mCamaId.put(plaza.Cama__c, plaza.Id);
        }
        update ListaPlazas;
                     
        string query = 'SELECT Id, IdExternoSAP__c, Plaza__c, PlazaLunes__c, PlazaMartes__c, PlazaMiercoles__c, PlazaJueves__c, PlazaViernes__c, PlazaSabado__c, PlazaDomingo__c FROM Opportunity WHERE IdExternoSAP__c =: Episodios AND ResidenciaIngreso__r.Name != null';  
        return Database.getQueryLocator(query);
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new CuentasResidencia(), 200); 
    }

    public void execute(Database.BatchableContext bc, List<Opportunity> ListaOportunidades){
        List<Id> ListaPlazasOcupadas = new List<Id>();
        List<Plaza__c> ListaPlazasOcupadasUpdate = new List<Plaza__c>();

        Account Centro = [SELECT Id FROM Account WHERE CodigoCentroSAP__c =: payload_global.Centro];
        List<Plaza__c> ListaPlazas = [SELECT Name, Id, Cama__c, PlazaOcupada__c FROM Plaza__c WHERE Cuenta__c =: Centro.Id];

        map<String, Id> mCamaId = new map<String, Id>();

        for(Plaza__c plaza : ListaPlazas){
            plaza.PlazaOcupada__c = false;
            mCamaId.put(plaza.Cama__c, plaza.Id);
        }

        for(Opportunity Oportunidad : ListaOportunidades){
            Oportunidad.Plaza__c = mCamaId.get(payload_global.Episodios.get(Oportunidad.IdExternoSAP__c).get('Residencia'));
            Oportunidad.PlazaLunes__c = mCamaId.get(payload_global.Episodios.get(Oportunidad.IdExternoSAP__c).get('Lunes') + 'L');
            Oportunidad.PlazaMartes__c = mCamaId.get(payload_global.Episodios.get(Oportunidad.IdExternoSAP__c).get('Martes') + 'M');
            Oportunidad.PlazaMiercoles__c = mCamaId.get(payload_global.Episodios.get(Oportunidad.IdExternoSAP__c).get('Miercoles') + 'X');
            Oportunidad.PlazaJueves__c = mCamaId.get(payload_global.Episodios.get(Oportunidad.IdExternoSAP__c).get('Jueves') + 'J');
            Oportunidad.PlazaViernes__c = mCamaId.get(payload_global.Episodios.get(Oportunidad.IdExternoSAP__c).get('Viernes') + 'V');
            Oportunidad.PlazaSabado__c = mCamaId.get(payload_global.Episodios.get(Oportunidad.IdExternoSAP__c).get('Sabado') + 'S');
            Oportunidad.PlazaDomingo__c = mCamaId.get(payload_global.Episodios.get(Oportunidad.IdExternoSAP__c).get('Domingo') + 'D');

            ListaPlazasOcupadas.add(mCamaId.get(payload_global.Episodios.get(Oportunidad.IdExternoSAP__c).get('Residencia')));
            ListaPlazasOcupadas.add(mCamaId.get(payload_global.Episodios.get(Oportunidad.IdExternoSAP__c).get('Lunes') + 'L'));
            ListaPlazasOcupadas.add(mCamaId.get(payload_global.Episodios.get(Oportunidad.IdExternoSAP__c).get('Martes') + 'M'));
            ListaPlazasOcupadas.add(mCamaId.get(payload_global.Episodios.get(Oportunidad.IdExternoSAP__c).get('Miercoles') + 'X'));
            ListaPlazasOcupadas.add(mCamaId.get(payload_global.Episodios.get(Oportunidad.IdExternoSAP__c).get('Jueves') + 'J'));
            ListaPlazasOcupadas.add(mCamaId.get(payload_global.Episodios.get(Oportunidad.IdExternoSAP__c).get('Viernes') + 'V'));
            ListaPlazasOcupadas.add(mCamaId.get(payload_global.Episodios.get(Oportunidad.IdExternoSAP__c).get('Sabado') + 'S'));
            ListaPlazasOcupadas.add(mCamaId.get(payload_global.Episodios.get(Oportunidad.IdExternoSAP__c).get('Domingo') + 'D'));
        }

        ListaPlazasOcupadasUpdate = [SELECT Id, PlazaOcupada__c FROM Plaza__c WHERE Id IN: ListaPlazasOcupadas];

        for(Plaza__c plaza : ListaPlazasOcupadasUpdate){
            plaza.PlazaOcupada__c = true;
        }
        update ListaOportunidades;
        update ListaPlazasOcupadasUpdate;
    }
    public void finish(Database.BatchableContext bc){

        System.debug(payload_global);
        System.debug(Episodios);

    }

    ///////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////

    //Web Service

    ///////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////
    @HttpPost
    global static PayloadOut WSReajustarOcupacion(PayloadIn payload) {

        PayloadOut payloadOut = new PayloadOut();

        try{
            payloadOut.errorCode = '-1';
            payloadOut.errorDescription = 'Se va a proceder a realizar la ocupación';
            Database.executeBatch(new WSReajustarOcupacion(payload), 20);

        }catch(Exception e){
            Mensaje_Error__mdt resp = fetchResponses('err500');
            payloadOut.errorCode = resp.Error_Code__c;
            payloadOut.errorDescription = e.getMessage();
            CreateErrorLog(resp.Error_Code__c, e.getMessage(), payload);
        }

        return payloadOut;
    }

    //Wrapper class de entrada
    global class PayloadIn {
        public String Centro {get;set;}
        public map<String, map<String, String>> Episodios {get;set;}
    }

    //Wrapper class de salida
    global class PayloadOut {
        public String errorDescription {get;set;}
        public String errorCode {get;set;}
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
        ErrorGenerado.ClaseGeneradora__c = 'WSGestionUsuarios';

        insert ErrorGenerado;
    }
}