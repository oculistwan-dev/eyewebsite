// 首页轮播图初始化
document.addEventListener('DOMContentLoaded', function() {
    // 初始化顶部轮播图
    var mySwiper = new Swiper('.top-slider', {
        autoplay: {
            delay: 6000,
        },
        effect: 'fade',
        loop: true,
        speed: 1300,
    });
    
    // 初始化新闻滑块
    var swiper = new Swiper('.topics-slider', {
        slidesPerView: 'auto',
        freeMode: true,
        touchRatio: 0.03,
        grabCursor: true,
        scrollbar: {
            el: '.swiper-scrollbar',
            draggable: true,
        },
    });
});