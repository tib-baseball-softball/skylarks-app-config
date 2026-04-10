/**
 * @typedef {Object} FeatureFlag
 * @property {string?} id
 * @property {string} key
 * @property {string?} description
 */

document.addEventListener("DOMContentLoaded", async () => {
  const configID = document.getElementById("config-main-container")?.dataset
    .config;
  /** @type {HTMLTemplateElement|null} */
  const rowTemplate = document.getElementById("flag-item-template");
  const configFlagsContainer = document.getElementById(
    "config-flags-container",
  );

  if (!configID || !rowTemplate || !configFlagsContainer) {
    return;
  }

  const params = new URLSearchParams({
    excludedConfigID: configID,
  });
  const url = `/api/flags?${params.toString()}`;
  const response = await fetch(url);
  if (!response.ok) {
    console.error("error loading unassigned feature flags");
    return;
  }

  /** @type {FeatureFlag[]} */
  const flags = await response.json();
  flags.forEach((flag) => {
    const newRow = document.importNode(rowTemplate.content, true);
    if (!newRow) {
      return;
    }

    const elements = newRow.querySelectorAll("[data-replace]");
    elements[0].textContent = flag.key;
    elements[1].textContent = flag.description;
    elements[2].value = flag.id;
    elements[3].value = configID;

    configFlagsContainer.appendChild(newRow);
  });
});
