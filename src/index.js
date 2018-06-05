import { Main } from './Main.elm';

const storedSession = localStorage.getItem('session');
const app = Main.fullscreen(JSON.parse(storedSession) || null);

app.ports.storeSession.subscribe(function(session) {
  localStorage.setItem('session', JSON.stringify(session));
  app.ports.onSessionChange.send(session);
});

window.addEventListener("storage", function(event) {
  if (event.storageArea === localStorage && event.key === "session") {
    app.ports.onSessionChange.send(JSON.parse(event.newValue));
  }
}, false);
