global with sharing class WarehouseSyncSchedule implements Schedulable{
    global void execute(SchedulableContext sc){
        Id jobID = System.enqueueJob(new WarehouseCalloutService());
        System.debug('jobID->'+jobID);
    }
    
}