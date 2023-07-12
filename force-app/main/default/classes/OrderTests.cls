@isTest
public class OrderTests{
	@TestSetup
	private static void SetupTestData(){
        System.debug('We are in setup Method');
		TestDataFactory.InsertTestData(5);
	}

	@isTest
	private static void OrderUpdate_UnitTest(){
		List<Order> ordList = [SELECT Id, status, Pricebook2Id, (select ID,  Product2.Name, Product2.Quantity_Ordered__c, Quantity
		                                                         from orderItems) FROM Order];
		Map<Id, Product2> oldprdMap = new Map<Id, Product2>();
        Map<Id, Product2> newprdMap = new Map<Id, Product2>();
        List<Order> orderListToUpdate = new List<Order>();
        System.debug('Total Orders:' + ordList);
		for (order ord : ordList){
			System.debug('Total Order Items:' + ord.orderItems);
			for (orderItem item : ord.orderItems){
				oldprdMap.put(item.Id, item.Product2);
			}
            ord.status = Constants.ACTIVATED_ORDER_STATUS;
            orderListToUpdate.add(ord);
        }
        System.debug('Old Product Map-->' + oldprdMap);
        if(orderListToUpdate.size() >0){
            update orderListToUpdate;
        }
        
        List<Order> updatedOrdList = [SELECT Id, status, Pricebook2Id, (select ID, Product2Id, Product2.Name, Product2.Quantity_Ordered__c, Quantity
                                                                 from orderItems) FROM Order];
        For(Order ord: updatedOrdList){
            for (OrderItem item: ord.OrderItems){
                TestDataFactory.VerifyQuantityOrdered(oldprdMap.get(item.Id), item.Product2, Integer.valueOf(item.Quantity) );
            }
        }

	}
	@isTest
    private static void OrderExtension_UnitTest(){
       
        List<Order> orders = [SELECT Id,AccountId,EffectiveDate,Pricebook2Id,Status FROM Order];
       
        ApexPages.StandardController std = new ApexPages.StandardController(orders[0]);
       
        Test.startTest();
       
        OrderExtension extensions = new OrderExtension(std);
       
        extensions.First();
        extensions.Next();
        extensions.Previous();
        extensions.Last();
        extensions.GetFamilyOptions();
        extensions.OnFieldChange();
        extensions.SelectFamily();
       
        Boolean previous = extensions.GetHasPrevious();
        Boolean next = extensions.GetHasNext();
        Integer numberPages = extensions.GetPageNumber();
        Integer totalPages = extensions.GetTotalPages();
       
        extensions.save();
       
        Test.stopTest();
  
        System.assert(!previous);
        System.assert(!next);
        System.assertEquals(1, numberPages);
        System.assertEquals(1, totalPages);
       
    }
}