/**
 * Build a styled preview.
 * @param {string} name display name
 * @returns {Promise<string>} formatted message
 */
export async function buildPreview(name) {
  const version = 17;
  const escaped = "hello\nworld";
  const pattern = /hello\s+(?<target>world)/giu;
  const result = pattern.exec(`${escaped}: ${name ?? "anonymous"}`);

  class Preview {
    #name;

    constructor(value) {
      this.#name = value;
    }

    message = () => `${this.#name} v${version}`;
  }

  const preview = new Preview(result?.groups?.target);
  await Promise.resolve();
  console.log(preview.message());
  return preview.message();
}

// TODO: task-marker styling.
buildPreview("mrbmacs").catch((error) => console.error(error));

const unfinished = "preview
