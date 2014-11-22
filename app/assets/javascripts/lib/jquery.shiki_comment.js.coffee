(($) ->
  $.fn.extend
    shiki_comment: ->
      @each ->
        $root = $(@)
        return unless $root.hasClass('unprocessed')

        new ShikiComment($root)
) jQuery

# TODO: в кнструктор перенесён весь старый код
# надо отрефакторить. подумать над view бекбона.
# сделал бы сразу, но не уверен, что не будет тормозить
class @ShikiComment extends ShikiView
  initialize: ($root) ->
    @$body = @$('.body')

    if @$inner.hasClass('check_height')
      @_check_height()

    # выделение текста в комментарии
    @$body.on 'mouseup', =>
      text = $.getSelectionText()
      return unless text

      # скрываем все кнопки цитаты
      $('.item-quote').hide()

      @$root.data(selected_text: text)
      $quote = @$('.item-quote').css(display: 'inline-block')

      _.delay ->
        $(document).one 'click', ->
          unless $.getSelectionText().length
            $quote.hide()
          else
            _.delay ->
              $quote.hide() unless $.getSelectionText().length
            , 250

    # цитирование комментария
    @$('.item-quote').on 'click', =>
      ids = [@$root.prop('id'), @$root.data('user_id'), @$root.data('user_nickname')]
      selected_text = @$root.data('selected_text')
      quote = "[quote=#{ids.join ';'}]#{selected_text}[/quote]\n"

      @$root.trigger 'comment:reply', [quote, @_is_offtopic()]

    # ответ на комментарий
    @$('.item-reply').on 'ajax:success', (e, response) =>
      reply = "[#{response.kind}=#{response.id}]#{response.user}[/#{response.kind}], "
      @$root.trigger 'comment:reply', [reply, @_is_offtopic()]

    # edit message
    @$('.main-controls .item-edit').on 'ajax:success', (e, html, status, xhr) =>
      $editor = $(html)
      new ShikiEditor($editor).edit_comment(@$root)

    # moderation
    @$('.main-controls .item-moderation').on 'click', =>
      @$('.main-controls').hide()
      @$('.moderation-controls').show()

    # по нажатиям на кнопки закрываем меню в мобильной версии
    @$('.item-quote,.item-reply,.item-edit,.item-review,.item-offtopic').on 'click', =>
      @_close_aside()

    # пометка комментария обзором/оффтопиком
    @$('.item-review,.item-offtopic,.item-spoiler,.item-abuse,.b-offtopic_marker,.b-review_marker').on 'ajax:success', (e, data, satus, xhr) =>
      if 'affected_ids' of data && data.affected_ids.length
        data.affected_ids.each (id) ->
          $(".b-comment##{id}").data('object').mark(data.kind, data.value)
          $.notice marker_message(data)
      else
        $.notice 'Ваш запрос будет рассмотрен. Домо аригато.'

      @$('.item-moderation-cancel').trigger('click')

    # cancel moderation
    @$('.moderation-controls .item-moderation-cancel').on 'click', =>
      #@$('.main-controls').show()
      #@$('.moderation-controls').hide()
      @_close_aside()

    # кнопка бана или предупреждения
    @$('.item-ban').on 'ajax:success', (e, html) =>
      @$('.moderation-ban').html(html).show()
      @_close_aside()

    # закрытие формы бана
    @$('.moderation-ban').on 'click', '.form-cancel', =>
      @$('.moderation-ban').hide()

    # сабмит формы бана
    @$('.moderation-ban').on 'ajax:success', 'form', (e, response) =>
      @_replace response.html

    # замена комментария новым контентом
    @on 'comment:replace', (e, html) =>
      @_replace html

    # по клику на 'новое' пометка прочитанным
    @$('.b-new_marker').on 'click', =>
      # эвент appear обрабатывается в shiki-topic
      @$('.appear-marker').trigger 'appear', [@$('.appear-marker'), true]

    # realtime уведомление об изменении комментария
    @on 'faye:comment:updated', (e, data) =>
      @$('.was_updated').remove()
      $notice = $("<div class='was_updated'>
        <div><span>Комментарий изменён пользователем</span><a class='actor b-user16' href='/#{data.actor}'><img src='#{data.actor_avatar}' srcset='#{data.actor_avatar_2x} 2x' /><span>#{data.actor}</span></a>.</div>
        <div>Кликните для обновления.</div>
      </div>")
      $notice
        .appendTo(@$inner)
        .on 'click', (e) =>
          @_reload() unless $(e.target).closest('.actor').exists()

    # realtime уведомление об удалении комментария
    @on 'faye:comment:deleted', (e, data) =>
      @_replace "<div class='b-comment-info b-comment'><span>Комментарий удалён пользователем</span><a class='b-user16' href='/#{data.actor}'><img src='#{data.actor_avatar}' /><span>#{data.actor}</span></a></div>"

  # пометка комментария маркером (оффтопик/отзыв)
  mark: (kind, value) ->
    @$(".item-#{kind}").toggleClass('selected', value)
    @$(".b-#{kind}_marker").toggle(value)

  # оффтопиковый ли данный комментарий
  _is_offtopic: ->
    @$('.b-offtopic_marker').css('display') != 'none'

  # перезагрузка комментария
  _reload: =>
    @$root.addClass 'ajax:request'
    $.get "/comments/#{@$root.attr 'id'}", (response) =>
      @_replace response

  # замена комментария другим контентом
  _replace: (html) ->
    $replaced_comment = $(html)
    @$root.replaceWith($replaced_comment)

    $replaced_comment
      .process()
      .shiki_comment()
      .yellowFade()

# текст сообщения, отображаемый при изменении маркера
marker_message = (data) ->
  if data.value
    if data.kind == 'offtopic'
      if data.affected_ids.length > 1
        $.notice 'Комментарии помечены оффтопиком'
      else
        $.notice 'Комментарий помечен оффтопиком'
    else
      $.notice 'Комментарий помечен отзывом'
  else
    if data.kind == 'offtopic'
      $.notice 'Метка оффтопика снята'
    else
      $.notice 'Метка отзыва снята'
