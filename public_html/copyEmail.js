function copyToClipboard(text) {
  navigator.clipboard.writeText(text).then(() => {
  console.log(`Copied text to clipboard: ${text}`);
  alert(`Email copied to clipboard :)`);
  }).catch((error) => {
  console.error(`Could not copy text: ${error}`);
  });
  }