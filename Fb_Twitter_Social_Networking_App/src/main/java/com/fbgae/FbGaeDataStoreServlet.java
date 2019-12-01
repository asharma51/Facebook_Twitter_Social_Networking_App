package com.fbgae;

import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;

/**
 * FbGaeDataStoreServlet to handle creating new tweets to add to the GAE
 * Datastore
 * 
 */
@SuppressWarnings("serial")
@WebServlet("/FbGaeDataStoreServlet")
public class FbGaeDataStoreServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public FbGaeDataStoreServlet() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * doGet method to create a new "tweet" entity and add it to the GAE Datastore
	 */
	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// timestamp_format contains the format for the tweet entity's timestamp
		DateFormat timestamp_format = new SimpleDateFormat("MM/dd/yy, h:mm a");
		timestamp_format.setTimeZone(TimeZone.getTimeZone("America/Los_Angeles"));

		// current_date contains the current date that will become the tweet's timestamp
		// property
		Date current_date = new Date();

		/*
		 * GAEDatstore is an instance of the DatastoreService interface that provides
		 * synchronous access to the GAE Datastore
		 */
		DatastoreService GAEDatastore = DatastoreServiceFactory.getDatastoreService();

		// Create a new tweet entity message to add to the Datastore
		Entity message = new Entity("tweet");

		// Set the properties of the tweet entity message
		message.setProperty("status", request.getParameter("text_content"));
		message.setProperty("user_id", request.getParameter("user_id"));
		message.setProperty("first_name", request.getParameter("first_name"));
		message.setProperty("last_name", request.getParameter("last_name"));
		message.setProperty("picture", request.getParameter("picture"));
		message.setProperty("visited_count", 0);
		message.setProperty("timestamp", timestamp_format.format(current_date));

		/*
		 * Create cookies for the application user's user_id, first name, last name, and
		 * profile picture and add them to the client response
		 */
		Cookie user_id = new Cookie("user_id", request.getParameter("user_id"));
		Cookie f_name = new Cookie("first_name", request.getParameter("first_name"));
		Cookie l_name = new Cookie("last_name", request.getParameter("last_name"));
		Cookie pic = new Cookie("picture", request.getParameter("picture"));

		// Add the cookies to the client response
		response.addCookie(user_id);
		response.addCookie(f_name);
		response.addCookie(l_name);
		response.addCookie(pic);

		/*
		 * Add the new tweet entity message repo to the datastore associated with the
		 * GCP project and maintain the returned key for the new tweet entity in the
		 * tweet_key variable
		 */
		Key tweet_key = GAEDatastore.put(message);

		// forward the client back to the index page to send and view their tweets
		request.getRequestDispatcher("index.jsp").forward(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}

}
