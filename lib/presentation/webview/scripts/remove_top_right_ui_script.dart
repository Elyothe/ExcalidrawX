abstract final class RemoveTopRightUiScript {
  static const source = r'''
    (() => {
      const selector = '.layer-ui__wrapper__top-right';
      const removeElements = () => {
        document.querySelectorAll(selector).forEach((element) => element.remove());
      };

      removeElements();

      if (!window.__excalidrawxTopRightUiObserver) {
        window.__excalidrawxTopRightUiObserver = new MutationObserver(removeElements);
        window.__excalidrawxTopRightUiObserver.observe(document.body, {
          childList: true,
          subtree: true,
        });
      }
    })();
  ''';
}
