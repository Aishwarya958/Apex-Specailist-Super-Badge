@isTest
public with sharing class MaintenanceRequestHelperTest {
    
   	@testSetup
    static void setup(){
        Vehicle__c vehicleRecord = new Vehicle__c(Name='Test Vehicle');
        insert vehicleRecord;
        
        Case caseRecord = new Case(Status='New', Type='Repair',Subject='Test CaseRecord',Vehicle__c=vehicleRecord.Id);
        insert caseRecord;
        
        Product2 equipmentRecord1 = new Product2(Name='Generator 1000 kW',Maintenance_Cycle__c=15,Replacement_Part__c=true);
        insert equipmentRecord1;   
        Product2 equipmentRecord2 = new Product2(Name='GenWatt Diesel 1000kW',Maintenance_Cycle__c=30,Replacement_Part__c=true);
        insert equipmentRecord2;   
        Product2 equipmentRecord3 = new Product2(Name='Breaker 13C',Maintenance_Cycle__c=45,Replacement_Part__c=true);
        insert equipmentRecord3;
        
        Equipment_Maintenance_Item__c newEmi1 = new Equipment_Maintenance_Item__c(Equipment__c=equipmentRecord1.Id,Maintenance_Request__c=caseRecord.Id);
        insert newEmi1;
        Equipment_Maintenance_Item__c newEmi2 = new Equipment_Maintenance_Item__c(Equipment__c=equipmentRecord2.Id,Maintenance_Request__c=caseRecord.Id);
        insert newEmi2;
        Equipment_Maintenance_Item__c newEmi3 = new Equipment_Maintenance_Item__c(Equipment__c=equipmentRecord3.Id,Maintenance_Request__c=caseRecord.Id);
        insert newEmi3;
    }
    
    static testMethod void UpdateWorkOrders(){
        Test.startTest();
        Case caseRecord = [select status,id,type,subject,Vehicle__c,Date_Reported__c,Date_Due__c,Product__c from Case LIMIT 1];
        caseRecord.status='Closed';
        update caseRecord;
        Test.stopTest();
        List<Case> newCase = [select status,id,type,subject,Vehicle__c,Date_Reported__c,Date_Due__c,Product__c from Case where id != :caseRecord.Id];
        Date dueDate = Date.today().addDays(15);
        System.assertEquals(1, newCase.size());
        System.assertEquals(dueDate, newCase[0].Date_Due__c);
        System.assertEquals('New', newCase[0].Status);
        System.assertEquals('Routine Maintenance', newCase[0].Type);
        
        List<Equipment_Maintenance_Item__c> emis = [select Maintenance_Request__r.ID,Equipment__r.ID from Equipment_Maintenance_Item__c where Maintenance_Request__r.ID=:newCase[0].id];
        System.debug('emis'+emis);
    }
}