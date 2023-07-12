public class Product2Helper{
	/**
	 * @name COLLABORATION_GROUP
	 * @description List of CollaborationGroup used in both business and test logic
	 **/
	static List<CollaborationGroup> COLLABORATION_GROUP = [SELECT Id
	                                                       FROM CollaborationGroup
	                                                       WHERE Name = :Constants.INVENTORY_ANNOUNCEMENTS OR Name = :('TEST' + Constants.INVENTORY_ANNOUNCEMENTS)
	                                                       LIMIT 1];
	/**
	 * @name afterUpdate
	 * @description called by product2 Trigger on After Update
	 * @param List<Product2> newList
	 * @param List<Product2> oldList
	 **/
	public static void AfterUpdate(List<Product2> prdList){
		//ToDo: Declare a List of Product2 records named needsAnnouncement
		//ToDo: Declare a Map of Strings to Inventory_Setting__mdt records
		//ToDo: Loop through a query of Inventory_Setting__mdt records and populate the Map with Name as the key
		//ToDo: Loop through the Products in newList
		// Use the corresponding Inventory Setting record to determine the correct Low Quantity Alert
		// If the Product's Quantity Remaining has been changed to less than the Low Quantity Alert
		// add it to the needsAnnouncement list

		//ToDo: Pass records to the postAlerts method

		List<Product2> productsListToAnnounce = new List<Product2>();
		Map<String, Inventory_Setting__mdt> mdtMap = new Map<String, Inventory_Setting__mdt>();

		for (Inventory_Setting__mdt mdt : [SELECT Id, MasterLabel, Low_Quantity_Alert__c, Label, DeveloperName
		                                   FROM Inventory_Setting__mdt]){
			mdtMap.put(mdt.DeveloperName, mdt);

		}
		for (Product2 prd : prdList){
			if (prd.Quantity_Remaining__c <= mdtMap.get(prd.Family).Low_Quantity_Alert__c){
				productsListToAnnounce.add(prd);
			}
		}
		if (productsListToAnnounce.size() > 0){
			PostAlerts(productsListToAnnounce);
		}
	}

	/**
	 * @name postAlerts
	 * @description called by product2 Trigger on After Update
	 * @param List<Product2> productList
	 **/
	public static void PostAlerts(List<Product2> productList){
		System.debug('PostAlerts');
		List<ConnectApi.AnnouncementInput> toPost = new List<ConnectApi.AnnouncementInput>();
		for (Product2 p : productList){
			System.debug('loop');
			ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
			ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
			ConnectApi.AnnouncementInput ann = new ConnectApi.AnnouncementInput();

			// ToDo: Construct a new AnnouncementInput for the Chatter Group so that it
			//  expires in a day
			//  does not notify users via email.
			//  and has a text body that includes the name of the product followed by the INVENTORY_LEVEL_LOW constant
			ann.sendEmails = false;
			ann.expirationDate = Date.today().addDays(1);
			ann.parentId = COLLABORATION_GROUP[0].Id;

			textSegmentInput.text = p.Name + ' ' + Constants.INVENTORY_LEVEL_LOW;

			messageBodyInput.messageSegments = new List<ConnectApi.TextSegmentInput>();
			messageBodyInput.messageSegments.add(textSegmentInput);

			ann.body = messageBodyInput;
			toPost.add(ann);
		}
		// ToDo: Create and enqueue an instance of the announcementQueuable class with the list of Products
		System.debug('toPost: ' + toPost);
		AnnouncementQueueable q = new AnnouncementQueueable();
		q.toPost = toPost;
		System.enqueueJob(q);
		// ToDo: Create and enqueue an instance of the announcementQueuable class with the list of Products
	}
}