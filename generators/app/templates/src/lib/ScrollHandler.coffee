class ScrollHandler
    constructor: ->
        console.log('initiliazed a ScrollHandler!')
        for hType in ['h1', 'h2', 'h3', 'h4', 'h5', 'h6']
            for h in $(hType)
                console.log(hType, $(h).attr('id'), $(h).offset().top)

        $('window').scroll(console.log('scrolling!'))


        # Get handling
        @handle()

    handle: ->
        @currentScroll = $('body').scrollTop()
        console.log(@currentScroll)

module.exports = ScrollHandler
