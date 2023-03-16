// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"
import infiniteScroll from "./infiniteScroll"
let documentScroll = () => {
    let scrollTop = document.documentElement.scrollTop || document.body.scrollTop
    let scrollHeight = document.documentElement.scrollHeight || document.body.scrollHeight
    let clientHeight = document.documentElement.clientHeight

    return scrollTop / (scrollHeight - clientHeight) * 100
}

messagesEl = () => document.querySelector("#chat-messages")
commentsEl = () => document.querySelector("#post-comments")
let elementScroll = (el) => {
    return () => {
        item = el()
        let scrollTop = item.scrollTop
        let scrollHeight = item.scrollHeight
        let clientHeight = item.clientHeight

        return scrollTop / (scrollHeight - clientHeight) * 100
    }
}
commentsInfiniteScroll = infiniteScroll(elementScroll(commentsEl), commentsEl)
messagesInfiniteScroll = infiniteScroll(elementScroll(messagesEl), messagesEl)
let Hooks = {
    InfiniteScroll: infiniteScroll(documentScroll, () => window), CommentsInfiniteScroll: commentsInfiniteScroll, MessagesInfiniteScroll: messagesInfiniteScroll
}
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
    params: { _csrf_token: csrfToken },
    hooks: Hooks
})



// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())
window.addEventListener("phx:clear-input", (e) => {
    let el = document.getElementById(e.detail.id)
    if (el) {
        el.value = ""
    }
})
// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

