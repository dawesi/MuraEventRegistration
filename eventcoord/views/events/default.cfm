<cfsilent>
<!---

This file is part of MuraFW1

Copyright 2010-2013 Stephen J. Withington, Jr.
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

--->
</cfsilent>
<cfset PriorDate = #DateAdd("m", -2, Now())#>
<cfquery name="getAvailableEvents" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
	Select TContent_ID, ShortTitle, EventDate, LongDescription
	From eEvents
	Where Site_ID = <cfqueryparam value="#rc.$.siteConfig('siteID')#" cfsqltype="cf_sql_varchar"> and
		EventDate >= <cfqueryparam value="#Variables.PriorDate#" cfsqltype="cf_sql_date"> and
		Active = <cfqueryparam value="1" cfsqltype="cf_sql_bit">
	Order by EventDate DESC
</cfquery>
<cfif isDefined("URL.Successful")>
	<cfswitch expression="#URL.Successful#">
		<cfcase value="true">
			<cfif isDefined("URL.UserAction")>
				<cfswitch expression="#URL.UserAction#">
					<cfcase value="RemoveParticipants">
						<cfquery name="GetSelectedEvent" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
							Select ShortTitle
							From eEvents
							Where TContent_ID = <cfqueryparam value="#URL.EventID#" cfsqltype="cf_sql_integer">
						</cfquery>
						<cfoutput>
							<div class="alert-box success">
								<p>Your have successfully remove participants from the event titled <cfoutput>#GetSelectedEvent.ShortTitle#</cfoutput>.</p>
							</div>
						</cfoutput>
					</cfcase>
					<cfcase value="RegistrationsSent">
						<cfquery name="GetSelectedEvent" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
							Select ShortTitle
							From eEvents
							Where TContent_ID = <cfqueryparam value="#URL.EventID#" cfsqltype="cf_sql_integer">
						</cfquery>
						<cfoutput>
							<div class="alert-box success">
								<p>Emails to everyone who is registered for the event titled <cfoutput>#GetSelectedEvent.ShortTitle#</cfoutput> is in the process of being sent. </p>
							</div>
						</cfoutput>
					</cfcase>
					<cfcase value="AddedEvent">
						<cfoutput>
							<div class="alert-box success">
								<p>You have successfully added a new event to the system.</p>
							</div>
						</cfoutput>
					</cfcase>
					<cfcase value="UpdatedEvent">
						<div class="alert-box success">
							<p>You have successfully updated the event within the system.</p>
						</div>
					</cfcase>
					<cfcase value="EventCopied">
						<div class="alert-box success">
							<p>You have successfully copied the event as a new event in the system.</p>
						</div>
					</cfcase>
					<cfcase value="EventCancelled">
						<cfoutput>
							<div class="alert-box success">
								<p>You have successfully cancelled the event within the system. If anyone has registered for the event you cancelled, they will be receiving an email within the next few minutes.</p>
							</div>
						</cfoutput>
					</cfcase>
				</cfswitch>
			</cfif>
		</cfcase>
		<cfcase value="false">
			<cfswitch expression="#URL.UserAction#">
				<cfcase value="NoRegistrations">
					<div class="alert-box notice">
						<p>The Event you tried to send an email to did not have any users registered for it. For this reason emails were not sent from this system.</p>
					</div>
				</cfcase>
			</cfswitch>
		</cfcase>
	</cfswitch>
</cfif>
<cfif isDefined("URL.RegistrationSuccessfull")>
	<cfswitch expression="#URL.RegistrationSuccessfull#">
		<cfcase value="True">
			<div class="alert-box success">
				<p>You have successfully added new participants to the event registration system for the event titled <cfoutput>#Session.UserSuppliedInfo.ShortTitle#</cfoutput>.</p>
			</div>
		</cfcase>
	</cfswitch>
</cfif>
<cfoutput>
	<table class="art-article" style="width:100%;">
		<thead>
			<tr>
				<td width="50%">Event Title</td>
				<td width="15%">Event Date</td>
				<td>Actions</td>
			</tr>
		</thead>
		<cfif getAvailableEvents.RecordCount>
			<tfoot>
				<tr>
					<td colspan="3">Add a new Event or Workshop to allow registrations not listed above by clicking <a href="#buildURL('eventcoord:events.addevent')#" class="art-button">here</a></td>
				</tr>
			</tfoot>
			<tbody>
				<cfloop query="getAvailableEvents">
					<cfquery name="getRegistrationsForEvent" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
						Select TContent_ID
						From eRegistrations
						Where Site_ID = <cfqueryparam value="#rc.$.siteConfig('siteID')#" cfsqltype="cf_sql_varchar"> and
							EventID = <cfqueryparam value="#getAvailableEvents.TContent_ID#" cfsqltype="cf_sql_integer">
					</cfquery>
					<tr bgcolor="###iif(currentrow MOD 2,DE('ffffff'),DE('efefef'))#">
						<td width="50%">#getAvailableEvents.ShortTitle#</td>
						<td width="15%">#DateFormat(getAvailableEvents.EventDate, "mmm dd, yy")#</td>
						<td>
							<a href="#buildURL('eventcoord:events.updateevent_review')#&EventID=#getAvailableEvents.TContent_ID#" class="art-button">Update</a>&nbsp;&nbsp;<a href="#buildURL('eventcoord:events.cancelevent')#&EventID=#getAvailableEvents.TContent_ID#" class="art-button">Cancel</a>&nbsp;&nbsp;<a href="#buildURL('eventcoord:events.emailregistered')#&EventID=#getAvailableEvents.TContent_ID#" class="art-button">Email</a>&nbsp;&nbsp;<a href="#buildURL('eventcoord:events.copypriorevent')#&EventID=#getAvailableEvents.TContent_ID#" class="art-button">Copy</a>&nbsp;&nbsp;<a href="" class="art-button">Info</a><br />
							<a href="#buildURL('eventcoord:events.registeruserforevent')#&EventID=#getAvailableEvents.TContent_ID#" class="art-button">Register</a>
							<cfif getRegistrationsForEvent.RecordCount>
								&nbsp;&nbsp;<a href="#buildURL('eventcoord:events.deregisteruserforevent')#&EventID=#getAvailableEvents.TContent_ID#" class="art-button">De-Register</a>
								&nbsp;&nbsp;<a href="#buildURL('eventcoord:events.eventsigninsheet')#&EventID=#getAvailableEvents.TContent_ID#" class="art-button">Sign-In Sheet</a>
								&nbsp;&nbsp;<a href="#buildURL('eventcoord:events.eventsigninparticipant')#&EventID=#getAvailableEvents.TContent_ID#" class="art-button">Sign-In Participant</a>
							</cfif>
						</td>
					</tr>
				</cfloop>
			</tbody>
		<cfelse>
			<tbody>
				<tr>
					<td colspan="6"><div align="center" class="alert-box notice">No Events have been located within the database with an event date after #DateFormat(Variables.PriorDate, "FULL")#. Please click <a href="#buildURL('eventcoord:events.addevent')#" class="art-button">here</a> to add a new event or workshop.</div></td>
				</tr>
			</tbody>
		</cfif>
	</table>
</cfoutput>