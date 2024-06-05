/**
@description
Clase de un solo uso para realizar un histórico de los archivos.

DATE 		AUTHOR 		DESCRIPTION
31/10/2022  LCS - MSA	Creación

@author Leadclic Solutions
@date 31/10/2022 
*/
public class QueryUnicaIntroducirArchivosCuentas {
    /* 
    @description Método que a ejecutar
    @param void
    @return void no se realiza devolución
    */
    public static void GetQuery(){
        
        List<ContentDocumentLink> ListaDocumentos = [SELECT LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN (select Id from Contact)];
        List<ContentDocumentLink> ListaDocumentosOportunidades = [SELECT LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN (select Id from Opportunity)];
        
        for(ContentDocumentLink  a:ListaDocumentosOportunidades){
            ListaDocumentos.add(a);
        }
        Insertar(ListaDocumentos);
        
    }
    /* 
    @description Método de apoyo para obtener un fichero csv
    @param Lista de relaciones entre registros y documentos
    @return void no se realiza devolución
    */
     public static void Insertar(List<ContentDocumentLink> TriggerNew){
        List<Id> ListaIds = new List<Id>(); //Lista de Ids de los registros a los cuales se comparten
        List<Id> IdsCuenta = new List<Id>(); //Lista de Ids de las cuentas
        List<ContentDocumentLink> ListaUpsert = new List<ContentDocumentLink>(); //Lista para subir las nuevas relaciones entre el archivo y la cuenta
       
        //Rellenamos las listas y los mapas
        for(ContentDocumentLink Archivos: TriggerNew){
            ListaIds.add(Archivos.LinkedEntityId);
        }
        
        //Buscamos los contactos y las oportunidades en concreto
        List<Contact> ListaContactos = [SELECT Id, AccountId FROM Contact WHERE Id=: ListaIds];
        List<Opportunity> ListaOportunidades = [SELECT Id, AccountId FROM Opportunity WHERE Id=: ListaIds];
         
        
        
        
        //Nos quedamos con los Ids de las cuentas
        for(Contact Contacto: ListaContactos){
            IdsCuenta.add(Contacto.AccountId);
        }
        for(Opportunity Oportunidad: ListaOportunidades){
            IdsCuenta.add(Oportunidad.AccountId);
        }
        
        List<ContentDocumentLink> CuentasConDocumento = new List<ContentDocumentLink>();
        ListaContactos = [SELECT Id, AccountId FROM Contact WHERE AccountId=: IdsCuenta];
        ListaOportunidades = [SELECT Id, AccountId FROM Opportunity WHERE AccountId=: IdsCuenta];
        
        List<ContentDocumentLink> ListaDocumentos = [SELECT LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN (select Id from contact WHERE AccountId=: IdsCuenta)];
        List<ContentDocumentLink> ListaDocumentosOportunidades = [SELECT LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN (select Id from Opportunity WHERE AccountId=: IdsCuenta)];
         
        //Buscamos las cuentas que tienen uno de los documentos que entran en el trigger
        List<ContentDocumentLink> Documentos = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN(select Id from Account where id IN: IdsCuenta)];
        
        //Relacionamos el Id de cuenta con el documento
        for(ContentDocumentLink Documento:Documentos){
            
            ContentDocumentLink NuevaRelacion= new ContentDocumentLink();
            NuevaRelacion.ContentDocumentId = Documento.ContentDocumentId; 
            NuevaRelacion.LinkedEntityId = Documento.LinkedEntityId;
            
            CuentasConDocumento.add(NuevaRelacion);
        }
        
        //Buscamos si esa cuenta ya tiene el archivo en concreto, si no lo tiene, se crea la relación
        map<Id, Id> mapaContactosCuenta = new map<Id, Id>();
         
         for(Contact Contacto:ListaContactos){
             mapaContactosCuenta.put(Contacto.Id,  Contacto.AccountId);
         }
            for(ContentDocumentLink Archivos: ListaDocumentosOportunidades){
                if(mapaContactosCuenta.get(Archivos.LinkedEntityId) != null){
                    ContentDocumentLink NuevaRelacion= new ContentDocumentLink();
                    NuevaRelacion.ContentDocumentId = Archivos.ContentDocumentId; 
                    NuevaRelacion.LinkedEntityId = mapaContactosCuenta.get(Archivos.LinkedEntityId);
                    if((!CuentasConDocumento.contains(NuevaRelacion))){
                        ListaUpsert.add(NuevaRelacion);
                        CuentasConDocumento.add(NuevaRelacion);
                    }
                }
             }
                 map<Id, Id> mapaOportunidadesCuenta = new map<Id, Id>();
         
         for(Opportunity Oportunidad:ListaOportunidades){
             mapaOportunidadesCuenta.put(Oportunidad.Id,  Oportunidad.AccountId);
         }
            for(ContentDocumentLink Archivos: ListaDocumentosOportunidades){
                if(mapaOportunidadesCuenta.get(Archivos.LinkedEntityId) != null){
                    ContentDocumentLink NuevaRelacion= new ContentDocumentLink();
                    NuevaRelacion.ContentDocumentId = Archivos.ContentDocumentId; 
                    NuevaRelacion.LinkedEntityId = mapaOportunidadesCuenta.get(Archivos.LinkedEntityId);
                    if((!CuentasConDocumento.contains(NuevaRelacion))){
                        ListaUpsert.add(NuevaRelacion);
                        CuentasConDocumento.add(NuevaRelacion);
                    }
                }
             }
        
        //Realizamos el csv
        String csv = 'LinkedEntityId,ContentDocumentId';
         for(ContentDocumentLink NuevasRelaciones: ListaUpsert){
             csv= csv + '\n';
             csv= csv + NuevasRelaciones.LinkedEntityId+','+NuevasRelaciones.ContentDocumentId;
         }
         System.debug(csv);
        //upsert ListaUpsert;
     }
}