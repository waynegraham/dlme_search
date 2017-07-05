(function() {
  'use strict';
  $(document).ready(function() {

    const offset = 200;
    const duration = 500;

    $('a').bind('click', function(event) {
      const $anchor = $(this);
      $('html, body').stop().animate({ scrollTop: $($anchor.attr('href')).offset().top - 78 }, 1500, 'easeInOutExpo');
      event.preventDefault();
    });

    $(window).scroll(function() {
      if ($(this).scrollTop() > offset) {
        $('.scroll-to-top').fadeIn(duration);
      } else {
        $('.scroll-to-top').fadeOut(duration);
      }
    });

    $('.scroll-to-top').click(function(event) {
      event.preventDefault();
      $('html, body').animate({ scrollTop: 0 }, duration);
      return false;
    });

    // Build Calendar
    // const CALENDAR_ID = 'g2hval0pee3rmrv4f3n9hp9cok@group.calendar.google.com';
    // const API_KEY = 'AIzaSyA5W2MDJs9uknQv6Cn4OZ07K-wtvkoqYwE';
    // // see https://developers.google.com/google-apps/calendar/v3/reference/events/list#parameters
    // const extra_params = {
    //   timeMin: moment().format(),
    //   key: API_KEY
    // };
    // let cal_url = 'https://www.googleapis.com/calendar/v3/calendars/';
    // cal_url += CALENDAR_ID + '/events?';
    // cal_url += $.param(extra_params);
    //
    // // Using https://github.com/MilanKacurak/FormatGoogleCalendar
    // formatGoogleCalendar.init({
    //   calendarUrl: cal_url,
    //   past: false,
    //   upcoming: true,
    //   sameDayTimes: true,
    //   upcomingTopN: 2,
    //   itemsTagName: 'li',
    //   upcomingSelector: '#upcoming-events',
    //   upcomingHeading: '',
    //   format: [
    //     '<h5>',
    //     '*summary*',
    //     '</h5><p> ',
    //     '*date*',
    //     ': ',
    //     '*location*',
    //     ' </p> '
    //   ]});
      // RSS
      // TODO: check if clir.org "blogs" have RSS; if so, go to mix.chimpfeedr.com
      // $('#news').FeedEk
      //   FeedUrl: 'https://www.diglib.org/feed/'
      //   MaxCount: 5
      //   ShowDesc: true
      //   ShowPubDate: true
      //   DescCharacterLimit: 100
      //   TitleLinkTarget: '_blank'

      /* Simple spam protection for email addresses using jQuery.
      * Well, the protection isn’t jQuery-based, but you get the idea.
      * This snippet allows you to slightly ‘obfuscate’ email addresses to make it harder for spambots to harvest them, while still offering a readable address to your visitors.
      * E.g.
      * <a href="mailto:foo(at)example(dot)com">foo at example dot com</a>
      * →
      * <a href="mailto:foo@example.com">foo@example.com</a>
      */

      $('a[href^="mailto:"]').each(function() {
        this.href = this.href.replace('(at)', '@').replace(/\(dot\)/g, '.');
        this.innerHTML = this.href.replace('mailto:', '');
      });
    });
})();
