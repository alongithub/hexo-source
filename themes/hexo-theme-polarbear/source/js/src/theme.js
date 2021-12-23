(function () {
  "use strict";

  var Theme = {};

  function checkhref(item) {
    $('.toc_checked').removeClass('toc_checked');
    const $this = $(item);
    $this.addClass('toc_checked');
    $this.parents('.toc-child').prev('.toc-link').addClass('toc_checked');
  }


  Theme.toc = {
    register: function() {
      // var $mobelmenu = $('#mobelmenu')
      // var open = false;
      // $(window).scroll(function() {
      //   var top = $(window).scrollTop()
      //   if (top > 60) {
      //     $mobelmenu.css({'position': 'fixed', 'top': '5px'})
      //   } else {
      //     $mobelmenu.css({'position': 'absolute', 'top': '70px'})
      //   }
      // })
      // $('body').bind('click', function(event) {
      //   if (open) {
      //     // IE支持 event.srcElement ， FF支持 event.target    
      //     var evt = event.srcElement ? event.srcElement : event.target;    
      //     if(evt.id == 'toc' ) return; // 如果是元素本身，则返回
      //     else {
      //       $mobelmenu.removeClass('open')
      //       $('#toc').removeClass('open'); // 如不是则隐藏元素
      //     }  
      //     open = false;
      //     console.log('关闭')
      //   }
         
      // });
      // $mobelmenu.click(function() {
      //   $(this).addClass('open')
      //   $('#toc').addClass('open')
      //   setTimeout(function() {
      //     open = true;
      //     console.log('展开')
      //   }, 0)
        
      // })

      

      var $tocLinks = $('.toc-link');
      var lock = false;
      var index = 0;
      var idTop = {}
      var idarray = [];
      $tocLinks.each(function() {
        var $this = $(this) 
        var codeid = $this.attr('href')
        var herfid = decodeURI(codeid)
        var $item = $(herfid);
        idTop[herfid] = {top: $item.offset().top, codeid: codeid}
        idarray.push(herfid)
      });
      
      $tocLinks.click(function(e) {
        e.preventDefault()
        lock= true;
        checkhref(this);
        var herfid = decodeURI($(this).attr('href'))
        var scrollTop = idTop[herfid].top;
        $('body,html').animate({ scrollTop: scrollTop }, function() {
          setTimeout(function() {
            lock = false
          }, 100)
        });
      })

      var $window = $(window);
      var timer = null;
      $(window).scroll(function() {
        if (!lock) {
          clearInterval(timer);
          // 节流
          timer = setTimeout(function() {
            var top = $window.scrollTop()
            while(top > idTop[idarray[index]].top) {
              if (index < idarray.length - 1)
                index ++;
              else break
            }
            while(true) {
              if (top > idTop[idarray[index]].top) {
                if (index === idarray.length - 1) {
                  break;
                } else if (top < idTop[idarray[index + 1]].top) {
                  break;
                } else {
                  index ++
                }
              } else {
                if (index === 0) {
                  break;
                } else{
                  index --;
                }
              }
            }
            checkhref($('.toc-link[href="'+ idTop[idarray[index]].codeid +'"]'))

          }, 30)
          
        }
      })

      // 获取所有的锚点位置
      
    }
  }

  Theme.backToTop = {
    register: function () {
      var $backToTop = $('#back-to-top');

      $(window).scroll(function () {
        if($(window).scrollTop() > 100) {
          $backToTop.fadeIn(1000);
        } else {
          $backToTop.fadeOut(1000);
        }
      });

      $backToTop.click(function () {
        $('body,html').animate({ scrollTop: 0 });
      });
    }
  };

  Theme.fancybox = {
    register: function () {
      if ($.fancybox){
        $('.post').each(function () {
          $(this).find('img').each(function () {
            $(this).wrap('<a class="fancybox" href="' + this.src + '" title="' + this.alt + '"></a>')
          });
        });

        $('.fancybox').fancybox({
          openEffect	: 'elastic',
          closeEffect	: 'elastic'
        });
      }
    }
  };

  this.Theme = Theme;
}.call(this));
