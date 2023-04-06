public class OrderToAssetHelper {
    public static void CreateAssetRecord(List<Order> orders, Map<Id, Order> oldOrderList){
        Set<Id> activatedOrder=new Set<Id>();
        for(Order ord : orders)
        {
            if(oldOrderList.containsKey(ord.Id)&& oldOrderList.get(ord.Id).Status=='Draft' && (ord.Status=='Activated' || ord.Status=='Shipped'))
            {
                activatedOrder.add(ord.Id);
            }
        }
        List<OrderItem> orderProductList = [SELECT Id, OrderId, Order.Name, Quantity, Order.AccountId, Product2.ProductCode,
                                            Product2.Id, order.EffectiveDate, UnitPrice,  order.OpportunityId, order.Status from OrderItem
                                            WHERE Product2.Family = 'Software' AND OrderId In :activatedOrder ];
        
        List<Asset> assetList = new List<Asset>();
        List<EntitlementContact>entitlementContactList = new List<EntitlementContact>();
        Set<ID>opportunityIdSet = new Set<ID>();
        List<BusinessHours>businessHours = [SELECT id from BusinessHours];
        
        Map<String, Entitlement> assetEntitleMap = new Map<String, Entitlement>();
        
        for(OrderItem ol : orderProductList){
            Integer noOfAssets = (Integer)ol.Quantity;
            for(Integer i=1; i<=noOfAssets; i++){
                Asset asset  = new Asset(
                    Name = 'Asset' + ol.Order.Name + ol.Product2.ProductCode + i, 
                    AccountId = ol.order.AccountId,
                    Opportunity__c = ol.order.OpportunityId, 
                    Product2Id = ol.Product2Id, 
                    Price = ol.UnitPrice, 
                    PurchaseDate = ol.order.EffectiveDate, 
                    Status = (ol.order.Status == 'Shipped' ?'Shipped' : 'Purchased'),
                    Quantity = ol.Quantity
                );
                opportunityIdSet.add(ol.order.OpportunityId);
                if(asset.Status == 'Shipped'){
                    asset.Actual_Ship_Date__c = Date.today();
                }
                assetList.add(asset);
                
                //creating entitlement
       
                Entitlement et = new Entitlement(
                    Name = 'Ent' + ol.order.Name + ol.Product2.ProductCode + i,
                    AccountId = ol.order.AccountId,
                    AssetId = asset.id,
                    StartDate = ol.order.EffectiveDate,
                    //EndDate = ol.order.EffectiveDate .addDays(ol.Product2.POC__c ? 90 : 365),
                    BusinessHoursId = businessHours[0].id
                        
                );
                assetEntitleMap.put(asset.Name, et);

            }
                     
        }
        insert assetList;
        
        for(Asset asset : assetList){
            assetEntitleMap.get(asset.Name).AssetId = asset.id;
        }
        insert assetEntitleMap.values();
        
        // creating entitlement contact record
        List<OpportunityContactRole> opportunityContactList = [SELECT Id, OpportunityId, ContactId, Role from OpportunityContactRole 
                                                               where Role = 'Primary Support' AND OpportunityId in :opportunityIdSet];
        for(OpportunityContactRole opp : opportunityContactList){
            for(Entitlement etn : assetEntitleMap.values()){
                EntitlementContact ec = new EntitlementContact(
                       EntitlementId = etn.id,
                       ContactId = opp.ContactId
                 );
                 entitlementContactList.add(ec);
            }
        }
        insert entitlementContactList;
    }
    
    
    // updating Asset Status
    public static void updateAssetStatus(List<Order> orders, Map<Id, Order> oldOrderList){
        Set<Id> shippedOrder=new Set<Id>();
        for(Order ord : orders)
        {
            if(oldOrderList.containsKey(ord.Id)&& oldOrderList.get(ord.Id).Status=='Activated' && ord.Status=='Shipped')
            {
                shippedOrder.add(ord.Id);
            }
        }
        
        List<OrderItem> orderProductList = [SELECT Id, OrderId, Order.Name, Quantity, order.Status,Order.AccountId, Product2.ProductCode from OrderItem
                                            WHERE Product2.Family = 'Software' AND OrderId In :shippedOrder ];
        
        List<Asset>assetList = [Select ID, Name, Status, Actual_Ship_Date__c from Asset];
        List<Asset>orderAssetList = new List<Asset>();
        
        for(OrderItem orderItem : orderProductList){
            String assetName = 'Asset' + orderItem.Order.Name + orderItem.Product2.ProductCode;
            for(Asset asset : assetList){
                if((asset.Name).startsWith(assetName)){
                    orderAssetList.add(asset);
                }
            }
            System.debug(orderAssetList);
        }
        for(Asset asset : orderAssetList){
            asset.Status = 'Shipped';
            asset.Actual_Ship_Date__c = Date.today();
        }
        update orderAssetList;
    }
    
    
    //function to create user record
    public static void createUserRecord(List<Order> orders, Map<Id, Order> oldOrderList){
        List<User>usersList = [Select Id, Name, Email, Username, UserRoleId from User ];
        Set<Id> shippedOpportunityIDSet=new Set<Id>();
        for(Order ord : orders)
        {
            if(oldOrderList.containsKey(ord.Id)&& oldOrderList.get(ord.Id).Status=='Activated' && ord.Status=='Shipped')
            {
                shippedOpportunityIDSet.add(ord.OpportunityId);
            }
        }
        
        List<OpportunityContactRole> opportunityContactList = [SELECT Id, OpportunityId, Contact.Email, Role from OpportunityContactRole 
                                                               where Role = 'Primary Support' AND Contact.Email != null
                                                               AND OpportunityId in :shippedOpportunityIDSet];
        List<Id>contactIdList = new List<Id>();
        for(OpportunityContactRole oppConRole : opportunityContactList){
            contactIdList.add(oppConRole.ContactId);
        }
        List<Contact>contactList = [SELECT Id, Email, Name, DripCampaign__c FROM Contact WHERE Id in :contactIdList];
       
        Set<User>userHavingContactSet = new Set<User>();
        Set<Contact>contactNotHavingUser = new Set<Contact>();
        Set<Id>userIdSet = new Set<Id>();
        for(Contact con : contactList){
            Boolean isUserExists = false;
            for(User user : usersList){
                if(user.Username == con.Email){
                    userHavingContactSet.add(user);
                    isUserExists = true;
                    break;
                }
            }
            if (!isUserExists) {
                contactNotHavingUser.add(con);
            }
        }
        for(User u : userHavingContactSet){
            System.debug('existing: ' + u);
        }
        for(Contact u : contactNotHavingUser){
            System.debug('Not existing: ' +u);
        }
        Profile customerCommunityLoginUserProfile = [Select Id, Name from Profile WHERE Name = 'Customer Community Login User' limit 1];
        UserRole userRole = [Select Id, Name from UserRole where Name = 'Customer Support, North America' limit 1];
        
        //Scenario 1
        List<User>newUserList = new List<User>();
        for(Contact con : contactNotHavingUser){
            User user = new User(
                FirstName = con.Name,
                LastName = con.Name,
                Email = con.Email,
                Alias = con.Name.substring(0,5),
                Username = con.Email,
                IsActive = true,
                ProfileId = customerCommunityLoginUserProfile.Id,
                EmailEncodingKey = 'ISO-8859-1',
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ContactId = con.Id
            );
            newUserList.add(user);
        }
        for (User u : newUserList) {
            System.debug(u);
        }
        
        insert newUserList;
        
        for(User user : userHavingContactSet){
            userIdSet.add(user.Id);
        }
        updateUser(userIdSet);
    }
     //Scenario 2
    @future
    public static void updateUser(Set<Id>userIdSet){
        List<User>userList = [SELECT Id, Name, isActive FROM User WHERE Id in :userIdSet];
        for(User user : userList){
            if(!user.IsActive){
                user.IsActive = true;
            }
        }
        update userList;

    }
    
    //function to check dripCampaign
    public static void checkDripCampaign(List<Order> orders, Map<Id, Order> oldOrderList){
        Set<Id> shippedOpportunityIDSet=new Set<Id>();
        for(Order ord : orders)
        {
            if(oldOrderList.containsKey(ord.Id)&& oldOrderList.get(ord.Id).Status=='Activated' && ord.Status=='Shipped')
            {
                shippedOpportunityIDSet.add(ord.OpportunityId);
            }
        }
        
        List<OpportunityContactRole> opportunityContactList = [SELECT Id, OpportunityId, ContactId, Role from OpportunityContactRole 
                                                               where Role = 'Primary Support' AND OpportunityId in :shippedOpportunityIDSet];
        //Set<Contact>contactList = [SELECT Id, DripCampaign__c FROM Contact WHERE Id in :opportunityContactList];
        List<Id>contactIdList = new List<Id>();
        for(OpportunityContactRole oppConRole : opportunityContactList){
            contactIdList.add(oppConRole.ContactId);
        }
        List<Contact>contactList = [SELECT Id, DripCampaign__c FROM Contact WHERE Id in :contactIdList];
        List<Contact>updatedContacts = new List<Contact>();
        for(Contact con : contactList){
            if(con.DripCampaign__c == false){
                con.DripCampaign__c = true;
                updatedContacts.add(con);
            }
        }
        update contactList;
    }
    
}