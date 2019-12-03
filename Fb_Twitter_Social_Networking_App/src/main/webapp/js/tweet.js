var first_name;
var last_name;
var picture;
var user_id;

function callme(){
window.fbAsyncInit = function() {
    FB.init({
      appId      : '2558098631093993',
      cookie     : true,
      xfbml      : true,
      version    : 'v5.0'
    });
    FB.AppEvents.logPageView(); 
    loadsdk();
    checkLoginState();
};
}


function onLogin(response) {
	  if (response.status == 'connected') {
	    FB.api('/me?fields=first_name', function(data) {
	      var welcomeBlock = document.getElementById('fb-welcome');
	      welcomeBlock.innerHTML = 'Hello, ' + data.first_name + '!';
	      
	    });
	  }
};

	
function loadsdk(){
(function(d, s, id){
    var js, fjs = d.getElementsByTagName(s)[0];
    if (d.getElementById(id)) {return;}
    js = d.createElement(s); js.id = id;
    js.src = "//connect.facebook.net/en_US/sdk.js";
    fjs.parentNode.insertBefore(js, fjs);
    }(document, 'script', 'facebook-jssdk'));
};


function checkLoginState() {
  FB.getLoginStatus(function(response) {
    statusChangeCallback(response);
  });
};


function statusChangeCallback(response) {
    console.log('statusChangeCallback');
    console.log(response);
    if (response.status === 'connected') {
      user_id = response.authResponse.userID;
      console.log(user_id);
      extractInfo();
      console.log("Already logged in");
    } else {
      console.log("Please login");
      FB.login();
    }
  };

  
(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/en_US/sdk.js#xfbml=1&version=v5.0&appId=900799546729806";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));


function shareTweet(){
	checkLoginState();
	FB.ui({method: 'share',
		href: "https://apps.facebook.com/fb_networking_app",
		quote: document.getElementById('text_content').value,
		},function(response){
		if (!response || response.error)
		{
			console.log(response.error);
			alert('Posting error occured');
		}
		else{
			CreateTweetViaAjax();
		}
	});
};


function createCORSRequest(method, url) {
	  var xhr = new XMLHttpRequest();
	  if ("withCredentials" in xhr) {
	    // XHR for Chrome/Firefox/Opera/Safari.
	    xhr.open(method, url, true);
	  } else if (typeof XDomainRequest != "undefined") {
	    // XDomainRequest for IE.
	    xhr = new XDomainRequest();
	    xhr.open(method, url);
	  } else {
	    // CORS not supported.
	    xhr = null;
	  }
	  return xhr;
}


function CreateTweetViaAjax(){
	var url = "https://fb-social-networking-app.appspot.com/GaeDataStore?text_content=" + 
				document.getElementById('text_content').value +
				"&user_id=" + document.getElementById("user_id").value + 
				"&first_name=" + document.getElementById("first_name").value +
				"&last_name=" + document.getElementById("last_name").value +
				"&picture=" + document.getElementById("picture").value;
	
	var xmlhttp = createCORSRequest('GET', url);
	
	if(!xmlhttp){
	    alert('CORS not supported');
	    return;
	}
	
	// Response handlers.
	xmlhttp.onload = function() {
		document.getElementById('text_content').value = "";
		alert('Tweet posted successfully!.');
	};

	xmlhttp.onerror = function() {
	    alert('Woops, there was an error making the request.');
	};
	
	xmlhttp.send();
	
}


function shareDirectTweet(){
	checkLoginState();
	FB.ui({method: 'share',
		href: "https://apps.facebook.com/fb_networking_app/tweet",
		},function(response){
		if (!response || response.error)
		{
			console.log(response.error);
			alert('Posting error occured');
		}
	});
}


function extractInfo(){
	FB.api('/me', 
			'GET',
			{"fields":"id,first_name,last_name, picture.width(150).height(150)"},
			function(response){
				console.log(response);
				document.cookie="user_id="+response.id;
				
				first_name = response.first_name;
				document.cookie="first_name="+first_name;
				localStorage.setItem('first_name',first_name);
				
				last_name = response.last_name;
				document.cookie="last_name="+last_name;
				localStorage.setItem('last_name',last_name);
				
				picture = response.picture.data.url;
				document.cookie="picture="+picture;
				localStorage.setItem('picture',picture);
				
				console.log(document.cookie);
			});
	 
	document.getElementById("user_id").value = getCookie('user_id');
	document.getElementById("first_name").value = getCookie('first_name');
	document.getElementById("last_name").value = getCookie('last_name');
	document.getElementById("picture").value = getCookie('picture');
	console.log(document.getElementById("first_name").value);
	console.log(document.getElementById("last_name").value);
	console.log(document.getElementById("picture").value);
};


function getCookie(cname) {
	var re = new RegExp(cname + "=([^;]+)");
	var value = re.exec(document.cookie);
	return (value != null) ? unescape(value[1]) : null;
}


function sendDirectMsg(){
	checkLoginState();
	var tweet_id = "5669869676658688";
	var url = "https://apps.facebook.com/fb_networking_app/LinkedTweet?tweet_id=" + tweet_id;
	FB.ui({method:  'send',
		link:url });
};


