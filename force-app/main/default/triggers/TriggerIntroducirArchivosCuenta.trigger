/**
@description
Trigger que crea las relaciones de archivos que hay en contactos y oportunidad a las cuentas relacionadas sin repetir relaciones entre archivos.

DATE 		AUTHOR 		DESCRIPTION
28/09/2022  LCS - MSA   Creación.
03/06/2024  LCS - MSA   Añadir nuevo método.

@author Leadclic Solutions
@date 28/09/2022 
*/

trigger TriggerIntroducirArchivosCuenta on ContentDocumentLink (after insert, after update) {
    
    HandlerIntroducirArchivosCuenta claseApex = new HandlerIntroducirArchivosCuenta();
        if(Trigger.IsAfter){
            if(Trigger.IsUpdate){
                claseApex.insertarArchivosEnCuentas(Trigger.New);
                claseApex.insertarArchivosResidentes(Trigger.New);
            }
            if(Trigger.IsInsert){
            	claseApex.insertarArchivosEnCuentas(Trigger.New);
                claseApex.insertarArchivosResidentes(Trigger.New);
            }
        }

}