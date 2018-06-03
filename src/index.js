import { Main } from './Main.elm';

const storedSession = localStorage.getItem('session');

Main.fullscreen(JSON.parse(storedSession) || null);
