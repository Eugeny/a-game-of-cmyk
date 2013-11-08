class Color
    constructor: (@c, @m, @y) ->

    copy: () ->
        return new Color(@c, @m, @y)

    add: (c) ->
        @c += c.c
        @m += c.m
        @y += c.y
        @c = Math.min(@c, 1)
        @m = Math.min(@m, 1)
        @y = Math.min(@y, 1)

    hex: () ->
        r = 1 - @c
        g = 1 - @m
        b = 1 - @y
        r = Math.round(r * 255)
        g = Math.round(g * 255)
        b = Math.round(b * 255)
        return "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1)

    sameAs: (b) ->
        return Math.abs(@c - b.c) + Math.abs(@m - b.m) + Math.abs(@y - b.y) < 0.01

    apply: (e) ->
        console.log @c, @m, @y
        console.log @hex()
        $(e).css 'background-color': @hex()


class Square
    constructor: (@dom) ->
        @active = false

    activate: () ->
        @active = true
        @dom.addClass('pulse')

    setColor: (c) ->
        @color = c.copy()
        @color.apply(@dom)


class Board
    constructor: (@dom) ->
        @width = 8
        @height = 8
        @dom.empty()

    generate: (currentColor, mixins) ->
        colors = [currentColor, new Color(0.5,0.5,0), new Color(0.5,1.0,0), new Color(1.0,1.0,1.0)]
        @squares = []

        for y in [0...@width]
            @squares.push []
            for x in [0...@height]
                square = new Square($("""
                    <div class="square">
                    </div>
                """))
                square.setColor(colors[Math.floor(Math.random() * colors.length)])
                @squares[y].push square
                @dom.append(square.dom)
            @dom.append("""<div class="newline"></div>""")

        initialX = Math.floor(Math.random() * @width)
        initialY = Math.floor(Math.random() * @height)
        @squares[initialY][initialX].setColor(currentColor)
        @squares[initialY][initialX].activate()
        @update(currentColor)

    update: (currentColor) ->
        while true
            needsAnotherRun = false
            for y in [0...@width]
                for x in [0...@height]
                    sq = @squares[y][x]
                    if sq.active
                        sq.setColor(currentColor)
                        for i in [0..3]
                            dx = [-1,0,1,0][i]
                            dy = [0,1,0,-1][i]
                            if x + dx in [0...@width] and y + dy in [0...@height]
                                sq2 = @squares[y+dy][x+dx]
                                if not sq2.active
                                    if sq2.color.sameAs(currentColor)
                                        console.log sq2.color.hex(), '=', currentColor.hex()
                                        needsAnotherRun = true
                                        #sq2.setColor(currentColor)
                                        sq2.activate()
            if not needsAnotherRun
                break
        

class Game
    constructor: () ->
        @board = new Board($('#board'))

    start: () ->
        @currentColor = new Color(0,0,0)

        mixins = [new Color(0.5,0,0), new Color(0,0.5,0), new Color(0,0,0.5)]

        mixinBox = $('#mixins')
        mixinBox.empty()
        for mixin in mixins
            button = $("""
                <a class="mixin">+</a>
            """)
            mixin.apply(button)
            mixinBox.append(button)

            ((mixin) =>
                button.click () =>
                    @currentColor.add(mixin)
                    @updateCurrentColor()
            )(mixin)


        button = $("""
            <a class="mixin">R</a>
        """)
        new Color(0,0,0).apply(button)
        mixinBox.append(button)
        button.click () =>
            @currentColor.c = 0
            @currentColor.m = 0
            @currentColor.y = 0
            @updateCurrentColor()

        @board.generate(@currentColor, mixins)
        @updateCurrentColor()


    updateCurrentColor: () ->
        @currentColor.apply($('#current-color'))
        @board.update(@currentColor)


$ () ->
    g = new Game()
    g.start()