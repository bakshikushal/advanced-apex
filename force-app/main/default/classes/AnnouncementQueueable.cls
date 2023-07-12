/**
 * @name AnnouncementQueueable
 * @description This class posts Chatter Announcements
 **/
public class AnnouncementQueueable implements Queueable{
	public List<ConnectApi.AnnouncementInput> toPost;
	public void execute(QueueableContext context){
		PostAnnouncements(toPost);
	}

	//ToDo: Modify this class to implement the Queueable interface and call the postAnnouncements method.
	// Modify AnnouncementQueueable to implement the Queueable interface and call its postAnnouncements method.
	// Ensure that it requeues itself when it has more Announcements to post than limits allow.
	/**
	 * @name postAnnouncements
	 * @description This method is provided for you to facilitate the Super Badge
	 **/
	public static void PostAnnouncements(List<ConnectApi.AnnouncementInput> announcements){
		System.debug('Post Announcements: ' + announcements);
		while (announcements.size() > 0){
			if (Limits.getDMLStatements() < Limits.getLimitDMLStatements() && !test.isRunningTest()){
				ConnectApi.AnnouncementInput a = announcements.remove(0);
				System.debug('a: ' + a);
				ConnectApi.Announcements.postAnnouncement('Internal', a);
			} else{

				break;
			}
		}
		if (announcements.size() > 0 && !test.isRunningTest()){
			AnnouncementQueueable q = new AnnouncementQueueable();
			q.toPost = announcements;
			System.enqueueJob(q);
		}
	}
}