#= require pages/p-moderation
#= require pages/p-users-index
#= require pages/p-animes
#= require pages/p-animes_collection-index
#= require pages/p-recommendations-index

#= require pages/p-seyu
#= require pages/p-people
#= require pages/p-characters
#= require pages/p-contests
#= require pages/p-clubs
#= require pages/p-dialogs
#= require pages/p-messages
#= require pages/p-userlist_comparer
#= require pages/p-translations
#= require_directory ./pages/p-reviews
#= require_directory ./pages/p-profiles
#= require_directory ./pages/p-user_rates
#= require_directory ./pages/p-topics

# require anime_online/application
# require manga_online/application

$ =>
  $body = $(document.body)
  @ENV = $body.data 'env'
  @USER_SIGNED_IN = $body.data 'user-signed-in'
  @DAY_REGISTERED = $body.data 'day-registered'
  @IGNORE_COPYRIGHT = $body.data 'ignore-copyright'

  @OPTIONS =
    comments_auto_collapsed: $body.data('comments-auto-collapsed')
    comments_auto_loaded: $body.data('comments-auto-loaded')

  $(document).trigger 'page:load', true

  if USER_SIGNED_IN && !window.faye_loader
    @faye_loader = new FayeLoader()
    @comments_notifier = new CommentsNotifier()

  $('.appear-marker').appear()

  $.form_navigate
    size: 250
    message: "Вы написали и не сохранили какой-то комментарий! Уверены, что хотите покинуть страницу?"

  if match = location.hash.match(/^#(comment-\d+)$/)
    $("a[name=#{match[1]}]").closest('.b-comment').yellowFade()

$(document).on 'page:restore', (e, is_dom_content_loaded) ->
  $(document.body).process()

$(document).on 'page:load', (e, is_dom_content_loaded) ->
  Turbolinks.enableProgressBar false
  Turbolinks.enableProgressBar true, '.turbolinks'

  #unless is_dom_content_loaded
    #turbolinks_compatibility()

  # отображение flash сообщений от рельс
  $('p.flash-notice').each (k, v) ->
    $.flash notice: v.innerHTML if v.innerHTML.length

  $('p.flash-alert').each (k, v) ->
    $.flash alert: v.innerHTML if v.innerHTML.length

  #$(document.body).addClass 'l-mobile' if is_mobile()
  $(document.body).process()

  $('#sign_in').on 'click', ->
    Turbolinks.visit $(@).data('href')


#$(document).on 'page:fetch', ->
  #$('.l-page').css opacity: 0.3

#$(document).on 'page:restore', ->
  #turbolinks_compatibility()
  #$('.l-page').css opacity: 1

# для совместимости с турболинками
#turbolinks_compatibility = ->
  #$('#fancybox-wrap').remove()
  #$.fancybox.init()

# поиск селектора одновременно с добавлением root, если root удовлетворяет селектору
$with = (selector, $root) ->
  if $root.is(selector)
    $root.find(selector).add($root)
  else
    $root.find(selector)

# обработка элементов страницы (инициализация галерей, шрифтов, ссылок)
@process_current_dom = (root = document.body) ->
  $root = $(root)

  # то, что должно превратиться в ссылки
  $with('.linkeable', $root)
    .change_tag('a')
    .removeClass('linkeable')

  # стена картинок
  $with('.b-shiki_wall.unprocessed', $root).shiki_wall()
  $with('.b-forum.unprocessed', $root).shiki_forum()
  $with('.b-topic.unprocessed', $root).shiki_topic()
  $with('.b-comment.unprocessed', $root).shiki_comment()

  # блоки, загружаемые аяксом
  $with('.postloaded[data-href]', $root).each ->
    $this = $(@)
    return unless $this.is(':visible')
    $this.load $this.data('href'), ->
      $this
        .removeClass('postloaded')
        .process()
        .trigger('postloaded:success')

    $this.attr 'data-href', null

  # подгружаемые тултипы
  $with('.anime-tooltip', $root)
    .tooltip(ANIME_TOOLTIP_OPTIONS)
    .removeClass('anime-tooltip')
  $with('.bubbled', $root)
    .addClass('bubbled-processed')
    .removeClass('bubbled')
    .tooltip($.extend(offset: [-35, 10, -10], tooltip_options))

  $with('.b-spoiler.unprocessed', $root).spoiler()

  $with('.b-video.unprocessed', $root).shiki_video()
  $with('img.check-width', $root)
    .removeClass('check-width')
    .normalize_image(append_marker: true)
  $with('.b-image.unprocessed', $root)
    .removeClass('unprocessed')
    .magnific_rel_gallery()

  # сворачиваение всех нужных блоков "свернуть"
  _.each ($.cookie('collapses') || '').replace(/;$/, '').split(';'), (v, k) ->
    $with("#collapse-#{v}", $root).trigger 'click', true
