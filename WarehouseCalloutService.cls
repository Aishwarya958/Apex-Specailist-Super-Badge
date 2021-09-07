public with sharing class WarehouseCalloutService implements Queueable,Database.AllowsCallouts{

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    public void execute(QueueableContext context) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(WAREHOUSE_URL);
        req.setMethod('GET');
        
        HttpResponse res = http.send(req);
        System.debug(res.getBody());
        
        List<Product2> wareHouseEquipments = new List<Product2>();
        if(res.getStatusCode() == 200){
            List<Object> jsonResponse = (List<Object>)JSON.deserializeUntyped(res.getBody());
            System.debug('jsonResponse->' + jsonResponse);
            System.debug('deserializeUntyped->' + JSON.deserializeUntyped(res.getBody()));
            for(Object equipment: jsonResponse){
                System.debug('equipment->'+equipment);
                Map<String,Object> mapJSON = (Map<String,Object>)equipment;
                System.debug('mapJSON->'+mapJSON);
                Product2 sfEquipment = new Product2();
                sfEquipment.Replacement_Part__c = true;
                sfEquipment.Name = (String) mapJson.get('name');
                sfEquipment.Maintenance_Cycle__c = (Integer) mapJson.get('maintenanceperiod');
                sfEquipment.Lifespan_Months__c = (Integer) mapJson.get('lifespan');
                sfEquipment.Cost__c = (Decimal) mapJson.get('cost');
                sfEquipment.Warehouse_SKU__c = (String) mapJson.get('sku');
                sfEquipment.Current_Inventory__c = (Double) mapJson.get('quantity');
                wareHouseEquipments.add(sfEquipment);
                if(wareHouseEquipments.size()>0) upsert wareHouseEquipments;
                System.debug('Your equipment was synced with the warehouse one');
                System.debug(wareHouseEquipments);           
            }
        }
		        
    }
    
}