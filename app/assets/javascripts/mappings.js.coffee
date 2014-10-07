jQuery ->
  $('.target-fields').on 'click', '.kill', (e) -> revertField(e, this)

  $('#source-fields').delegate '.field:not(.ui-draggable)', 'mouseenter', ->
    $(this).draggable revert: 'invalid'

  $('.target-fields').delegate '.field:not(.ui-droppable)', 'mouseenter', ->
    $(this).droppable
      accept: "#source-fields li",
      hoverClass: "over",
      drop: (event, ui) -> dropField($(this), ui)

  dropField = (el, ui) ->
    addFields el, ui
    addEnumFields(el) if $('.target', el).attr('data-enum') != undefined
    addDateFields(el) if $('.target', el).attr('data-format') == 'date'
    addPriceField(el) if ['price_single', 'cost'].indexOf($('.target', el).attr('data-name')) != -1

  addFields = (el, ui) ->
    $('.target', el).after "<div class='source' " +
      "data-name='" + ui.draggable.data('name') + "' data-source='" + ui.draggable.data('source') + "'>" +
      "<div>" + ui.draggable.text() + "</div>" +
      "<div class='map_actions'><div class='kill'> x </div></div>" +
      "</div>"
    ui.draggable.hide()
    if $('.source', el).length > 1 && $("input[name='conversion_type']", el).length == 0
      el.append "<input name='conversion_type' type='hidden' value='join'>"
    el.addClass 'dropped'

  addPriceField = (el) ->
    if $('input[name="conversion_type"]', el).length == 0
      el.append "<input name='conversion_type' type='hidden' value='price'>"

  addEnumFields = (el) ->
    els = ["<div class='options'>"]

    $.each $('.target', el).attr('data-enum').split(','), ->
      #clean "[] from strings, comming from ary markup
      name = this.replace( /["\[\]]/g, '')
      els.push "<div> <input class='mini' name='" + name + "' type='text'> <label>=> " + name + "</label></div>"
    els.push "<input name='conversion_type' type='hidden' value='enum'>"
    els.push "</div>"
    el.append els.join('')

  addDateFields = (el) ->
    els = ["<div class='options'>"]
    els.push "<div> <input class='mini' name='date' type='text'> <label>=> Target format YYYY.MM.DD</label></div>"
    els.push "<div class='help-block'>Use Placeholders %Y %m %d describing the incoming date format.</div>"
    els.push "</div>"
    els.push "<input name='conversion_type' type='hidden' value='date'>"
    el.append els.join('')

  revertField = (event, el) ->
    field = $($(el).parents('.source')[0])
    parent = $($(field).parents('.field')[0])
    srcElement = $("#source-fields li[data-source=" + field.data('source') + "]")
    field.remove()
    $('.options', parent).remove()
    if $('.source', parent).length == 0
      parent.removeClass 'dropped'
      $("input[name='conversion_type']", el).remove()
    srcElement.show().css left: '', top: ''

  $('.target-fields .field').trigger 'mouseenter'

  $(':submit').click (e) ->
    mappings = []
    $.each $('.target-fields .field.dropped'), (i) ->
      el = $(this)
      sourceIDs = [];
      $.each $('.source', el), -> sourceIDs.push $(this).attr('data-source')
      mappings.push "<input type='hidden' name='mapping[mapping_elements_attributes][" + i + "][source]' value='" + sourceIDs.join(',') + "'>"
      mappings.push "<input type='hidden' name='mapping[mapping_elements_attributes][" + i + "][target]' value='" + $('.target', el).attr('data-target') + "'>"
      mappings.push "<input type='hidden' name='mapping[mapping_elements_attributes][" + i + "][model_to_import]' value='" + $('.target', el).attr('data-model-to-import') + "'>"
      if $("input[name='conversion_type']", el).length > 0
        mappings.push "<input type='hidden' name='mapping[mapping_elements_attributes][" + i + "][conversion_type]' value='" + $("input[name='conversion_type']", el).val() + "'>"
      if $('.options', el).length > 0
        opts = {};
        $.each $('.options :text', el), -> opts[$(this).attr('name')] = $(this).val()
        mappings.push "<input type='hidden' name='mapping[mapping_elements_attributes][" + i + "][conversion_options]' value='" + JSON.stringify(opts) + "'>"
    $('form').append mappings.join('')

  $('input[name="mapping[import_type]"]').click ->
    $doc_id = $("#mapping_document_id")
    if $(this).val() == 'line_item'
      $doc_id.select2('enable', true)
    else
      removeSelectValue($doc_id)
      $doc_id.select2('enable', false)

  $('input[name="mapping[document_type]"]').change ->
    removeSelectValue("#mapping_document_id")

  $("#mapping_document_id").select2
    placeholder: window.gon.document_id_placeholder
    minimumInputLength: 1
    allowClear: true
    quietMillis: 100
    width: 350
    ajax:
      url: "/documents.json"
      dataType: "json"
      data: (term, page) ->
        q: term
        type: $('input[name="mapping[document_type]"]:checked').val()
        per_page: 10
        page: page

      results: (data, page) ->
        results: data.results
        more: (page < data.total_pages)

    formatResult: (doc) ->
      doc.name + '<br/>' + doc.address
    formatSelection: (doc) ->
      doc.name
    escapeMarkup: (m) ->
      m

removeSelectValue = (el) ->
  $(el).val('')
  $(el).select2('val', '')
