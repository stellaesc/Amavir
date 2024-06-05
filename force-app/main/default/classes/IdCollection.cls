/**
@description
<pre>
Clase con metodos que se necesitan para obtener registros de una lista de IDs en un Flow<br/>
FECHA       AUTOR    DESCRIPCION<br/>
25-02-2022. JLQ.     Creacion
</pre>
@author Leadclic Solutions
@date 25-02-2022
*/

global with sharing class IdCollection {
    
    /**
    @description Metodo que devuelve una lista de contactos a partir de una lista de ids
    @param listIDs lista batcheable de la lista de ids
    @return Lista batcheable de la lista de contactos
    */
    @InvocableMethod (label='Obtener contactos de Evento' description='Convierte una lista de IDs en una lista de Contactos')
    public static List<List<Contact>> getContactsCollection(List<List<String>> listIDs)
    {
        //Se almacenan todos los ids en una lista
        List<String> totalIds = new List<String>();
        for (List<String> lista : listIDs) {
    		for (String idContact : lista) {
    			totalIds.add(idContact);
			}
		}
        
        //Se hace una query para obtener todos los contactos con el recordtype de los ids de la lista
        List<Contact> lContacts = [ SELECT id, RecordTypeId FROM Contact WHERE id IN :totalIds ] ;
        
        //Se mapean todos los contactos almacenando el par (id, contacto) 
        Map<String, Contact> mapaContactos = new Map<String, Contact>();
        for (Contact contacto : lContacts) {
            mapaContactos.put(contacto.id, contacto);
        }
        
        //Se crea la lista final que almacenará las listas de contactos de cada lista.
        List<List<Contact>> listaFinal = new List<List<Contact>>();
        for (List<String> lista : listIDs) {
            List<Contact> lContact = new List<Contact>(); 
    		for (String idContact : lista) {
                //Devolverá null si es un candidato
                if(mapaContactos.get(idContact) != null)
    				lContact.add(mapaContactos.get(idContact));
			}
            listaFinal.add(lContact);
		}
        
        return listaFinal;
    }
}