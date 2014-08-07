/**
 * @author      Josep Vall-llobera <valnavjo_at_gmail.com>
 * @version     1.0.0
 * @since       25/08/2012
 */
global abstract class BatchableTemplate extends SchedulableTemplate
										implements Database.Batchable<SObject> {

	/**ATTRIBUTES*/
	protected String query;
	
	/**SCHEDULABLE TEMPLATE METHODS*/
	global override void schExecute(SchedulableContext sc) {
		System.debug('Executing "BatchableTemplate.schExecute()".');
		System.debug('Parameters --> sc: ' + sc);

		Database.executeBatch(this);
	}
	
	/**DATABASE.BATCHABLE METHODS*/
	global Database.QueryLocator start(Database.BatchableContext bc) {
		System.debug('Executing "BatchableTemplate.start()".');
		System.debug('Parameters --> bc: ' + bc);
		
		Database.QueryLocator ql;
		try {
			ql = this.batchStart(bc);
		} catch (Exception e) {
			System.debug('BatchableTemplate.start() Exception --> ' + e);
			if (this.getSendErrors()) super.sendEmail('BatchableTemplate.start() --> ' + e.getMessage());
		}
		
		return ql;
	}
	
	global void execute(Database.BatchableContext bc, List<SObject> scope) {
		System.debug('Executing "BatchableTemplate.execute()".');
		System.debug('Parameters --> bc: ' + bc);
		System.debug('Parameters --> scope: ' + scope);

		try {
			this.batchExecute(bc, scope);
		} catch (Exception e) {
			System.debug('BatchableTemplate.execute() Exception --> ' + e);
			if (this.getSendErrors()) super.sendEmail('BatchableTemplate.execute() --> ' + e.getMessage());
		}
	}
	
	global void finish(Database.BatchableContext bc) {
		System.debug('Executing "BatchableTemplate.finish()".');
		System.debug('Parameters --> bc: ' + bc);

		try {
			this.batchFinish(bc);
		} catch (Exception e) {
			System.debug('BatchableTemplate.finish() Exception --> ' + e);
			if (this.getSendErrors()) super.sendEmail('BatchableTemplate.finish() --> ' + e.getMessage());
		} finally {
			//Scheduling itself
			if (super.getAutoSchedule()) {
				
				//We only want to schedule the job here if we want to wait until the
				//Batch is finished. That is, if we don't want parallel executions.
				if (!super.getParallelExecutions()) super.autoSchedulable(this);
			}
		}
	}
	
	/**ABSTRACT METHODS*/
	global abstract Database.QueryLocator batchStart(Database.BatchableContext bc);
	global abstract void batchExecute(Database.BatchableContext bc, List<SObject> scope);
	global abstract void batchFinish(Database.BatchableContext bc);
}