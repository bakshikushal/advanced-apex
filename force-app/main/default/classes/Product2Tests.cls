@isTest
public class Product2Tests {

    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for product2Extension
    **/
    @istest
  	private static void Product2Extension_UnitTest(){
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName=uniqueUserName);
        System.runAs(u) {
			PageReference pageRef = Page.product2New;
           	Test.setCurrentPage(pageRef);
            Test.setCurrentPageReference(pageRef);
            
            
            Product2 prd = new Product2();
			Apexpages.StandardController cnt = new Apexpages.StandardController(prd);
            Test.startTest();
            Product2Extension ext = new Product2Extension(cnt);
        	System.assert(ext.productsToInsert.size() == Constants.DEFAULT_ROWS);
            ext.addRows();
            System.assert(ext.productsToInsert.size() == Constants.DEFAULT_ROWS *2);
        
	        List<Product2Extension.ProductWrapper> wrapList = new List<Product2Extension.ProductWrapper>();
    	    for(integer i=0; i<5; i++){
            Product2 productRecord = new Product2();
            PriceBookEntry pricebookEntryRecord = new PriceBookEntry();
            Product2Extension.ProductWrapper wrap = new Product2Extension.ProductWrapper();
            productRecord.Name = 'Test Prd '+i;
            productRecord.Family = Constants.PRODUCT_FAMILY.get(math.mod(i,4)).getValue();
			productRecord.isActive = true;
			productRecord.Initial_Inventory__c = 2;
            pricebookEntryRecord.UnitPrice = 100.00;
            wrap.productRecord = productRecord;
            wrap.pricebookEntryRecord = pricebookEntryRecord;
            ext.productsToInsert.add(wrap);
            System.debug('wrapperList->' + productRecord);
        }
        
            ext.save();
            List<Product2> prdList = [select Name, Id from Product2];
            System.debug('Prd List->' + prdList.size());
            for (Product2 prod : prdList){
                System.debug('Prd-->' + prod);
            }
            System.assert(prdList.size() == 5);
            List<SelectOption> options = ext.GetFamilyOptions();
            List<ChartHelper.ChartData> chartData = ext.GetInventory();
            Test.stopTest();            
            }
    }
}