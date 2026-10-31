// Firefox exposes `browser`; Chrome exposes `chrome`. Both return promises in MV3.
const api = globalThis.browser ?? globalThis.chrome;

async function focusNextAudibleTab() {
  const audibleTabs = await api.tabs.query({ audible: true });
  if (audibleTabs.length === 0) return;

  audibleTabs.sort((a, b) => a.windowId - b.windowId || a.index - b.index);

  const [currentTab] = await api.tabs.query({ active: true, lastFocusedWindow: true });
  const currentPosition = audibleTabs.findIndex((tab) => tab.id === currentTab?.id);
  const nextTab = audibleTabs[(currentPosition + 1) % audibleTabs.length];

  await api.tabs.update(nextTab.id, { active: true });
  await api.windows.update(nextTab.windowId, { focused: true });
}

api.commands.onCommand.addListener((command) => {
  if (command === "focus-next-audible-tab") focusNextAudibleTab();
});
