//ローディング
//ローディング画面の表示
(function($){
jQuery(window).on('load',function(){
	jQuery(".loading").delay(400).fadeOut('slow');
	jQuery(".stage").delay(200).fadeOut('slow');
	jQuery(".top-slide-head").delay(500).fadeIn();
});
})(jQuery);





//メニュートリガー
jQuery(function(){
	jQuery('.menu-trigger-wrap').on('click',function(){
		jQuery('.menu-trigger').toggleClass('show');
		jQuery('.sp-nav-wrap').fadeToggle(400);
	});
});


//スマホ背景固定
jQuery(function(){
	var state = false;
	var scrollpos;
	jQuery('.menu-trigger-wrap').on('click', function(){
		if(state == false) {
			scrollpos = jQuery(window).scrollTop();
			jQuery('body').addClass('fixed').css({'top': -scrollpos});
			jQuery('.sp-nav-wrap').addClass('open');
			state = true;
		} else {
			jQuery('body').removeClass('fixed').css({'top': 0});
			window.scrollTo( 0 , scrollpos );
			jQuery('.sp-nav-wrap').removeClass('open');
			state = false;
		}
	});
});

//PCサブメニュー開閉
jQuery(function () {
	jQuery('.healthcare-nav,#healthcare-sub-nav').hover(
		function () {
			jQuery('#healthcare-sub-nav').stop().fadeIn();
		},
		function () {
			jQuery('#healthcare-sub-nav').stop().fadeOut('fast');
		});
});
jQuery(function () {
	jQuery('.team-nav,#team-sub-nav').hover(
		function () {
			jQuery('#team-sub-nav').stop().fadeIn();
		},
		function () {
			jQuery('#team-sub-nav').stop().fadeOut('fast');
		});
});

(function($){
jQuery(function () {
	jQuery('.menu-trigger-wrap').click(function(){
		jQuery(this).toggleClass("gra");
	});
});
})(jQuery);



//nav-menu-accordion
(function($){
jQuery(function () { 
	jQuery('.sp-main-nav li div').click(function() { 
		jQuery(this).next('.close').slideToggle(); 
		jQuery(this).toggleClass('open');
	}); 
});
})(jQuery);

$(function () {
	$('.sp-main-nav li div').click(function () {
		$(this).next('div').slideToggle();
		$(this).find(".icon").toggleClass('open');
	});
});


//infiniteslide
(function(){
jQuery(function(){
	jQuery('.infiniteslide01').infiniteslide({
		speed: 30,
		direction: 'left',
		clone: 10,
	});
});
})(jQuery);
(function(){
jQuery(function(){
	jQuery('.infiniteslide02').infiniteslide({
		speed: 30,
		direction: 'right',
		clone: 10,
	});
});
})(jQuery);
(function(){
jQuery(function(){
	jQuery('.infiniteslide03').infiniteslide({
		speed: 30,
		direction: 'left',
	});
});
})(jQuery);


//ページ内スクロール
$windowWidth = window.innerWidth;

$breakPointA = 520;
$breakPointB = 1024;

isMobileSize = ($windowWidth < $breakPointA);
isPcSize = ($windowWidth > $breakPointB);

if(isMobileSize){
jQuery(function() {
	var headerHeight = 72;
	jQuery('[href^="#"]').not('.healthcare-nav a','team-nav a').click(function(){
		var href= jQuery(this).attr("href");
		var target = jQuery(href == "#" || href == "" ? 'html' : href);
		var position = target.offset().top-headerHeight; 
		jQuery("html, body").animate({scrollTop:position}, 400, "swing");
		return false;
	});
});
}

if(isPcSize){
jQuery(function() {
	var headerHeight = 140;
	jQuery('[href^="#"]').not('.healthcare-nav a','team-nav a').click(function(){
		var href= jQuery(this).attr("href");
		var target = jQuery(href == "#" || href == "" ? 'html' : href);
		var position = target.offset().top-headerHeight; 
		jQuery("html, body").animate({scrollTop:position}, 400, "swing");
		return false;
	});
});
}

