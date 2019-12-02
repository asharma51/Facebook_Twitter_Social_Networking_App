<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ page import="com.google.appengine.api.datastore.DatastoreService"%>
<%@ page import="com.google.appengine.api.datastore.DatastoreServiceFactory"%>
<%@ page import="com.google.appengine.api.datastore.Entity"%>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>
<%@ page import="com.google.appengine.api.datastore.Query.Filter" %>
<%@ page import="com.google.appengine.api.datastore.Query.FilterOperator" %>
<%@ page import="com.google.appengine.api.datastore.Query.FilterPredicate" %>
<%@ page import="com.google.appengine.api.datastore.Query" %>
<%@ page import="com.google.appengine.api.datastore.PreparedQuery" %>
<%@ page import="com.google.appengine.api.datastore.Query.SortDirection" %>
<%@ page import="java.util.List"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">	
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css">
	<link rel="stylesheet" href="/css/tweet.css">
	
	<!-- Global site tag (gtag.js) - Google Analytics -->
	<script async src="https://www.googletagmanager.com/gtag/js?id=UA-153625153-1"></script>
	<script>  
		window.dataLayer = window.dataLayer || [];  
		function gtag(){dataLayer.push(arguments);}  
		gtag('js', new Date());  
		gtag('config', 'UA-153625153-1');
	</script>
	
	<script type="text/javascript" src="/js/tweet.js"></script>
	<script type="text/javascript" src="https://code.jquery.com/jquery-1.7.1.min.js"></script>
	<script type="text/javascript">callme()</script>
	
	<title>Tweet Page</title>
</head>
<body>

	<!-- Top Navigation Bar -->
	<div class="topnav">
		<!-- List the Items in the Top Navigation Bar  -->
		<a href="tweet.jsp">Tweet</a> 
		<a href="friends.jsp">Friends</a> 
		<a id=toptweet href=topTweets.jsp>Top Tweets</a>

		<div id="fb-root"></div>
		<div align="right">
			<div class="fb-login-button" data-max-rows="1" data-size="large"
				data-button-type="login_with" data-show-faces="false"
				data-auto-logout-link="true" data-use-continue-as="true"
				scope="public_profile,email" onlogin="checkLoginState();"></div>
		</div>
	</div>

	<br>	
	<div align="center">
		<table>
			<tr>
				<td>
					<textarea id="text_content" name="text_content" 
					 class="textarea" placeholder="Enter Tweet Message....."></textarea>
				</td> 
					<!-- <input type=hidden id=user_id name=user_id />
					<input type=hidden id=first_name name=first_name /> 
					<input type=hidden id=last_name	name=last_name /> 
					<input type=hidden id=picture name=picture /> -->
					<script>
						console.log(document.getElementById("first_name") + " "
								+ document.getElementById("last_name") + " "
								+ document.getElementById("picture"));
					</script>
				<td>
					<!-- <input type="submit" id=submit name=save class="button" value="Post Tweet to the App" /> -->
					<form>
						<input type=hidden id=user_id name=user_id />
						<input type=hidden id=first_name name=first_name /> 
						<input type=hidden id=last_name	name=last_name /> 
						<input type=hidden id=picture name=picture />
						<input type="button" id="post-button" value="Post Tweet to the App" onclick="shareTweet()">
					</form>
				</td>
			</tr>

			<tr>				
				<td>
					<br>
					<input type="button" id="share_tweet" class="button" value="Other Tweet Sharing Options" />
				</td>
				
				<td>
					<br>
					<form action="tweet.jsp" method="GET">
						<input type=hidden id=usr_id name=usr_id />
						<input type="submit" class="button" value="View All Tweets" name="view_tweets" />
					</form>
				</td>
			</tr>
			
		</table>
	</div>

	<div align="center">
		<div id="mypopup" class="popup">
			<div class="popup-content">
				<span class="close">&times;</span> 
					<input type="button" class="button" value="Post Tweet to FB TimeLine" 
					 name="share_tweet" onclick=shareDirectTweet() /> 
					<input type="button" class="button" value="Send Direct Message Tweet" 
					 name="send_direct_msg" onclick=sendDirectMsg() />
			</div>
		</div>
	</div>
	
	<br><br>
	<h1 id="TweetHeader"></h1>
	<div id = "pic"></div>
	<br><br>

	<script>
		var modal = document.getElementById('mypopup');
		var btn = document.getElementById("share_tweet");
		var span = document.getElementsByClassName("close")[0];
		btn.onclick = function() {
			modal.style.display = "block";
		};
		span.onclick = function() {
			modal.style.display = "none";
		};
		window.onclick = function(event) {
			if (event.target == modal) {
				modal.style.display = "none";
			}
		};
		
		document.getElementById("usr_id").value = getCookie('user_id');
		document.getElementById("user_id").value = getCookie('user_id');
		document.getElementById("first_name").value = getCookie('first_name');
		document.getElementById("last_name").value = getCookie('last_name');
		document.getElementById("picture").value = getCookie('picture');
		document.getElementById("TweetHeader").innerHTML = "Tweets posted by: " 
				+ document.getElementById("first_name").value + " " 
				+ document.getElementById("last_name").value;
		document.getElementById("pic").innerHTML = "<img src='" + document.getElementById("picture").value + "'>";
	</script>	
	
	<!-- Create a table to display all of user's tweet messages  -->
	<table id="my_tweets">
		<tr>
			<th>#</th>
			<th>Tweet Message</th>
			<th>Posted at</th>
			<th># of Visits</th>
			<th>Delete</th>
		</tr>
		
<%
	// Only display the user's tweets if the request contains the proper parameter
	if (request.getParameter("usr_id") != null){
				
		// Create a DatastoreService interface instance
		DatastoreService GAEDatastore = DatastoreServiceFactory.getDatastoreService();
		
		/* Delete a tweet as necessary if the correct parameter exists
		 * before displaying all of the user's tweets in the Datastore */
		if (request.getParameter("delete_query_id") != null) {
			Entity tweet = GAEDatastore.get(KeyFactory.createKey("tweet", 
					Long.parseLong(request.getParameter("delete_query_id"))));
			GAEDatastore.delete(tweet.getKey());
		}
		
		// Create a new query for entities whose kind is "tweet" and sort the query results
		Query TweetQuery = new Query("tweet").addSort("visited_count", SortDirection.DESCENDING);
		PreparedQuery prepQ = GAEDatastore.prepare(TweetQuery);
		int counter = 0;

		/* Loop through all of the tweet entity results and display the entities whose
		 * user_id field matches the user_id of the current user */
		for (Entity output : prepQ.asIterable()) {
			if (output.getProperty("user_id") != null
				&& ((output.getProperty("user_id")).equals(request.getParameter("usr_id")))){
				String tweetMessage = (String) output.getProperty("status");	
				String timestamp = (String) output.getProperty("timestamp");
				Long visitedCount = (Long) output.getProperty("visited_count");
				String userID = (String) output.getProperty("user_id"); 
				Long keyID = (Long) output.getKey().getId();
%>
	
			<tr>
				<td><%= ++counter%></td>
				<td><%= tweetMessage %></td>			  	
				<td><%= timestamp %></td>
				<td><%= visitedCount %></td>
				<td>
					<form action="tweet.jsp" action="GET">
						<input type=hidden id=usr_id name=usr_id value=<%= userID %> />
						<input type=hidden name=delete_query_id id=delete_query_id value=<%= keyID %> />
						<button name="Delete" type="submit" class="button" value=Delete >Delete</button>
					</form>
				</td>
			</tr>
			
<%  
			}
		}
	}
%>
						
	</table>		
	
</body>
</html>