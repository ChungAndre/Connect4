import confetti from "canvas-confetti"

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

window.liveSocket = liveSocket

window.addEventListener("phx:gameover", (e) => {
    shootConfetti();
  });

const shootConfetti = () => {
    const colors = ["#E9826C", "#65CB61", "#6191CB"];
  
    confetti({
      particleCount: 300,
      angle: 70,
      spread: 80,
      startVelocity: 45,
      gravity: 0.5,
      origin: { x: 0, y: 0.4 },
      colors
    });
  
    confetti({
      particleCount: 300,
      angle: 130,
      spread: 80,
      startVelocity: 45,
      gravity: 0.5,
      origin: { x: 1, y: 0.4 },
      colors
    });
  };
