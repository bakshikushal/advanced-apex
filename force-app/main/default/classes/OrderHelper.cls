public without sharing class OrderHelper{
	/**
	 * @name AfterUpdate
	 * @description
	 * @param List<Order> newList
	 * @param List<Order> oldList
	 * @return void
	 **/
	public static void AfterUpdate(List<Order> newList, List<Order> oldList){
		Set<Id> orderIds = new Set<Id>();
		System.debug('Inside Helper Checking For status ' + newList);
		System.debug('Old List ' + oldList);

		for (Integer i = 0; i < newList.size(); i++){
			if (newList[i].Status == Constants.ACTIVATED_ORDER_STATUS && oldList[i].Status == Constants.DRAFT_ORDER_STATUS){
				System.debug('Adding the order to set ' + newList[i]);
				orderIds.add(newList[i].Id);
			}
		}
		if (orderIds.size() > 0){
			System.debug('Calling Rollup Method now for set of Ids:' + orderIds);
			RollUpOrderItems(orderIds);
		}
	}

	/**
	 * @name RollUpOrderItems
	 * @description Given a set of Activated Order ids, query the child Order Items and related Products to calculate Inventory levels
	 * @param Set<Id> activatedOrderIds
	 * @return void
	 **/
	public static void RollUpOrderItems(Set<Id> activatedOrderIds){
		//ToDo: Declare a Map named "productMap" of Ids to Product2 records
		//ToDo: Loop through a query of OrderItems related to the activatedOrderIds
		//ToDo: Populate the map with the Id of the related Product2 as the key and Product2 record as the value
		//ToDo: Loop through a query that aggregates the OrderItems related to the Products in the ProductMap keyset
		//ToDo: Perform an update on the records in the productMap


		Map<Id, Product2> productMap = new Map<Id, Product2>();
		for (OrderItem item : [SELECT Id, Product2.ProductCode, Product2.Description, Product2.Initial_Inventory__c, Product2.Quantity_Remaining__c, Product2.Quantity_Ordered__c, Product2Id, AvailableQuantity, Quantity
		                       FROM OrderItem
		                       where orderId IN :activatedOrderIds]){
			ProductMap.put(item.Product2Id, item.Product2);
		}

		List<Product2> prdList = new List<Product2>();
		System.debug('Product Map Of items-->' + productMap);

		for (Aggregateresult ar : [select Sum(Quantity), Product2Id
		                           from OrderItem
		                           where Product2Id IN :ProductMap.keyset()
		                           group by Product2Id]){
			system.debug(ar);
			system.debug('Prd Id==' + ar.get('Product2Id')+' Quant->' + ar.get('expr0'));
			system.debug('----------------------------------------------');
            Product2 prd = new Product2();
            String prdId = (String) ar.get('Product2Id');
            Double quant = (Double) ar.get('expr0');
			prd = productMap.get(prdId);
			prd.Quantity_Ordered__c += quant;
			prdList.add(prd);
			System.debug('Product to be updated-->' + prd);
		}

		if (prdList.size() > 0){
			try{
				System.debug('Updating List now-->' + prdList);
				update prdList;
			} catch (Exception ex){
				System.debug('Error While Updating the Product Records--> ' + ex.getCause());
			}
		}
	}
}