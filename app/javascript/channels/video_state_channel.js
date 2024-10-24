import consumer from "./consumer"

consumer.subscriptions.create("VideoStateChannel", {
  connected() {
    console.log("Conectado al canal");
  },

  disconnected() {
    console.log("Desconectado del canal");
  },

  received(data) {
    const elem = document.getElementById(`icon-state-${data.id}`);
    const container = document.getElementById(`container-state-${data.id}`);
    if (elem) {
      switch (data.state) {
        case "unprocessable":
          container.className = 'bg-red-100 text-red-800 text-xs font-medium border border-red-300 me-2 px-2.5 py-0.5 rounded dark:bg-red-900 dark:text-red-300 inline-flex items-center';
          break;
        case "failed":
          container.className = 'bg-red-100 text-red-800 text-xs font-medium border border-red-300 me-2 px-2.5 py-0.5 rounded dark:bg-red-900 dark:text-red-300 inline-flex items-center';
          break;
        case "processed":
          container.className = 'bg-green-100 text-green-800 text-xs font-medium border border-green-300 me-2 px-2.5 py-0.5 rounded dark:bg-green-900 dark:text-green-300 inline-flex items-center';
          break;
        default:
          container.className = 'bg-gray-100 text-gray-800 text-xs font-medium border border-gray-300 me-2 px-2.5 py-0.5 rounded dark:bg-blue-900 dark:text-blue-300 inline-flex items-center';
          break
      }
      if (["created", "unprocessable", "processed", "failed"].includes(data.state)){
        elem.classList.add('hidden');
      } else {
        elem.classList.remove('hidden');
      }
    }
    const elemText = document.getElementById(`text-state-${data.id}`);
    elemText.innerText = data.state.charAt(0).toUpperCase() + data.state.slice(1).toLowerCase();
  }
});
