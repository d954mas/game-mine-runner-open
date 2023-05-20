var LibHtmlUtils = {


    HtmlHtmlUtilsHideBg: function () {
        let canvas_bg =  document.getElementById("canvas-bg");
        canvas_bg.style.display = "none";
        canvas_bg.style.background = "";
        canvas_bg.remove()
    },

    HtmlHtmlUtilsCanvasHaveFocus: function () {
        console.log(document.activeElement.id)
        return document.activeElement.id === 'canvas'
    },
    HtmlHtmlUtilsCanvasFocus: function () {
        document.getElementById("canvas").focus()
    },

}

mergeInto(LibraryManager.library, LibHtmlUtils);