const app = Vue.createApp({
    data() {
        return {
            serverName: undefined,
            slots: 0,

            myId: 0,
            players: [],
            counter: {}
        }
    }
}).mount('#scoreboard')

$(function () {
    window.addEventListener('message', function (event) {
        const item = event.data

        if (item.action == 'openScoreboard') {
            app.players    = item.players
            app.counter    = item.counter
            app.myId       = item.myId
            app.serverName = item.serverName
            app.slots      = item.slots

            $('#scoreboard').show()
        } else if (item.action == 'closeScoreboard') {
            $('#scoreboard').hide()
        } else if (item.action == 'scrollUp') {
            let el = document.getElementById('player-list');
            el.scrollTo(0, el.scrollTop - 30);
        } else if (item.action == 'scrollDown') {
            let el = document.getElementById('player-list');
            el.scrollTo(0, el.scrollTop + 30);
        }
    })
})