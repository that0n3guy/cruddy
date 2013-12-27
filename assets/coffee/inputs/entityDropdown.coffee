class EntityDropdown extends BaseInput
    className: "entity-dropdown"

    events:
        "click .btn-remove": "removeItem"
        "show.bs.dropdown": "renderDropdown"

    mutiple: false
    reference: null

    initialize: (options) ->
        @multiple = options.multiple if options.multiple?
        @reference = options.reference if options.reference?
        @active = false

        super

    removeItem: (e) ->
        if @multiple
            i = $(e.currentTarget).data "key"
            value = _.clone @model.get(@key)
            value.splice i, 1
        else
            value = null

        @model.set @key, value

        this

    renderDropdown: ->
        return if @selector?

        @selector = new EntitySelector
            model: @model
            key: @key
            multiple: @multiple
            reference: @reference

        @dropdown = $ "<div></div>", class: "selector-wrap"

        @$el.append @dropdown.append @selector.render().el

        this


    applyChanges: (model, value) ->
        if @multiple
            @renderItems()
        else
            @updateItem()
            @$el.removeClass "open"

        this

    render: ->
        @dispose()

        if @multiple then @renderMultiple() else @renderSingle()

        @$el.attr "id", @cid

        this

    renderMultiple: ->
        @$el.append @items = $ "<div>", class: "items"

        @$el.append """
            <button type="button" class="btn btn-default btn-sm btn-block dropdown-toggle" data-toggle="dropdown" data-target="##{ @cid }">
                Выбрать
                <span class="caret"></span>
            </button>
            """

        @renderItems()

    renderItems: ->
        html = ""
        html += @itemTemplate value.title, key for value, key in @model.get @key
        @items.html html
        @items.toggleClass "has-items", html isnt ""

        this

    renderSingle: ->

        @$el.html @itemTemplate "", ""

        @itemTitle = @$ ".form-control"
        @itemDelete = @$ ".btn-remove"

        @updateItem()

    updateItem: ->
        value = @model.get @key
        @itemTitle.text if value then value.title else "Не выбрано"
        @itemDelete.toggle !!value

        this

    itemTemplate: (value, key = null) ->
        html = """
        <div class="input-group input-group-sm item">
            <p class="form-control">#{ _.escape value }</p>
            <div class="input-group-btn">
        """

        if not @multiple or key isnt null
            html += """
                <button type="button" class="btn btn-default btn-remove" data-key="#{ key }">
                    <span class="glyphicon glyphicon-remove"></span>
                </button>
                """

        if not @multiple or key is null
            html += """
                <button type="button" class="btn btn-default btn-dropdown dropdown-toggle" data-toggle="dropdown" data-target="##{ @cid }">
                    <span class="caret"></span>
                </button>
                """

        html += "</div></div>"

    dispose: ->
        @selector.stopListening() if @selector
        @selector = null

        this

    stopListening: ->
        @dispose()

        super