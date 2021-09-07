public with sharing class MaintenanceRequestHelper {
    public static void updateWorkOrders(List<Case> caseList) {
        List<Case> newMaintenanceRequests = new List<Case>();
        Map<Id,Case> casesClosedMap = new Map<Id,Case>();
        Map<Id, Integer> dueDate = new Map<Id, Integer>();
        Map<Id,List<Id>> caseEquipMap = new Map<Id,List<ID>>();
        Map<Id,Case> oldNewCaseMap = new Map<Id,Case>();
		List<Equipment_Maintenance_Item__c> newEmiList = new List<Equipment_Maintenance_Item__c>();
 
        for(Case cs: caseList){
            if(cs.Status == 'Closed' && (cs.Type=='Repair' || cs.Type=='Routine Maintenance')){
                casesClosedMap.put(cs.Id, cs);
            }
        }
        System.debug('casesClosedMap->'+casesClosedMap);
        if(!casesClosedMap.isEmpty()){
            dueDate = getDueDate(casesClosedMap.keyset());
        }
        System.debug('dueDate->'+dueDate);
        List<Equipment_Maintenance_Item__c> equipments = [Select Maintenance_Request__r.ID,Equipment__r.Id
                                         				  FROM Equipment_Maintenance_Item__c
                                         				  WHERE Maintenance_Request__r.ID in :casesClosedMap.keyset()];
        System.debug('equipments->'+equipments);
        for(Equipment_Maintenance_Item__c emi:equipments){
            if(!caseEquipMap.containsKey(emi.Maintenance_Request__r.ID)){
                caseEquipMap.put(emi.Maintenance_Request__r.Id, new List<Id>());
            }
            caseEquipMap.get(emi.Maintenance_Request__r.Id).add(emi.Equipment__r.ID);
            
        }
        System.debug('caseEquipMap->'+caseEquipMap);
        for(Case cs:casesClosedMap.values()){
            Case newCase = new Case();
            newCase.Status = 'New';
            newCase.Type = 'Routine Maintenance';
            newCase.Subject = cs.Subject;
            newCase.Vehicle__c = cs.Vehicle__c;
            newCase.Date_Reported__c = Date.today();
            newCase.Date_Due__c = dueDate.containsKey(cs.Id) ?  Date.today().addDays(dueDate.get(cs.Id)) : Date.today();
            newCase.Product__c = cs.Product__c;
            oldNewCaseMap.put(cs.id, newCase);
            newMaintenanceRequests.add(newCase);
        }
        System.debug('newMaintenanceRequests->'+newMaintenanceRequests);
        if(newMaintenanceRequests.size()>0){
        	insert newMaintenanceRequests;
            for(Id cs: casesClosedMap.keyset()){
                Case newCase = oldNewCaseMap.get(cs);
                List<Id> equipmentsList = caseEquipMap.get(cs);
                for(Id eq: equipmentsList){
                    Equipment_Maintenance_Item__c newEmi = new Equipment_Maintenance_Item__c(Equipment__c=eq,Maintenance_Request__c=newCase.Id);
                    newEmiList.add(newEmi);
                }      
            }
            System.debug('newEmiList->'+newEmiList);
            if(newEmiList.size()>0) insert newEmiList;
        } 
    } 
    
    public static Map<Id,Integer> getDueDate(Set<ID> caseIds) {
        Map<Id, Integer> dueDate = new Map<Id, Integer>();
        List<AggregateResult> aggregateResults = [Select Maintenance_Request__r.ID caseId,MIN(Equipment__r.Maintenance_Cycle__c) mcycle
                                                  FROM Equipment_Maintenance_Item__c
                                                  WHERE Maintenance_Request__r.ID in :caseIds AND Equipment__r.Maintenance_Cycle__c != NULL
                                                  GROUP BY Maintenance_Request__r.Id];
        System.debug('res->' + aggregateResults);
        for(AggregateResult res: aggregateResults){
            if(res.get('mcycle') != NULL){
                Integer dueDateValue = Integer.valueOf(res.get('mcycle'));
                dueDate.put((ID)res.get('caseId'), dueDateValue);
            }
        }
        return dueDate;
        
    }
    
}