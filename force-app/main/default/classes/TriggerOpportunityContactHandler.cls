/**
@description
Handler del trigger TriggerOpportunityContact

DATE 		AUTHOR 		DESCRIPTION
03/09/2024	LCS - MSA	Creation

@author Leadclic Solutions
@date 03/09/2024
*/

public class TriggerOpportunityContactHandler {
    public void treatContactInformation(List<OpportunityContactRole> triggerNew) {
        if(triggerNew[0].Role != 'Residente'){
            List<OpportunityContactRole> residentOcr = [SELECT Id, Contact.IdExternoSAP__c, 
                                                    Opportunity.ResidenciaIngreso__r.CodigoCentroSAP__c 
                                                    FROM OpportunityContactRole 
                                                    WHERE OpportunityId = :triggerNew[0].OpportunityId AND Role ='Residente'
                                                    AND Opportunity.IdExternoSAP__c != null AND Opportunity.FechaSalida__c = null
                                                    AND (Opportunity.StageName = 'Cerrada - Éxito' OR Opportunity.StageName = 'Envío SAP')];

                                                    
                Contact familiar = [SELECT Id, FirstName, LastName, Salutation, Parentesco__c, MailingStreet,
                                    MailingPostalCode, MailingCity, MobilePhone, RecordType.DeveloperName,
                                    Email FROM Contact WHERE Id = :triggerNew[0].ContactId];

            if(residentOcr.size() > 0){
                ConectorFamiliares.sendContact(ConectorFamiliares.prepareDataToSend(familiar, residentOcr[0].Contact.IdExternoSAP__c, residentOcr[0].Opportunity.ResidenciaIngreso__r.CodigoCentroSAP__c), familiar.Id);
            }
        }
        
    }
}