import consumer from "./consumer"

consumer.subscriptions.create("ChannelStateChannel", {
  connected() {
    console.log('channel channel')
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    const elem = document.getElementById(`channel-icon-state-${data.id}`);
    const container = document.getElementById(`channel-container-state-${data.id}`);
    if (elem) {
      switch (data.state) {
        case "processed":
          container.className = 'bg-green-100 text-green-800 text-xs font-medium border border-green-300 me-2 px-2.5 py-0.5 rounded dark:bg-green-900 dark:text-green-300 inline-flex items-center';
          break;
        default:
          container.className = 'bg-gray-100 text-gray-800 text-xs font-medium border border-gray-300 me-2 px-2.5 py-0.5 rounded dark:bg-blue-900 dark:text-blue-300 inline-flex items-center';
          break
      }
      if (["unchecked", "processed"].includes(data.state)){
        elem.classList.add('hidden');
      } else {
        elem.classList.remove('hidden');
      }
    }
    const elemText = document.getElementById(`channel-text-state-${data.id}`);
    var text = data.state.charAt(0).toUpperCase() + data.state.slice(1).toLowerCase();
    if (data.remaining_jobs > 0 && data.state == "processing"){
      text += ` (${data.remaining_jobs})`
    }
    elemText.innerText = text;
  }
});
