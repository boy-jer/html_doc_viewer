$(document).ready(function() {	
	
var load_url = $('#page_select').attr('url');

/* abstraction to deal with a specific page in the doc */
var documentPage = {
	pageUrl: null,
	pageNum: null,
	pageContent: null,
	initialize: function(url, num) {
		this.pageUrl = url;
		this.pageNum = num;
	},
	loadContent: function() {
	  $('#document').html('');
	  $('#loader').show();
	  var current_page = 'page_'+this.page_num;	
	  var xhReq = new XMLHttpRequest();
	  xhReq.open("GET", this.pageUrl, true);
	  xhReq.onreadystatechange = function() {
	   if (xhReq.readyState != 4) {
	     return;	
	   }
	   this.pageContent = xhReq.responseText;
	   $('#loader').hide	();
	   $('#document').append("<div class='page' id='"+current_page+"'></div>");
	   $('#'+current_page).html(this.pageContent);
	  };
	  xhReq.send(null);
	}
}

/* abstraction that handles queueing of pages for loading and rendering */
var documentRenderer = {
	remoteUrl: load_url,
	pageQueue: [],
	enqueuePage: function(page_num) {
		var page_url = this.remoteUrl + '-' + page_num + '.html';
		var idx = this.alreadyEnqueued(page_num);
		if (idx === -1) {
			documentPage.initialize(page_url, page_num);
			documentPage.loadContent();
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
	// load the content for the first page
	documentRenderer.enqueuePage(1);
};


/* page navigation */ 
$("#next_page").on('click',function(){
  var pageLimit=$("#page_select").attr("page_count");
  var nextPage=parseInt($("#page_select").val())+1;

  if(nextPage<= pageLimit){
    var pageNumber=("#page_"+ nextPage);
	documentRenderer.enqueuePage(nextPage);
    pageScroll(pageNumber);
    $("#page_select").val(nextPage);
  }
});


$("#prev_page").on('click',function(){
  var pageLimit=$("#page_select").attr("page_count");
  var prevPage=parseInt($("#page_select").val())-1;

  if(prevPage !==0){
    var pageNumber=("#page_"+ prevPage);
    documentRenderer.enqueuePage(prevPage);
    pageScroll(pageNumber);
    $("#page_select").val(prevPage);
  }
});

$("#page_select").on('change',function(){ 
  var selectedVal = $(this).val();
  var pageNumber=("#page_"+selectedVal);
  documentRenderer.enqueuePage(selectedVal);
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


}); 






