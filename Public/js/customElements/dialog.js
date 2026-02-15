class FormDialog extends HTMLElement {
  constructor() {
    super();
  }

  connectedCallback() {
    /** @type HTMLTemplateElement|null */
    let template = document.getElementById("dialog-template");
    let templateContent = template?.content;

    if (templateContent instanceof DocumentFragment) {
      const shadowRoot = this.attachShadow({ mode: "open" });
      shadowRoot.appendChild(document.importNode(templateContent, true));

      const style = document.createElement("style");
      style.textContent = `
        dialog {
            max-width: 95%;
            margin: auto;
            border: 1px solid var(--color-border);
            border-radius: var(--border-radius-lg);
        }

        @media (min-width: 1024px) {
            dialog {
                max-width: 700px;
            }
        }

        dialog::backdrop {
            background: rgba(0, 0, 0, 0.6);
            backdrop-filter: blur(4px);
            animation: fade-in 0.2s ease-out;
        }

        @media (prefers-reduced-motion: "no-preference") {
            dialog[open] {
                animation: scale-in 0.2s ease-out;
            }
        }

        @keyframes fade-in {
            from {
                opacity: 0;
            }
            to {
                opacity: 1;
            }
        }

        .btn {
         	--button-color: var(--color-primary-invert);
         	vertical-align: middle;
         	min-height: 3.1rem;
         	min-width: 6.5rem;
         	display: inline-block;
         	padding: calc(var(--spacing-base) * .75) var(--spacing-base);
         	margin: .125rem .125rem .125rem 0;
         	background: var(--button-color);
         	color: contrast-color(var(--button-color));
         	border: none;
         	border-radius: var(--border-radius-md);
         	cursor: pointer;
         	font-weight: var(--font-weight-medium);
         	text-align: center;
         	transition: var(--transition-base);
         	position: relative;
         	overflow: hidden;
                  }

        .btn.primary {
         	--button-color: var(--color-primary);
         	color: var(--color-on-primary);
        }
        `;

      shadowRoot.appendChild(style);

      const dialog = shadowRoot.getElementById("form-dialog");
      const trigger = shadowRoot.getElementById("dialog-trigger");
      const closeButton = shadowRoot.getElementById("dialog-close-button");

      if (
        dialog instanceof HTMLDialogElement &&
        trigger instanceof HTMLButtonElement &&
        closeButton instanceof HTMLButtonElement
      ) {
        trigger.addEventListener("click", () => {
          dialog.showModal();
        });

        closeButton.addEventListener("click", () => {
          dialog.close();
        });
      }
    }
  }
}

customElements.define("form-dialog", FormDialog);
