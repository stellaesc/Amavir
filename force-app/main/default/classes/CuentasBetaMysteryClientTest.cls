@isTest
public with sharing class CuentasBetaMysteryClientTest {
    @TestSetup
    static void setup(){
        List<Account> NuevasCuentas = new List<Account>();
        List<Contact> NuevosContactos = new List<Contact>();

        Id IdFamiliaAllegado = [SELECT Id FROM RecordType WHERE DeveloperName = 'FamiliaAllegado' Limit 1].Id;
        Id IdPotencialResidente = [SELECT Id FROM RecordType WHERE DeveloperName = 'PotencialResidente' Limit 1].Id;

        for(Integer i = 0; i<200;i++){
            Account Nueva = new Account();
            Nueva.Name = 'TestCuentaNueva' +i;
            Nueva.RecordTypeId = IdFamiliaAllegado;
            NuevasCuentas.add(Nueva);
        }

        insert NuevasCuentas;

        for(Integer i = 0; i<4;i++){
            Contact Nueva = new Contact();
            Nueva.LastName = 'Test';
            Nueva.FirstName = 'Test';

            //Generar False - False, True - False, False - True y True - True
            Nueva.Beta__c = (math.mod(i,2)>0)? False : True;
            Nueva.MysteryClient__c = (i>1)? False : True;
            Nueva.RecordTypeId = IdPotencialResidente;
			Nueva.AccountId = NuevasCuentas[i].Id;
            NuevosContactos.add(Nueva);
        }
        insert NuevosContactos;
    }
    @isTest 
    static void Test(){

        test.startTest();
        Database.executeBatch(new CuentasBetaMysteryClient(), 200); 
        test.stopTest();

        List<Account> ListaCuentasFalseFalse = [Select Id, Beta__c, MysteryClient__c FROM Account WHERE Beta__c = False AND MysteryClient__c = False];
        List<Account> ListaCuentasFalseTrue = [Select Id, Beta__c, MysteryClient__c FROM Account WHERE Beta__c = False AND MysteryClient__c = True];
        List<Account> ListaCuentasTrueFalse = [Select Id, Beta__c, MysteryClient__c FROM Account WHERE Beta__c = True AND MysteryClient__c = False];
        List<Account> ListaCuentasTrueTrue = [Select Id, Beta__c, MysteryClient__c FROM Account WHERE Beta__c = True AND MysteryClient__c = True];

        List<Contact> ListaContactosFalseFalse = [Select Id, AccountId FROM Contact WHERE Beta__c = False AND MysteryClient__c = False];
        List<Contact> ListaContactosFalseTrue = [Select Id, AccountId FROM Contact WHERE Beta__c = False AND MysteryClient__c = True];
        List<Contact> ListaContactosTrueFalse = [Select Id, AccountId FROM Contact WHERE Beta__c = True AND MysteryClient__c = False];
        List<Contact> ListaContactosTrueTrue = [Select Id, AccountId FROM Contact WHERE Beta__c = True AND MysteryClient__c = True];

        System.assert(ListaCuentasFalseFalse.size() == 197, 'El batch ha fallado'); //196 no asignados y 1 asignado
        System.assert(ListaCuentasFalseTrue.size() == 1, 'El batch ha fallado'); //1 Asignado
        System.assert(ListaCuentasTrueFalse.size() == 1, 'El batch ha fallado'); //1 Asignado
        System.assert(ListaCuentasTrueTrue.size() == 1, 'El batch ha fallado'); //1 Asignado

        System.assert(ListaContactosFalseTrue[0].AccountId == ListaCuentasFalseTrue[0].Id, 'El batch ha fallado');
        System.assert(ListaContactosTrueFalse[0].AccountId == ListaCuentasTrueFalse[0].Id, 'El batch ha fallado');
        System.assert(ListaContactosTrueTrue[0].AccountId == ListaCuentasTrueTrue[0].Id, 'El batch ha fallado');

    }
}