abstract final class RemoveFooterRightUiScript {
  static const source = r'''
    (() => {
      const selector = '.layer-ui__wrapper__footer-right';
      const removeElements = () => {
        document.querySelectorAll(selector).forEach((element) => element.remove());
      };

      removeElements();

      if (!window.__excalidrawxFooterRightUiObserver) {
        window.__excalidrawxFooterRightUiObserver =
            new MutationObserver(removeElements);
        window.__excalidrawxFooterRightUiObserver.observe(document.body, {
          childList: true,
          subtree: true,
        });
      }
    })();
  ''';
}
