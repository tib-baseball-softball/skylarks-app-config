document.addEventListener("DOMContentLoaded", () => {
  const triggerButton = document.getElementById("feature-flag-form-trigger");
  /** @type HTMLDialogElement|null */
  const formDialog = document.getElementById("feature-flag-form-dialog");
  const featureFlagForm = document.getElementById("feature-flag-form");

  if (triggerButton && formDialog && featureFlagForm) {
    console.info("form dialog initialized")
    
    triggerButton.addEventListener("click", () => {
      formDialog.showModal();
    });
    
    featureFlagForm.addEventListener("submit", (event) => {
      console.info(event)
    })
  }
});
