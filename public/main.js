// Came from Stackoverflow but modified to used ;)
var allowCharacters = 140;

function countChar(val) {
	var len = val.value.length;
	if (len >= allowCharacters) {
		val.value = val.value.substring(0, allowCharacters);
	} else {
		$('#charNum').html(allowCharacters - len);
	}
	if($('textarea').val().length>=allowCharacters) {
		$('#sendIt').addClass('disabled');
		console.log('Stop!');
	}
}

/* https://stackoverflow.com/questions/19491336/get-url-parameter-jquery/21903119#21903119 */
var getUrlParameter = function getUrlParameter(sParam) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] === sParam) {
            return sParameterName[1] === undefined ? true : sParameterName[1];
        }
    }
};

var username = getUrlParameter('u');
var token = getUrlParameter('t');
var secret = getUrlParameter('s');
var referrer =  document.referrer;

$(function(){
	// for test propose
	console.log('Got it!');

	//hide until log in
	// $('aside').css('display','none');

	// $('button').on('click', function(){
		$('aside').css('display','inline').addClass('animated fadeInLeft');
		$('#loginPanel').addClass('animated fadeOutDown');

		$('#start').css('display','none');
		$('#listed').css('display','inline').addClass('animated fadeInUp');

		// Funny thing is allowed ;)
		$('#hireMe').attr('href','mailto:daniel@loultimoenlaweb.com?subject=Trento is OK&body=Nice one!');

		// for test propose
		//getMore();

	// });

	$('textarea').on('keyup', function(){
		// Show characters remain and remove disabled from button
		$('small').css('visibility','visible').addClass('animated shake');
		$('#sendIt').removeAttr('disabled').removeClass('disabled');

		// Check if textarea is in range, then..  
		if($('textarea').val().length==allowCharacters){
			$('#stopped').html('<p>Oh no! There is not space!</p>').css('display','');
			$('#stopped').addClass('animated bounceInUp');
		}
	});

	$(window).scroll(function() {
		if($(this).scrollTop()>0) {
			$('aside').css('height','2000px').addClass('animated fadeOutLeft');
		// } else {
			// $('aside').addClass('animated fadeInLeft');
		}
		if($(this).scrollTop()<10) {
			$('aside').removeClass('fadeOutLeft').addClass('bounceInLeft');
		}
	});

	$.post('/tweet', $("#postTweet").serialize(), function(data) {
			$('#stopped')css('display','inline').html("Tweet Posted");
			$("#postTweet")[0].reset();
		});
	}

	// for test propose
	//Static -> js/sample2.json
	//PHP ->http://localhost:8890/trento/api/me
	function getMore() {
		$.getJSON('/tweetbyuser?u=NaranjoDaniel&t=110495478-qnrKkkokaooS4xZhfjwI3m2xL9Mj5gF6xKFW5Lsh&s=IRyN7oP4lPMQzv7Glhqc5J1dDM6p578gyJ3XBjalX17fG', function(data){ 
			$('#listed ul.grid').html('');
			$('#more').css('display','inline').addClass('animated fadeIn');
			$('footer').addClass('animated bounceOutDown');

			$.each(data, function(i, field){
				$('#name').html('<a href="//www.twitter.com/'+data[i].user.screen_name+'">'+data[i].user.name+'</a>');
				$('#description').html(data[i].user.description);
				$('#url').html('Check it out at <a href="'+data[i].user.url+'">'+data[i].user.url+'</a>');
				$('#join').html('Playing here since '+moment(data[i].user.created_at).toNow());

				// Da Tweet
				//<div class="col-md-2"><img src="'+data[i].user.profile_image_url+'" alt="avatar" class="img-rounded img-responsive"></div>
				$("#listed ul").append('<li id="'+data[i].id+'" class="grid-item"><div class="grid-item"><p>'+data[i].text+'</p><p><span id="options'+data[i].id+'"></span> '+moment(data[i].created_at).toNow()+' by <a target="_blank" href="//twitter.com/'+data[i].user.screen_name+'">'+data[i].user.screen_name+'</a></p></div></li>').addClass('animated bounceInUp');
				
				// Reply :)
				$('#options'+data[i].id).append('<a href="/replyTo/'+data[i].id+'" title="Reply to this guy!"><i class="fa fa-reply"></i></a>');//'+ data[i].retweet_count+'
				// Like
				$('#options'+data[i].id).append('<a href="/api/loveIt/'+data[i].id+'" title="Loves... Likes... Favorites... All verbs means the same"><i class="fa fa-heart"></i></a>');//'+ data[i].favorite_count+'
				// Delete
				$('#options'+data[i].id).append('<a href="/api/delete/'+data[i].id+'" title="oh boy! delete! delete! delete!"><i class="fa fa-trash"></i></a>');
				// More
				$('#options'+data[i].id).append('<a href="javascript:;" data-toggle="modal" data-target="#myModal" title="More option will be great!"><i class="fa fa-ellipsis-h"></i></a>');

				$('#options'+data[i].id+' a').attr('data-toggle="tooltip" data-placement="bottom"');
			});
		})
		.error(function() {
			$('#listed h3').html("Can't connect to server. Please check your Internet connection.");
			setTimeout(function(){
				getMore();
				$('#listed h4').html('Retrying fetch data every 10 seconds..');
			},10000);
		});
	}

	// refresh()
	$('#getMore').on('click', function(){
		$('#listed ul').html('');
		getMore();
		console.log('getMore clicked');
	});
	// Fire tooltip widget!
	$('[data-toggle="tooltip"]').tooltip();

	$('.grid').masonry();
});