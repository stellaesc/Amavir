/**
@description
Clase del trigger IntroducirArchivosCuenta

DATE 		AUTHOR 		DESCRIPTION
26/09/2022  LCS - MSA   Creación.
28/09/2022  LCS - MSA   Corrección de errores.
02/11/2022  LCS - MSA	Corrección de errores.
03/06/2024  LCS - MSA	Nuevo método, introducir archivos en contactos.

@author Leadclic Solutions
@date 26/09/2022 
*/

public class HandlerIntroducirArchivosCuenta {
    
    private static final string RT_RESIDENTES = 'PotencialResidente';
    /* 
    @description Método que se ejecuta desde el trigger y crea las relaciones de archivos que hay en contactos y
					oportunidad a las cuentas relacionadas sin repetir relaciones entre archivos.
    @param triggerNew Lista de relaciones entre registros y archivos.
    @return void no se realiza devolución
    */   
    
    public void insertarArchivosEnCuentas(List<ContentDocumentLink> triggerNew){
        List<Id> listaIds = new List<Id>(); //Lista de Ids de los registros a los cuales se comparten
        List<Id> idsCuenta = new List<Id>(); //Lista de Ids de las cuentas
        List<ContentDocumentLink> listaUpsert = new List<ContentDocumentLink>(); //Lista para subir las nuevas relaciones entre el archivo y la cuenta
        //Rellenamos las listas y los mapas
        for(ContentDocumentLink archivos: triggerNew){
            listaIds.add(archivos.LinkedEntityId);
        }
        
        //Buscamos los contactos y las oportunidades en concreto
        List<Contact> listaContactos = [SELECT Id, AccountId FROM Contact WHERE Id = :listaIds];
        List<Opportunity> listaOportunidades = [SELECT Id, AccountId FROM Opportunity WHERE Id = :listaIds];
        
        //Nos quedamos con los Ids de las cuentas
        for(Contact contacto: listaContactos){
            idsCuenta.add(contacto.AccountId);
        }
        for(Opportunity oportunidad: listaOportunidades){
            idsCuenta.add(oportunidad.AccountId);
        }
        
        List<ContentDocumentLink> cuentasConDocumento = new List<ContentDocumentLink>();
        listaContactos = [SELECT Id, AccountId FROM Contact WHERE AccountId = :idsCuenta];
        listaOportunidades = [SELECT Id, AccountId FROM Opportunity WHERE AccountId = :idsCuenta];
        
         
        //Buscamos las cuentas que tienen uno de los documentos que entran en el trigger
        List<ContentDocumentLink> documentos = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN(select Id from Account where id IN: idsCuenta)];
        
        //Relacionamos el Id de cuenta con el documento
        for(ContentDocumentLink documento:documentos){
            
            ContentDocumentLink nuevaRelacion= new ContentDocumentLink();
            nuevaRelacion.ContentDocumentId = documento.ContentDocumentId; 
            nuevaRelacion.LinkedEntityId = documento.LinkedEntityId;
            
            cuentasConDocumento.add(nuevaRelacion);
        }
        
        //Buscamos si esa cuenta ya tiene el archivo en concreto, si no lo tiene, se crea la relación
        map<Id, Id> m_ContactosCuenta = new map<Id, Id>();
         
        for(Contact contacto : listaContactos){
            m_ContactosCuenta.put(contacto.Id,  contacto.AccountId);
        }
            for(ContentDocumentLink archivos: triggerNew){
                if(m_ContactosCuenta.get(archivos.LinkedEntityId) != null){
                    ContentDocumentLink nuevaRelacion= new ContentDocumentLink();
                    nuevaRelacion.ContentDocumentId = archivos.ContentDocumentId; 
                    nuevaRelacion.LinkedEntityId = m_ContactosCuenta.get(archivos.LinkedEntityId);
                    if((!cuentasConDocumento.contains(nuevaRelacion))){
                        listaUpsert.add(nuevaRelacion);
                        cuentasConDocumento.add(nuevaRelacion);
                    }
                }
             }
        
        map<Id, Id> m_OportunidadesCuenta = new map<Id, Id>();
         
        for(Opportunity oportunidad:listaOportunidades){
            m_OportunidadesCuenta.put(oportunidad.Id,  oportunidad.AccountId);
        }
            for(ContentDocumentLink archivos: triggerNew){
                if(m_OportunidadesCuenta.get(archivos.LinkedEntityId) != null){
                    ContentDocumentLink nuevaRelacion= new ContentDocumentLink();
                    nuevaRelacion.ContentDocumentId = archivos.ContentDocumentId; 
                    nuevaRelacion.LinkedEntityId = m_OportunidadesCuenta.get(archivos.LinkedEntityId);
                    if((!cuentasConDocumento.contains(nuevaRelacion))){
                        listaUpsert.add(nuevaRelacion);
                        cuentasConDocumento.add(nuevaRelacion);
                    }
                }
            }
        
        //Añadimos las relaciones
        upsert listaUpsert;
    }

    /* 
    @description Método que se ejecuta desde el trigger y crea las relaciones de archivos que hay en cuenta y
					oportunidad a los contactos residentes de la cuenta.
    @param triggerNew Lista de relaciones entre registros y archivos.
    @return void no se realiza devolución
    */   

    public void insertarArchivosResidentes(List<ContentDocumentLink> triggerNew){
        List<Id> listaIds = new List<Id>(); //Lista de Ids de los registros a los cuales se comparten

        //Rellenamos las listas y los mapas
        for(ContentDocumentLink archivos: triggerNew){
            listaIds.add(archivos.LinkedEntityId);
        }

        List<Contact> listaContactosResidentes = [SELECT Id FROM Contact WHERE AccountId = :listaIds AND RecordType.DeveloperName = :RT_RESIDENTES];

        if(listaContactosResidentes.size() > 0){
            List<ContentDocumentLink> listaUpsert = new List<ContentDocumentLink>();
            List<ContentDocumentLink> contactosConDocumento = new List<ContentDocumentLink>();

            //Buscamos los contactos que tienen uno de los documentos que entran en el trigger
            List<ContentDocumentLink> documentos = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN(select Id from Contact where id IN: listaContactosResidentes)];
            
            //Relacionamos el Id de contacto con el documento
            for(ContentDocumentLink documento : documentos){
                
                ContentDocumentLink nuevaRelacion= new ContentDocumentLink();
                nuevaRelacion.ContentDocumentId = documento.ContentDocumentId; 
                nuevaRelacion.LinkedEntityId = documento.LinkedEntityId;
                
                contactosConDocumento.add(nuevaRelacion);
            }

            //Introducimos las nuevas relaciones entre documento y contacto residente
            for(ContentDocumentLink documento : triggerNew){
                for(Contact contacto : listaContactosResidentes){

                    ContentDocumentLink nuevaRelacion= new ContentDocumentLink();
                    nuevaRelacion.ContentDocumentId = documento.ContentDocumentId; 
                    nuevaRelacion.LinkedEntityId = contacto.Id;

                    if((!contactosConDocumento.contains(nuevaRelacion))){
                        listaUpsert.add(nuevaRelacion);
                        contactosConDocumento.add(nuevaRelacion);
                    }
                }
            }

            upsert listaUpsert;
        }

        

    }
}