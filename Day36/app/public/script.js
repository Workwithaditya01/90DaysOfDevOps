// Typing effect for the terminal headline
const TYPED_LINE = "docker compose up --build";
const typedEl = document.getElementById("typedText");

function typeLine(text, el, speed = 45) {
  let i = 0;
  (function step() {
    if (i <= text.length) {
      el.textContent = text.slice(0, i);
      i++;
      setTimeout(step, speed);
    }
  })();
}
typeLine(TYPED_LINE, typedEl);

// Live clock
const clockEl = document.getElementById("clock");
function tickClock() {
  clockEl.textContent = new Date().toLocaleTimeString("en-GB", { hour12: false });
}
tickClock();
setInterval(tickClock, 1000);

// Live service status, polled from /api/status
async function pollStatus() {
  try {
    const res = await fetch("/api/status");
    const data = await res.json();

    setStatus("app", true, data.uptimeSeconds);
    setStatus("mongo", data.mongoConnected, null);
  } catch (err) {
    setStatus("app", false, null);
    setStatus("mongo", false, null);
  }
}

function setStatus(name, isUp, uptimeSeconds) {
  const dot = document.getElementById(`dot-${name}`);
  const state = document.getElementById(`state-${name}`);
  dot.classList.remove("up", "down");
  dot.classList.add(isUp ? "up" : "down");
  state.textContent = isUp ? "running" : "unreachable";
  state.style.color = isUp ? "var(--green)" : "var(--red)";

  if (name === "app") {
    const uptimeEl = document.getElementById("uptime-app");
    if (uptimeEl && typeof uptimeSeconds === "number") {
      uptimeEl.textContent = formatUptime(uptimeSeconds);
    }
  }
}

function formatUptime(seconds) {
  const m = Math.floor(seconds / 60);
  const s = Math.floor(seconds % 60);
  return m > 0 ? `${m}m ${s}s` : `${s}s`;
}

pollStatus();
setInterval(pollStatus, 5000);
