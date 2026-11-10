abstract final class RemoveMainMenuScript {
  static const source = r'''
    (() => {
      const selector = 'button[data-testid="main-menu-trigger"]';
      const removeElements = () => {
        document.querySelectorAll(selector).forEach((element) => element.remove());
      };

      removeElements();

      if (!window.__excalidrawxMainMenuObserver) {
        window.__excalidrawxMainMenuObserver = new MutationObserver(removeElements);
        window.__excalidrawxMainMenuObserver.observe(document.body, {
          childList: true,
          subtree: true,
        });
      }
    })();
  ''';
}
