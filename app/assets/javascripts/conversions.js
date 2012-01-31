$(document).ready(function() {	
	
var loadUrl = $('#page_select').attr('url');
var pageLimit=$("#page_select").attr("page_count");
var queryCount = 5;

/* abstraction to deal with a specific page in the doc */
var documentPage = {
	pageContent: null,
	loadContent: function(page_num) {
	  var current_page = 'page_'+page_num;	
	  var xhReq = new XMLHttpRequest();
	  var page_url = loadUrl + '-' + page_num + '.html';
	  xhReq.open("GET", page_url, true);
	  xhReq.onreadystatechange = function() {
	   if (xhReq.readyState != 4) {
	     return;	
	   }
	   this.pageContent = xhReq.responseText;
	   $('#'+current_page).html(this.pageContent);
	  };
	  xhReq.send(null);
	}
}

/* abstraction that handles queueing of pages for loading and rendering */
var documentRenderer = {
	pageQueue: [],
	enqueuePage: function(page_num) {
		var idx = this.alreadyEnqueued(page_num);
		if (idx === -1) {
			documentPage.loadContent(page_num);
			this.pageQueue.push(documentPage);	
		}
		else { return; }
	},
	alreadyEnqueued: function(page_num) {
		if (this.pageQueue.length > 0) {
			for(var i=0; i<this.pageQueue.length; i++) {
				if (this.pageQueue[i].pageNum === page_num) { return i; }
			}
		}
		return -1;
	}
}

if ($('#page_select option:first') != undefined) {
	// create page containers for all the pages in the document
	for(var i=1;i<=pageLimit;i++) {
	  var num = 'page_'+i;	
	  $('#document').append("<div class='page' id='"+num+"'><div class='loader'>Working...<img src='/assets/ajax_spinner.gif' width='50' height='50'></img></div></div>");
	  // load the content for the first page
	  documentRenderer.enqueuePage(i);
	}
};


/* page navigation */ 
$("#next_page").on('click',function(){
  var nextPage=parseInt($("#page_select").val())+1;

  if(nextPage<= pageLimit){
    var pageNumber=("#page_"+ nextPage);
    pageScroll(pageNumber);
    $("#page_select").val(nextPage);
  }
});


$("#prev_page").on('click',function(){
  var prevPage=parseInt($("#page_select").val())-1;

  if(prevPage !==0){
    var pageNumber=("#page_"+ prevPage);
    pageScroll(pageNumber);
    $("#page_select").val(prevPage);
  }
});

$("#page_select").on('change',function(){ 
  var selectedVal = $(this).val();
  var pageNumber=("#page_"+selectedVal);
  pageScroll(pageNumber);
});
 

function pageScroll(number){
$("#doc_container").scrollTo(number,1000,{easing:'esoincub',margin:"1000"})
 return false;
};
 
$.easing.esoincub = function(x, t, b, c, d) {
		if ((t/=d/2) < 1) return c/2*t*t*t + b;
		return c/2*((t-=2)*t*t + 2) + b;	
};

/* update the page select list based on page scroll */
$("#doc_container").on("scroll" , function(){
  $(".page:in-viewport").each(function(){
  var buffer=$(this).attr("id");
  var selectChange =$.trim(buffer).charAt(5)
  $("#page_select").val(selectChange)
  });
});


/* zoom*/ 
$('#zoomin').on('click',function() {
	var className = $("#document").attr("class").trim().charAt(5);
	var zoom_protect=parseInt(className);
	if(zoom_protect<=4){
		var zoom_buffer=zoom_protect+1;
		var zoom_level=$("#document").attr("class").replace(className,zoom_buffer);
		$("#document").removeClass();
		$("#document").addClass(zoom_level);
		return false;
	}
});

$('#zoomout').on('click',function() {
	var className = $("#document").attr("class").trim().charAt(5);
	var zoom_protect=parseInt(className);
	if(zoom_protect>1){
		var zoom_buffer=zoom_protect-1;
		var zoom_level=$("#document").attr("class").replace(className,zoom_buffer);
		$("#document").removeClass();
		$("#document").addClass(zoom_level);
		return false;
	}
});

/* Full screen */
$("#fullscreen").on("click",function(){
  if (this.webkitRequestFullScreen){
     document.documentElement.webkitRequestFullScreen(Element.ALLOW_KEYBOARD_INPUT);
  }
  else if(this.mozRequestFullScreen){ document.documentElement.mozRequestFullScreen(Element.ALLOW_KEYBOARD_INPUT);}
  else{document.documentElement.requestFullScreen();}
});


/* Ping conversion status */
function queryConversionStatus(query_url, conv_id) {
	$.ajax({
		url: query_url,
		data: {id: conv_id},
		success: function(resp) {
			if (resp === 'complete') {
				return true;
			}
			else if (resp == 'incomplete') {
				return false;
			}
		},
		failure: function(resp) {
			return false;
		}
	});
}

if ($('#result').find('#conversion_status_url') != undefined) {
	var status_url = $('#result').find('#conversion_status_url').val();
	var conv_id = $('#result').find('#conversion_status_url').attr('conv_id');
	var count = 0;
	while (count < queryCount) {
		if (queryConversionStatus(status_url, conv_id)) { 
			$('#result_spinner').hide();
			$('#text').hide(); 
			$('#yay_result').fadeIn(500);
			return; 
		}
		else { count = count + 1; }
	}
	$('#result_spinner').hide(); 
	$('#text').hide(); 
	$('#boo_result').fadeIn(500);
};

}); 






