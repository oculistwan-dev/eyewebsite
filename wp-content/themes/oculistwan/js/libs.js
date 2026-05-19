// Loading screen functionality
// Display loading screen
(function(){
	jQuery(window).on('load', function() {
		jQuery(".loading").delay(400).fadeOut('slow');
		jQuery(".stage").delay(200).fadeOut('slow');
		jQuery(".top-slide-head").delay(500).fadeIn();
	});
})();





// Menu trigger functionality
jQuery(function() {
	jQuery('.menu-trigger-wrap').on('click', function() {
		jQuery('.menu-trigger').toggleClass('show');
		jQuery('.sp-nav-wrap').fadeToggle(400);
	});
});


// Mobile background fix functionality
jQuery(function() {
	let state = false;
	let scrollpos;
	jQuery('.menu-trigger-wrap').on('click', function() {
		if (state === false) {
			scrollpos = jQuery(window).scrollTop();
			jQuery('body').addClass('fixed').css({'top': -scrollpos});
			jQuery('.sp-nav-wrap').addClass('open');
			state = true;
		} else {
			jQuery('body').removeClass('fixed').css({'top': 0});
			window.scrollTo(0, scrollpos);
			jQuery('.sp-nav-wrap').removeClass('open');
			state = false;
		}
	});
});

// PC submenu toggle functionality
jQuery(function() {
	jQuery('.healthcare-nav,#healthcare-sub-nav').hover(
		function() {
			jQuery('#healthcare-sub-nav').stop().fadeIn();
		},
		function() {
			jQuery('#healthcare-sub-nav').stop().fadeOut('fast');
		}
	);
});

jQuery(function() {
	jQuery('.team-nav,#team-sub-nav').hover(
		function() {
			jQuery('#team-sub-nav').stop().fadeIn();
		},
		function() {
			jQuery('#team-sub-nav').stop().fadeOut('fast');
		}
	);
});

// Menu trigger class toggle
(function() {
	jQuery(function() {
		jQuery('.menu-trigger-wrap').click(function() {
			jQuery(this).toggleClass("gra");
		});
	});
})();



// Navigation menu accordion functionality
jQuery(function() {
	jQuery('.sp-main-nav li div').click(function() {
		jQuery(this).next('.close').slideToggle();
		jQuery(this).toggleClass('open');
		// Also handle icon toggle
		jQuery(this).find(".icon").toggleClass('open');
	});
});


// Infinite slide functionality
jQuery(function() {
	// Initialize infinite slides if elements exist
	if (jQuery('.infiniteslide01').length) {
		jQuery('.infiniteslide01').infiniteslide({
			speed: 30,
			direction: 'left',
			clone: 10
		});
	}
	
	if (jQuery('.infiniteslide02').length) {
		jQuery('.infiniteslide02').infiniteslide({
			speed: 30,
			direction: 'right',
			clone: 10
		});
	}
	
	if (jQuery('.infiniteslide03').length) {
		jQuery('.infiniteslide03').infiniteslide({
			speed: 30,
			direction: 'left'
		});
	}
});


// In-page scroll functionality
jQuery(function() {
	const windowWidth = window.innerWidth;
	const breakPointA = 520;
	const breakPointB = 1024;
	
	const isMobileSize = (windowWidth < breakPointA);
	const isPcSize = (windowWidth > breakPointB);
	
	function initSmoothScroll(headerHeight) {
		jQuery('[href^="#"]').not('.healthcare-nav a', '.team-nav a').click(function() {
			const href = jQuery(this).attr("href");
			const target = jQuery(href === "#" || href === "" ? 'html' : href);
			
			if (target.length) {
				const position = target.offset().top - headerHeight;
				jQuery("html, body").animate({scrollTop: position}, 400, "swing");
			}
			return false;
		});
	}
	
	if (isMobileSize) {
		initSmoothScroll(72);
	} else if (isPcSize) {
		initSmoothScroll(140);
	} else {
		// Tablet size - use mobile header height
		initSmoothScroll(72);
	}
});

