<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
   
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Movie Search</title>
<script src="//code.jquery.com/jquery-2.2.1.js"></script>
<script type="text/javascript">
$(document).ready(function() {
	getCategories();
	//list film by category form post call
	// Attach a submit handler to the form
	$("#getfilmbycategoryForm")
		.submit(
			function(event) {						
				// Stop form from submitting normally
				event.preventDefault();
				// Get some values from elements on the page:										
				var $form = $(this);						
				var term = $form.serialize();						
				var url = $form.attr("action");
				// Send the data using post
				var posting = $.post(url, term);						
				// Put the results in a div
				posting.done(function(data, textStatus, jqXHR) {							
					var statusCode = jqXHR.status;
					var dataString = JSON.stringify(data);					
					
					switch(statusCode) {
					    case 200:								    	
					    	//Display results in table					    					    
					    	displayFilmList(data);
					        break;
					    case 204://No content - user not found							    	
					    	//
					        break;
					    default:							    	
					        //							    	
					} 
				}).fail(function(jqXHR, textStatus, errorThrown) {
					var statusCode = jqXHR.status;								
					switch(statusCode) {
					    case 403://Forbidden - user not authorized							    	
					    	//							    	
					        break;
					    case 404://
					        //							    	
					    	break;
					    default:							    	
					        //
					} 							
				}).always(function() {
					//
				});
			});
});

/*
 * Increment the likes of dislikes for a film by its id
 */
function setLikesDislikes(id, like){	
	 url = 'api/movie/likesdislikes';
	 var posting = $.post(url,  {id:id, like:like});
		// Put the results in a div
		posting.done(function(data, textStatus, jqXHR) {							
			var statusCode = jqXHR.status;
			var dataString = JSON.stringify(data);				
			switch(statusCode) {
			    case 200:
			    	//On success, resubmit category search form			    	
			    	$("#getfilmbycategoryForm").trigger( "submit" );
			        break;
			    case 204://No content - user not found							    	
			    	//
			        break;
			    default:							    	
			        //							    	
			} 
		}).fail(function(jqXHR, textStatus, errorThrown) {
			var statusCode = jqXHR.status;								
			switch(statusCode) {
			    case 403://Forbidden - user not authorized							    	
			    	//							    	
			        break;
			    case 404://
			        //							    	
			    	break;
			    default:							    	
			        //
			} 							
		}).always(function() {
			//
		});
}
/*
 * Get Film category list from Webservice 
 * and populate form category dropdown
 */
function getCategories() {	
	$.ajax({
		  url: "api/movie/getcategories"
		})
		  .done(function(data) {//process result
		    var selectDropDown = $('#categoryselect');
		    //parse JSON data
		    $.each(data, function(key0, value0) {//row data loop						
				var row = $("<tr/>");	
				$.each(value0, function(key1, value1) {//column data loop					
					selectDropDown.append("<option>" + value1.name + "</option>");																			
				});				
			});
		  });
}

/*
 * Display json film data in a table
 */
function displayFilmList(data){
	var table = $("<table/>");	
	table.attr("border","1");//set border attribute
	table.append("<tr><th>Description</th><th>Dislikes</th><th>Film Id</th><th>Length</th><th>Likes</th><th>Category</th><th>Title</th></tr>");
	var dataTable = $('#dataTable');
	  //parse JSON data
    $.each(data, function(key0, value0) {//row data loop    	
		$.each(value0, function(key1, value1) {//column data loop
			var row = $("<tr/>");
			$.each(value1, function(key1, value2) {//column data loop
				row.append($("<td/>").text(value2));
			});
			//create like and dislike buttons/links
			row.append($("<td/>").html("<a href='#' data-role='button' onclick='setLikesDislikes(" + value1.film_id + ",true)'>Like</a>"
			+ "<br><a href='#' data-role='button' onclick='setLikesDislikes(" + value1.film_id + ",false)'>Dislike</a>"));				
			table.append(row);//end tag			
		});			
	});	
    $("#dataTable").empty().append(table);  
}
</script>
</head>


<body>
<h1>Movie Database Search</h1>
<form id="getfilmbycategoryForm" action="api/movie/getfilmbycategory" method="post">
	<label>Category:</label><select id="categoryselect" name="category">		
	</select>
	<input type="submit" value="Search">
</form><br>

<div id="dataTable"></div>
</body>
</html>